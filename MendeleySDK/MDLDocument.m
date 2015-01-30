//
// MDLDocument.m
//
// Copyright (c) 2012-2015 shazino (shazino SAS), http://www.shazino.com/
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
#import "MDLResponseInfo.h"
#import "MDLAuthor.h"
#import "MDLGroup.h"
#import "MDLFile.h"
#import "MDLProfile.h"
#import "AFNetworking.h"

NSString * const MDLDocumentTypeGeneric = @"generic";
NSString * const MDLDocumentTypeJournal = @"journal";

NSString * const MDLDocumentViewAll    = @"all";
NSString * const MDLDocumentViewBIB    = @"bib";
NSString * const MDLDocumentViewClient = @"client";
NSString * const MDLDocumentViewTags   = @"tags";
NSString * const MDLDocumentViewPatent = @"patent";

@interface MDLDocument ()

- (void)updateWithCoreDocumentAttributes:(NSDictionary *)attributes;

+ (instancetype)documentWithRawDocument:(NSDictionary *)rawDocument;
+ (void)fetchDocumentsWithClient:(MDLMendeleyAPIClient *)client
                       inCatalog:(BOOL)inCatalog
                            path:(NSString *)path
                      parameters:(NSDictionary *)parameters
                            view:(NSString *)view
                          atPage:(NSString *)pagePath
                   numberOfItems:(NSUInteger)numberOfItems
                         success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                         failure:(void (^)(NSError *))failure;

@end

@implementation MDLDocument

- (void)updateWithCoreDocumentAttributes:(NSDictionary *)attributes {
    self.identifier = attributes[@"id"];
    self.title      = attributes[@"title"];
    self.type       = attributes[@"type"];

    NSString *profileIdentifier = attributes[@"profile_id"];
    if (profileIdentifier) {
        self.user = [MDLProfile profileWithIdentifier:profileIdentifier];
    }

    NSString *groupIdentifier = attributes[@"group_id"];
    if (groupIdentifier) {
        self.group = [MDLGroup new];
        self.group.identifier = groupIdentifier;
    }

    self.abstract = attributes[@"abstract"];
    self.source = attributes[@"source"];
    self.year = [NSNumber numberOrNumberFromString:attributes[@"year"]];

    NSMutableArray *authors = [NSMutableArray array];
    NSArray *authorsAttributes = attributes[@"authors"];
    for (NSDictionary *authorAttributes in authorsAttributes) {
        MDLAuthor *author = [MDLAuthor authorWithFirstName:authorAttributes[@"first_name"]
                                                  lastName:authorAttributes[@"last_name"]];
        if (author) {
            [authors addObject:author];
        }
    }
    self.authors = authors;

    NSDictionary *identifiers = attributes[@"identifiers"];
    if ([identifiers isKindOfClass:NSDictionary.class]) {
        self.identifiers = identifiers;
    }
    
    NSArray *keywords = attributes[@"keywords"];
    if ([keywords isKindOfClass:NSArray.class]) {
        self.keywords = keywords;
    }
}

+ (instancetype)createDocument:(MDLDocument *)document
                    withClient:(MDLMendeleyAPIClient *)client
                       success:(void (^)(MDLDocument *))success
                       failure:(void (^)(NSError *))failure {
    NSDictionary *parameters = nil;//[MDLDocument detailsContentForDocument:document];
    parameters = @{@"type": document.type, @"title": document.title};

    [client postPath:@"/documents"
          objectType:MDLMendeleyObjectTypeDocument
          parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseDictionary) {
                 MDLDocument *newDocument = [MDLDocument new];
                 newDocument.identifier = responseDictionary[@"id"];

                 if (success) {
                     success(newDocument);
                 }
             } failure:failure];
    return document;
}

+ (instancetype)documentWithRawDocument:(NSDictionary *)rawDocument {
    MDLDocument *document = [MDLDocument new];

    if (![rawDocument isKindOfClass:NSDictionary.class]) {
        return document;
    }

    [document updateWithCoreDocumentAttributes:rawDocument];

    return document;
}

+ (void)fetchDocumentsWithClient:(MDLMendeleyAPIClient *)client
                       inCatalog:(BOOL)inCatalog
                            path:(NSString *)path
                      parameters:(NSDictionary *)parameters
                            view:(NSString *)view
                          atPage:(NSString *)pagePath
                   numberOfItems:(NSUInteger)numberOfItems
                         success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                         failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];

    if (view) {
        mutableParameters[@"view"] = view;
    }

    [client getPath:path
         objectType:MDLMendeleyObjectTypeDocument
             atPage:pagePath
      numberOfItems:numberOfItems
         parameters:mutableParameters
            success:^(MDLResponseInfo *info, NSArray *responseArray) {
                NSMutableArray *documents = [NSMutableArray array];

                for (NSDictionary *rawDocument in responseArray) {
                    MDLDocument *document = [MDLDocument documentWithRawDocument:rawDocument];
                    document.isCatalogDocument = inCatalog;
                    if (document) {
                        [documents addObject:document];
                    }
                }

                if (success) {
                    success(info, documents);
                }
            }
            failure:failure];
}

+ (void)fetchDocumentsInUserLibraryWithClient:(MDLMendeleyAPIClient *)client
                                         view:(NSString *)view
                                       atPage:(NSString *)pagePath
                                numberOfItems:(NSUInteger)numberOfItems
                                      success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                                      failure:(void (^)(NSError *))failure {
    [self fetchDocumentsWithClient:client
                         inCatalog:NO
                              path:@"/documents"
                        parameters:nil
                              view:view
                            atPage:pagePath
                     numberOfItems:numberOfItems
                           success:success
                           failure:failure];
}

+ (void)fetchDocumentsInGroup:(MDLGroup *)group
                   withClient:(MDLMendeleyAPIClient *)client
                         view:(NSString *)view
                       atPage:(NSString *)pagePath
                numberOfItems:(NSUInteger)numberOfItems
                      success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                      failure:(void (^)(NSError *))failure {
    [self fetchDocumentsWithClient:client
                         inCatalog:NO
                              path:@"/documents"
                        parameters:@{@"group_id": group.identifier ?: @""}
                              view:view
                            atPage:pagePath
                     numberOfItems:numberOfItems
                           success:success
                           failure:failure];
}

+ (void)searchWithClient:(MDLMendeleyAPIClient *)client
                   terms:(NSString *)terms
                    view:(NSString *)view
                  atPage:(NSString *)pagePath
           numberOfItems:(NSUInteger)numberOfItems
                 success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                 failure:(void (^)(NSError *))failure {
    [self fetchDocumentsWithClient:client
                         inCatalog:YES
                              path:@"/search/catalog"
                        parameters:@{@"query": terms ?: @""}
                              view:view
                            atPage:pagePath
                     numberOfItems:numberOfItems
                           success:success
                           failure:failure];
}

+ (void)searchWithClient:(MDLMendeleyAPIClient *)client
                 authors:(NSString *)authors
                   title:(NSString *)title
                    year:(NSNumber *)year
                    view:(NSString *)view
                  atPage:(NSString *)pagePath
           numberOfItems:(NSUInteger)numberOfItems
                 success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                 failure:(void (^)(NSError *))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (authors.length > 0) {
        parameters[@"author"] = authors;
    }

    if (title.length > 0) {
        parameters[@"title"] = title;
    }

    if (year) {
        parameters[@"min_year"] = year;
        parameters[@"max_year"] = year;
    }

    [self fetchDocumentsWithClient:client
                         inCatalog:YES
                              path:@"/search/catalog"
                        parameters:parameters
                              view:view
                            atPage:pagePath
                     numberOfItems:numberOfItems
                           success:success
                           failure:failure];
}

- (AFHTTPRequestOperation *)uploadFileWithClient:(MDLMendeleyAPIClient *)client
                                           atURL:(NSURL *)fileURL
                                     contentType:(NSString *)contentType
                                        fileName:(NSString *)fileName
                                         success:(void (^)(MDLFile *newFile))success
                                         failure:(void (^)(NSError *))failure {
    if (!self.identifier) {
        failure([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        return nil;
    }

    return [client
            postPath:@"/files"
            fileAtURL:fileURL
            contentType:contentType
            fileName:fileName
            link:[NSString stringWithFormat:@"<https://api.mendeley.com/documents/%@>; rel=\"document\"", self.identifier]
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                MDLFile *file = [MDLFile new];

                if (success) {
                    success(file);
                }
            }
            failure:failure];
}

- (void)fetchDetailsWithClient:(MDLMendeleyAPIClient *)client
                          view:(NSString *)view
                       success:(void (^)(MDLDocument *))success
                       failure:(void (^)(NSError *))failure {
    NSString *path = [@"/documents" stringByAppendingPathComponent:self.identifier];
    if (self.isCatalogDocument) {
        path = [@"/catalog" stringByAppendingPathComponent:self.identifier];
    }

    NSDictionary *parameters;
    if (view) {
        parameters = @{@"view": view};
    }

    [client getPath:path
         objectType:MDLMendeleyObjectTypeDocument
             atPage:nil
      numberOfItems:0
         parameters:parameters
            success:^(MDLResponseInfo *info, NSDictionary *responseObject) {

                if (![responseObject isKindOfClass:[NSDictionary class]]) {
                    if (failure) {
                        failure(nil);
                    }
                    return;
                }

                [self updateWithCoreDocumentAttributes:responseObject];

//                self.abstract          = responseObject[@"abstract"];
//                self.addedDate         = [NSDate dateWithTimeIntervalSince1970:[[NSNumber numberOrNumberFromString:responseObject[@"added"]] doubleValue]];
//                self.cast              = responseObject[@"cast"];
//                self.citationKey       = responseObject[@"citation_key"];
//                self.deletionPending   = [NSNumber boolNumberFromNumberOrString:responseObject[@"deletionPending"]];
//                self.discipline        = responseObject[@"discipline"];
//                self.editors           = responseObject[@"editors"];
//                if ([responseObject[@"folders_ids"] isKindOfClass:[NSArray class]]) {
//                    self.foldersIdentifiers = responseObject[@"folders_ids"];
//                }
//                self.identifier        = (responseObject[@"id"]) ?: (responseObject[@"uuid"]) ?: nil ;
//                self.identifiers       = ([responseObject[@"identifiers"] isKindOfClass:[NSDictionary class]]) ? responseObject[@"identifiers"] : nil;
//                self.institution       = responseObject[@"institution"];
//                self.authored          = [NSNumber boolNumberFromNumberOrString:responseObject[@"isAuthor"]];
//                self.read              = [NSNumber boolNumberFromNumberOrString:responseObject[@"isRead"]];
//                self.starred           = [NSNumber boolNumberFromNumberOrString:responseObject[@"isStarred"]];
//                self.issue             = responseObject[@"issue"];
//                self.keywords          = responseObject[@"keywords"];
//                self.mendeleyURL       = [NSURL URLWithString:responseObject[@"mendeley_url"]];
//                self.modifiedDate      = [NSDate dateWithTimeIntervalSince1970:[[NSNumber numberOrNumberFromString:responseObject[@"modified"]] doubleValue]];
//                self.notes             = responseObject[@"notes"];
//                self.openAccess        = [NSNumber boolNumberFromNumberOrString:responseObject[@"oa_journal"]];
//                self.pages             = responseObject[@"pages"];
//                self.producers         = responseObject[@"producers"];
//                self.source            = responseObject[@"source"];
//                self.publisher         = responseObject[@"publisher"];
//                self.subdiscipline     = responseObject[@"subdiscipline"];
//                self.tags              = responseObject[@"tags"];
//                self.title             = responseObject[@"title"];
//                self.translators       = responseObject[@"translators"];
//                self.type              = responseObject[@"type"];
//                self.version           = [NSNumber numberOrNumberFromString:responseObject[@"version"]];
//                self.volume            = responseObject[@"volume"];
//                self.year              = [NSNumber numberOrNumberFromString:responseObject[@"year"]];
//
//                NSMutableArray *URLs = [NSMutableArray array];
//                for (NSString *URLString in [responseObject[@"url"] componentsSeparatedByString:@"\n"]) {
//                    NSURL *URL = [NSURL URLWithString:URLString];
//                    if (URL) {
//                        [URLs addObject:URL];
//                    }
//                }
//                self.URLs = URLs;
//
//                NSMutableArray *authors = [NSMutableArray array];
//                for (NSDictionary *authorDictionary in responseObject[@"authors"]) {
//                    MDLAuthor *author = [MDLAuthor authorWithForename:authorDictionary[@"forename"]
//                                                              surname:authorDictionary[@"surname"]];
//                    if (author) {
//                        [authors addObject:author];
//                    }
//                }
//                self.authors = authors;
//
//                if (responseObject[@"files"]) {
//                    NSMutableArray *files = [NSMutableArray array];
//                    NSDateFormatter *fileDateFormatter = [[NSDateFormatter alloc] init];
//                    fileDateFormatter.dateFormat = @"y-M-d H:m:s";
//                    for (NSDictionary *fileDictionary in responseObject[@"files"]) {
//                        MDLFile *file = [MDLFile fileWithDateAdded:[fileDateFormatter dateFromString:fileDictionary[@"date_added"]]
//                                                         extension:fileDictionary[@"file_extension"]
//                                                              hash:fileDictionary[@"file_hash"]
//                                                              size:[NSNumber numberOrNumberFromString:fileDictionary[@"file_size"]]
//                                                          document:self];
//                        if (file) {
//                            [files addObject:file];
//                        }
//                    }
//                    self.files = files;
//                }
//                else if (responseObject[@"file_url"]) {
//                    self.files = @[[MDLFile fileWithPublicURL:[NSURL URLWithString:responseObject[@"file_url"]] document:self]];
//                }

                if (success) {
                    success(self);
                }
            }
            failure:failure];
}

- (void)updateDetailsWithClient:(MDLMendeleyAPIClient *)client
                        success:(void (^)(MDLDocument *))success
                        failure:(void (^)(NSError *))failure {
    NSString *path = [@"/documents" stringByAppendingPathComponent:self.identifier];
    NSDictionary *bodyContent = nil;//[MDLDocument detailsContentForDocument:self];

    [client patchPath:path
           objectType:MDLMendeleyObjectTypeDocument
           parameters:bodyContent
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 if (success) {
                     success(self);
                 }
             }
             failure:failure];
}

- (void)markAsRead:(BOOL)read
        withClient:(MDLMendeleyAPIClient *)client
           success:(void (^)(MDLDocument *))success
           failure:(void (^)(NSError *))failure {
    NSString *path = [@"/documents" stringByAppendingPathComponent:self.identifier];

    [client patchPath:path
           objectType:MDLMendeleyObjectTypeDocument
           parameters:@{@"read": @(read)}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  self.read = @(read);
                  if (success) {
                      success(self);
                  }
              } failure:failure];
}

- (void)markAsStarred:(BOOL)starred
           withClient:(MDLMendeleyAPIClient *)client
              success:(void (^)(MDLDocument *))success
              failure:(void (^)(NSError *))failure {
    NSString *path = [@"/documents" stringByAppendingPathComponent:self.identifier];

    [client patchPath:path
           objectType:MDLMendeleyObjectTypeDocument
           parameters:@{@"starred": @(starred)}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 self.starred = @(starred);
                 if (success) {
                     success(self);
                 }
             } failure:failure];
}

- (void)moveToTrashWithClient:(MDLMendeleyAPIClient *)client
                      success:(void (^)(MDLDocument *))success
                      failure:(void (^)(NSError *))failure {
    NSString *path = [NSString stringWithFormat:@"/documents/%@/trash",
                      self.identifier];

    [client postPath:path
          objectType:nil
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 self.inTrash = @YES;
                 if (success) {
                     success(self);
                 }
             } failure:failure];
}

//- (void)importToUserLibraryWithClient:(MDLMendeleyAPIClient *)client
//                              success:(void (^)(NSString *newDocumentIdentifier))success
//                              failure:(void (^)(NSError *))failure {
//    [client postPath:@"/oapi/library/documents/"
//             bodyKey:@"canonical_id"
//         bodyContent:self.identifier
//             success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                 if (success) {
//                     success(responseObject[@"document_id"]);
//                 }
//             } failure:failure];
//}

- (void)deleteWithClient:(MDLMendeleyAPIClient *)client
                 success:(void (^)())success
                 failure:(void (^)(NSError *))failure {
    NSString *path = [@"/documents" stringByAppendingPathComponent:self.identifier];

    [client deletePath:path
               success:^(AFHTTPRequestOperation *requestOperation, id responseObject) {
                   if (success) {
                       success();
                   }
               }
               failure:failure];
}


#pragma mark - 

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ (identifier: %@; title: %@)",
            [super description], self.identifier, self.title];
}

@end
