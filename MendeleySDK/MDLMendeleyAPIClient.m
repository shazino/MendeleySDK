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

static NSString * const MDLMendeleyAPIBaseURLString = @"http://api.mendeley.com/";
NSString * const MDLNotificationDidAcquireAccessToken = @"MDLNotificationDidAcquireAccessToken";
NSString * const MDLNotificationFailedToAcquireAccessToken = @"MDLNotificationFailedToAcquireAccessToken";
NSString * const MDLNotificationRateLimitExceeded = @"MDLNotificationRateLimitExceeded";

@interface MDLMendeleyAPIClient ()

@property (strong, nonatomic) id applicationLaunchObserver;

+ (MDLMendeleyAPIClient *)sharedClientReset:(BOOL)reset;
+ (NSString *)SHA1ForFileAtURL:(NSURL *)fileURL;
+ (id)deserializeAndSanitizeJSONObjectWithData:(NSData *)JSONData;
+ (id)sanitizeObject:(id)object;
- (void)updateRateLimitRemainingWithOperation:(AFHTTPRequestOperation *)operation;
- (void)analyseFailureFromRequestOperation:(AFHTTPRequestOperation *)requestOperation
                                     error:(NSError *)error
                                   failure:(void (^)(NSError *))failure
 andAuthorizeUsingOAuthIfNeededWithSuccess:(void (^)(AFOAuth1Token *))authenticationSuccess;
- (void)authorizeUsingOAuthWithRequestTokenPath:(NSString *)requestTokenPath
                          userAuthorizationPath:(NSString *)userAuthorizationPath
                                    callbackURL:(NSURL *)callbackURL
                                accessTokenPath:(NSString *)accessTokenPath
                                   accessMethod:(NSString *)accessMethod
                       webAuthorizationCallback:(void (^)(NSURL *))webAuthorizationCallback
                                        success:(void (^)(AFOAuth1Token *accessToken))success
                                        failure:(void (^)(NSError *error))failure;
@end

@interface AFOAuth1Client ()

- (NSDictionary *)OAuthParameters;
- (NSString *)OAuthSignatureForMethod:(NSString *)method
                                 path:(NSString *)path
                           parameters:(NSDictionary *)parameters
                                token:(AFOAuth1Token *)requestToken;
- (NSString *)authorizationHeaderForParameters:(NSDictionary *)parameters;

@end

static NSDictionary * AFParametersFromQueryString(NSString *queryString) {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (queryString) {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:queryString];
        NSString *name = nil;
        NSString *value = nil;
        
        while (![parameterScanner isAtEnd]) {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];
            
            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];
            
            if (name && value) {
                [parameters setValue:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    return parameters;
}

@interface AFOAuth1Token ()
@property (readwrite, nonatomic, copy) NSString *verifier;
@end

@implementation MDLMendeleyAPIClient

+ (MDLMendeleyAPIClient *)sharedClientReset:(BOOL)reset
{
    static MDLMendeleyAPIClient *_sharedClient = nil;
    @synchronized(self)
    {
        if (reset)
        {
            if (_sharedClient.applicationLaunchObserver)
                [[NSNotificationCenter defaultCenter] removeObserver:_sharedClient.applicationLaunchObserver];
            _sharedClient = nil;
        }
        if (!_sharedClient)
            _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:MDLMendeleyAPIBaseURLString] key:MDLConsumerKey secret:MDLConsumerSecret];
    }
    
    return _sharedClient;
}

+ (MDLMendeleyAPIClient *)sharedClient
{
    return [self sharedClientReset:NO];
}

+ (void)resetSharedClient
{
    [self sharedClientReset:YES];
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
    if (self.rateLimitRemainingForLatestRequest == 0)
        [[NSNotificationCenter defaultCenter] postNotificationName:MDLNotificationRateLimitExceeded object:operation];
}

#pragma mark - Operation

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    if (parameters[@"consumer_key"] || [path isEqualToString:@"oauth/authorize"])
    {
        NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:method];
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)]];
        [request setURL:url];
        return request;
    }
    else
    {
        NSMutableDictionary *mutableParameters = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
        NSMutableDictionary *escapedParameters = [NSMutableDictionary dictionary];
        for (NSString *key in mutableParameters) {
            if ([mutableParameters[key] isKindOfClass:[NSString class]])
                escapedParameters[key] = [mutableParameters[key] stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
            else
                escapedParameters[key] = mutableParameters[key];
        }
        mutableParameters = escapedParameters;
        
        if (self.accessToken) {
            [mutableParameters addEntriesFromDictionary:[self OAuthParameters]];
            [mutableParameters setValue:self.accessToken.key forKey:@"oauth_token"];
        }
        
        [mutableParameters setValue:[self OAuthSignatureForMethod:method path:path parameters:mutableParameters token:self.accessToken] forKey:@"oauth_signature"];
        
        NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
        [request setValue:[self authorizationHeaderForParameters:mutableParameters] forHTTPHeaderField:@"Authorization"];
        [request setHTTPShouldHandleCookies:NO];
        
        return request;
    }
}

- (void)acquireOAuthAccessTokenWithPath:(NSString *)path
                           requestToken:(AFOAuth1Token *)requestToken
                           accessMethod:(NSString *)accessMethod
                                success:(void (^)(AFOAuth1Token *accessToken))success
                                failure:(void (^)(NSError *error))failure
{
    self.accessToken = requestToken;
    [super acquireOAuthAccessTokenWithPath:path requestToken:requestToken accessMethod:accessMethod success:success failure:failure];
}

- (void)getPath:(NSString *)path requiresAuthentication:(BOOL)requiresAuthentication parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if (!requiresAuthentication)
        requestParameters[@"consumer_key"] = MDLConsumerKey;
    
    [self getPath:path
       parameters:requestParameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [self updateRateLimitRemainingWithOperation:operation];
              if (success)
                  success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (requiresAuthentication)
                  [self analyseFailureFromRequestOperation:operation error:error failure:failure andAuthorizeUsingOAuthIfNeededWithSuccess:^(AFOAuth1Token *accessToken) {
                      [self getPath:path requiresAuthentication:requiresAuthentication parameters:parameters success:success failure:failure];
                  }];
              else
                  failure(error);
          }];
}

- (void)getPath:(NSString *)path requiresAuthentication:(BOOL)requiresAuthentication parameters:(NSDictionary *)parameters outputStreamToFileAtPath:(NSString *)filePath success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
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
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path bodyKey:(NSString *)bodyKey bodyContent:(id)bodyContent success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
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
               [self analyseFailureFromRequestOperation:operation error:error failure:failure andAuthorizeUsingOAuthIfNeededWithSuccess:^(AFOAuth1Token *accessToken) {
                   [self postPath:path bodyKey:bodyKey bodyContent:bodyContent success:success failure:failure];
               }];
           }];
}

- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
{
    [super deletePath:path
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [self updateRateLimitRemainingWithOperation:operation];
                  if (success)
                      success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [self analyseFailureFromRequestOperation:operation error:error failure:failure andAuthorizeUsingOAuthIfNeededWithSuccess:^(AFOAuth1Token *accessToken) {
                      [self deletePath:path parameters:parameters success:success failure:failure];
                  }];
              }];
}

- (void)putPath:(NSString *)path fileAtURL:(NSURL *)fileURL success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure
{
    NSMutableURLRequest *request= [self requestWithMethod:@"PUT" path:path parameters:@{@"oauth_body_hash" : [MDLMendeleyAPIClient SHA1ForFileAtURL:fileURL]}];
    request.HTTPBody = [NSData dataWithContentsOfURL:fileURL];
    [request setValue:[NSString stringWithFormat:@"attachment; filename=\"%@\"", [[fileURL path] lastPathComponent]] forHTTPHeaderField:@"Content-Disposition"];
	
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self updateRateLimitRemainingWithOperation:operation];
        if (success)
            success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self analyseFailureFromRequestOperation:operation error:error failure:failure andAuthorizeUsingOAuthIfNeededWithSuccess:^(AFOAuth1Token *accessToken) {
            [self putPath:path fileAtURL:fileURL success:success failure:failure];
        }];
    }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)analyseFailureFromRequestOperation:(AFHTTPRequestOperation *)requestOperation
                                     error:(NSError *)error
                                   failure:(void (^)(NSError *))failure
 andAuthorizeUsingOAuthIfNeededWithSuccess:(void (^)(AFOAuth1Token *))authenticationSuccess
{
    if (requestOperation.response.statusCode == 401 && self.isAutomaticAuthenticationEnabled)
        [self authenticateWithSuccess:authenticationSuccess failure:failure];
    else if (failure)
        failure(error);
}

- (void)authenticateWithSuccess:(void (^)(AFOAuth1Token *))success failure:(void (^)(NSError *))failure
{
    [self authenticateWithWebAuthorizationCallback:nil success:success failure:failure];
}

- (void)authenticateWithWebAuthorizationCallback:(void (^)(NSURL *))webAuthorizationCallback success:(void (^)(AFOAuth1Token *))success failure:(void (^)(NSError *))failure
{
    [self authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token" userAuthorizationPath:@"oauth/authorize" callbackURL:[NSURL URLWithString:[MDLURLScheme stringByAppendingString:@"://"]] accessTokenPath:@"oauth/access_token" accessMethod:@"GET" webAuthorizationCallback:webAuthorizationCallback success:^(AFOAuth1Token *accessToken) {
        if (success)
            success(accessToken);
        [[NSNotificationCenter defaultCenter] postNotificationName:MDLNotificationDidAcquireAccessToken object:self];
    } failure:^(NSError *authError) {
        [self.operationQueue cancelAllOperations];
        self.accessToken = nil;
        if (failure)
            failure(authError);
        [[NSNotificationCenter defaultCenter] postNotificationName:MDLNotificationFailedToAcquireAccessToken object:self];
    }];
}

- (void)authorizeUsingOAuthWithRequestTokenPath:(NSString *)requestTokenPath
                          userAuthorizationPath:(NSString *)userAuthorizationPath
                                    callbackURL:(NSURL *)callbackURL
                                accessTokenPath:(NSString *)accessTokenPath
                                   accessMethod:(NSString *)accessMethod
                                        success:(void (^)(AFOAuth1Token *accessToken))success
                                        failure:(void (^)(NSError *error))failure
{
    [self authorizeUsingOAuthWithRequestTokenPath:requestTokenPath userAuthorizationPath:userAuthorizationPath callbackURL:callbackURL accessTokenPath:accessTokenPath accessMethod:accessMethod webAuthorizationCallback:nil success:success failure:failure];
}

- (void)authorizeUsingOAuthWithRequestTokenPath:(NSString *)requestTokenPath
                          userAuthorizationPath:(NSString *)userAuthorizationPath
                                    callbackURL:(NSURL *)callbackURL
                                accessTokenPath:(NSString *)accessTokenPath
                                   accessMethod:(NSString *)accessMethod
                       webAuthorizationCallback:(void (^)(NSURL *))webAuthorizationCallback
                                        success:(void (^)(AFOAuth1Token *accessToken))success
                                        failure:(void (^)(NSError *error))failure
{
    [self acquireOAuthRequestTokenWithPath:requestTokenPath callback:callbackURL accessMethod:(NSString *)accessMethod success:^(AFOAuth1Token *requestToken) {
        __block AFOAuth1Token *currentRequestToken = requestToken;
        if (self.applicationLaunchObserver)
            [[NSNotificationCenter defaultCenter] removeObserver:self.applicationLaunchObserver];
        self.applicationLaunchObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kAFApplicationLaunchedWithURLNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            NSURL *url = [[notification userInfo] valueForKey:kAFApplicationLaunchOptionsURLKey];
            
            currentRequestToken.verifier = [AFParametersFromQueryString([url query]) valueForKey:@"oauth_verifier"];
            
            [self acquireOAuthAccessTokenWithPath:accessTokenPath requestToken:currentRequestToken accessMethod:accessMethod success:^(AFOAuth1Token * accessToken) {
                self.accessToken = accessToken;
                
                if (success) {
                    success(accessToken);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:requestToken.key forKey:@"oauth_token"];
        NSURL *requestURL = [[self requestWithMethod:@"GET" path:userAuthorizationPath parameters:parameters] URL];
        
        if (webAuthorizationCallback)
            webAuthorizationCallback(requestURL);
        else
#if __IPHONE_OS_VERSION_MIN_REQUIRED
            [[UIApplication sharedApplication] openURL:requestURL];
#else
            [[NSWorkspace sharedWorkspace] openURL:requestURL];
#endif
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
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

+ (NSNumber *)boolNumberFromNumberOrString:(id)numberOrString
{
    if ([numberOrString isKindOfClass:[NSString class]])
    {
        if ([@"1" isEqualToString:numberOrString])
            return @(YES);
        else
            return @(NO);
    }
    else if ([numberOrString isKindOfClass:[NSNumber class]])
    {
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

