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
#import "MDLMendeleyAPIClient.h"

@interface MDLGroup ()

- (void)updateWithRawGroup:(NSDictionary *)rawGroup;

@end

@implementation MDLGroup

+ (MDLGroup *)groupWithIdentifier:(NSString *)identifier name:(NSString *)name ownerName:(NSString *)ownerName category:(MDLCategory *)category
{
    MDLGroup *group = [MDLGroup new];
    group.identifier = identifier;
    group.name      = name;
    group.owner     = [MDLUser userWithIdentifier:nil name:ownerName];
    group.category  = category;
    return group;
}

+ (void)topGroupsInPublicLibraryForCategory:(NSString *)categoryIdentifier atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure
{
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (categoryIdentifier)
        parameters[@"cat"] = categoryIdentifier;
    parameters[@"page"] = @(pageIndex);
    parameters[@"items"] = @(count);
    
    [client getPublicPath:@"/oapi/documents/groups"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                      if (success)
                      {
                          NSMutableArray *groups = [NSMutableArray array];
                          NSArray *rawGroups = responseObject[@"groups"];
                          NSNumber *totalResults = responseObject[@"total_results"];
                          NSNumber *totalPages = responseObject[@"total_pages"];
                          NSNumber *pageIndex = responseObject[@"current_page"];
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

- (void)updateWithRawGroup:(NSDictionary *)rawGroup
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    
    self.identifier         = rawGroup[@"id"];
    self.name               = rawGroup[@"name"];
    if (!self.owner)
        self.owner = [MDLUser new];
    self.owner.name         = rawGroup[@"owner"];
    self.category           = [MDLCategory categoryWithIdentifier:rawGroup[@"disciplines"][@"id"] name:rawGroup[@"disciplines"][@"name"] slug:nil];
    self.mendeleyURL        = [NSURL URLWithString:rawGroup[@"public_url"]];
    self.numberOfDocuments  = rawGroup[@"total_documents"];
    self.numberOfAdmins     = [formatter numberFromString:rawGroup[@"people"][@"admins"]];
    self.numberOfMembers    = [formatter numberFromString:rawGroup[@"people"][@"members"]];
    self.numberOfFollowers  = [formatter numberFromString:rawGroup[@"people"][@"followers"]];
}

- (void)fetchDetailsSuccess:(void (^)(MDLGroup *))success failure:(void (^)(NSError *))failure
{
    if (!self.identifier)
    {
        failure([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        return;
    }
    
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    [client getPublicPath:[NSString stringWithFormat:@"/oapi/documents/groups/%@", self.identifier]
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
    if (!self.identifier)
    {
        failure([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        return;
    }
    
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    [client getPublicPath:[NSString stringWithFormat:@"/oapi/documents/groups/%@/people", self.identifier]
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                      NSArray *rawAdmins = responseObject[@"admins"];
                      NSMutableArray *admins = [NSMutableArray array];
                      [rawAdmins enumerateObjectsUsingBlock:^(NSDictionary *rawUser, NSUInteger idx, BOOL *stop) {
                          [admins addObject:[MDLUser userWithIdentifier:rawUser[@"user_id"] name:rawUser[@"name"]]];
                      }];
                      self.admins = admins;
                      
                      NSArray *rawMembers = responseObject[@"members"];
                      NSMutableArray *members = [NSMutableArray array];
                      [rawMembers enumerateObjectsUsingBlock:^(NSDictionary *rawUser, NSUInteger idx, BOOL *stop) {
                          [members addObject:[MDLUser userWithIdentifier:rawUser[@"user_id"] name:rawUser[@"name"]]];
                      }];
                      self.members = members;
                      
                      NSArray *rawFollowers = responseObject[@"followers"];
                      NSMutableArray *followers = [NSMutableArray array];
                      [rawFollowers enumerateObjectsUsingBlock:^(NSDictionary *rawUser, NSUInteger idx, BOOL *stop) {
                          [followers addObject:[MDLUser userWithIdentifier:rawUser[@"user_id"] name:rawUser[@"name"]]];
                      }];
                      self.followers = followers;
                      if (success)
                          success(self);
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (failure)
                          failure(error);
                  }];
}

@end
