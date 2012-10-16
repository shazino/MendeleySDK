//
// MDLCategory.m
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
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    [client getPath:@"oapi/documents/categories/"
            success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                NSMutableArray *categories = [NSMutableArray array];
                [responseObject enumerateObjectsUsingBlock:^(NSDictionary *rawCategory, NSUInteger idx, BOOL *stop) {
                    MDLCategory *category = [MDLCategory categoryWithIdentifier:rawCategory[@"id"] name:rawCategory[@"name"] slug:rawCategory[@"slug"]];
                    [categories addObject:category];
                }];
                
                if (success)
                    success(categories);
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failure)
                    failure(error);
            }];
}

- (void)subcategoriesSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    [client getPath:[NSString stringWithFormat:@"oapi/documents/subcategories/%@/", self.identifier]
            success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                NSMutableArray *subcategories = [NSMutableArray array];
                [responseObject enumerateObjectsUsingBlock:^(NSDictionary *rawSubcategory, NSUInteger idx, BOOL *stop) {
                    MDLSubcategory *subcategory = [MDLSubcategory subcategoryWithIdentifier:rawSubcategory[@"id"] name:rawSubcategory[@"name"] slug:rawSubcategory[@"slug"]];
                    [subcategories addObject:subcategory];
                }];
                
                if (success)
                    success(subcategories);
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failure)
                    failure(error);
            }];
}

- (void)lastTagsInPublicLibrarSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [MDLTag lastTagsInPublicLibraryForCategory:self.identifier success:success failure:failure];
}

@end
