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

@interface MDLMendeleyAPIClient ()

+ (NSString *)SHA1ForFileAtURL:(NSURL *)fileURL;
- (void)registerForNotifications;
- (void)unregisterForNotifications;
- (void)networkingOperationDidFinishNotification:(NSNotification *)notification;
- (void)networkingOperationDidFinish:(AFHTTPRequestOperation *)requestOperation;

@end

@interface AFOAuth1Client ()

- (void)signCallPerAuthHeaderWithPath:(NSString *)path andParameters:(NSDictionary *)parameters andMethod:(NSString *)method;

@end

@implementation MDLMendeleyAPIClient

+ (MDLMendeleyAPIClient *)sharedClient {
    static MDLMendeleyAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kMDLMendeleyAPIBaseURLString] key:kMDLConsumerKey secret:kMDLConsumerSecret];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
    self = [super initWithBaseURL:url key:key secret:secret];
    if (!self) {
        return nil;
    }

    self.automaticAuthenticationEnabled = YES;
    [self registerForNotifications];
    
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (void)dealloc
{
    [self unregisterForNotifications];
}

#pragma mark - Operation

- (void)getPath:(NSString *)path success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    [self getPath:path
       parameters:@{@"consumer_key" : kMDLConsumerKey}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              id deserializedResponseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
              if (success)
                  success(operation, deserializedResponseObject);
          }
          failure:failure];
}

- (void)postPath:(NSString *)path bodyKey:(NSString *)bodyKey bodyContent:(id)bodyContent success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSString *serializedParameters = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:bodyContent options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
    
    [self postPath:path
          parameters:@{bodyKey : serializedParameters}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 id deserializedResponseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                 if (success)
                     success(operation, deserializedResponseObject);
             }
             failure:failure];
}

- (void)putPath:(NSString *)path fileAtURL:(NSURL *)fileURL success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    [self signCallPerAuthHeaderWithPath:path andParameters:@{@"oauth_body_hash" : [MDLMendeleyAPIClient SHA1ForFileAtURL:fileURL]} andMethod:@"PUT"];
    
    NSMutableURLRequest *request= [self requestWithMethod:@"PUT" path:path parameters:nil];
    request.HTTPBody = [NSData dataWithContentsOfURL:fileURL];
    [request setValue:[NSString stringWithFormat:@"attachment; filename=\"%@\"", [[fileURL path] lastPathComponent]] forHTTPHeaderField:@"Content-Disposition"];
	
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkingOperationDidFinishNotification:) name:AFNetworkingOperationDidFinishNotification object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingOperationDidFinishNotification object:nil];
}

- (void)networkingOperationDidFinish:(AFHTTPRequestOperation *)requestOperation
{
    if (requestOperation.response.statusCode == 401 && self.isAutomaticAuthenticationEnabled)
    {
        [self authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token" userAuthorizationPath:@"oauth/authorize" callbackURL:[NSURL URLWithString:[kMDLURLScheme stringByAppendingString:@"://"]] accessTokenPath:@"oauth/access_token" accessMethod:@"GET" success:^(AFOAuth1Token *accessToken) {
        } failure:^(NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void)networkingOperationDidFinishNotification:(NSNotification *)notification
{
    if ([notification.object isMemberOfClass:[AFHTTPRequestOperation class]])
    {
        [self networkingOperationDidFinish:(AFHTTPRequestOperation *)notification.object];
    }
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
