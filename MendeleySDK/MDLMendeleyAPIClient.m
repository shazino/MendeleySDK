//
// MDLMendeleyAPIClient.m
//
// Copyright (c) 2012 shazino (shazino SAS), http://www.shazino.com/
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
#import "AFNetworking.h"

#import <CommonCrypto/CommonDigest.h>

static NSString * const kMDLMendeleyAPIBaseURLString = @"http://api.mendeley.com/";
NSString * const kMDLNotificationDidAcquireAccessToken = @"kMDLNotificationDidAcquireAccessToken";
NSString * const kMDLNotificationFailedToAcquireAccessToken = @"kMDLNotificationFailedToAcquireAccessToken";

@interface MDLMendeleyAPIClient ()

+ (NSString *)SHA1ForFileAtURL:(NSURL *)fileURL;
+ (id)deserializeAndSanitizeJSONObjectWithData:(NSData *)JSONData;
+ (id)sanitizeObject:(id)object;
- (void)updateRateLimitRemainingWithOperation:(AFHTTPRequestOperation *)operation;
- (void)analyseFailureFromRequestOperation:(AFHTTPRequestOperation *)requestOperation
                                     error:(NSError *)error
                                   failure:(void (^)(NSError *))failure
 andAuthorizeUsingOAuthIfNeededWithSuccess:(void (^)())authenticationSuccess;

@end

@interface AFOAuth1Client ()

- (void)signCallPerAuthHeaderWithPath:(NSString *)path andParameters:(NSDictionary *)parameters andMethod:(NSString *)method;

@end

@implementation MDLMendeleyAPIClient

+ (MDLMendeleyAPIClient *)sharedClient
{
    static MDLMendeleyAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kMDLMendeleyAPIBaseURLString] key:kMDLConsumerKey secret:kMDLConsumerSecret];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret
{
    self = [super initWithBaseURL:url key:key secret:secret];
    if (!self)
        return nil;

    self.automaticAuthenticationEnabled = YES;
    self.rateLimitRemainingForLatestRequest = NSNotFound;
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

+ (id)deserializeAndSanitizeJSONObjectWithData:(NSData *)JSONData
{
    if (!JSONData)
        return nil;
    
    id object = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:nil];
    return [self sanitizeObject:object];
}

+ (id)sanitizeObject:(id)object
{
    if ([object isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        NSMutableArray *sanitizedArray = [NSMutableArray arrayWithArray:object];
        [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id sanitized = [self sanitizeObject:obj];
            if (!sanitized)
                [sanitizedArray removeObjectIdenticalTo:obj];
            else
                [sanitizedArray replaceObjectAtIndex:[sanitizedArray indexOfObject:obj] withObject:sanitized];
        }];
        
        return [NSArray arrayWithArray:sanitizedArray];
    }
    else if ([object isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionaryWithDictionary:object];
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id sanitized = [self sanitizeObject:obj];
            if (!sanitized)
                [sanitizedDictionary removeObjectForKey:key];
            else
                [sanitizedDictionary setObject:sanitized forKey:key];
        }];
        
        return [NSDictionary dictionaryWithDictionary:sanitizedDictionary];
    }
    else
    {
        return object;
    }
}

- (void)updateRateLimitRemainingWithOperation:(AFHTTPRequestOperation *)operation
{
    NSString *rateLimitRemaining = operation.response.allHeaderFields[@"x-ratelimit-remaining"];
    if (!rateLimitRemaining || ![[NSScanner scannerWithString:rateLimitRemaining] scanInteger:&_rateLimitRemainingForLatestRequest])
        self.rateLimitRemainingForLatestRequest = NSNotFound;
}

#pragma mark - Operation

- (void)getPath:(NSString *)path requiresAuthentication:(BOOL)requiresAuthentication parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if (!requiresAuthentication)
        requestParameters[@"consumer_key"] = kMDLConsumerKey;
    
    [super getPath:path
        parameters:requestParameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               [self updateRateLimitRemainingWithOperation:operation];
               if (success)
                   success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (requiresAuthentication)
                   [self analyseFailureFromRequestOperation:operation error:error failure:failure andAuthorizeUsingOAuthIfNeededWithSuccess:^{
                       [self getPath:path requiresAuthentication:requiresAuthentication parameters:parameters success:success failure:failure];
                   }];
           }];
}

- (void)getPath:(NSString *)path requiresAuthentication:(BOOL)requiresAuthentication parameters:(NSDictionary *)parameters outputStreamToFileAtPath:(NSString *)filePath success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
{
    [self signCallPerAuthHeaderWithPath:path andParameters:parameters andMethod:@"GET"];
    
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
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPrivatePath:(NSString *)path bodyKey:(NSString *)bodyKey bodyContent:(id)bodyContent success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *parameters;
    if (bodyKey && bodyContent)
    {
        NSString *serializedParameters = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:bodyContent options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
        parameters = @{bodyKey : serializedParameters};
    }
    
    [self postPath:path
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               [self updateRateLimitRemainingWithOperation:operation];
               if (success)
                   success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               [self analyseFailureFromRequestOperation:operation error:error failure:failure andAuthorizeUsingOAuthIfNeededWithSuccess:^{
                   [self postPrivatePath:path bodyKey:bodyKey bodyContent:bodyContent success:success failure:failure];
               }];
           }];
}

- (void)deletePrivatePath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
{
    [super deletePath:path
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [self updateRateLimitRemainingWithOperation:operation];
                  if (success)
                      success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [self analyseFailureFromRequestOperation:operation error:error failure:failure andAuthorizeUsingOAuthIfNeededWithSuccess:^{
                      [self deletePrivatePath:path parameters:parameters success:success failure:failure];
                  }];
              }];
}

- (void)putPrivatePath:(NSString *)path fileAtURL:(NSURL *)fileURL success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
{
    [self signCallPerAuthHeaderWithPath:path andParameters:@{@"oauth_body_hash" : [MDLMendeleyAPIClient SHA1ForFileAtURL:fileURL]} andMethod:@"PUT"];
    
    NSMutableURLRequest *request= [self requestWithMethod:@"PUT" path:path parameters:nil];
    request.HTTPBody = [NSData dataWithContentsOfURL:fileURL];
    [request setValue:[NSString stringWithFormat:@"attachment; filename=\"%@\"", [[fileURL path] lastPathComponent]] forHTTPHeaderField:@"Content-Disposition"];
	
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self updateRateLimitRemainingWithOperation:operation];
        if (success)
            success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self analyseFailureFromRequestOperation:operation error:error failure:failure andAuthorizeUsingOAuthIfNeededWithSuccess:^{
            [self putPrivatePath:path fileAtURL:fileURL success:success failure:failure];
        }];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)analyseFailureFromRequestOperation:(AFHTTPRequestOperation *)requestOperation
                                     error:(NSError *)error
                                   failure:(void (^)(NSError *))failure
 andAuthorizeUsingOAuthIfNeededWithSuccess:(void (^)())authenticationSuccess
{
    if (requestOperation.response.statusCode == 401 && self.isAutomaticAuthenticationEnabled)
    {
        [self authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token" userAuthorizationPath:@"oauth/authorize" callbackURL:[NSURL URLWithString:[kMDLURLScheme stringByAppendingString:@"://"]] accessTokenPath:@"oauth/access_token" accessMethod:@"GET" success:^(AFOAuth1Token *accessToken) {
            authenticationSuccess();
            [[NSNotificationCenter defaultCenter] postNotificationName:kMDLNotificationDidAcquireAccessToken object:self];
        } failure:^(NSError *authError) {
            for (NSOperation *operation in [self.operationQueue operations])
                [operation cancel];
            failure([NSError errorWithDomain:AFNetworkingErrorDomain code:NSURLErrorUserCancelledAuthentication userInfo:nil]);
            [[NSNotificationCenter defaultCenter] postNotificationName:kMDLNotificationFailedToAcquireAccessToken object:self];
        }];
    }
    else
        failure(error);
}

#pragma mark - Crypto

+ (NSString *)SHA1ForFileAtURL:(NSURL *)fileURL
{
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end


@implementation NSNumber (NiceNumber)

+ (NSNumber *)numberOrNumberFromString:(id)numberOrString
{
    if ([numberOrString isKindOfClass:[NSString class]])
        return [[NSNumberFormatter new] numberFromString:numberOrString];
    return numberOrString;
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

+ (NSDictionary *)parametersForCategory:(NSString *)categoryIdentifier upAndComing:(BOOL)upAndComing
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (upAndComing)
        parameters[@"upandcoming"] = @"true";
    if (categoryIdentifier)
        parameters[@"discipline"] = categoryIdentifier;
    return parameters;
}

@end
