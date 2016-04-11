//
// MDLMendeleyAPIClient.m
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

#import "MDLMendeleyAPIClient.h"

#import "MDLResponseInfo.h"

#import <AFNetworking/AFNetworking.h>

NSString * const MDLMendeleyAPIBaseURLString = @"https://api.mendeley.com/";

NSString * const  MDLMendeleyObjectTypeAnnotation        = @"application/vnd.mendeley-annotation.1+json";
NSString * const  MDLMendeleyObjectTypeDocument          = @"application/vnd.mendeley-document.1+json";
NSString * const  MDLMendeleyObjectTypeMetadataLookup    = @"application/vnd.mendeley-document-lookup.1+json";
NSString * const  MDLMendeleyObjectTypeFile              = @"application/vnd.mendeley-file.1+json";
NSString * const  MDLMendeleyObjectTypeFolder            = @"application/vnd.mendeley-folder.1+json";
NSString * const  MDLMendeleyObjectTypeFolderDocumentIDs = @"application/vnd.mendeley-folder-documentids.1+json";
NSString * const  MDLMendeleyObjectTypeGroup             = @"application/vnd.mendeley-group.1+json";
NSString * const  MDLMendeleyObjectTypeUserRole          = @"application/vnd.mendeley-membership.1+json";
NSString * const  MDLMendeleyObjectTypeLookup            = @"application/vnd.mendeley-lookup.1+json";
NSString * const  MDLMendeleyObjectTypeProfiles          = @"application/vnd.mendeley-profiles.1+json";


@interface MDLMendeleyAPIClient ()

@property (nonatomic, copy)   NSString *redirectURI;

+ (id)deserializeAndSanitizeJSONObjectWithData:(NSData *)JSONData;
+ (id)sanitizeObject:(id)object;

@end


@implementation MDLMendeleyAPIClient

+ (nonnull instancetype)clientWithClientID:(nonnull NSString *)clientID
                                    secret:(nonnull NSString *)secret
                               redirectURI:(nonnull NSString *)redirectURI {
    NSURL *baseURL = [NSURL URLWithString:MDLMendeleyAPIBaseURLString];
    MDLMendeleyAPIClient *client = [[self alloc] initWithBaseURL:baseURL clientID:clientID secret:secret];
    client.redirectURI = redirectURI;
    return client;
}

- (instancetype)initWithBaseURL:(NSURL *)url
             clientID:(NSString *)clientID
               secret:(NSString *)secret {
    self = [super initWithBaseURL:url
                         clientID:clientID
                           secret:secret];

    if (!self) {
        return nil;
    }

    self.parameterEncoding = AFJSONParameterEncoding;
    [self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

+ (id)deserializeAndSanitizeJSONObjectWithData:(NSData *)JSONData {
    id object;
    if ([JSONData isKindOfClass:[NSData class]]) {
        object = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:nil];
    }
    else {
        object = JSONData;
    }

    return [self sanitizeObject:object];
}

+ (id)sanitizeObject:(id)object {
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


#pragma mark - Authentication

- (nonnull NSURL *)authenticationWebURL {
    self.parameterEncoding = AFFormURLParameterEncoding;

    NSDictionary *parameters = @{@"client_id": self.clientID ?: @"",
                                 @"response_type": @"code",
                                 @"scope": @"all",
                                 @"redirect_uri": self.redirectURI ?: @""};

    NSURLRequest *request = [self requestWithMethod:@"GET" path:@"oauth/authorize" parameters:parameters];

    self.parameterEncoding = AFJSONParameterEncoding;

    return request.URL;
}

- (void)validateOAuthCode:(nonnull NSString *)code
                  success:(nullable void (^)(AFOAuthCredential * __nonnull credential))success
                  failure:(nullable void (^)(NSError * __nullable error))failure {
    self.parameterEncoding = AFFormURLParameterEncoding;

    [self authenticateUsingOAuthWithPath:@"oauth/token"
                                    code:code
                             redirectURI:self.redirectURI
                                 success:success
                                 failure:failure];

    self.parameterEncoding = AFJSONParameterEncoding;
}

- (void)refreshToken:(nonnull NSString *)refreshToken
             success:(nullable void (^)(AFOAuthCredential * __nonnull credential))success
             failure:(nullable void (^)(NSError * __nullable error))failure {
    self.parameterEncoding = AFFormURLParameterEncoding;

    [self setDefaultHeader:@"Authorization" value:nil];
    [self authenticateUsingOAuthWithPath:@"oauth/token"
                            refreshToken:refreshToken
                                 success:success
                                 failure:failure];

    self.parameterEncoding = AFJSONParameterEncoding;
}


#pragma mark - Operations

- (nullable AFHTTPRequestOperation *)getPath:(nonnull NSString *)path
                                  objectType:(nullable NSString *)objectType
                                      atPage:(nullable NSString *)pagePath
                               numberOfItems:(NSUInteger)numberOfItems
                                  parameters:(nullable NSDictionary *)parameters
                                     success:(nullable void (^)(MDLResponseInfo * __nonnull, id __nonnull))success
                                     failure:(nullable void (^)(NSError * __nullable))failure {
    if (numberOfItems > 0 && !pagePath) {
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        mutableParameters[@"limit"] = @(numberOfItems);
        parameters = [mutableParameters copy];
    }

    if (pagePath) {
        path = pagePath;
        parameters = nil;
    }

    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    [request setValue:objectType forHTTPHeaderField:@"Accept"];

    AFHTTPRequestOperation *operation;
    operation = [self
                 HTTPRequestOperationWithRequest:request
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (success) {
                         id object = [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject];
                         MDLResponseInfo *info = [MDLResponseInfo infoWithHTTPResponse:operation.response];
                         success(info, object);
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

- (nullable AFHTTPRequestOperation *)getPath:(nonnull NSString *)path
                                  parameters:(nullable NSDictionary *)parameters
                    outputStreamToFileAtPath:(nonnull NSString *)filePath
                                    progress:(nullable void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
                                     success:(nullable void (^)(AFHTTPRequestOperation * __nonnull, id __nonnull))success
                                     failure:(nullable void (^)(NSError * __nullable))failure {
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];

    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         if (success) {
            success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (failure) {
            failure(error);
         }
     }];

    [operation setDownloadProgressBlock:progress];

    [self enqueueHTTPRequestOperation:operation];
    return operation;
}

- (nullable AFHTTPRequestOperation *)postPath:(nonnull NSString *)path
                                   objectType:(nullable NSString *)objectType
                                   parameters:(nullable NSDictionary *)parameters
                                      success:(nullable void (^)(AFHTTPRequestOperation * __nonnull, id __nonnull))success
                                      failure:(nullable void (^)(NSError * __nullable))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    if (objectType) {
        [request setValue:objectType forHTTPHeaderField:@"Accept"];
        [request setValue:objectType forHTTPHeaderField:@"Content-Type"];
    }

    AFHTTPRequestOperation *operation;
    operation = [self
                 HTTPRequestOperationWithRequest:request
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (nullable AFHTTPRequestOperation *)patchPath:(nonnull NSString *)path
                                    objectType:(nullable NSString *)objectType
                                    parameters:(nullable NSDictionary *)parameters
                                       success:(nullable void (^)(AFHTTPRequestOperation * __nonnull, id __nonnull))success
                                       failure:(nullable void (^)(NSError * __nullable))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"PATCH" path:path parameters:parameters];
    if (objectType) {
        [request setValue:objectType forHTTPHeaderField:@"Accept"];
        [request setValue:objectType forHTTPHeaderField:@"Content-Type"];
    }

    AFHTTPRequestOperation *operation;
    operation = [self
                 HTTPRequestOperationWithRequest:request
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (nullable AFHTTPRequestOperation *)deletePath:(nonnull NSString *)path
                                        success:(nullable void (^)(AFHTTPRequestOperation * __nonnnull, id __nonnull responseObject))success
                                        failure:(nullable void (^)(NSError * __nullable))failure {
    NSURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:nil];
	AFHTTPRequestOperation *operation;
    operation = [self
                 HTTPRequestOperationWithRequest:request
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (nullable AFHTTPRequestOperation *)postPath:(nonnull NSString *)path
                                    fileAtURL:(nonnull NSURL *)fileURL
                                  contentType:(nonnull NSString *)contentType
                                     fileName:(nonnull NSString *)fileName
                                         link:(nonnull NSString *)link
                                      success:(nullable void (^)(AFHTTPRequestOperation * __nonnull, id __nonnull))success
                                      failure:(nullable void (^)(NSError * __nullable))failure {
    NSMutableURLRequest *request= [self requestWithMethod:@"POST"
                                                     path:path
                                               parameters:nil];
    request.HTTPBody = [NSData dataWithContentsOfURL:fileURL];

    NSString *contentDisposition = [NSString stringWithFormat:@"attachment; filename=\"%@\"", fileName];
    [request setValue:contentType        forHTTPHeaderField:@"Content-Type"];
    [request setValue:contentDisposition forHTTPHeaderField:@"Content-Disposition"];
    [request setValue:link               forHTTPHeaderField:@"Link"];
    [request setValue:nil                forHTTPHeaderField:@"Accept"];

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation, [MDLMendeleyAPIClient deserializeAndSanitizeJSONObjectWithData:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [self enqueueHTTPRequestOperation:operation];
    
    return operation;
}

@end


@implementation NSNumber (NiceNumber)

+ (nullable NSNumber *)numberOrNumberFromString:(nonnull id)numberOrString {
    if ([numberOrString isKindOfClass:[NSString class]]) {
        return [[NSNumberFormatter new] numberFromString:numberOrString];
    }

    return numberOrString;
}

+ (nullable NSNumber *)boolNumberFromNumberOrString:(nonnull id)numberOrString {
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

@end

