//
// MDLMendeleyAPIClient.m
//
// Copyright (c) 2012-2014 shazino (shazino SAS), http://www.shazino.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MDLMendeleyAPIClient.h"

#import <AFNetworking.h>

#import <CommonCrypto/CommonDigest.h>

static NSString * const MDLMendeleyAPIBaseURLString        = @"https://api-oauth2.mendeley.com/";
NSString * const MDLNotificationDidAcquireAccessToken      = @"MDLNotificationDidAcquireAccessToken";
NSString * const MDLNotificationFailedToAcquireAccessToken = @"MDLNotificationFailedToAcquireAccessToken";
NSString * const MDLNotificationRateLimitExceeded          = @"MDLNotificationRateLimitExceeded";

@interface MDLMendeleyAPIClient ()

@property (nonatomic, strong) id applicationLaunchObserver;
@property (nonatomic, copy)   NSString *redirectURI;

+ (MDLMendeleyAPIClient *)sharedClientReset:(BOOL)reset
                               withClientID:(NSString *)clientID
                                     secret:(NSString *)secret
                                redirectURI:(NSString *)redirectURI;

+ (NSString *)SHA1ForFileAtURL:(NSURL *)fileURL;
+ (id)deserializeAndSanitizeJSONObjectWithData:(NSData *)JSONData;
+ (id)sanitizeObject:(id)object;
- (void)updateRateLimitRemainingWithOperation:(AFHTTPRequestOperation *)operation;

@end


@implementation MDLMendeleyAPIClient

+ (MDLMendeleyAPIClient *)sharedClientReset:(BOOL)reset
                               withClientID:(NSString *)clientID
                                     secret:(NSString *)secret
                                redirectURI:(NSString *)redirectURI
{
    static MDLMendeleyAPIClient *_sharedClient = nil;
    @synchronized(self) {
        if (reset) {
            if (_sharedClient.applicationLaunchObserver) {
                [[NSNotificationCenter defaultCenter] removeObserver:_sharedClient.applicationLaunchObserver];
            }
            _sharedClient = nil;
        }

        if (!_sharedClient && clientID && secret && redirectURI) {
            _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:MDLMendeleyAPIBaseURLString]
                                                 clientID:clientID
                                                   secret:secret];
            _sharedClient.redirectURI = redirectURI;
        }
    }
    
    return _sharedClient;
}

+ (void)configureSharedClientWithClientID:(NSString *)clientID
                                   secret:(NSString *)secret
                              redirectURI:(NSString *)redirectURI
{
    [self sharedClientReset:YES
               withClientID:clientID
                     secret:secret
                redirectURI:redirectURI];
}

+ (MDLMendeleyAPIClient *)sharedClient
{
    return [self sharedClientReset:NO
                      withClientID:nil
                            secret:nil
                       redirectURI:nil];
}

+ (void)resetSharedClient
{
    [self sharedClientReset:YES
               withClientID:nil
                     secret:nil
                redirectURI:nil];
}

- (id)initWithBaseURL:(NSURL *)url
             clientID:(NSString *)clientID
               secret:(NSString *)secret
{
    self = [super initWithBaseURL:url
                         clientID:clientID
                           secret:secret];

    if (!self) {
        return nil;
    }

    self.automaticAuthenticationEnabled     = YES;
    self.rateLimitRemainingForLatestRequest = NSNotFound;
    [self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

+ (id)deserializeAndSanitizeJSONObjectWithData:(NSData *)JSONData
{
    id object;
    if ([JSONData isKindOfClass:[NSData class]]) {
        object = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:nil];
    }
    else {
        object = JSONData;
    }

    return [self sanitizeObject:object];
}

+ (id)sanitizeObject:(id)object
{
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *sanitizedArray = [NSMutableArray arrayWithArray:object];
        [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id sanitized = [self sanitizeObject:obj];
            if (!sanitized) {
                [sanitizedArray removeObjectIdenticalTo:obj];
            }
            else {
                [sanitizedArray replaceObjectAtIndex:[sanitizedArray indexOfObject:obj] withObject:sanitized];
            }
        }];

        return [NSArray arrayWithArray:sanitizedArray];
    }
    else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionaryWithDictionary:object];
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id sanitized = [self sanitizeObject:obj];
            if (!sanitized) {
                [sanitizedDictionary removeObjectForKey:key];
            }
            else {
                [sanitizedDictionary setObject:sanitized forKey:key];
            }
        }];

        return [NSDictionary dictionaryWithDictionary:sanitizedDictionary];
    }
    else {
        return object;
    }
}

- (void)updateRateLimitRemainingWithOperation:(AFHTTPRequestOperation *)operation
{
    NSString *rateLimitRemaining = operation.response.allHeaderFields[@"x-ratelimit-remaining"];

    if (!rateLimitRemaining || ![[NSScanner scannerWithString:rateLimitRemaining] scanInteger:&_rateLimitRemainingForLatestRequest]) {
        self.rateLimitRemainingForLatestRequest = NSNotFound;
    }

    if (self.rateLimitRemainingForLatestRequest == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MDLNotificationRateLimitExceeded
                                                            object:operation];
    }
}

#pragma mark - Operation

- (AFHTTPRequestOperation *)getPath:(NSString *)path
             requiresAuthentication:(BOOL)requiresAuthentication
                         parameters:(NSDictionary *)parameters
                            success:(void (^)(AFHTTPRequestOperation *, id))success
                            failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];

    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:requestParameters];
    AFHTTPRequestOperation *operation;
    operation = [self HTTPRequestOperationWithRequest:request
                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                  [self updateRateLimitRemainingWithOperation:operation];
                                                  if (success) {
                                                      success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
                                                  }
                                              }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  if (failure) {
                                                      failure(error);
                                                  }
                                              }];
    [self enqueueHTTPRequestOperation:operation];
    return operation;
}

- (NSURL *)authenticationWebURL
{
    NSDictionary *parameters = @{@"client_id": self.clientID,
                                 @"response_type": @"code",
                                 @"scope": @"all",
                                 @"redirect_uri": self.redirectURI};

    NSURLRequest *request = [self requestWithMethod:@"GET" path:@"oauth/authorize" parameters:parameters];
    return request.URL;
}

- (void)validateOAuthCode:(NSString *)code
                  success:(void (^)(AFOAuthCredential *credential))success
                  failure:(void (^)(NSError *error))failure
{
    [self authenticateUsingOAuthWithPath:@"oauth/token"
                                    code:code
                             redirectURI:self.redirectURI
                                 success:success
                                 failure:failure];
}

- (void)refreshToken:(NSString *)refreshToken
             success:(void (^)(AFOAuthCredential *credential))success
             failure:(void (^)(NSError *error))failure
{
    [self setDefaultHeader:@"Authorization" value:nil];
    [self authenticateUsingOAuthWithPath:@"oauth/token"
                            refreshToken:refreshToken
                                 success:success
                                 failure:failure];
}

- (AFHTTPRequestOperation *)getPath:(NSString *)path
             requiresAuthentication:(BOOL)requiresAuthentication
                         parameters:(NSDictionary *)parameters
           outputStreamToFileAtPath:(NSString *)filePath
                           progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
                            success:(void (^)(AFHTTPRequestOperation *, id))success
                            failure:(void (^)(NSError *))failure
{
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self updateRateLimitRemainingWithOperation:operation];
        if (success)
            success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
    }];

    [operation setDownloadProgressBlock:progress];

    [self enqueueHTTPRequestOperation:operation];
    return operation;
}

- (AFHTTPRequestOperation *)postPath:(NSString *)path
                             bodyKey:(NSString *)bodyKey
                         bodyContent:(id)bodyContent
                             success:(void (^)(AFHTTPRequestOperation *, id))success
                             failure:(void (^)(NSError *))failure
{
    NSDictionary *parameters;
    if (bodyKey && bodyContent) {
        NSString *serializedParameters;
        if ([bodyContent isKindOfClass:[NSString class]])
            serializedParameters = bodyContent;
        else
            serializedParameters = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:bodyContent options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
        parameters = @{bodyKey : serializedParameters};
    }
    
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
	AFHTTPRequestOperation *operation;
    operation = [self HTTPRequestOperationWithRequest:request
                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                  [self updateRateLimitRemainingWithOperation:operation];
                                                  if (success)
                                                      success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
                                              }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  if (failure)
                                                      failure(error);
                                              }];
    [self enqueueHTTPRequestOperation:operation];
    return operation;
}

- (AFHTTPRequestOperation *)deletePath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                               success:(void (^)(AFHTTPRequestOperation *, id))success
                               failure:(void (^)(NSError *))failure
{
    NSURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
	AFHTTPRequestOperation *operation;
    operation = [self HTTPRequestOperationWithRequest:request
                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                  [self updateRateLimitRemainingWithOperation:operation];
                                                  if (success) {
                                                      success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
                                                  }
                                              }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  if (failure) {
                                                      failure(error);
                                                  }
                                              }];
    [self enqueueHTTPRequestOperation:operation];
    return operation;
}

- (AFHTTPRequestOperation *)putPath:(NSString *)path
                          fileAtURL:(NSURL *)fileURL
                            success:(void (^)(AFHTTPRequestOperation *operation, NSString *fileHash, id responseObject))success
                            failure:(void (^)(NSError *))failure
{
    NSString *fileHash = [MDLMendeleyAPIClient SHA1ForFileAtURL:fileURL];
    NSMutableURLRequest *request= [self requestWithMethod:@"PUT" path:path parameters:@{@"oauth_body_hash" : fileHash ?: @""}];
    request.HTTPBody = [NSData dataWithContentsOfURL:fileURL];
    [request setValue:[NSString stringWithFormat:@"attachment; filename=\"%@\"", [[fileURL path] lastPathComponent]] forHTTPHeaderField:@"Content-Disposition"];

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self updateRateLimitRemainingWithOperation:operation];
        if (success) {
            success(operation, fileHash, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [self enqueueHTTPRequestOperation:operation];
    
    return operation;
}

#pragma mark - Crypto

+ (NSString *)SHA1ForFileAtURL:(NSURL *)fileURL
{
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

@end


@implementation NSNumber (NiceNumber)

+ (NSNumber *)numberOrNumberFromString:(id)numberOrString
{
    if ([numberOrString isKindOfClass:[NSString class]]) {
        return [[NSNumberFormatter new] numberFromString:numberOrString];
    }
    return numberOrString;
}

+ (NSNumber *)boolNumberFromNumberOrString:(id)numberOrString
{
    if ([numberOrString isKindOfClass:[NSString class]]) {
        if ([@"1" isEqualToString:numberOrString]) {
            return @YES;
        }
        else {
            return @NO;
        }
    }
    else if ([numberOrString isKindOfClass:[NSNumber class]]) {
        return @([numberOrString boolValue]);
    }

    return nil;
}

@end


@implementation NSDictionary (PaginatedResponse)

- (NSUInteger)responseTotalResults
{
    return [[NSNumber numberOrNumberFromString:self[@"total_results"]] unsignedIntegerValue];
}

- (NSUInteger)responseTotalPages
{
    return [[NSNumber numberOrNumberFromString:self[@"total_pages"]] unsignedIntegerValue];
}

- (NSUInteger)responsePageIndex
{
    return [[NSNumber numberOrNumberFromString:self[@"current_page"]] unsignedIntegerValue];
}

- (NSUInteger)responseItemsPerPage
{
    return [[NSNumber numberOrNumberFromString:self[@"items_per_page"]] unsignedIntegerValue];
}

+ (NSDictionary *)parametersForCategory:(NSString *)categoryIdentifier
                            upAndComing:(BOOL)upAndComing
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (upAndComing) {
        parameters[@"upandcoming"] = @"true";
    }

    if (categoryIdentifier) {
        parameters[@"discipline"] = categoryIdentifier;
    }

    return parameters;
}

@end

