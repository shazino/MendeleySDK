//
// MDLGroup.m
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

#import "MDLGroup.h"

#import "MDLProfile.h"
#import "MDLDocument.h"
#import "MDLFolder.h"
#import "MDLMendeleyAPIClient.h"

@interface MDLGroup ()

+ (NSString *)stringValueForAccessLevel:(MDLGroupAccessLevel)accessLevel;

+ (instancetype)groupWithIdentifier:(NSString *)identifier;
+ (instancetype)groupWithGroupAttributes:(NSDictionary *)attributes;

+ (NSArray *)usersWithRole:(NSString *)role
              fromRawUsers:(NSArray *)rawUsers;

- (void)updateWithGroupAttributes:(NSDictionary *)attributes;

@end

@implementation MDLGroup

+ (NSString *)path {
    return @"/groups";
}

+ (NSString *)stringValueForAccessLevel:(MDLGroupAccessLevel)accessLevel {
    switch (accessLevel) {
        case MDLGroupAccessLevelPrivate:
            return @"private";

        case MDLGroupAccessLevelInvite:
            return @"invite_only";

        case MDLGroupAccessLevelOpen:
            return @"public";
    }
}

+ (instancetype)groupWithIdentifier:(NSString *)identifier {
    MDLGroup *group = [MDLGroup new];
    group.identifier = identifier;
    return group;
}

+ (instancetype)groupWithGroupAttributes:(NSDictionary *)attributes {
    MDLGroup *group = [MDLGroup new];
    [group updateWithGroupAttributes:attributes];
    return group;
}

+ (void)fetchGroupsForCurrentUserWithClient:(MDLMendeleyAPIClient *)client
                                     atPage:(NSString *)pagePath
                              numberOfItems:(NSUInteger)numberOfItems
                                    success:(void (^)(MDLResponseInfo *info, NSArray *))success
                                    failure:(void (^)(NSError *))failure {
    [client getPath:@"/groups"
         objectType:MDLMendeleyObjectTypeGroup
             atPage:pagePath
      numberOfItems:numberOfItems
         parameters:nil
            success:^(MDLResponseInfo *info, id responseObject) {
                NSMutableArray *groups = [NSMutableArray array];

                for (NSDictionary *rawGroup in responseObject) {
                    [groups addObject:[self groupWithGroupAttributes:rawGroup]];
                }

                if (success) {
                    success(info, groups);
                }
            } failure:failure];
}

- (void)updateWithGroupAttributes:(NSDictionary *)attributes {
    self.identifier  = attributes[@"id"];
    self.mendeleyURL = [NSURL URLWithString:attributes[@"link"]];

    NSString *ownerIdentifier = attributes[@"owning_profile_id"];
    if (!self.owner && ownerIdentifier) {
        self.owner = [MDLProfile profileWithIdentifier:ownerIdentifier];
    }

    NSString *accessLevel = attributes[@"access_level"];
    if([accessLevel isEqualToString:[MDLGroup stringValueForAccessLevel:MDLGroupAccessLevelPrivate]]) {
        self.accessLevel = MDLGroupAccessLevelPrivate;
    }
    else if([accessLevel isEqualToString:[MDLGroup stringValueForAccessLevel:MDLGroupAccessLevelInvite]]) {
        self.accessLevel = MDLGroupAccessLevelInvite;
    }
    else if([accessLevel isEqualToString:[MDLGroup stringValueForAccessLevel:MDLGroupAccessLevelOpen]]) {
        self.accessLevel = MDLGroupAccessLevelOpen;
    }

    self.name             = attributes[@"name"];
    self.groupDescription = attributes[@"description"];
    self.webPage          = [NSURL URLWithString:attributes[@"webpage"]];
    self.disciplines      = attributes[@"disciplines"];
    self.tags             = attributes[@"tags"];
    self.role             = attributes[@"role"];
}

- (void)fetchDetailsWithClient:(MDLMendeleyAPIClient *)client
                       success:(void (^)(MDLGroup *))success
                       failure:(void (^)(NSError *))failure {
    [client getPath:[@"/groups" stringByAppendingPathComponent:self.identifier]
         objectType:MDLMendeleyObjectTypeGroup
             atPage:nil
      numberOfItems:0
         parameters:nil
            success:^(MDLResponseInfo *info, NSDictionary *responseObject) {
                [self updateWithGroupAttributes:responseObject];
                if (success) {
                    success(self);
                }
            } failure:failure];
}

+ (NSArray *)usersWithRole:(NSString *)role
              fromRawUsers:(NSArray *)rawUsers {
    NSMutableArray *users = [NSMutableArray array];
    for (NSDictionary *rawUser in rawUsers) {
        if ([rawUser[@"role"] isEqualToString:role]) {
            [users addObject:[MDLProfile profileWithIdentifier:rawUser[@"profile_id"]]];
        }
    }

    return users;
}

- (void)fetchPeopleWithClient:(MDLMendeleyAPIClient *)client
                       atPage:(NSString *)pagePath
                numberOfItems:(NSUInteger)numberOfItems
                      success:(void (^)(MDLResponseInfo *info, MDLGroup *))success
                      failure:(void (^)(NSError *))failure {
    NSString *path = [[@"/groups"
                       stringByAppendingPathComponent:self.identifier]
                      stringByAppendingPathComponent:@"members"];

    [client getPath:path
         objectType:MDLMendeleyObjectTypeUserRole
             atPage:nil
      numberOfItems:0
         parameters:nil
            success:^(MDLResponseInfo *info, NSArray *responseObject) {
                self.admins    = [MDLGroup usersWithRole:@"admin"    fromRawUsers:responseObject];
                self.members   = [MDLGroup usersWithRole:@"normal"   fromRawUsers:responseObject];
                self.followers = [MDLGroup usersWithRole:@"follower" fromRawUsers:responseObject];
                if (!self.owner) {
                    self.owner = [MDLGroup usersWithRole:@"owner" fromRawUsers:responseObject].firstObject;
                }

                if (success) {
                    success(info, self);
                }
            } failure:failure];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ (identifier: %@; name: %@; access level: %tu)",
            [super description], self.identifier, self.name, self.accessLevel];
}

@end
