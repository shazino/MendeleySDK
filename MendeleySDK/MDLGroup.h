//
// MDLGroup.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MDLGroupType)
{
    MDLGroupTypePrivate,
    MDLGroupTypeInvite,
    MDLGroupTypeOpen
};

@class MDLCategory, MDLUser;

/**
 `MDLGroup` represents a group, as described by Mendeley.
 */

@interface MDLGroup : NSObject

/**
 The group identifier.
 */
@property (copy, nonatomic) NSString *identifier;

/**
 The group name.
 */
@property (copy, nonatomic) NSString *name;

/**
 The group owner.
 */
@property (strong, nonatomic) MDLUser *owner;

/**
 The group category.
 */
@property (strong, nonatomic) MDLCategory *category;

/**
 The group Mendeley URL.
 */
@property (strong, nonatomic) NSURL *mendeleyURL;

/**
 The group number of documents.
 */
@property (strong, nonatomic) NSNumber *numberOfDocuments;

/**
 The group documents.
 */
@property (strong, nonatomic) NSArray *documents;

/**
 The group number of admins.
 */
@property (strong, nonatomic) NSNumber *numberOfAdmins;

/**
 The group admins.
 */
@property (strong, nonatomic) NSArray *admins;

/**
 The group number of members.
 */
@property (strong, nonatomic) NSNumber *numberOfMembers;

/**
 The group members.
 */
@property (strong, nonatomic) NSArray *members;

/**
 The group number of followers.
 */
@property (strong, nonatomic) NSNumber *numberOfFollowers;

/**
 The group followers.
 */
@property (strong, nonatomic) NSArray *followers;

/**
 The group type (can be ‘private’, ‘invite’, or ‘open’)
 */
@property (nonatomic, assign) MDLGroupType type;

/**
 Creates a `MDLGroup` and sends an API creation request using the shared client.
 
 @param name The name of the group.
 @param type The type of the group.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the created `MDLGroup` with its newly assigned group identifier.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return  The newly-initialized group, with group identifier = `nil`.
 
 @see [API documentation: User Library Create Document](http://apidocs.mendeley.com/home/user-specific-methods/user-library-create-document)
 */
+ (instancetype)createGroupWithName:(NSString *)name
                               type:(MDLGroupType)type
                            success:(void (^)(MDLGroup *))success
                            failure:(void (^)(NSError *))failure;

/**
 Sends a public group overview API request using the shared client and fetches the response as an array of `MDLGroup`.
 
 @param categoryIdentifier The identifier of the category.
 @param pageIndex The page index. `O` is first page.
 @param count The number of items returned per page. Maximum is `1000`.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes five arguments: an array of `MDLGroup` objects, the total number of results, the total number of pages, the index of the current page, and the number of items per page.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Search Public Groups](http://apidocs.mendeley.com/home/public-resources/search-public-groups)
 */
+ (void)fetchTopGroupsInPublicLibraryForCategory:(NSString *)categoryIdentifier
                                          atPage:(NSUInteger)pageIndex
                                           count:(NSUInteger)count
                                         success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success
                                         failure:(void (^)(NSError *))failure;

/**
 Sends a user library groups API request using the shared client and fetches the response as an array of `MDLGroup`.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `MDLGroup` objects.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: User Library Groups](http://apidocs.mendeley.com/home/user-specific-methods/user-library-groups)
 */
+ (void)fetchGroupsInUserLibrarySuccess:(void (^)(NSArray *))success
                                failure:(void (^)(NSError *))failure;

/**
 Sends a public groups details API request for the current document using the shared client.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the current group with its newly assigned details.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Public Groups Details](http://apidocs.mendeley.com/home/public-resources/public-groups-details)
 */
- (void)fetchDetailsSuccess:(void (^)(MDLGroup *))success
                    failure:(void (^)(NSError *))failure;

/**
 Sends a groups people API request for the current document using the shared client.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the current group with its newly assigned people.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Public Groups People](http://apidocs.mendeley.com/home/public-resources/public-groups-people)
 @see [API documentation: User Library Group People](http://apidocs.mendeley.com/home/user-specific-methods/user-library-group-people)
 */
- (void)fetchPeopleSuccess:(void (^)(MDLGroup *))success
                   failure:(void (^)(NSError *))failure;

/**
 Sends a groups documents API request for the current document using the shared client.
 
 @param pageIndex The page index. `O` is first page.
 @param count The number of items returned per page.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes five arguments: an array of `MDLDocument` objects, the total number of results, the total number of pages, the index of the current page, and the number of items per page.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Public Groups Documents](http://apidocs.mendeley.com/home/public-resources/public-groups-documents)
 @see [API documentation: User Library Group Documents](http://apidocs.mendeley.com/home/user-specific-methods/user-library-group-documents)
 */
- (void)fetchDocumentsAtPage:(NSUInteger)pageIndex
                       count:(NSUInteger)count
                     success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success
                     failure:(void (^)(NSError *))failure;

/**
 Sends a delete group API request using the shared client (you need to be a owner of the group).
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Delete Group](http://apidocs.mendeley.com/home/user-specific-methods/user-library-delete-group)
 */
- (void)deleteSuccess:(void (^)())success
              failure:(void (^)(NSError *))failure;

/**
 Sends a leave group API request using the shared client (you need to be an administrator or a member of the group).
 
 @param success A block object to be executed when the request operation finishes successfully.
  This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data.
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Delete Group](http://apidocs.mendeley.com/home/user-specific-methods/user-library-delete-group)
 */
- (void)leaveSuccess:(void (^)())success
             failure:(void (^)(NSError *))failure;

/**
 Sends a unfollow group API request using the shared client (you need to be a follower of the group).
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data.
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Delete Group](http://apidocs.mendeley.com/home/user-specific-methods/user-library-delete-group)
 */
- (void)unfollowSuccess:(void (^)())success
                failure:(void (^)(NSError *))failure;

@end
