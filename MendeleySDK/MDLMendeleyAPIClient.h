//
// MDLMendeleyAPIClient.h
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

#import "AFOAuth2Client.h"

extern NSString * const MDLNotificationDidAcquireAccessToken;
extern NSString * const MDLNotificationFailedToAcquireAccessToken;
extern NSString * const MDLNotificationRateLimitExceeded;

@class AFHTTPRequestOperation;

/**
 `MDLMendeleyAPIClient` is an HTTP client preconfigured for accessing Mendeley Open API.
 */

@interface MDLMendeleyAPIClient : AFOAuth2Client

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
 You need to call `configureSharedClientWithClientID:secret:redirectURI` before calling this method in order to configure the singleton.
 
 @return The newly-initialized client
 */
+ (MDLMendeleyAPIClient *)sharedClient;

/**
 Configure the singleton instance for `MDLMendeleyAPIClient`.
 You need to call this method before calling the `sharedClient` method.
 
 @param clientID The client identifier issued by the authorization server, uniquely representing the registration information provided by the client.
 @param secret The client secret.
 @param redirectURI The URI to redirect to after successful authentication
 
 @return The newly-initialized client
 */
+ (void)configureSharedClientWithClientID:(NSString *)clientID
                                   secret:(NSString *)secret
                              redirectURI:(NSString *)redirectURI;

/**
 Deallocates the singleton instance returned by `sharedClient`.
 */
+ (void)resetSharedClient;

/**
 Construct the `NSURL` to authenticate the user.
 You can use this URL for an embedded `UIWebView`, or open it with Safari.
 */
- (NSURL *)authenticationWebURL;

/**
 Creates and enqueues an `AFHTTPRequestOperation` to authenticate against the server with an authorization code.
 
 @param code The authorization code
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes a single argument: the OAuth credential returned by the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a single argument: the error returned from the server.
 */
- (void)validateOAuthCode:(NSString *)code
                  success:(void (^)(AFOAuthCredential *credential))success
                  failure:(void (^)(NSError *error))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `GET` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param requiresAuthentication A boolean value that corresponds to whether the resource requires authentication
 @param parameters The parameters of the request.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes two arguments: the created request operation and the deserialized JSON object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return A new HTTP request operation
 */
- (AFHTTPRequestOperation *)getPath:(NSString *)path
             requiresAuthentication:(BOOL)requiresAuthentication
                         parameters:(NSDictionary *)parameters
                            success:(void (^)(AFHTTPRequestOperation *, id))success
                            failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `GET` request, setup outstream to a file, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param requiresAuthentication A boolean value that corresponds to whether the resource requires authentication.
 @param parameters The parameters of the request.
 @param filePath The path to the file output stream to.
 @param progress A block object to be called when an undetermined number of bytes have been downloaded from the server. 
  This block has no return value and takes three arguments: the number of bytes read since the last time the download progress block was called, the total bytes read, and the total bytes expected to be read during the request, as initially determined by the expected content size of the `NSHTTPURLResponse` object. 
  This block may be called multiple times, and will execute on the main thread.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes two arguments: the created request operation and the deserialized JSON object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return A new HTTP request operation
 */
- (AFHTTPRequestOperation *)getPath:(NSString *)path
             requiresAuthentication:(BOOL)requiresAuthentication
                         parameters:(NSDictionary *)parameters
           outputStreamToFileAtPath:(NSString *)filePath
                           progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
                            success:(void (^)(AFHTTPRequestOperation *, id))success
                            failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `POST` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param bodyKey The key for the object to be encoded and set in the request HTTP body.
 @param bodyContent The object to be encoded and set in the request HTTP body.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes two arguments: the created request operation and the deserialized JSON object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return A new HTTP request operation
 */
- (AFHTTPRequestOperation *)postPath:(NSString *)path
                             bodyKey:(NSString *)bodyKey
                         bodyContent:(id)bodyContent
                             success:(void (^)(AFHTTPRequestOperation *, id))success
                             failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `DELETE` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param parameters The parameters of the request.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes two arguments: the created request operation and the deserialized JSON object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return A new HTTP request operation
 */
- (AFHTTPRequestOperation *)deletePath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                               success:(void (^)(AFHTTPRequestOperation *, id))success
                               failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `PUT` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param fileURL The local URL for the object to be encoded and set in the request HTTP body.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes three arguments: the created request operation, the file hash, and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return A new HTTP request operation
 */
- (AFHTTPRequestOperation *)putPath:(NSString *)path
                          fileAtURL:(NSURL *)fileURL
                            success:(void (^)(AFHTTPRequestOperation *operation, NSString *fileHash, id responseObject))success
                            failure:(void (^)(NSError *))failure;

@end

@interface NSNumber (NiceNumber)

+ (NSNumber *)numberOrNumberFromString:(id)numberOrString;
+ (NSNumber *)boolNumberFromNumberOrString:(id)numberOrString;

@end

@interface NSDictionary (PaginatedResponse)

- (NSUInteger)responseTotalResults;
- (NSUInteger)responseTotalPages;
- (NSUInteger)responsePageIndex;
- (NSUInteger)responseItemsPerPage;
+ (NSDictionary *)parametersForCategory:(NSString *)categoryIdentifier
                            upAndComing:(BOOL)upAndComing;

@end
