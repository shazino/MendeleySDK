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
#import "MDLGroup.h"
#import "MDLFile.h"
#import "AFNetworking.h"

NSString * const kMDLDocumentTypeGeneric = @"Generic";

@interface MDLDocument ()

@property (strong, nonatomic) NSNumber *inUserLibrary;

+ (MDLDocument *)documentWithRawDocument:(NSDictionary *)rawDocument;
+ (void)fetchDocumentsWithPath:(NSString *)path public:(BOOL)public parameters:(NSDictionary *)parameters atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure;

@end

@implementation MDLDocument

+ (MDLDocument *)documentWithTitle:(NSString *)title success:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    MDLDocument *newDocument = [MDLDocument new];
    newDocument.title   = title;
    newDocument.type    = kMDLDocumentTypeGeneric;
    
    [[MDLMendeleyAPIClient sharedClient] postPrivatePath:@"/oapi/library/documents/"
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
    document.identifier = (rawDocument[@"id"]) ? rawDocument[@"id"] : rawDocument[@"uuid"];
    document.title      = rawDocument[@"title"];
    document.type       = rawDocument[@"type"];
    document.DOI        = rawDocument[@"doi"];
    return document;
}

+ (void)fetchDocumentsWithPath:(NSString *)path public:(BOOL)public parameters:(NSDictionary *)parameters atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    mutableParameters[@"page"]  = @(pageIndex);
    mutableParameters[@"items"] = @(count);
    
    [[MDLMendeleyAPIClient sharedClient] getPath:path
                          requiresAuthentication:!public
                                      parameters:mutableParameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (success)
                                             {
                                                 NSArray *rawDocuments   = responseObject[@"documents"];
                                                 NSNumber *totalResults  = [NSNumber numberOrNumberFromString:responseObject[@"total_results"]];
                                                 NSNumber *totalPages    = [NSNumber numberOrNumberFromString:responseObject[@"total_pages"]];
                                                 NSNumber *pageIndex     = [NSNumber numberOrNumberFromString:responseObject[@"current_page"]];
                                                 NSNumber *itemsPerPage  = [NSNumber numberOrNumberFromString:responseObject[@"items_per_page"]];
                                                 NSMutableArray *documents = [NSMutableArray array];
                                                 [rawDocuments enumerateObjectsUsingBlock:^(NSDictionary *rawDocument, NSUInteger idx, BOOL *stop) {
                                                     MDLDocument *document = [MDLDocument documentWithRawDocument:rawDocument];
                                                     document.inUserLibrary = @(!public);
                                                     [documents addObject:document];
                                                 }];
                                                 success(documents, [totalResults unsignedIntegerValue], [totalPages unsignedIntegerValue], [pageIndex unsignedIntegerValue], [itemsPerPage unsignedIntegerValue]);
                                             }
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (failure)
                                                 failure(error);
                                         }];
}

+ (void)searchWithTerms:(NSString *)terms atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    NSString *encodedTerms = [terms stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    encodedTerms = [encodedTerms stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    
    [self fetchDocumentsWithPath:[NSString stringWithFormat:@"/oapi/documents/search/%@/", encodedTerms] public:YES parameters:nil atPage:pageIndex count:count success:success failure:failure];
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
    [self fetchDocumentsWithPath:[NSString stringWithFormat:@"/oapi/documents/tagged/%@/", tag] public:YES parameters:parameters atPage:pageIndex count:count success:success failure:failure];
}

+ (void)searchAuthoredWithName:(NSString *)name year:(NSNumber *)year atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    NSDictionary *parameters;
    if (year)
        parameters = @{@"year" : year};
    [self fetchDocumentsWithPath:[NSString stringWithFormat:@"/oapi/documents/authored/%@/", name] public:YES parameters:parameters atPage:pageIndex count:count success:success failure:failure];
}

+ (void)topDocumentsInPublicLibraryForCategory:(NSString *)categoryIdentifier upAndComing:(BOOL)upAndComing success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (upAndComing)
        parameters[@"upandcoming"] = @"true";
    if (categoryIdentifier)
        parameters[@"discipline"] = categoryIdentifier;
    
    [[MDLMendeleyAPIClient sharedClient] getPath:@"/oapi/stats/papers/"
                          requiresAuthentication:NO
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

+ (void)fetchDocumentsInUserLibraryAtPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    [self fetchDocumentsWithPath:@"/oapi/library/" public:NO parameters:nil atPage:pageIndex count:count success:success failure:failure];
}

+ (void)fetchAuthoredDocumentsInUserLibraryAtPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    [self fetchDocumentsWithPath:@"/oapi/library/documents/authored/" public:NO parameters:nil atPage:pageIndex count:count success:success failure:failure];
}

- (BOOL)isInUserLibrary
{
    return [self.inUserLibrary boolValue];
}

- (void)uploadFileAtURL:(NSURL *)fileURL success:(void (^)())success failure:(void (^)(NSError *))failure
{
    if (!self.identifier)
    {
        failure([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        return;
    }
    
    [[MDLMendeleyAPIClient sharedClient] putPrivatePath:[NSString stringWithFormat:@"/oapi/library/documents/%@/", self.identifier]
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
    
    NSString *path;
    if (self.group)
        path = [NSString stringWithFormat:@"/oapi/library/groups/%@/%@/", self.group.identifier, self.identifier];
    else
        path = [NSString stringWithFormat:(self.isInUserLibrary) ? @"/oapi/library/documents/%@/" : @"/oapi/documents/details/%@/", self.identifier];
    
    [[MDLMendeleyAPIClient sharedClient] getPath:path
                          requiresAuthentication:self.isInUserLibrary || (self.group.type == MDLGroupTypePrivate)
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             self.abstract       = responseObject[@"abstract"];
                                             self.title          = responseObject[@"title"];
                                             self.type           = responseObject[@"type"];
                                             self.year           = [NSNumber numberOrNumberFromString:responseObject[@"year"]];
                                             self.mendeleyURL    = [NSURL URLWithString:responseObject[@"mendeley_url"]];
                                             
                                             NSMutableArray *authors = [NSMutableArray array];
                                             for (NSDictionary *author in responseObject[@"authors"])
                                                 [authors addObject:[MDLAuthor authorWithName:[NSString stringWithFormat:@"%@ %@", author[@"forename"], author[@"surname"]]]];
                                             self.authors = authors;
                                             
                                             if (responseObject[@"publication_outlet"])
                                                 self.publication = [MDLPublication publicationWithName:responseObject[@"publication_outlet"]];
                                             else if (responseObject[@"published_in"])
                                                 self.publication = [MDLPublication publicationWithName:responseObject[@"published_in"]];
                                             
                                             NSMutableArray *files = [NSMutableArray array];
                                             NSDateFormatter *fileDateFormatter = [[NSDateFormatter alloc] init];
                                             fileDateFormatter.dateFormat = @"y-M-d H:m:s";
                                             for (NSDictionary *file in responseObject[@"files"])
                                                 [files addObject:[MDLFile fileWithDateAdded:[fileDateFormatter dateFromString:file[@"date_added"]] extension:file[@"file_extension"] hash:file[@"file_hash"] size:[NSNumber numberOrNumberFromString:file[@"file_size"]] document:self]];
                                             self.files = files;
                                             
                                             if (success)
                                                 success(self);
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    
    [[MDLMendeleyAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/oapi/documents/related/%@/", self.identifier]
                          requiresAuthentication:NO
                                      parameters:@{@"page" : @(pageIndex), @"items" : @(count)}
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             if (success)
                                             {
                                                 NSMutableArray *documents = [NSMutableArray array];
                                                 for (NSDictionary *rawDocument in responseObject[@"documents"])
                                                     [documents addObject:[MDLDocument documentWithRawDocument:rawDocument]];
                                                 success(documents);
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (failure)
                                                 failure(error);
                                         }];
}

- (void)deleteSuccess:(void (^)())success failure:(void (^)(NSError *))failure
{
    if (!self.identifier)
    {
        failure([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        return;
    }
    
    [[MDLMendeleyAPIClient sharedClient] deletePrivatePath:[NSString stringWithFormat:@"/oapi/library/documents/%@/", self.identifier]
                                                parameters:nil success:^(AFHTTPRequestOperation *requestOperation, id responseObject) {
                                                    if (success) success();
                                                } failure:^(AFHTTPRequestOperation *requestOperation, NSError *error) {
                                                    if (failure) failure(error);
                                                }];
}

@end
