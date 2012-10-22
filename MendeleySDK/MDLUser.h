//
// MDLUser.h
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

#import <Foundation/Foundation.h>

@class MDLCategory;

/**
 `MDLUser` represents a user, as described by Mendeley.
 */

@interface MDLUser : NSObject

/**
 The user name.
 */
@property (copy, nonatomic) NSString *name;

/**
 The user academic status.
 */
@property (copy, nonatomic) NSString *academicStatus;

/**
 The user academic status identifier.
 */
@property (copy, nonatomic) NSString *academicStatusIdentifier;

/**
 The user bio.
 */
@property (copy, nonatomic) NSString *bio;

/**
 The user category.
 */
@property (strong, nonatomic) MDLCategory *category;

/**
 The user location.
 */
@property (copy, nonatomic) NSString *location;

/**
 The user pohoto URL.
 */
@property (strong, nonatomic) NSURL *photoURL;

/**
 The user identifier, as generated by Mendeley.
 */
@property (copy, nonatomic) NSString *identifier;

/**
 The user research interests.
 */
@property (copy, nonatomic) NSString *researchInterests;

/**
 The user Mendeley URL.
 */
@property (strong, nonatomic) NSURL *mendeleyURL;

/**
 Creates a `MDLUser` and initializes its identifier and name properties.
 
 @param identifier The identifier of the user.
 @param name The name of the user.
 
 @return  The newly-initialized user.
 */
+ (MDLUser *)userWithIdentifier:(NSString *)identifier name:(NSString *)name;

/**
 Sends a profile information API request using the shared client and fetches the response as a `MDLUser`.
 
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: a `MDLUser` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Profile Information](http://apidocs.mendeley.com/home/user-specific-methods/profile-information)
 */
+ (void)fetchMyUserProfileSuccess:(void (^)(MDLUser *))success failure:(void (^)(NSError *))failure;

/**
 Sends a profile information API request using the shared client and fetches the response as a `MDLUser`.
 
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: a `MDLUser` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Profile Information](http://apidocs.mendeley.com/home/user-specific-methods/profile-information)
 */
- (void)fetchProfileSuccess:(void (^)(MDLUser *))success failure:(void (^)(NSError *))failure;

@end
