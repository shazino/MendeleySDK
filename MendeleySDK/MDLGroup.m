//
// MDLGroup.m
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

#import "MDLGroup.h"
#import "MDLCategory.h"
#import "MDLUser.h"
#import "MDLDocument.h"
#import "MDLMendeleyAPIClient.h"

@interface MDLGroup ()

+ (NSString *)stringValueForType:(MDLGroupType)type;
+ (MDLGroup *)groupWithIdentifier:(NSString *)identifier name:(NSString *)name ownerName:(NSString *)ownerName category:(MDLCategory *)category;
+ (MDLGroup *)groupWithRawGroup:(NSDictionary *)rawGroup;
+ (NSArray *)usersFromRawUsers:(NSArray *)rawUsers;
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

+ (MDLGroup *)groupWithRawGroup:(NSDictionary *)rawGroup
{
    MDLGroup *group = [MDLGroup new];
    [group updateWithRawGroup:rawGroup];
    return group;
}

+ (MDLGroup *)createGroupWithName:(NSString *)name type:(MDLGroupType)type success:(void (^)(MDLGroup *))success failure:(void (^)(NSError *))failure
{
    MDLGroup *group = [MDLGroup new];
    group.name = name;
    group.type = type;
    
    [[MDLMendeleyAPIClient sharedClient] postPath:@"/oapi/library/groups/"
                                          bodyKey:@"group"
                                      bodyContent:@{@"name" : group.name, @"type" : [self stringValueForType:group.type]}
                                          success:^(AFHTTPRequestOperation *operation, id responseDictionary) {
                                              group.identifier = responseDictionary[@"group_id"];
                                              if (success)
                                                  success(group);
                                          } failure:failure];
    
    return group;
}

+ (void)fetchTopGroupsInPublicLibraryForCategory:(NSString *)categoryIdentifier
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
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseDictionary) {
                                             NSMutableArray *groups = [NSMutableArray array];
                                             for (NSDictionary *rawGroup in responseDictionary[@"groups"])
                                                 [groups addObject:[self groupWithRawGroup:rawGroup]];
                                             if (success)
                                                 success(groups, [responseDictionary responseTotalResults], [responseDictionary responseTotalPages], [responseDictionary responsePageIndex], [responseDictionary responseItemsPerPage]);
                                         } failure:failure];
}

+ (void)fetchGroupsInUserLibrarySuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:@"/oapi/library/groups/"
                          requiresAuthentication:YES
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                                             NSMutableArray *groups = [NSMutableArray array];
                                             for (NSDictionary *rawGroup in responseObject)
                                                 [groups addObject:[self groupWithRawGroup:rawGroup]];
                                             if (success)
                                                 success(groups);
                                         } failure:failure];
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
        else if([rawGroup[@"type"] isEqualToString:[MDLGroup stringValueForType:MDLGroupTypeOpen]] || [rawGroup[@"type"] isEqualToString:@"public"])
            self.type = MDLGroupTypeOpen;
    }
}

- (void)fetchDetailsSuccess:(void (^)(MDLGroup *))success failure:(void (^)(NSError *))failure
{
    if (self.type == MDLGroupTypePrivate)
    {
        success(self);
        return;
    }
    
    [[MDLMendeleyAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/oapi/documents/groups/%@/", self.identifier]
                          requiresAuthentication:NO
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             [self updateWithRawGroup:responseObject];
                                             if (success)
                                                 success(self);
                                         } failure:failure];
}

+ (NSArray *)usersFromRawUsers:(NSArray *)rawUsers
{
    NSMutableArray *users = [NSMutableArray array];
    for (NSDictionary *rawUser in rawUsers)
        [users addObject:[MDLUser userWithIdentifier:rawUser[@"user_id"] name:rawUser[@"name"]]];
    return users;
}

- (void)fetchPeopleSuccess:(void (^)(MDLGroup *))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:[NSString stringWithFormat:@"/oapi/%@/groups/%@/people", (self.type == MDLGroupTypePrivate) ? @"library" : @"documents", self.identifier]
                          requiresAuthentication:(self.type == MDLGroupTypePrivate)
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                             self.admins = [MDLGroup usersFromRawUsers:responseObject[@"admins"]];
                                             self.numberOfAdmins = @([self.admins count]);
                                             self.members = [MDLGroup usersFromRawUsers:responseObject[@"members"]];
                                             self.numberOfMembers = @([self.members count]);
                                             self.followers = [MDLGroup usersFromRawUsers:responseObject[@"followers"]];
                                             self.numberOfFollowers = @([self.followers count]);
                                             if (responseObject[@"owner"])
                                                 self.owner = [MDLUser userWithIdentifier:responseObject[@"owner"][@"user_id"] name:responseObject[@"owner"][@"name"]];
                                             
                                             if (success)
                                                 success(self);
                                         } failure:failure];
}

- (void)fetchDocumentsAtPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] getPath:[NSString stringWithFormat:(self.type == MDLGroupTypePrivate) ? @"/oapi/library/groups/%@/" : @"/oapi/documents/groups/%@/docs/", self.identifier]
                          requiresAuthentication:(self.type == MDLGroupTypePrivate)
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseDictionary) {
                                             NSArray *rawDocuments = responseDictionary[@"document_ids"];
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
                                             
                                             if (success)
                                                 success(self.documents, [responseDictionary responseTotalResults], [responseDictionary responseTotalPages], [responseDictionary responsePageIndex], [responseDictionary responseItemsPerPage]);
                                         } failure:failure];
}

- (void)deleteAtPath:(NSString *)path success:(void (^)())success failure:(void (^)(NSError *))failure
{
    [[MDLMendeleyAPIClient sharedClient] deletePath:path parameters:nil
                                            success:^(AFHTTPRequestOperation *requestOperation, id responseObject) { if (success) success(); }
                                            failure:failure];
    
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
