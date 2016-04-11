//
// MDLGroup.h
//
// Copyright (c) 2012-2016 shazino (shazino SAS), http://www.shazino.com/
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

typedef NS_ENUM(NSUInteger, MDLGroupAccessLevel) {
    MDLGroupAccessLevelPrivate,
    MDLGroupAccessLevelInvite,
    MDLGroupAccessLevelOpen
};


@class MDLMendeleyAPIClient, MDLResponseInfo, MDLCategory, MDLProfile, MDLDocument;

/**
 `MDLGroup` represents a group, as described by Mendeley.
 */

@interface MDLGroup : MDLMendeleyAPIObject

/**
 The group Mendeley URL.
 */
@property (nonatomic, copy, nullable) NSURL *mendeleyURL;

/**
 The group owner.
 */
@property (nonatomic, strong, nullable) MDLProfile *owner;

/**
 The group type (can be ‘private’, ‘invite’, or ‘open’)
 */
@property (nonatomic, assign) MDLGroupAccessLevel accessLevel;

/**
 The group name.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 The group description.
 */
@property (nonatomic, copy, nullable) NSString *groupDescription;

/**
 The group URL.
 */
@property (nonatomic, copy, nullable) NSURL *webPage;

/**
 The group disciplines.
 */
@property (nonatomic, strong, nullable) NSArray <NSString *> *disciplines;

/**
 The group tags.
 */
@property (nonatomic, strong, nullable) NSArray <NSString *> *tags;

/**
 The group documents.
 */
@property (nonatomic, strong, nullable) NSArray <MDLDocument *> *documents;

/**
 The group admins.
 */
@property (nonatomic, strong, nullable) NSArray <MDLProfile *> *admins;

/**
 The group members.
 */
@property (nonatomic, strong, nullable) NSArray <MDLProfile *> *members;

/**
 The group followers.
 */
@property (nonatomic, strong, nullable) NSArray <MDLProfile *> *followers;

/**
 Role of the authenticated user in the group.
 - `owner`: the creator of the group.
 - `admin`: administrator of the group.
    Only owners and admins can make other members administrators.
 - `normal`: normal member of the group.
    Users can add new references, add files and start discussions in the newsfeed of the group.
 - `follower`: followers of the group.
    Only public groups can have followers.
    Followers cannot interact with other members, i.e. post in newsfeed and participate in discussions, nor add references to the group.
    This is a read-only access membership.
 - `invited`: person who has been invited to the group, but not accepted the invitation.
    This is a read-only access membership.
 */
@property (nonatomic, copy, nullable) NSString *role;


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
+ (void)fetchGroupsForCurrentUserWithClient:(nonnull MDLMendeleyAPIClient *)client
                                     atPage:(nullable NSString *)pagePath
                              numberOfItems:(NSUInteger)numberOfItems
                                    success:(nullable void (^)(MDLResponseInfo * __nonnull, NSArray * __nonnull))success
                                    failure:(nullable void (^)(NSError * __nullable))failure;

/**
 Fetches information for the receiver group.

 @param client The API client performing the request.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the current group with its newly assigned details.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchDetailsWithClient:(nonnull MDLMendeleyAPIClient *)client
                       success:(nullable void (^)(MDLGroup * __nonnull))success
                       failure:(nullable void (^)(NSError * __nullable))failure;

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
- (void)fetchPeopleWithClient:(nonnull MDLMendeleyAPIClient *)client
                       atPage:(nullable NSString *)pagePath
                numberOfItems:(NSUInteger)numberOfItems
                      success:(nullable void (^)(MDLResponseInfo * __nonnull, MDLGroup * __nonnull))success
                      failure:(nullable void (^)(NSError * __nullable))failure;

@end
