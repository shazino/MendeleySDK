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


@implementation MDLProfile

+ (NSString *)objectType {
    return MDLMendeleyObjectTypeProfiles;
}

+ (NSString *)path {
    return @"/profiles";
}

- (void)updateWithServerResponseObject:(id)responseObject {
    [super updateWithServerResponseObject:responseObject];
    
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return;
    }

    self.identifier = responseObject[@"id"];
    self.firstName  = responseObject[@"first_name"];
    self.lastName   = responseObject[@"last_name"];

    NSDictionary *location = responseObject[@"location"];
    if ([location isKindOfClass:NSDictionary.class]) {
        self.location = location[@"name"];
    }

    self.displayName       = responseObject[@"display_name"];
    self.email             = responseObject[@"email"];
    self.researchInterests = responseObject[@"research_interests"];
    self.academicStatus    = responseObject[@"academic_status"];
    self.mendeleyURL       = [NSURL URLWithString:responseObject[@"link"]];

    NSDictionary *photos = responseObject[@"photo"];
    if ([photos isKindOfClass:NSDictionary.class]) {
        self.photoOriginalURL = [NSURL URLWithString:photos[@"original"]];
    }
}


#pragma mark -

+ (instancetype)profileWithIdentifier:(NSString *)identifier {
    MDLProfile *profile = [MDLProfile new];
    profile.identifier = identifier;
    return profile;
}

+ (void)fetchMyProfileWithClient:(MDLMendeleyAPIClient *)client
                         success:(void (^)(MDLObject *))success
                         failure:(void (^)(NSError *))failure {
    MDLProfile *me = [MDLProfile new];
    me.identifier = @"me";

    [me fetchWithClient:client
                success:success
                failure:failure];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ (identifier: %@; display name: %@)",
            [super description], self.identifier, self.displayName];
}

@end
