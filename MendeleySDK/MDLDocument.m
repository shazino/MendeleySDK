//
// MDLDocument.m
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

#import "MDLDocument.h"

#import "MDLMendeleyAPIClient.h"
#import "MDLAuthor.h"
#import "MDLPublication.h"
#import "MDLCategory.h"
#import "MDLSubcategory.h"
#import "AFNetworking.h"

NSString * const kMDLDocumentTypeGeneric = @"Generic";

@interface MDLDocument ()

+ (MDLDocument *)documentWithRawDocument:(NSDictionary *)rawDocument;
+ (void)searchWithPath:(NSString *)path parameters:(NSDictionary *)parameters atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure;

@end

@implementation MDLDocument

+ (MDLDocument *)documentWithTitle:(NSString *)title success:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    MDLDocument *newDocument = [MDLDocument new];
    newDocument.title = title;
    newDocument.type =  kMDLDocumentTypeGeneric;
    
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    [client postPrivatePath:@"oapi/library/documents/"
                    bodyKey:@"document"
                bodyContent:@{@"type" : newDocument.type, @"title" : newDocument.title}
                    success:^(AFHTTPRequestOperation *operation, id responseDictionary) {
                        newDocument.identifier = responseDictionary[@"document_id"];
                        if (success)
                            success(newDocument);
                    } failure:^(AFHTTPRequestOperation *requestOperation, NSError *error) {
                        if (failure)
                            failure(error);
                    }];
    
    return newDocument;
}

+ (MDLDocument *)documentWithRawDocument:(NSDictionary *)rawDocument
{
    MDLDocument *document = [MDLDocument new];
    document.identifier = rawDocument[@"uuid"];
    document.title = rawDocument[@"title"];
    document.type = rawDocument[@"type"];
    document.DOI = rawDocument[@"doi"];
    return document;
}

+ (void)searchWithPath:(NSString *)path parameters:(NSDictionary *)parameters atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    mutableParameters[@"page"] = @(pageIndex);
    mutableParameters[@"items"] = @(count);
    
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    [client getPublicPath:path
               parameters:mutableParameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      if (success)
                      {
                          NSArray *rawDocuments = responseObject[@"documents"];
                          NSNumber *totalResults = responseObject[@"total_results"];
                          NSNumber *totalPages = responseObject[@"total_pages"];
                          NSString *pageIndex = responseObject[@"current_page"];
                          NSString *itemsPerPage = responseObject[@"items_per_page"];
                          NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
                          NSMutableArray *documents = [NSMutableArray array];
                          [rawDocuments enumerateObjectsUsingBlock:^(NSDictionary *rawDocument, NSUInteger idx, BOOL *stop) {
                              MDLDocument *document = [MDLDocument documentWithRawDocument:rawDocument];
                              [documents addObject:document];
                          }];
                          success(documents, [totalResults unsignedIntegerValue], [totalPages unsignedIntegerValue], [[numberFormatter numberFromString:pageIndex] unsignedIntegerValue], [[numberFormatter numberFromString:itemsPerPage] unsignedIntegerValue]);
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (failure)
                          failure(error);
                  }];
}

+ (void)searchWithTerms:(NSString *)terms atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    NSString *encodedTerms = [terms stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    encodedTerms = [encodedTerms stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    
    [self searchWithPath:[NSString stringWithFormat:@"oapi/documents/search/%@/", encodedTerms] parameters:nil atPage:pageIndex count:count success:success failure:failure];
}

+ (void)searchWithGenericTerms:(NSString *)genericTerms authors:(NSString *)authors title:(NSString *)title year:(NSNumber *)year tags:(NSString *)tags atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    NSMutableArray *terms = [NSMutableArray array];
    if ([genericTerms length] > 0)
        [terms addObject:genericTerms];
    if ([authors length] > 0)
        [terms addObject:[NSString stringWithFormat:@"author:%@", authors]];
    if ([title length] > 0)
        [terms addObject:[NSString stringWithFormat:@"title:%@", title]];
    if (year)
        [terms addObject:[NSString stringWithFormat:@"year:%@", [year stringValue]]];
    if ([tags length] > 0)
        [terms addObject:[NSString stringWithFormat:@"tags:%@", tags]];
    
    [self searchWithTerms:[terms componentsJoinedByString:@" "] atPage:pageIndex count:count success:success failure:failure];
}

+ (void)searchTagged:(NSString *)tag category:(MDLCategory *)category subcategory:(MDLSubcategory *)subcategory atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (category)
        parameters[@"cat"] = category.identifier;
    if (subcategory)
        parameters[@"subcat"] = subcategory.identifier;
    [self searchWithPath:[NSString stringWithFormat:@"oapi/documents/tagged/%@/", tag] parameters:parameters atPage:pageIndex count:count success:success failure:failure];
}

+ (void)searchAuthoredWithName:(NSString *)name year:(NSNumber *)year atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    NSDictionary *parameters;
    if (year)
        parameters = @{@"year" : year};
    [self searchWithPath:[NSString stringWithFormat:@"oapi/documents/authored/%@/", name] parameters:parameters atPage:pageIndex count:count success:success failure:failure];
}

+ (void)topDocumentsInPublicLibraryForCategory:(NSString *)categoryIdentifier upAndComing:(BOOL)upAndComing success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (upAndComing)
        parameters[@"upandcoming"] = @"true";
    if (categoryIdentifier)
        parameters[@"discipline"] = categoryIdentifier;
    
    [client getPublicPath:@"oapi/stats/papers/"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                      if (success)
                      {
                          NSMutableArray *documents = [NSMutableArray array];
                          [responseObject enumerateObjectsUsingBlock:^(NSDictionary *rawDocument, NSUInteger idx, BOOL *stop) {
                              MDLDocument *document = [MDLDocument documentWithRawDocument:rawDocument];
                              [documents addObject:document];
                          }];
                          success(documents);
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (failure)
                          failure(error);
                  }];
}

- (void)uploadFileAtURL:(NSURL *)fileURL success:(void (^)())success failure:(void (^)(NSError *))failure
{
    if (!self.identifier)
    {
        failure([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        return;
    }
    
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    [client putPrivatePath:[NSString stringWithFormat:@"oapi/library/documents/%@/", self.identifier]
                 fileAtURL:fileURL success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (success)
                         success();
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (failure)
                         failure(error);
                 }];
}

- (void)fetchDetailsSuccess:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    if (!self.identifier)
    {
        failure([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        return;
    }
    
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    [client getPublicPath:[NSString stringWithFormat:@"oapi/documents/details/%@/", self.identifier]
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                      self.abstract = responseObject[@"abstract"];
                      self.title = responseObject[@"title"];
                      self.type = responseObject[@"type"];
                      self.mendeleyURL = [NSURL URLWithString:responseObject[@"mendeley_url"]];
                      NSMutableArray *authors = [NSMutableArray array];
                      for (NSDictionary *author in responseObject[@"authors"])
                          [authors addObject:[MDLAuthor authorWithName:[NSString stringWithFormat:@"%@ %@", author[@"forename"], author[@"surname"]]]];
                      self.authors = authors;
                      self.publication = [MDLPublication publicationWithName:responseObject[@"publication_outlet"]];
                      self.year = responseObject[@"year"];
                      
                      if (success)
                          success(self);
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (failure)
                          failure(error);
                  }];
}

- (void)fetchRelatedDocumentsAtPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    if (!self.identifier)
    {
        failure([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        return;
    }
    
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    [client getPublicPath:[NSString stringWithFormat:@"oapi/documents/related/%@/", self.identifier]
               parameters:@{@"page" : @(pageIndex), @"items" : @(count)}
                  success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                      if (success)
                      {
                          NSMutableArray *documents = [NSMutableArray array];
                          [responseObject[@"documents"] enumerateObjectsUsingBlock:^(NSDictionary *rawDocument, NSUInteger idx, BOOL *stop) {
                              MDLDocument *document = [MDLDocument documentWithRawDocument:rawDocument];
                              [documents addObject:document];
                          }];
                          success(documents);
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (failure)
                          failure(error);
                  }];
}

@end
