//
// MDLAuthor.m
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

#import "MDLAuthor.h"
#import "MDLMendeleyAPIClient.h"

@interface MDLAuthor ()

+ (NSArray *)authorsFromRequestResponseObject:(NSArray *)responseObject;

@end

@implementation MDLAuthor

+ (MDLAuthor *)authorWithName:(NSString *)name
{
    MDLAuthor *author = [MDLAuthor new];
    author.name = name;
    return author;
}

+ (NSArray *)authorsFromRequestResponseObject:(NSArray *)responseObject
{
    NSMutableArray *authors = [NSMutableArray array];
    [responseObject enumerateObjectsUsingBlock:^(NSDictionary *rawAuthor, NSUInteger idx, BOOL *stop) {
        [authors addObject:[MDLAuthor authorWithName:rawAuthor[@"name"]]];
    }];
    return authors;
}

+ (void)topAuthorsInPublicLibraryForCategory:(NSString *)categoryIdentifier upAndComing:(BOOL)upAndComing success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (upAndComing)
        parameters[@"upandcoming"] = @"true";
    if (categoryIdentifier)
        parameters[@"discipline"] = categoryIdentifier;
    
    [client getPublicPath:@"/oapi/stats/authors/"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                      if (success)
                          success([self authorsFromRequestResponseObject:responseObject]);
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (failure)
                          failure(error);
                  }];
}

+ (void)topAuthorsInUserLibrarySuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    [client getPrivatePath:@"/oapi/library/authors/"
                   success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                       if (success)
                           success([self authorsFromRequestResponseObject:responseObject]);
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       if (failure)
                           failure(error);
                   }];
}

@end
