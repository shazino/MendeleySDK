//
// MDLDocument.m
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

#import "MDLDocument.h"

#import "MDLMendeleyAPIClient.h"
#import "MDLAuthor.h"
#import "MDLPublication.h"
#import "MDLCategory.h"
#import "MDLSubcategory.h"
#import "MDLGroup.h"
#import "MDLFile.h"
#import "AFNetworking.h"

NSString * const MDLDocumentTypeGeneric = @"Generic";

@interface MDLDocument ()

+ (MDLDocument *)documentWithRawDocument:(NSDictionary *)rawDocument;
+ (NSDictionary *)detailsContentForDocument:(MDLDocument *)document;
+ (void)fetchDocumentsWithPath:(NSString *)path public:(BOOL)public parameters:(NSDictionary *)parameters atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure;

@end

@implementation MDLDocument

+ (MDLDocument *)createDocumentWithTitle:(NSString *)title parameters:(NSDictionary *)parameters success:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    MDLDocument *newDocument = [MDLDocument new];
    newDocument.title   = title;
    newDocument.type    = parameters[@"type"] ?: MDLDocumentTypeGeneric;
    
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

+ (MDLDocument *)createDocument:(MDLDocument *)document
                        success:(void (^)(MDLDocument *))success
                        failure:(void (^)(NSError *))failure
{
    NSDictionary *bodyContent = [MDLDocument detailsContentForDocument:document];
    
    [[MDLMendeleyAPIClient sharedClient] postPath:@"/oapi/library/documents/"
                                          bodyKey:@"document"
                                      bodyContent:bodyContent
                                          success:^(AFHTTPRequestOperation *operation, id responseDictionary) {
                                              MDLDocument *newDocument = [MDLDocument new];
                                              newDocument.identifier = responseDictionary[@"document_id"];
                                              if (success)
                                                  success(newDocument);
                                          } failure:failure];
    return document;
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
    document.version    = [NSNumber numberOrNumberFromString:rawDocument[@"version"]];
    return document;
}

+ (NSDictionary *)detailsContentForDocument:(MDLDocument *)document
{
    NSMutableDictionary *bodyContent = [NSMutableDictionary dictionary];
    bodyContent[@"issue"]  = document.issue ?: @"";
    bodyContent[@"pages"]  = document.pages ?: @"";
    bodyContent[@"title"]  = document.title ?: @"";
    bodyContent[@"volume"] = document.volume ?: @"";
    bodyContent[@"year"]   = document.year ?: @"";
    bodyContent[@"publisher"] = document.publisher ?: @"";
    bodyContent[@"published_in"] = document.publication.name ?: @"";
    bodyContent[@"keywords"] = document.keywords ?: @"";
    bodyContent[@"tags"]     = document.tags ?: @"";
    bodyContent[@"notes"]    = document.notes ?: @"";
    bodyContent[@"doi"]      = document.DOI ?: @"";
    bodyContent[@"pmid"]     = document.PubMedIdentifier ?: @"";
    bodyContent[@"type"]     = document.type ?: MDLDocumentTypeGeneric;
    if (document.starred)
        bodyContent[@"isStarred"] = document.starred.boolValue ? @"1" : @"0";
    if (document.read)
        bodyContent[@"isRead"] = document.read.boolValue ? @"1" : @"0";
    
    NSMutableArray *URLsStrings = [NSMutableArray array];
    for (NSURL *URL in document.URLs) {
        [URLsStrings addObject:[URL absoluteString]];
    }
    bodyContent[@"url"] = [URLsStrings componentsJoinedByString:@"\n"];
    
    NSMutableArray *authors = [NSMutableArray array];
    for (MDLAuthor *author in document.authors) {
        if (author.name)
            [authors addObject:author.name];
    }
    bodyContent[@"authors"] = authors;
    
    return bodyContent;
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
                                                 if (document)
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

- (AFHTTPRequestOperation *)uploadFileAtURL:(NSURL *)fileURL success:(void (^)(MDLFile *newFile))success failure:(void (^)(NSError *))failure
{
    if (!self.identifier)
    {
        failure([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"/oapi/library/documents/%@/", self.identifier];
    return [[MDLMendeleyAPIClient sharedClient] putPath:path
                                              fileAtURL:fileURL
                                                success:^(AFHTTPRequestOperation *operation, NSString *fileHash, id responseObject) {
                                                    MDLFile *file = [MDLFile fileWithDateAdded:nil
                                                                                     extension:[fileURL pathExtension]
                                                                                          hash:fileHash
                                                                                          size:nil
                                                                                      document:nil];
                                                    if (success)
                                                        success(file);
                                                }
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
                                             self.abstract          = responseObject[@"abstract"];
                                             self.addedDate         = [NSDate dateWithTimeIntervalSince1970:[[NSNumber numberOrNumberFromString:responseObject[@"added"]] doubleValue]];
                                             self.canonicalIdentifier = responseObject[@"canonical_id"];
                                             self.cast              = responseObject[@"cast"];
                                             self.deletionPending   = [NSNumber boolNumberFromNumberOrString:responseObject[@"deletionPending"]];
                                             self.discipline        = responseObject[@"discipline"];
                                             self.DOI               = responseObject[@"doi"];
                                             self.editors           = responseObject[@"editors"];
                                             if ([responseObject[@"folders_ids"] isKindOfClass:[NSArray class]])
                                                 self.foldersIdentifiers = responseObject[@"folders_ids"];
                                             self.identifier        = (responseObject[@"id"]) ?: (responseObject[@"uuid"]) ?: nil ;
                                             self.identifiers       = ([responseObject[@"identifiers"] isKindOfClass:[NSDictionary class]]) ? responseObject[@"identifiers"] : nil;
                                             self.institution       = responseObject[@"institution"];
                                             self.authored          = [NSNumber boolNumberFromNumberOrString:responseObject[@"isAuthor"]];
                                             self.read              = [NSNumber boolNumberFromNumberOrString:responseObject[@"isRead"]];
                                             self.starred           = [NSNumber boolNumberFromNumberOrString:responseObject[@"isStarred"]];
                                             self.issue             = responseObject[@"issue"];
                                             self.keywords          = responseObject[@"keywords"];
                                             self.mendeleyURL       = [NSURL URLWithString:responseObject[@"mendeley_url"]];
                                             self.modifiedDate      = [NSDate dateWithTimeIntervalSince1970:[[NSNumber numberOrNumberFromString:responseObject[@"modified"]] doubleValue]];
                                             self.notes             = responseObject[@"notes"];
                                             self.openAccess        = [NSNumber boolNumberFromNumberOrString:responseObject[@"oa_journal"]];
                                             self.pages             = responseObject[@"pages"];
                                             self.PubMedIdentifier  = responseObject[@"pmid"];
                                             self.producers         = responseObject[@"producers"];
                                             if (responseObject[@"publication_outlet"])
                                                 self.publicationOutlet = [MDLPublication publicationWithName:responseObject[@"publication_outlet"]];
                                             else if (responseObject[@"published_in"])
                                                 self.publication = [MDLPublication publicationWithName:responseObject[@"published_in"]];
                                             self.publisher         = responseObject[@"publisher"];
                                             self.subdiscipline     = responseObject[@"subdiscipline"];
                                             self.tags              = responseObject[@"tags"];
                                             self.title             = responseObject[@"title"];
                                             self.translators       = responseObject[@"translators"];
                                             self.type              = responseObject[@"type"];
                                             self.version           = [NSNumber numberOrNumberFromString:responseObject[@"version"]];
                                             self.volume            = responseObject[@"volume"];
                                             self.year              = [NSNumber numberOrNumberFromString:responseObject[@"year"]];
                                             
                                             if (!self.DOI && self.identifiers[@"doi"])
                                                 self.DOI = self.identifiers[@"doi"];
                                             
                                             NSMutableArray *URLs = [NSMutableArray array];
                                             for (NSString *URLString in [responseObject[@"url"] componentsSeparatedByString:@"\n"]) {
                                                 NSURL *URL = [NSURL URLWithString:URLString];
                                                 if (URL)
                                                     [URLs addObject:URL];
                                             }
                                             self.URLs = URLs;
                                             
                                             NSMutableArray *authors = [NSMutableArray array];
                                             for (NSDictionary *authorDictionary in responseObject[@"authors"]) {
                                                 MDLAuthor *author = [MDLAuthor authorWithName:[NSString stringWithFormat:@"%@%@%@", authorDictionary[@"forename"] ?: @"", ([authorDictionary[@"forename"] length] > 0 && [authorDictionary[@"surname"] length] > 0) ? @" " : @"", authorDictionary[@"surname"]]];
                                                 if (author)
                                                     [authors addObject:author];
                                             }
                                             self.authors = authors;
                                             
                                             if (responseObject[@"files"])
                                             {
                                                 NSMutableArray *files = [NSMutableArray array];
                                                 NSDateFormatter *fileDateFormatter = [[NSDateFormatter alloc] init];
                                                 fileDateFormatter.dateFormat = @"y-M-d H:m:s";
                                                 for (NSDictionary *fileDictionary in responseObject[@"files"]) {
                                                     MDLFile *file = [MDLFile fileWithDateAdded:[fileDateFormatter dateFromString:fileDictionary[@"date_added"]] extension:fileDictionary[@"file_extension"] hash:fileDictionary[@"file_hash"] size:[NSNumber numberOrNumberFromString:fileDictionary[@"file_size"]] document:self];
                                                     if (file)
                                                         [files addObject:file];
                                                 }
                                                 self.files = files;
                                             }
                                             else if (responseObject[@"file_url"])
                                                 self.files = @[[MDLFile fileWithPublicURL:[NSURL URLWithString:responseObject[@"file_url"]] document:self]];
                                             
                                             if (success)
                                                 success(self);
                                         }
                                         failure:failure];
}

- (void)updateDetailsSuccess:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    NSDictionary *bodyContent = [MDLDocument detailsContentForDocument:self];
    
    [[MDLMendeleyAPIClient sharedClient] postPath:[NSString stringWithFormat:@"/oapi/library/documents/%@/", self.identifier]
                                          bodyKey:@"document"
                                      bodyContent:bodyContent
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void)moveToTrashSuccess:(void (^)(MDLDocument *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] postPath:[NSString stringWithFormat:@"/oapi/library/documents/%@/", self.identifier]
                                          bodyKey:@"document" bodyContent:@{@"deletionPending": @"1"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              self.deletionPending = @(YES);
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

- (void)importToUserLibrarySuccess:(void (^)(NSString *newDocumentIdentifier))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] postPath:@"/oapi/library/documents/"
                                          bodyKey:@"canonical_id"
                                      bodyContent:self.identifier
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              if (success)
                                                  success(responseObject[@"document_id"]);
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
