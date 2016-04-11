//
// MDLMendeleyAPIClient.h
//
// Copyright (c) 2012-2016 shazino (shazino SAS), http://www.shazino.com/
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

extern NSString * const MDLMendeleyAPIBaseURLString;

extern NSString * const MDLMendeleyObjectTypeAnnotation;
extern NSString * const MDLMendeleyObjectTypeDocument;
extern NSString * const MDLMendeleyObjectTypeMetadataLookup;
extern NSString * const MDLMendeleyObjectTypeFile;
extern NSString * const MDLMendeleyObjectTypeFolder;
extern NSString * const MDLMendeleyObjectTypeFolderDocumentIDs;
extern NSString * const MDLMendeleyObjectTypeGroup;
extern NSString * const MDLMendeleyObjectTypeUserRole;
extern NSString * const MDLMendeleyObjectTypeLookup;
extern NSString * const MDLMendeleyObjectTypeProfiles;

@class AFHTTPRequestOperation;
@class MDLResponseInfo;

/**
 `MDLMendeleyAPIClient` is an HTTP client preconfigured for accessing Mendeley Open API.
 */

@interface MDLMendeleyAPIClient : AFOAuth2Client

/**
 Configure the singleton instance for `MDLMendeleyAPIClient`.
 You need to call this method before calling the `sharedClient` method.

 @param clientID The client identifier issued by the authorization server, uniquely representing the registration information provided by the client.
 @param secret The client secret.
 @param redirectURI The URI to redirect to after successful authentication

 @return The newly-initialized client
 */
+ (nonnull instancetype)clientWithClientID:(nonnull NSString *)clientID
                                    secret:(nonnull NSString *)secret
                               redirectURI:(nonnull NSString *)redirectURI;

/**
 Construct the `NSURL` to authenticate the user.
 You can use this URL for an embedded `UIWebView`/`WebView`/`WKWebView`, or open it with Safari.
 */
- (nonnull NSURL *)authenticationWebURL;

/**
 Creates and enqueues an `AFHTTPRequestOperation` to authenticate against the server with an authorization code.

 @param code The authorization code
 @param success A block object to be executed when the request operation finishes successfully.
  This block has no return value and takes a single argument: the OAuth credential returned by the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data.
  This block has no return value and takes a single argument: the error returned from the server.
 */
- (void)validateOAuthCode:(nonnull NSString *)code
                  success:(nullable void (^)(AFOAuthCredential * __nonnull credential))success
                  failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Creates and enqueues an `AFHTTPRequestOperation` to authenticate against the server using the specified refresh token.

 @param refreshToken The OAuth refresh token
 @param success A block object to be executed when the request operation finishes successfully.
  This block has no return value and takes a single argument: the OAuth credential returned by the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data.
  This block has no return value and takes a single argument: the error returned from the server.
 */
- (void)refreshToken:(nonnull NSString *)refreshToken
             success:(nullable void (^)(AFOAuthCredential * __nonnull credential))success
             failure:(nullable void (^)(NSError * __nullable error))failure;

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
- (nullable AFHTTPRequestOperation *)getPath:(nonnull NSString *)path
                                  objectType:(nonnull NSString *)objectType
                                      atPage:(nullable NSString *)pagePath
                               numberOfItems:(NSUInteger)numberOfItems
                                  parameters:(nullable NSDictionary *)parameters
                                     success:(nullable void (^)(MDLResponseInfo * __nonnull, id __nonnull))success
                                     failure:(nullable void (^)(NSError * __nullable))failure;

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
- (nullable AFHTTPRequestOperation *)getPath:(nonnull NSString *)path
                                  parameters:(nullable NSDictionary *)parameters
                    outputStreamToFileAtPath:(nonnull NSString *)filePath
                                    progress:(nullable void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
                                     success:(nullable void (^)(AFHTTPRequestOperation * __nonnull, id __nonnull))success
                                     failure:(nullable void (^)(NSError * __nullable))failure;

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
- (nullable AFHTTPRequestOperation *)postPath:(nonnull NSString *)path
                                   objectType:(nonnull NSString *)objectType
                                   parameters:(nullable NSDictionary *)parameters
                                      success:(nullable void (^)(AFHTTPRequestOperation * __nonnull, id __nonnull))success
                                      failure:(nullable void (^)(NSError * __nullable))failure;
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
- (nullable AFHTTPRequestOperation *)postPath:(nonnull NSString *)path
                                    fileAtURL:(nonnull NSURL *)fileURL
                                  contentType:(nonnull NSString *)contentType
                                     fileName:(nonnull NSString *)fileName
                                         link:(nonnull NSString *)link
                                      success:(nullable void (^)(AFHTTPRequestOperation * __nonnull, id __nonnull))success
                                      failure:(nullable void (^)(NSError * __nullable))failure;

- (nullable AFHTTPRequestOperation *)patchPath:(nonnull NSString *)path
                                    objectType:(nonnull NSString *)objectType
                                    parameters:(nullable NSDictionary *)parameters
                                       success:(nullable void (^)(AFHTTPRequestOperation * __nonnull, id __nonnull))success
                                       failure:(nullable void (^)(NSError * __nullable))failure;

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
- (nullable AFHTTPRequestOperation *)deletePath:(nonnull NSString *)path
                                        success:(nullable void (^)(AFHTTPRequestOperation * __nonnnull, id __nonnull))success
                                        failure:(nullable void (^)(NSError * __nullable))failure;

@end

@interface NSNumber (NiceNumber)

+ (nullable NSNumber *)numberOrNumberFromString:(nonnull id)numberOrString;
+ (nullable NSNumber *)boolNumberFromNumberOrString:(nonnull id)numberOrString;

@end

@interface NSDictionary (PaginatedResponse)

@end
