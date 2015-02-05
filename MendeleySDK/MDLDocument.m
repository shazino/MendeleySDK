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
#import "MDLPerson.h"
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

+ (instancetype)documentWithRawDocument:(NSDictionary *)rawDocument;

@end


@implementation MDLDocument

+ (NSString *)objectType {
    return MDLMendeleyObjectTypeDocument;
}

+ (NSString *)path {
    return @"/documents";
}

- (void)updateWithServerResponseObject:(id)responseObject {
    [super updateWithServerResponseObject:responseObject];
    
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return;
    }

    self.title      = responseObject[@"title"];
    self.type       = responseObject[@"type"];

    NSString *profileIdentifier = responseObject[@"profile_id"];
    if (profileIdentifier) {
        self.user = [MDLProfile profileWithIdentifier:profileIdentifier];
    }

    NSString *groupIdentifier = responseObject[@"group_id"];
    if (groupIdentifier) {
        self.group = [MDLGroup new];
        self.group.identifier = groupIdentifier;
    }

    self.abstract = responseObject[@"abstract"];
    self.source   = responseObject[@"source"];
    self.year     = [NSNumber numberOrNumberFromString:responseObject[@"year"]];

    self.creationDateString = responseObject[@"created"];
    self.modificationDateString = responseObject[@"last_modified"];

    self.authors = [MDLPerson personsFromServerResponseObject:responseObject[@"authors"]];

    NSDictionary *identifiers = responseObject[@"identifiers"];
    if ([identifiers isKindOfClass:NSDictionary.class]) {
        self.identifiers = identifiers;
    }
    
    NSArray *keywords = responseObject[@"keywords"];
    if ([keywords isKindOfClass:NSArray.class]) {
        self.keywords = keywords;
    }

    self.month = [NSNumber numberOrNumberFromString:responseObject[@"month"]];
    self.day   = [NSNumber numberOrNumberFromString:responseObject[@"day"]];

    self.revision = responseObject[@"revision"];
    self.pages    = responseObject[@"pages"];
    self.volume   = responseObject[@"volume"];
    self.issue    = responseObject[@"issue"];

    NSArray *attributesWebsites = responseObject[@"websites"];
    if ([attributesWebsites isKindOfClass:NSArray.class]) {
        NSMutableArray *URLs = [NSMutableArray array];
        for (NSString *attributeURL in attributesWebsites) {
            NSURL *URL = [NSURL URLWithString:attributeURL];
            if (URL) {
                [URLs addObject:URL];
            }
        }
        self.websitesURLs = URLs;
    }
    else {
        self.websitesURLs = nil;
    }

    self.publisher   = responseObject[@"publisher"];
    self.city        = responseObject[@"city"];
    self.edition     = responseObject[@"edition"];
    self.institution = responseObject[@"institution"];
    self.series      = responseObject[@"series"];
    self.chapter     = responseObject[@"chapter"];
    self.editors     = [MDLPerson personsFromServerResponseObject:responseObject[@"editors"]];
    self.tags        = responseObject[@"tags"];

    self.read         = [NSNumber boolNumberFromNumberOrString:responseObject[@"read"]];
    self.starred      = [NSNumber boolNumberFromNumberOrString:responseObject[@"starred"]];
    self.authored     = [NSNumber boolNumberFromNumberOrString:responseObject[@"authored"]];
    self.confirmed    = [NSNumber boolNumberFromNumberOrString:responseObject[@"confirmed"]];
    self.hidden       = [NSNumber boolNumberFromNumberOrString:responseObject[@"hidden"]];
    self.fileAttached = [NSNumber boolNumberFromNumberOrString:responseObject[@"file_attached"]];

    self.citationKey    = responseObject[@"citation_key"];
    self.sourceType     = responseObject[@"source_type"];
    self.language       = responseObject[@"language"];
    self.shortTitle     = responseObject[@"short_title"];
    self.reprintEdition = responseObject[@"reprint_edition"];
    self.genre          = responseObject[@"genre"];
    self.country        = responseObject[@"country"];
    self.translators    = [MDLPerson personsFromServerResponseObject:responseObject[@"translators"]];
    self.seriesEditor   = responseObject[@"series_editor"];
    self.code           = responseObject[@"code"];
    self.medium         = responseObject[@"medium"];
    self.userContext    = responseObject[@"user_context"];
    self.department     = responseObject[@"departement"];
    self.patentOwner             = responseObject[@"patent_owner"];
    self.patentApplicationNumber = responseObject[@"patent_application_number"];
    self.patentLegalStatus       = responseObject[@"patent_legal_status"];
}

- (void)setIfNotNilValue:(id)value forKey:(NSString *)key inDictionary:(NSMutableDictionary *)dictionary {
    if (value) {
        dictionary[key] = value;
    }
}

- (NSDictionary *)serverRepresentation {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

    [self setIfNotNilValue:self.title    forKey:@"title"    inDictionary:attributes];
    [self setIfNotNilValue:self.type     forKey:@"type"     inDictionary:attributes];
    [self setIfNotNilValue:self.abstract forKey:@"abstract" inDictionary:attributes];
    [self setIfNotNilValue:self.source   forKey:@"source"   inDictionary:attributes];
    [self setIfNotNilValue:self.year     forKey:@"year"     inDictionary:attributes];

    if (self.authors) {
        NSMutableArray *authors = [NSMutableArray arrayWithCapacity:self.authors.count];
        for (MDLPerson *author in self.authors) {
            NSDictionary *requestObject = author.requestObject;
            if (requestObject) {
                [authors addObject:requestObject];
            }
        }

        attributes[@"authors"] = authors;
    }

    [self setIfNotNilValue:self.identifiers forKey:@"identifiers" inDictionary:attributes];
    [self setIfNotNilValue:self.keywords    forKey:@"keywords"    inDictionary:attributes];

    // ---------------------
    // Additional attributes
    // ---------------------

    [self setIfNotNilValue:self.month    forKey:@"month" inDictionary:attributes];
    [self setIfNotNilValue:self.day      forKey:@"day" inDictionary:attributes];
    [self setIfNotNilValue:self.revision forKey:@"revision" inDictionary:attributes];
    [self setIfNotNilValue:self.pages    forKey:@"pages" inDictionary:attributes];
    [self setIfNotNilValue:self.volume   forKey:@"volume" inDictionary:attributes];
    [self setIfNotNilValue:self.issue    forKey:@"issue" inDictionary:attributes];
//    [self setIfNotNilValue:self.websitesURLs forKey:@"" inDictionary:attributes];
    [self setIfNotNilValue:self.publisher   forKey:@"publisher" inDictionary:attributes];
    [self setIfNotNilValue:self.city        forKey:@"city" inDictionary:attributes];
    [self setIfNotNilValue:self.edition     forKey:@"edition" inDictionary:attributes];
    [self setIfNotNilValue:self.institution forKey:@"institution" inDictionary:attributes];
    [self setIfNotNilValue:self.series      forKey:@"series" inDictionary:attributes];
    [self setIfNotNilValue:self.chapter     forKey:@"chapter" inDictionary:attributes];
//    [self setIfNotNilValue:self.editors forKey:@"" inDictionary:attributes];
    [self setIfNotNilValue:self.tags           forKey:@"tags" inDictionary:attributes];
    [self setIfNotNilValue:self.read           forKey:@"read" inDictionary:attributes];
    [self setIfNotNilValue:self.starred        forKey:@"starred" inDictionary:attributes];
    [self setIfNotNilValue:self.authored       forKey:@"authored" inDictionary:attributes];
    [self setIfNotNilValue:self.confirmed      forKey:@"confirmed" inDictionary:attributes];
    [self setIfNotNilValue:self.hidden         forKey:@"hidden" inDictionary:attributes];
    [self setIfNotNilValue:self.fileAttached   forKey:@"file_attached" inDictionary:attributes];
    [self setIfNotNilValue:self.citationKey    forKey:@"citationKey" inDictionary:attributes];
    [self setIfNotNilValue:self.sourceType     forKey:@"source_type" inDictionary:attributes];
    [self setIfNotNilValue:self.language       forKey:@"language" inDictionary:attributes];
    [self setIfNotNilValue:self.shortTitle     forKey:@"short_title" inDictionary:attributes];
    [self setIfNotNilValue:self.reprintEdition forKey:@"reprint_edition" inDictionary:attributes];
    [self setIfNotNilValue:self.genre          forKey:@"genre" inDictionary:attributes];
    [self setIfNotNilValue:self.country        forKey:@"country" inDictionary:attributes];
//    [self setIfNotNilValue:self.translators forKey:@"" inDictionary:attributes];
    [self setIfNotNilValue:self.seriesEditor forKey:@"series_editor" inDictionary:attributes];
    [self setIfNotNilValue:self.code         forKey:@"code" inDictionary:attributes];
    [self setIfNotNilValue:self.medium       forKey:@"medium" inDictionary:attributes];
    [self setIfNotNilValue:self.userContext  forKey:@"user_context" inDictionary:attributes];
    [self setIfNotNilValue:self.department   forKey:@"department" inDictionary:attributes];
    [self setIfNotNilValue:self.patentOwner             forKey:@"patent_owner"              inDictionary:attributes];
    [self setIfNotNilValue:self.patentApplicationNumber forKey:@"patent_application_number" inDictionary:attributes];
    [self setIfNotNilValue:self.patentLegalStatus       forKey:@"patentLegal_status"        inDictionary:attributes];

    return attributes;
}

+ (instancetype)documentWithRawDocument:(NSDictionary *)rawDocument {
    MDLDocument *document = [MDLDocument new];
    [document updateWithServerResponseObject:rawDocument];
    return document;
}

+ (void)searchWithClient:(MDLMendeleyAPIClient *)client
                   terms:(NSString *)terms
                    view:(NSString *)view
                  atPage:(NSString *)pagePath
           numberOfItems:(NSUInteger)numberOfItems
                 success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                 failure:(void (^)(NSError *))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (view) {
        parameters[@"view"] = view;
    }

    if (terms) {
        parameters[@"query"] = terms;
    }

    [client
     getPath:@"/search/catalog"
     objectType:MDLMendeleyObjectTypeDocument
     atPage:pagePath
     numberOfItems:numberOfItems
     parameters:parameters
     success:^(MDLResponseInfo *responseInfo, id responseObject) {
         NSMutableArray *objects = [NSMutableArray array];
         for (NSDictionary *rawObject in responseObject) {
             MDLObject *object = [self objectWithServerResponseObject:rawObject];
             if (object) {
                 [objects addObject:object];
             }
         }

         if (success) {
             success(responseInfo, objects);
         }
     } failure:failure];
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

    if (view) {
        parameters[@"view"] = view;
    }

    [client
     getPath:@"/search/catalog"
     objectType:MDLMendeleyObjectTypeDocument
     atPage:pagePath
     numberOfItems:numberOfItems
     parameters:parameters
     success:^(MDLResponseInfo *responseInfo, id responseObject) {
         NSMutableArray *objects = [NSMutableArray array];
         for (NSDictionary *rawObject in responseObject) {
             MDLObject *object = [self objectWithServerResponseObject:rawObject];
             if (object) {
                 [objects addObject:object];
             }
         }

         if (success) {
             success(responseInfo, objects);
         }
     } failure:failure];
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
                MDLFile *file = [MDLFile objectWithServerResponseObject:responseObject];

                if (success) {
                    success(file);
                }
            }
            failure:failure];
}

- (void)fetchWithClient:(MDLMendeleyAPIClient *)client
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
                [self updateWithServerResponseObject:responseObject];
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
                 if (success) {
                     success(self);
                 }
             } failure:failure];
}

#pragma mark - 

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ (identifier: %@; title: %@)",
            [super description], self.identifier, self.title];
}

@end
