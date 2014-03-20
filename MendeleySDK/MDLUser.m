//
// MDLUser.m
//
// Copyright (c) 2012-2014 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLUser.h"
#import "MDLCategory.h"
#import "MDLMendeleyAPIClient.h"

@interface MDLUser ()

+ (void)fetchUserProfileForUser:(MDLUser *)user
                 withIdentifier:(NSString *)identifier
                        success:(void (^)(MDLUser *))success
                        failure:(void (^)(NSError *))failure;

@end

@implementation MDLUser

+ (instancetype)userWithIdentifier:(NSString *)identifier
                              name:(NSString *)name
{
    MDLUser *user = [MDLUser new];
    user.identifier = identifier;
    user.name       = name;
    return user;
}

+ (void)fetchUserProfileForUser:(MDLUser *)user
                 withIdentifier:(NSString *)identifier
                        success:(void (^)(MDLUser *))success
                        failure:(void (^)(NSError *))failure
{
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient sharedClient];
    NSString *path = [NSString stringWithFormat:@"/oapi/profiles/info/%@/",
                      identifier];

    [client getPath:path
requiresAuthentication:YES
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, NSDictionary *responseDictionary) {

                NSDictionary *profileMain = responseDictionary[@"main"];
                if ([profileMain isKindOfClass:[NSDictionary class]]) {
                    user.name              = profileMain[@"name"];
                    user.academicStatus    = profileMain[@"academic_status"];
                    user.academicStatusIdentifier = profileMain[@"academic_status_id"];
                    user.bio               = profileMain[@"bio"];
                    user.category          = [MDLCategory categoryWithIdentifier:profileMain[@"discipline_id"]
                                                                            name:profileMain[@"discipline_name"]
                                                                            slug:nil];
                    user.location          = profileMain[@"location"];
                    user.photoURL          = [NSURL URLWithString:profileMain[@"photo"]];
                    user.identifier        = profileMain[@"profile_id"];
                    user.researchInterests = profileMain[@"research_interests"];
                    user.mendeleyURL       = [NSURL URLWithString:profileMain[@"url"]];
                }

                NSDictionary *profileContact = responseDictionary[@"contact"];
                if ([profileContact isKindOfClass:[NSDictionary class]]) {
                    user.contactAddress = profileContact[@"address"];
                    user.contactEmail   = profileContact[@"email"];
                    user.contactFax     = profileContact[@"fax"];
                    user.contactMobile  = profileContact[@"mobile"];
                    user.contactPhone   = profileContact[@"phone"];
                    user.contactWebpage = profileContact[@"webpage"];
                    user.contactZIPCode = profileContact[@"zipcode"];
                }

                if (success) {
                    success(user);
                }
            } failure:failure];
}

+ (void)fetchMyUserProfileSuccess:(void (^)(MDLUser *))success
                          failure:(void (^)(NSError *))failure
{
    [self fetchUserProfileForUser:[MDLUser new]
                   withIdentifier:@"me"
                          success:success
                          failure:failure];
}

- (void)fetchProfileSuccess:(void (^)(MDLUser *))success
                    failure:(void (^)(NSError *))failure
{
    [MDLUser fetchUserProfileForUser:self
                      withIdentifier:self.identifier
                             success:success
                             failure:failure];
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"%@ (identifier: %@; name: %@)",
            [super description], self.identifier, self.name];
}

@end
