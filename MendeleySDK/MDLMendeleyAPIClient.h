//
// MDLMendeleyAPIClient.h
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

#import "AFOAuth1Client.h"

extern NSString * const kMDLConsumerKey;
extern NSString * const kMDLConsumerSecret;
extern NSString * const kMDLURLScheme;

extern NSString * const kMDLNotificationDidAcquireAccessToken;
extern NSString * const kMDLNotificationFailedToAcquireAccessToken;

/**
 `MDLMendeleyAPIClient` is an HTTP client preconfigured for accessing Mendeley Open API.
 */

@interface MDLMendeleyAPIClient : AFOAuth1Client

/**
 When enabled, automatic authentication launch the authentication process upon receiving network responses with status code = 401. This is `YES` by default.
 */
@property (getter = isAutomaticAuthenticationEnabled) BOOL automaticAuthenticationEnabled;

/**
 Number of calls you can still do within the next hour for the latest request. This is `NSNotFound` by default.
 Note that the default rate limit for calls varies depending on the method being requested.
 
 @see [API documentation: Rate Limiting](http://apidocs.mendeley.com/home/rate-limiting)
 */
@property (assign, nonatomic) NSInteger rateLimitRemainingForLatestRequest;

/**
 Creates and initializes if needed a singleton instance of a `MDLMendeleyAPIClient` object configured with Mendeley Open API URL.
 
 @return The newly-initialized client
 */
+ (MDLMendeleyAPIClient *)sharedClient;

/**
 Deallocates the singleton instance returned by `sharedClient`.
 */
+ (void)resetSharedClient;

/**
 Creates an authentication request, and enqueues it to the HTTP client’s operation queue.
 
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the newly acquired access token.
 @param failure A block object to be executed when the request operation finishes unsuccessfully. This block has no return value and takes one argument: the `NSError` object describing the network or authentication error that occurred.
 */
- (void)authenticateWithSuccess:(void (^)(AFOAuth1Token *))success failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `GET` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param requiresAuthentication A boolean value that corresponds to whether the resource requires authentication
 @param parameters The parameters of the request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the deserialized JSON object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getPath:(NSString *)path requiresAuthentication:(BOOL)requiresAuthentication parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `GET` request, setup outstream to a file, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param requiresAuthentication A boolean value that corresponds to whether the resource requires authentication.
 @param parameters The parameters of the request.
 @param filePath The path to the file output stream to.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the deserialized JSON object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getPath:(NSString *)path requiresAuthentication:(BOOL)requiresAuthentication parameters:(NSDictionary *)parameters outputStreamToFileAtPath:(NSString *)filePath success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `POST` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param bodyKey The key for the object to be encoded and set in the request HTTP body.
 @param bodyContent The object to be encoded and set in the request HTTP body.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the deserialized JSON object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)postPath:(NSString *)path bodyKey:(NSString *)bodyKey bodyContent:(id)bodyContent success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `DELETE` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param parameters The parameters of the request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the deserialized JSON object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `PUT` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param fileURL The local URL for the object to be encoded and set in the request HTTP body.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)putPath:(NSString *)path fileAtURL:(NSURL *)fileURL success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(NSError *))failure;

@end

@interface NSNumber (NiceNumber)

+ (NSNumber *)numberOrNumberFromString:(id)numberOrString;
+ (NSNumber *)boolNumberFromString:(id)string;

@end

@interface NSDictionary (PaginatedResponse)

- (NSUInteger)responseTotalResults;
- (NSUInteger)responseTotalPages;
- (NSUInteger)responsePageIndex;
- (NSUInteger)responseItemsPerPage;
+ (NSDictionary *)parametersForCategory:(NSString *)categoryIdentifier upAndComing:(BOOL)upAndComing;

@end
