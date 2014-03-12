//
// MDLPublication.m
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

#import "MDLPublication.h"
#import "MDLMendeleyAPIClient.h"

@interface MDLPublication ()

+ (void)getPublicationsAtPath:(NSString *)path
       requiresAuthentication:(BOOL)requiresAuthentication
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(NSArray *))success
                      failure:(void (^)(NSError *))failure;

@end

@implementation MDLPublication

+ (instancetype)publicationWithName:(NSString *)name
{
    if (!name) {
        return nil;
    }

    MDLPublication *publication = [MDLPublication new];
    publication.name = name;
    return publication;
}

+ (void)getPublicationsAtPath:(NSString *)path
       requiresAuthentication:(BOOL)requiresAuthentication
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(NSArray *))success
                      failure:(void (^)(NSError *))failure
{
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];

    [client getPath:path
requiresAuthentication:requiresAuthentication
         parameters:parameters
            success:^(AFHTTPRequestOperation *operation, NSArray *responseArray) {
                NSMutableArray *publications = [NSMutableArray array];

                for (NSDictionary *rawPublication in responseArray) {
                    NSString *name = rawPublication[@"name"];
                    MDLPublication *publication = [MDLPublication publicationWithName:name];
                    if (publication) {
                        [publications addObject:publication];
                    }
                }

                if (success) {
                    success(publications);
                }
            }
            failure:failure];
}

+ (void)fetchTopPublicationsInPublicLibraryForCategory:(NSString *)categoryIdentifier
                                           upAndComing:(BOOL)upAndComing
                                               success:(void (^)(NSArray *))success
                                               failure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = [NSDictionary parametersForCategory:categoryIdentifier
                                                       upAndComing:upAndComing];

    [self getPublicationsAtPath:@"/oapi/stats/publications/"
         requiresAuthentication:NO
                     parameters:parameters
                        success:success
                        failure:failure];
}

+ (void)fetchTopPublicationsInUserLibrarySuccess:(void (^)(NSArray *))success
                                         failure:(void (^)(NSError *))failure
{
    [self getPublicationsAtPath:@"/oapi/library/publications/"
         requiresAuthentication:YES
                     parameters:nil
                        success:success
                        failure:failure];
}

@end
