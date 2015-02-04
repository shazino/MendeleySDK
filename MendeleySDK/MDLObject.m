//
// MDLObject.m
//
// Copyright (c) 2015 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLObject.h"

#import "MDLMendeleyAPIClient.h"
#import "MDLResponseInfo.h"

@interface MDLObject ()

@end


@implementation MDLObject

+ (NSString *)objectType {
    return nil;
}

+ (NSString *)path {
    return nil;
}

- (NSString *)objectPath {
    return [[self.class path] stringByAppendingPathComponent:self.identifier];
}

+ (instancetype)objectWithServerResponseObject:(id)responseObject {
    MDLObject *object = [self new];
    [object updateWithServerResponseObject:responseObject];
    return object;
}

- (void)updateWithServerResponseObject:(id)responseObject {
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return;
    }

    self.identifier = responseObject[@"id"];
}

- (NSDictionary *)serverRepresentation {
    return nil;
}


- (void)createWithClient:(MDLMendeleyAPIClient *)client
                 success:(void (^)(MDLObject *))success
                 failure:(void (^)(NSError *))failure {
    [client
     postPath:self.class.path
     objectType:self.class.objectType
     parameters:self.serverRepresentation
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         [self updateWithServerResponseObject:responseObject];
         if (success) {
             success(self);
         }
     }
     failure:failure];
}

- (void)updateWithClient:(MDLMendeleyAPIClient *)client
                 success:(void (^)(MDLObject *))success
                 failure:(void (^)(NSError *))failure {
    [client
     patchPath:self.objectPath
     objectType:self.class.objectType
     parameters:self.serverRepresentation
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         if (success) {
             success(self);
         }
     }
     failure:failure];
}

- (void)deleteWithClient:(MDLMendeleyAPIClient *)client
                 success:(void (^)(void))success
                 failure:(void (^)(NSError *))failure {
    [client
     deletePath:self.objectPath
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         if (success) {
             success();
         }
     } failure:failure];
}

- (void)fetchWithClient:(MDLMendeleyAPIClient *)client
                success:(void (^)(MDLObject *object))success
                failure:(void (^)(NSError *))failure {
    [client getPath:self.objectPath
         objectType:self.class.objectType
             atPage:nil
      numberOfItems:0
         parameters:nil
            success:^(MDLResponseInfo *responseInfo, id responseObject) {
                [self updateWithServerResponseObject:responseObject];
                if (success) {
                    success(self);
                }
            }
            failure:failure];
}

+ (void)fetchWithClient:(MDLMendeleyAPIClient *)client
                 atPage:(NSString *)pagePath
          numberOfItems:(NSUInteger)numberOfItems
             parameters:(NSDictionary *)parameters
                success:(void (^)(MDLResponseInfo *info, NSArray *objects))success
                failure:(void (^)(NSError *))failure {
    [client getPath:self.path
         objectType:self.objectType
             atPage:pagePath
      numberOfItems:numberOfItems
         parameters:parameters
            success:^(MDLResponseInfo *info, NSArray *responseArray) {
                NSMutableArray *objects = [NSMutableArray array];
                for (NSDictionary *rawObject in responseArray) {
                    MDLObject *object = [self objectWithServerResponseObject:rawObject];
                    if (object) {
                        [objects addObject:object];
                    }
                }

                if (success) {
                    success(info, objects);
                }
            }
            failure:failure];
}

@end
