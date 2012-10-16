//
// MDLPublication.m
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

#import "MDLPublication.h"
#import "MDLMendeleyAPIClient.h"

@implementation MDLPublication

+ (MDLPublication *)publicationWithName:(NSString *)name
{
    MDLPublication *publication = [MDLPublication new];
    publication.name = name;
    return publication;
}

+ (void)topPublicationsInPublicLibraryForDiscipline:(NSNumber *)disciplineIdentifier upAndComing:(BOOL)upAndComing success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (upAndComing)
        parameters[@"upandcoming"] = @"true";
    if (disciplineIdentifier)
        parameters[@"discipline"] = disciplineIdentifier;
    
    [client getPath:@"/oapi/stats/publications/"
         parameters:parameters
            success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                if (success)
                {
                    NSMutableArray *publications = [NSMutableArray array];
                    [responseObject enumerateObjectsUsingBlock:^(NSDictionary *rawPublication, NSUInteger idx, BOOL *stop) {
                        MDLPublication *publication = [MDLPublication publicationWithName:rawPublication[@"name"]];
                        [publications addObject:publication];
                    }];
                    success(publications);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failure)
                    failure(error);
            }];
}

@end
