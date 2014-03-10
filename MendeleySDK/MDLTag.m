//
// MDLTag.m
//
// Copyright (c) 2012-2013 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLTag.h"
#import "MDLMendeleyAPIClient.h"

@interface MDLTag ()

+ (void)getTagsAtPath:(NSString *)path
requiresAuthentication:(BOOL)requiresAuthentication
              success:(void (^)(NSArray *))success
              failure:(void (^)(NSError *))failure;

@end

@implementation MDLTag

+ (MDLTag *)tagWithName:(NSString *)name count:(NSNumber *)count
{
    MDLTag *tag = [MDLTag new];
    tag.name = name;
    tag.count = count;
    return tag;
}

+ (void)getTagsAtPath:(NSString *)path
requiresAuthentication:(BOOL)requiresAuthentication
              success:(void (^)(NSArray *))success
              failure:(void (^)(NSError *))failure
{
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];

    [client getPath:path
requiresAuthentication:requiresAuthentication
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, NSArray *responseArray) {
                NSMutableArray *tags = [NSMutableArray array];
                for (NSDictionary *rawTagOrGroupOfTag in responseArray) {
                    if (rawTagOrGroupOfTag[@"name"] && rawTagOrGroupOfTag[@"count"]) {
                        [tags addObject:[MDLTag tagWithName:rawTagOrGroupOfTag[@"name"] count:rawTagOrGroupOfTag[@"count"]]];
                    }
                    else if ([rawTagOrGroupOfTag[@"tags"] isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *rawTag in rawTagOrGroupOfTag[@"tags"]) {
                            [tags addObject:[MDLTag tagWithName:rawTag[@"name"] count:rawTag[@"count"]]];
                        }
                    }
                }

                if (success) {
                    success(tags);
                }
            }
            failure:failure];
}

+ (void)fetchLastTagsInPublicLibraryForCategory:(NSString *)categoryIdentifier
                                        success:(void (^)(NSArray *))success
                                        failure:(void (^)(NSError *))failure
{
    NSString *path = [NSString stringWithFormat:@"/oapi/stats/tags/%@/",
                      categoryIdentifier];

    [self getTagsAtPath:path
 requiresAuthentication:NO
                success:success
                failure:failure];
}

+ (void)fetchLastTagsInUserLibrarySuccess:(void (^)(NSArray *))success
                                  failure:(void (^)(NSError *))failure
{
    [self getTagsAtPath:@"/oapi/library/tags/"
 requiresAuthentication:YES
                success:success
                failure:failure];
}

@end
