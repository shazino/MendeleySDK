//
// MDLCategory.m
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

#import "MDLCategory.h"

#import "MDLTag.h"
#import "MDLSubcategory.h"
#import "MDLMendeleyAPIClient.h"

@implementation MDLCategory

+ (MDLCategory *)categoryWithIdentifier:(NSString *)identifier name:(NSString *)name slug:(NSString *)slug
{
    MDLCategory *category = [MDLCategory new];
    category.identifier = identifier;
    category.name = name;
    category.slug = slug;
    return category;
}

+ (void)fetchCategoriesSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:@"/oapi/documents/categories/"
                          requiresAuthentication:NO
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSArray *responseArray) {
                                             NSMutableArray *categories = [NSMutableArray array];
                                             for (NSDictionary *rawCategory in responseArray)
                                                 [categories addObject:[MDLCategory categoryWithIdentifier:rawCategory[@"id"] name:rawCategory[@"name"] slug:rawCategory[@"slug"]]];
                                             if (success)
                                                 success(categories);
                                         }
                                         failure:failure];
}

- (void)fetchSubcategoriesSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/oapi/documents/subcategories/%@/", self.identifier]
                          requiresAuthentication:NO
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSArray *responseArray) {
                                             NSMutableArray *subcategories = [NSMutableArray array];
                                             for (NSDictionary *rawSubcategory in responseArray)
                                                 [subcategories addObject:[MDLSubcategory subcategoryWithIdentifier:rawSubcategory[@"id"] name:rawSubcategory[@"name"] slug:rawSubcategory[@"slug"]]];
                                             if (success)
                                                 success(subcategories);
                                         }
                                         failure:failure];
}

- (void)fetchLastTagsInPublicLibrarySuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [MDLTag fetchLastTagsInPublicLibraryForCategory:self.identifier success:success failure:failure];
}

@end
