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

+ (MDLDocument *)createDocumentWithTitle:(NSString *)title parameters:(NSDictionary *)parameters success:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    MDLDocument *newDocument = [MDLDocument new];
    newDocument.title   = title;
    newDocument.type    = kMDLDocumentTypeGeneric;
    
    NSMutableDictionary *bodyContent = [NSMutableDictionary dictionaryWithDictionary:parameters];
    bodyContent[@"type"] = newDocument.type;
    bodyContent[@"title"] = newDocument.title;
    
    [[MDLMendeleyAPIClient sharedClient] postPath:@"/oapi/library/documents/"
                                          bodyKey:@"document"
                                      bodyContent:bodyContent
                                          success:^(AFHTTPRequestOperation *operation, id responseDictionary) {
                                              newDocument.identifier = responseDictionary[@"document_id"];
                                              if (success)
                                                  success(newDocument);
                                          } failure:failure];
    
    return newDocument;
}

+ (MDLDocument *)documentWithRawDocument:(NSDictionary *)rawDocument
{
    MDLDocument *document = [MDLDocument new];
    if (![rawDocument isKindOfClass:[NSDictionary class]])
        return document;
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
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseDictionary) {
                                             NSArray *rawDocuments = responseDictionary[@"documents"];
                                             NSMutableArray *documents = [NSMutableArray array];
                                             for (NSDictionary *rawDocument in rawDocuments)
                                             {
                                                 MDLDocument *document = [MDLDocument documentWithRawDocument:rawDocument];
                                                 document.inUserLibrary = @(!public);
                                                 [documents addObject:document];
                                             }
                                             if (success)
                                                 success(documents, [responseDictionary responseTotalResults], [responseDictionary responseTotalPages], [responseDictionary responsePageIndex], [responseDictionary responseItemsPerPage]);
                                         }
                                         failure:failure];
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
    [self fetchDocumentsWithPath:[NSString stringWithFormat:@"/oapi/documents/authored/%@/", name] public:YES parameters:(year) ? @{@"year" : year} : nil atPage:pageIndex count:count success:success failure:failure];
}

+ (void)fetchTopDocumentsInPublicLibraryForCategory:(NSString *)categoryIdentifier upAndComing:(BOOL)upAndComing success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:@"/oapi/stats/papers/"
                          requiresAuthentication:NO
                                      parameters:[NSDictionary parametersForCategory:categoryIdentifier upAndComing:upAndComing]
                                         success:^(AFHTTPRequestOperation *operation, NSArray *responseArray) {
                                             NSMutableArray *documents = [NSMutableArray array];
                                             for (NSDictionary *rawDocument in responseArray)
                                                 [documents addObject:[MDLDocument documentWithRawDocument:rawDocument]];
                                             if (success)
                                                 success(documents);
                                         } failure:failure];
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
    
    [[MDLMendeleyAPIClient sharedClient] putPath:[NSString stringWithFormat:@"/oapi/library/documents/%@/", self.identifier]
                                       fileAtURL:fileURL
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) { if (success) success(); }
                                         failure:failure];
}

- (void)fetchDetailsSuccess:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    NSString *path;
    if (self.group)
        path = [NSString stringWithFormat:@"/oapi/library/groups/%@/%@/", self.group.identifier, self.identifier];
    else
        path = [NSString stringWithFormat:(self.isInUserLibrary) ? @"/oapi/library/documents/%@/" : @"/oapi/documents/details/%@/", self.identifier];
    
    [[MDLMendeleyAPIClient sharedClient] getPath:path
                          requiresAuthentication:self.isInUserLibrary || (self.group.type == MDLGroupTypePrivate)
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             self.abstract      = responseObject[@"abstract"];
                                             self.title         = responseObject[@"title"];
                                             self.type          = responseObject[@"type"];
                                             self.volume        = responseObject[@"volume"];
                                             self.pages         = responseObject[@"pages"];
                                             self.read          = [NSNumber boolNumberFromString:responseObject[@"isRead"]];
                                             self.starred       = [NSNumber boolNumberFromString:responseObject[@"isStarred"]];
                                             self.year          = [NSNumber numberOrNumberFromString:responseObject[@"year"]];
                                             self.mendeleyURL   = [NSURL URLWithString:responseObject[@"mendeley_url"]];
                                             
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
                                         failure:failure];
}

- (void)markAsRead:(BOOL)read success:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] postPath:[NSString stringWithFormat:@"/oapi/library/documents/%@/", self.identifier]
                                          bodyKey:@"document" bodyContent:@{@"isRead": read ? @"1" : @"0"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              self.read = @(read);
                                              if (success)
                                                  success(self);
                                          } failure:failure];
}

- (void)markAsStarred:(BOOL)starred success:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] postPath:[NSString stringWithFormat:@"/oapi/library/documents/%@/", self.identifier]
                                          bodyKey:@"document" bodyContent:@{@"isStarred": starred ? @"1" : @"0"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              self.starred = @(starred);
                                              if (success)
                                                  success(self);
                                          } failure:failure];
}

- (void)fetchRelatedDocumentsAtPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/oapi/documents/related/%@/", self.identifier]
                          requiresAuthentication:NO
                                      parameters:@{@"page" : @(pageIndex), @"items" : @(count)}
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             NSMutableArray *documents = [NSMutableArray array];
                                             for (NSDictionary *rawDocument in responseObject[@"documents"])
                                                 [documents addObject:[MDLDocument documentWithRawDocument:rawDocument]];
                                             if (success)
                                                 success(documents);
                                         } failure:failure];
}

- (void)deleteSuccess:(void (^)())success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] deletePath:[NSString stringWithFormat:@"/oapi/library/documents/%@/", self.identifier]
                                         parameters:nil
                                            success:^(AFHTTPRequestOperation *requestOperation, id responseObject) { if (success) success(); }
                                            failure:failure];
}

@end
