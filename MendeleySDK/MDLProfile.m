//
// MDLProfile.m
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

#import "MDLProfile.h"

#import "MDLMendeleyAPIClient.h"

@interface MDLProfile ()

- (void)updateWithProfileAttributes:(NSDictionary *)attributes;
+ (void)fetchUserProfileWithClient:(MDLMendeleyAPIClient *)client
                           forUser:(MDLProfile *)user
                    withIdentifier:(NSString *)identifier
                           success:(void (^)(MDLProfile *))success
                           failure:(void (^)(NSError *))failure;

@end

@implementation MDLProfile

- (void)updateWithProfileAttributes:(NSDictionary *)attributes {
    self.identifier = attributes[@"id"];
    self.firstName  = attributes[@"first_name"];
    self.lastName   = attributes[@"last_name"];

    NSDictionary *location = attributes[@"location"];
    if ([location isKindOfClass:NSDictionary.class]) {
        self.location = location[@"name"];
    }

    self.displayName = attributes[@"display_name"];
    self.email = attributes[@"email"];
    self.researchInterests = attributes[@"research_interests"];
    self.academicStatus = attributes[@"academic_status"];
    self.mendeleyURL = [NSURL URLWithString:attributes[@"link"]];

    NSDictionary *photos = attributes[@"photo"];
    if ([photos isKindOfClass:NSDictionary.class]) {
        self.photoOriginalURL = [NSURL URLWithString:photos[@"original"]];
    }
}

+ (instancetype)profileWithIdentifier:(NSString *)identifier {
    MDLProfile *profile = [MDLProfile new];
    profile.identifier = identifier;
    return profile;
}

+ (void)fetchUserProfileWithClient:(MDLMendeleyAPIClient *)client
                           forUser:(MDLProfile *)user
                    withIdentifier:(NSString *)identifier
                           success:(void (^)(MDLProfile *))success
                           failure:(void (^)(NSError *))failure {
    [client getPath:[@"/profiles" stringByAppendingPathComponent:identifier]
         objectType:MDLMendeleyObjectTypeProfiles
             atPage:nil
      numberOfItems:0
         parameters:nil
            success:^(MDLResponseInfo *info, NSDictionary *responseDictionary) {
                [user updateWithProfileAttributes:responseDictionary];
                if (success) {
                    success(user);
                }
            } failure:failure];
}

+ (void)fetchMyProfileWithClient:(MDLMendeleyAPIClient *)client
                         success:(void (^)(MDLProfile *))success
                         failure:(void (^)(NSError *))failure {
    [self fetchUserProfileWithClient:client
                             forUser:[MDLProfile new]
                      withIdentifier:@"me"
                             success:success
                             failure:failure];
}

- (void)fetchProfileWithClient:(MDLMendeleyAPIClient *)client
                       success:(void (^)(MDLProfile *))success
                       failure:(void (^)(NSError *))failure {
    [MDLProfile fetchUserProfileWithClient:client
                                   forUser:self
                            withIdentifier:self.identifier
                                   success:success
                                   failure:failure];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ (identifier: %@; display name: %@)",
            [super description], self.identifier, self.displayName];
}

@end
