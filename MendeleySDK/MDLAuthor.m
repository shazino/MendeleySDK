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

+ (void)getAuthorsAtPath:(NSString *)path requiresAuthentication:(BOOL)requiresAuthentication parameters:(NSDictionary *)parameters success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

@end

@implementation MDLAuthor

+ (MDLAuthor *)authorWithName:(NSString *)name
{
    MDLAuthor *author = [MDLAuthor new];
    author.name = name;
    return author;
}

+ (void)getAuthorsAtPath:(NSString *)path requiresAuthentication:(BOOL)requiresAuthentication parameters:(NSDictionary *)parameters success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:path
                          requiresAuthentication:requiresAuthentication
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, NSArray *responseArray) {
                                             NSMutableArray *authors = [NSMutableArray array];
                                             for (NSDictionary *rawAuthor in responseArray)
                                                 [authors addObject:[MDLAuthor authorWithName:rawAuthor[@"name"]]];
                                             if (success)
                                                 success(authors);
                                         } failure:failure];
}

+ (void)topAuthorsInPublicLibraryForCategory:(NSString *)categoryIdentifier upAndComing:(BOOL)upAndComing success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [self getAuthorsAtPath:@"/oapi/stats/authors/" requiresAuthentication:NO parameters:[NSDictionary parametersForCategory:categoryIdentifier upAndComing:upAndComing] success:success failure:failure];
}

+ (void)topAuthorsInUserLibrarySuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [self getAuthorsAtPath:@"/oapi/library/authors/" requiresAuthentication:YES parameters:nil success:success failure:failure];
}

@end
