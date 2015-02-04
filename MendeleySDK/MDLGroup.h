//
// MDLGroup.h
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

#import "MDLObject.h"

typedef NS_ENUM(NSUInteger, MDLGroupAccessLevel) {
    MDLGroupAccessLevelPrivate,
    MDLGroupAccessLevelInvite,
    MDLGroupAccessLevelOpen
};


@class MDLMendeleyAPIClient, MDLResponseInfo, MDLCategory, MDLProfile;

/**
 `MDLGroup` represents a group, as described by Mendeley.
 */

@interface MDLGroup : MDLObject

/**
 The group Mendeley URL.
 */
@property (strong, nonatomic) NSURL *mendeleyURL;

/**
 The group owner.
 */
@property (strong, nonatomic) MDLProfile *owner;

/**
 The group type (can be ‘private’, ‘invite’, or ‘open’)
 */
@property (nonatomic, assign) MDLGroupAccessLevel accessLevel;

/**
 The group name.
 */
@property (copy, nonatomic) NSString *name;

/**
 The group description.
 */
@property (copy, nonatomic) NSString *groupDescription;

/**
 The group URL.
 */
@property (strong, nonatomic) NSURL *webPage;

/**
 The group disciplines.
 */
@property (copy, nonatomic) NSArray *disciplines;

/**
 The group tags.
 */
@property (copy, nonatomic) NSArray *tags;

/**
 The group documents.
 */
@property (strong, nonatomic) NSArray *documents;

/**
 The group admins.
 */
@property (strong, nonatomic) NSArray *admins;

/**
 The group members.
 */
@property (strong, nonatomic) NSArray *members;

/**
 The group followers.
 */
@property (strong, nonatomic) NSArray *followers;


/**
 Fetches the groups the current user belongs to.

 @param client The API client performing the request.
 @param pagePath The page path (optional).
 @param numberOfItems The number of items to fetch (default if equals to `0`).
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `MDLGroup` objects.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)fetchGroupsForCurrentUserWithClient:(MDLMendeleyAPIClient *)client
                                     atPage:(NSString *)pagePath
                              numberOfItems:(NSUInteger)numberOfItems
                                    success:(void (^)(MDLResponseInfo *info, NSArray *))success
                                    failure:(void (^)(NSError *))failure;

/**
 Fetches information for the receiver group.

 @param client The API client performing the request.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the current group with its newly assigned details.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchDetailsWithClient:(MDLMendeleyAPIClient *)client
                       success:(void (^)(MDLGroup *))success
                       failure:(void (^)(NSError *))failure;

/**
 Fetches the members for the receiver group.

 @param client The API client performing the request.
 @param pagePath The page path (optional).
 @param numberOfItems The number of items to fetch (default if equals to `0`).
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the current group with its newly assigned people.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchPeopleWithClient:(MDLMendeleyAPIClient *)client
                       atPage:(NSString *)pagePath
                numberOfItems:(NSUInteger)numberOfItems
                      success:(void (^)(MDLResponseInfo *info, MDLGroup *))success
                      failure:(void (^)(NSError *))failure;

@end
