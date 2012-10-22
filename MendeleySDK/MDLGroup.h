//
// MDLGroup.h
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
 Creates a `MDLGroup` and initializes its identifier, name, owner, and category properties.
 
 @param identifier The identifier of the group.
 @param name The name of the group.
 @param ownerName The owner of the group.
 @param category The category of the group.
 
 @return  The newly-initialized group.
 */
+ (MDLGroup *)groupWithIdentifier:(NSString *)identifier name:(NSString *)name ownerName:(NSString *)ownerName category:(MDLCategory *)category;

/**
 Sends a public group overview API request using the shared client and fetches the response as an array of `MDLGroup`.
 
 @param categoryIdentifier The identifier of the category.
 @param pageIndex The page index. `O` is first page.
 @param count The number of items returned per page. Maximum is `1000`.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `MDLGroup` objects.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Search Public Groups](http://apidocs.mendeley.com/home/public-resources/search-public-groups)
 */
+ (void)topGroupsInPublicLibraryForCategory:(NSString *)categoryIdentifier atPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

/**
 Sends a public groups details API request for the current document using the shared client.
 
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the current group with its newly assigned details.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Public Groups Details](http://apidocs.mendeley.com/home/public-resources/public-groups-details)
 */
- (void)fetchDetailsSuccess:(void (^)(MDLGroup *))success failure:(void (^)(NSError *))failure;

/**
 Sends a public groups people API request for the current document using the shared client.
 
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the current group with its newly assigned people.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Public Groups People](http://apidocs.mendeley.com/home/public-resources/public-groups-people)
 */
- (void)fetchPeopleSuccess:(void (^)(MDLGroup *))success failure:(void (^)(NSError *))failure;

@end
