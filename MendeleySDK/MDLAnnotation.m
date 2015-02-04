//
// MDLAnnotation.m
//
// Copyright (c) 2015 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLAnnotation.h"

#import "MDLMendeleyAPIClient.h"
#import "MDLDocument.h"
#import "MDLGroup.h"

@implementation MDLAnnotation

+ (NSString *)objectType {
    return MDLMendeleyObjectTypeAnnotation;
}

+ (NSString *)path {
    return @"/annotations";
}

- (void)updateWithServerResponseObject:(id)responseObject {
    [super updateWithServerResponseObject:responseObject];

    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return;
    }

    NSDictionary *colorRGB = responseObject[@"color"];
    if ([colorRGB isKindOfClass:NSDictionary.class]) {
        self.colorRGB = colorRGB;
    }

    self.text       = responseObject[@"text"];

    NSArray *positions = responseObject[@"positions"];
    if ([positions isKindOfClass:NSArray.class]) {
        self.positions = positions;
    }

    self.privacyLevel       = responseObject[@"privacy_level"];
    self.documentIdentifier = responseObject[@"document_id"];
    self.profileIdentifier  = responseObject[@"profile_id"];
    self.fileHash           = responseObject[@"filehash"];
    self.creationDateString = responseObject[@"created"];
    self.modificationDateString = responseObject[@"last_modified"];
}

- (NSDictionary *)serverRepresentation {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

    if (self.text) {
        attributes[@"text"] = self.text;
    }
    if (self.privacyLevel) {
        attributes[@"privacy_level"] = self.privacyLevel;
    }
    if (self.documentIdentifier) {
        attributes[@"document_id"] = self.documentIdentifier;
    }

    return attributes;
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ (identifier: %@; text: %@)",
            [super description], self.identifier, self.text];
}


#pragma mark - 

+ (void)fetchAnnotationsWithClient:(MDLMendeleyAPIClient *)client
                       forDocument:(MDLDocument *)document
                          forGroup:(MDLGroup *)group
                            atPage:(NSString *)pagePath
                     numberOfItems:(NSUInteger)numberOfItems
                           success:(void (^)(MDLResponseInfo *info, NSArray *annotations))success
                           failure:(void (^)(NSError *))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (document.identifier) {
        parameters[@"document_id"] = document.identifier;
    }
    else if (group.identifier) {
        parameters[@"group_id"] = group.identifier;
    }

    [self fetchWithClient:client
                   atPage:pagePath
            numberOfItems:numberOfItems
               parameters:parameters
                  success:success
                  failure:failure];
}

@end
