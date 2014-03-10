//
// MDLTag.h
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

/**
 `MDLTag` represents a category tag, as described by Mendeley.
 */

@interface MDLTag : NSObject

/**
 The tag name.
 */
@property (copy, nonatomic) NSString *name;

/**
 The tag count.
 */
@property (copy, nonatomic) NSNumber *count;

/**
 Creates a `MDLTag` and initializes its name and count properties.
 
 @param name The name of the tag.
 @param count The count of the tag.
 
 @return  The newly-initialized tag.
 */
+ (MDLTag *)tagWithName:(NSString *)name
                  count:(NSNumber *)count;

/**
 Sends a last tags API request using the shared client and fetches the response as an array of `MDLTag`.
 
 @param categoryIdentifier The identifier of the category. This value must not be nil.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `MDLTag` objects.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Stats Tags](http://apidocs.mendeley.com/home/public-resources/stats-tags)
 */
+ (void)fetchLastTagsInPublicLibraryForCategory:(NSString *)categoryIdentifier
                                        success:(void (^)(NSArray *))success
                                        failure:(void (^)(NSError *))failure;

/**
 Sends a user last tags API request using the shared client and fetches the response as an array of `MDLTag`.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `MDLTag` objects.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: User Tags Stats](http://apidocs.mendeley.com/home/user-specific-methods/user-tags-stats)
 */
+ (void)fetchLastTagsInUserLibrarySuccess:(void (^)(NSArray *))success
                                  failure:(void (^)(NSError *))failure;

@end
