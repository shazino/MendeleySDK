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
@property (copy, nonatomic) NSString *identifier;

+ (NSString *)objectType;

+ (NSString *)path;
- (NSString *)objectPath;

+ (instancetype)objectWithServerResponseObject:(id)responseObject;
- (void)updateWithServerResponseObject:(id)responseObject;
- (NSDictionary *)serverRepresentation;

- (void)createWithClient:(MDLMendeleyAPIClient *)client
                 success:(void (^)(MDLMendeleyAPIObject *))success
                 failure:(void (^)(NSError *))failure;

- (void)updateWithClient:(MDLMendeleyAPIClient *)client
                 success:(void (^)(MDLMendeleyAPIObject *))success
                 failure:(void (^)(NSError *))failure;

- (void)deleteWithClient:(MDLMendeleyAPIClient *)client
                 success:(void (^)(void))success
                 failure:(void (^)(NSError *))failure;

- (void)fetchWithClient:(MDLMendeleyAPIClient *)client
                success:(void (^)(MDLMendeleyAPIObject *object))success
                failure:(void (^)(NSError *))failure;

+ (void)fetchWithClient:(MDLMendeleyAPIClient *)client
                 atPage:(NSString *)pagePath
          numberOfItems:(NSUInteger)numberOfItems
             parameters:(NSDictionary *)parameters
                success:(void (^)(MDLResponseInfo *info, NSArray *objects))success
                failure:(void (^)(NSError *))failure;

@end
