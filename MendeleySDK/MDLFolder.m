//
// MDLFolder.h
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

#import "MDLFolder.h"

#import "MDLMendeleyAPIClient.h"
#import "MDLDocument.h"

@interface MDLFolder ()

@end


@implementation MDLFolder

+ (NSString *)objectType {
    return MDLMendeleyObjectTypeFolder;
}

+ (NSString *)path {
    return @"/folders";
}

- (void)updateWithServerResponseObject:(id)responseObject {
    [super updateWithServerResponseObject:responseObject];
    
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return;
    }

    self.identifier       = responseObject[@"id"];
    self.name             = responseObject[@"name"];
    self.parentIdentifier = responseObject[@"parent_id"];

    self.creationDateString = responseObject[@"created"];
    self.modificationDateString = responseObject[@"last_modified"];
}

- (NSDictionary *)serverRepresentation {
    NSMutableDictionary *representation = [NSMutableDictionary dictionary];

    if (self.name) {
        representation[@"name"] = self.name;
    }

    if (self.parentIdentifier) {
        representation[@"parent_id"] = self.parentIdentifier;
    }

    return representation;
}


#pragma mark -

+ (instancetype)createFolderWithClient:(MDLMendeleyAPIClient *)client
                                  name:(NSString *)name
                                parent:(MDLFolder *)parent
                               success:(void (^)(MDLMendeleyAPIObject *))success
                               failure:(void (^)(NSError *))failure {
    MDLFolder *folder = [MDLFolder new];
    folder.name = name;
    folder.parentIdentifier = parent.identifier;

    [folder createWithClient:client
                     success:success
                     failure:failure];

    return folder;
}

+ (void)fetchFoldersInUserLibraryWithClient:(MDLMendeleyAPIClient *)client
                                     atPage:(NSString *)pagePath
                              numberOfItems:(NSUInteger)numberOfItems
                                    success:(void (^)(MDLResponseInfo *info, NSArray *folders))success
                                    failure:(void (^)(NSError *))failure {
    [self fetchWithClient:client
                   atPage:pagePath
            numberOfItems:numberOfItems
               parameters:nil
                  success:success
                  failure:failure];
}

- (void)fetchDocumentsWithClient:(MDLMendeleyAPIClient *)client
                          atPage:(NSString *)pagePath
                   numberOfItems:(NSUInteger)numberOfItems
                         success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                         failure:(void (^)(NSError *))failure {
    NSString *path = [NSString stringWithFormat:@"/folders/%@/documents",
                      self.identifier];

    [client getPath:path
         objectType:MDLMendeleyObjectTypeDocument
             atPage:pagePath
      numberOfItems:numberOfItems
         parameters:nil
            success:^(MDLResponseInfo *info, NSArray *responseArray) {
                NSMutableArray *documents = [NSMutableArray array];

                for (NSDictionary *responseDocument in responseArray) {
                    NSString *documentIdentifier = responseDocument[@"id"];
                    MDLDocument *document = [MDLDocument new];
                    document.identifier = documentIdentifier;
                    [documents addObject:document];
                }

                if (success) {
                    success(info, documents);
                }
            } failure:failure];
}

- (void)addDocument:(MDLDocument *)document
         withClient:(MDLMendeleyAPIClient *)client
            success:(void (^)())success
            failure:(void (^)(NSError *))failure {
    NSString *path = [[@"/folders"
                       stringByAppendingPathComponent:self.identifier]
                      stringByAppendingPathComponent:@"documents"];

    [client postPath:path
          objectType:MDLMendeleyObjectTypeDocument
          parameters:@{@"id": document.identifier ?: @""}
             success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                 if (success) {
                     success();
                 }
             }
             failure:failure];
}

- (void)removeDocument:(MDLDocument *)document
               withClient:(MDLMendeleyAPIClient *)client
               success:(void (^)())success
               failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"/folders/%@/documents/%@",
                      self.identifier,
                      document.identifier];

    [client deletePath:path
               success:^(AFHTTPRequestOperation *requestOperation, id responseObject) {
                   if (success) {
                       success();
                   }
               }
               failure:failure];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ (identifier: %@; name: %@; parent identifier: %@)",
            [super description], self.identifier, self.name, self.parentIdentifier];
}

@end
