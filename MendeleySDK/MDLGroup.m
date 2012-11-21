//
// MDLGroup.m
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

#import "MDLGroup.h"
#import "MDLCategory.h"
#import "MDLUser.h"
#import "MDLDocument.h"
#import "MDLMendeleyAPIClient.h"

@interface MDLGroup ()

+ (NSString *)stringValueForType:(MDLGroupType)type;
- (void)updateWithRawGroup:(NSDictionary *)rawGroup;
- (void)deleteAtPath:(NSString *)path success:(void (^)())success failure:(void (^)(NSError *))failure;

@end

@implementation MDLGroup

+ (NSString *)stringValueForType:(MDLGroupType)type
{
    switch (type)
    {
        case MDLGroupTypePrivate:
            return @"private";
        case MDLGroupTypeInvite:
            return @"invite";
        case MDLGroupTypeOpen:
            return @"open";
    }
}

+ (MDLGroup *)groupWithIdentifier:(NSString *)identifier name:(NSString *)name ownerName:(NSString *)ownerName category:(MDLCategory *)category
{
    MDLGroup *group = [MDLGroup new];
    group.identifier = identifier;
    group.name      = name;
    group.owner     = [MDLUser userWithIdentifier:nil name:ownerName];
    group.category  = category;
    return group;
}

+ (MDLGroup *)createGroupWithName:(NSString *)name type:(MDLGroupType)type success:(void (^)(MDLGroup *))success failure:(void (^)(NSError *))failure
{
    MDLGroup *group = [MDLGroup new];
    group.name = name;
    group.type = type;
    
    [[MDLMendeleyAPIClient sharedClient] postPrivatePath:@"/oapi/library/groups/"
                                                 bodyKey:@"group"
                                             bodyContent:@{@"name" : group.name, @"type" : [self stringValueForType:group.type]}
                                                 success:^(AFHTTPRequestOperation *operation, id responseDictionary) {
                                                     group.identifier = responseDictionary[@"group_id"];
                                                     if (success)
                                                         success(group);
                                                 } failure:^(AFHTTPRequestOperation *requestOperation, NSError *error) { if (failure) failure(error); }];
    
    return group;
}

+ (void)topGroupsInPublicLibraryForCategory:(NSString *)categoryIdentifier
                                     atPage:(NSUInteger)pageIndex
                                      count:(NSUInteger)count
                                    success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success
                                    failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (categoryIdentifier)
        parameters[@"cat"] = categoryIdentifier;
    parameters[@"page"] = @(pageIndex);
    parameters[@"items"] = @(count);
    
    [[MDLMendeleyAPIClient sharedClient] getPath:@"/oapi/documents/groups"
                          requiresAuthentication:NO
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             if (success)
                                             {
                                                 NSMutableArray *groups = [NSMutableArray array];
                                                 NSArray *rawGroups     = responseObject[@"groups"];
                                                 NSNumber *totalResults = responseObject[@"total_results"];
                                                 NSNumber *totalPages   = responseObject[@"total_pages"];
                                                 NSNumber *pageIndex    = responseObject[@"current_page"];
                                                 NSNumber *itemsPerPage = responseObject[@"items_per_page"];
                                                 [rawGroups enumerateObjectsUsingBlock:^(NSDictionary *rawGroup, NSUInteger idx, BOOL *stop) {
                                                     MDLGroup *group = [MDLGroup new];
                                                     [group updateWithRawGroup:rawGroup];
                                                     [groups addObject:group];
                                                 }];
                                                 success(groups, [totalResults unsignedIntegerValue], [totalPages unsignedIntegerValue], [pageIndex unsignedIntegerValue], [itemsPerPage unsignedIntegerValue]);
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (failure)
                                                 failure(error);
                                         }];
}

+ (void)fetchGroupsInUserLibrarySuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:@"/oapi/library/groups/"
                          requiresAuthentication:YES
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                                             if (success)
                                             {
                                                 NSMutableArray *groups = [NSMutableArray array];
                                                 for (NSDictionary *rawGroup in responseObject)
                                                 {
                                                     MDLGroup *group = [MDLGroup new];
                                                     [group updateWithRawGroup:rawGroup];
                                                     [groups addObject:group];
                                                 };
                                                 success(groups);
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (failure)
                                                 failure(error);
                                         }];
}

- (void)updateWithRawGroup:(NSDictionary *)rawGroup
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    
    self.identifier = rawGroup[@"id"];
    self.name = rawGroup[@"name"];
    if (!self.owner)
        self.owner = [MDLUser new];
    self.owner.name         = rawGroup[@"owner"];
    self.category           = [MDLCategory categoryWithIdentifier:rawGroup[@"disciplines"][@"id"] name:rawGroup[@"disciplines"][@"name"] slug:nil];
    self.mendeleyURL        = [NSURL URLWithString:rawGroup[@"public_url"]];
    self.numberOfDocuments  = (rawGroup[@"size"]) ? [formatter numberFromString:rawGroup[@"size"]] : rawGroup[@"total_documents"];
    self.numberOfAdmins     = [formatter numberFromString:rawGroup[@"people"][@"admins"]];
    self.numberOfMembers    = [formatter numberFromString:rawGroup[@"people"][@"members"]];
    self.numberOfFollowers  = [formatter numberFromString:rawGroup[@"people"][@"followers"]];
    if (rawGroup[@"type"])
    {
        if([rawGroup[@"type"] isEqualToString:[MDLGroup stringValueForType:MDLGroupTypePrivate]])
            self.type = MDLGroupTypePrivate;
        else if([rawGroup[@"type"] isEqualToString:[MDLGroup stringValueForType:MDLGroupTypeInvite]])
            self.type = MDLGroupTypeInvite;
        else if([rawGroup[@"type"] isEqualToString:[MDLGroup stringValueForType:MDLGroupTypeOpen]])
            self.type = MDLGroupTypeOpen;
    }
}

- (void)fetchDetailsSuccess:(void (^)(MDLGroup *))success failure:(void (^)(NSError *))failure
{
    if (self.type == MDLGroupTypePrivate)
    {
        success(self);
    }
    
    [[MDLMendeleyAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/oapi/documents/groups/%@/", self.identifier]
                          requiresAuthentication:NO
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             [self updateWithRawGroup:responseObject];
                                             if (success)
                                                 success(self);
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (failure)
                                                 failure(error);
                                         }];
}

- (void)fetchPeopleSuccess:(void (^)(MDLGroup *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/oapi/%@/groups/%@/people", (self.type == MDLGroupTypePrivate) ? @"library" : @"documents", self.identifier]
                          requiresAuthentication:(self.type == MDLGroupTypePrivate)
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             NSArray *rawAdmins = responseObject[@"admins"];
                                             NSMutableArray *admins = [NSMutableArray array];
                                             for (NSDictionary *rawUser in rawAdmins)
                                                 [admins addObject:[MDLUser userWithIdentifier:rawUser[@"user_id"] name:rawUser[@"name"]]];
                                             self.admins = admins;
                                             self.numberOfAdmins = @([self.admins count]);
                                             
                                             NSArray *rawMembers = responseObject[@"members"];
                                             NSMutableArray *members = [NSMutableArray array];
                                             for (NSDictionary *rawUser in rawMembers)
                                                 [members addObject:[MDLUser userWithIdentifier:rawUser[@"user_id"] name:rawUser[@"name"]]];
                                             self.members = members;
                                             self.numberOfMembers = @([self.members count]);
                                             
                                             NSArray *rawFollowers = responseObject[@"followers"];
                                             NSMutableArray *followers = [NSMutableArray array];
                                             for (NSDictionary *rawUser in rawFollowers)
                                                 [followers addObject:[MDLUser userWithIdentifier:rawUser[@"user_id"] name:rawUser[@"name"]]];
                                             self.followers = followers;
                                             self.numberOfFollowers = @([self.followers count]);
                                             
                                             if (success)
                                                 success(self);
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (failure)
                                                 failure(error);
                                         }];
}

- (void)fetchDocumentsAtPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:[NSString stringWithFormat:(self.type == MDLGroupTypePrivate) ? @"/oapi/library/groups/%@/" : @"/oapi/documents/groups/%@/docs/", self.identifier]
                          requiresAuthentication:(self.type == MDLGroupTypePrivate)
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             NSArray *rawDocuments = responseObject[@"document_ids"];
                                             NSMutableArray *documents = [NSMutableArray array];
                                             for (NSString *documentIdentifier in rawDocuments)
                                             {
                                                 MDLDocument * document = [MDLDocument new];
                                                 document.identifier = documentIdentifier;
                                                 document.group = self;
                                                 [documents addObject:document];
                                             }
                                             self.documents = documents;
                                             self.numberOfDocuments = @([self.documents count]);
                                             
                                             NSNumber *totalResults  = [NSNumber numberOrNumberFromString:responseObject[@"total_results"]];
                                             NSNumber *totalPages    = [NSNumber numberOrNumberFromString:responseObject[@"total_pages"]];
                                             NSNumber *pageIndex     = [NSNumber numberOrNumberFromString:responseObject[@"current_page"]];
                                             NSNumber *itemsPerPage  = [NSNumber numberOrNumberFromString:responseObject[@"items_per_page"]];
                                             
                                             if (success)
                                                 success(self.documents, [totalResults unsignedIntegerValue], [totalPages unsignedIntegerValue], [pageIndex unsignedIntegerValue], [itemsPerPage unsignedIntegerValue]);
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (failure)
                                                 failure(error);
                                         }];
}

- (void)deleteAtPath:(NSString *)path success:(void (^)())success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] deletePrivatePath:path parameters:nil
                                                   success:^(AFHTTPRequestOperation *requestOperation, id responseObject) { if (success) success(); }
                                                   failure:^(AFHTTPRequestOperation *requestOperation, NSError *error) { if (failure) failure(error); }];
    
}

- (void)deleteSuccess:(void (^)())success failure:(void (^)(NSError *))failure
{
    [self deleteAtPath:[NSString stringWithFormat:@"/oapi/library/groups/%@/", self.identifier] success:success failure:failure];
}

- (void)leaveSuccess:(void (^)())success failure:(void (^)(NSError *))failure
{
    [self deleteAtPath:[NSString stringWithFormat:@"/oapi/library/groups/%@/leave/", self.identifier] success:success failure:failure];
}

- (void)unfollowSuccess:(void (^)())success failure:(void (^)(NSError *))failure
{
    [self deleteAtPath:[NSString stringWithFormat:@"/oapi/library/groups/%@/unfollow", self.identifier] success:success failure:failure];
}

@end
