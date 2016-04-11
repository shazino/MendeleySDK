//
// MDLMendeleyAPIObject.h
//
// Copyright (c) 2015-2016 shazino (shazino SAS), http://www.shazino.com/
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

@import Foundation;

@class MDLMendeleyAPIClient, MDLResponseInfo;


/**
 `MDLMendeleyAPIObject` represents an API object.
 */

@interface MDLMendeleyAPIObject : NSObject

/**
 The identifier.
 */
@property (nonatomic, copy, nullable) NSString *identifier;

+ (nonnull NSString *)objectType;

+ (nonnull NSString *)path;
- (nonnull NSString *)objectPath;

+ (nonnull instancetype)objectWithServerResponseObject:(nonnull id)responseObject;

- (void)updateWithServerResponseObject:(nonnull id)responseObject;

- (nonnull NSDictionary *)serverRepresentation;

- (void)createWithClient:(nonnull MDLMendeleyAPIClient *)client
                 success:(nullable void (^)(MDLMendeleyAPIObject * __nonnull))success
                 failure:(nullable void (^)(NSError * __nullable))failure;

- (void)updateWithClient:(nonnull MDLMendeleyAPIClient *)client
                 success:(nullable void (^)(MDLMendeleyAPIObject * __nonnull))success
                 failure:(nullable void (^)(NSError * __nullable))failure;

- (void)deleteWithClient:(nonnull MDLMendeleyAPIClient *)client
                 success:(nullable void (^)(void))success
                 failure:(nullable void (^)(NSError * __nullable))failure;

- (void)fetchWithClient:(nonnull MDLMendeleyAPIClient *)client
                success:(nullable void (^)(MDLMendeleyAPIObject * __nonnull object))success
                failure:(nullable void (^)(NSError * __nullable))failure;

+ (void)fetchWithClient:(nonnull MDLMendeleyAPIClient *)client
                 atPage:(nullable NSString *)pagePath
          numberOfItems:(NSUInteger)numberOfItems
             parameters:(nullable NSDictionary *)parameters
                success:(nullable void (^)(MDLResponseInfo * __nonnull info, NSArray * __nonnull objects))success
                failure:(nullable void (^)(NSError * __nullable))failure;

@end
