//
// MDLProfile.h
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

@import Foundation;

#import "MDLMendeleyAPIObject.h"

@class MDLMendeleyAPIClient, MDLDiscipline;

/**
 `MDLProfile` represents a user profile, as described by Mendeley.
 */

@interface MDLProfile : MDLMendeleyAPIObject

/**
 The profile name.
 */
@property (copy, nonatomic) NSString *firstName;

/**
 The profile name.
 */
@property (copy, nonatomic) NSString *lastName;

/**
 The profile location.
 */
@property (copy, nonatomic) NSString *location;

/**
 The profile name.
 */
@property (copy, nonatomic) NSString *displayName;

/**
 The profile email
 */
@property (copy, nonatomic) NSString *email;

/**
 The profile research interests.
 */
@property (copy, nonatomic) NSString *researchInterests;

/**
 The profile academic status.
 */
@property (copy, nonatomic) NSString *academicStatus;

/**
 The profile Mendeley URL.
 */
@property (strong, nonatomic) NSURL *mendeleyURL;

/**
 The current research discipline.
 */
@property (strong, nonatomic) MDLDiscipline *discipline;

/**
 The profile original photo URL.
 */
@property (strong, nonatomic) NSURL *photoOriginalURL;


/**
 Creates a `MDLProfile` and initializes its identifier property.

 @param identifier The identifier of the user.

 @return  The newly-initialized user.
 */
+ (instancetype)profileWithIdentifier:(NSString *)identifier;

/**
 Fetches the complete profile for the currently logged in user (“my profile”).

 @param client The API client performing the request.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: a `MDLProfile` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)fetchMyProfileWithClient:(MDLMendeleyAPIClient *)client
                         success:(void (^)(MDLMendeleyAPIObject *))success
                         failure:(void (^)(NSError *))failure;


@end
