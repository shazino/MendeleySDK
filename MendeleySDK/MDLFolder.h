//
// MDLFolder.h
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

@class MDLMendeleyAPIClient, MDLResponseInfo, MDLDocument;

/**
 `MDLFolder` represents a folder, as described by Mendeley.
 */

@interface MDLFolder : MDLObject

/**
 The folder name.
 */
@property (copy, nonatomic) NSString *name;

/**
 The folder parent identifier.
 */
@property (copy, nonatomic) NSString *parentIdentifier;

@property (nonatomic, copy) NSString *creationDateString;

@property (nonatomic, copy) NSString *modificationDateString;

/**
 Creates a `MDLFolder`.
 
 @param client The API client performing the request.
 @param name The name of the folder.
 @param parent The parent folder. If parent = `nil`, the folder is created at the root level.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the created `MDLFolder` with its newly assigned folder identifier.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return  The newly-initialized folder, with folder identifier = `nil`.
 */
+ (instancetype)createFolderWithClient:(MDLMendeleyAPIClient *)client
                                  name:(NSString *)name
                                parent:(MDLFolder *)parent
                               success:(void (^)(MDLObject *))success
                               failure:(void (^)(NSError *))failure;

/**
 Fetches the documents in the receiver folder.

 @param client The API client performing the request.
 @param pagePath The page path (optional).
 @param numberOfItems The number of items to fetch (default if equals to `0`).
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes five arguments: an array of `MDLDocument` objects, the total number of results, the total number of pages, the index of the current page, and the number of items per page.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchDocumentsWithClient:(MDLMendeleyAPIClient *)client
                          atPage:(NSString *)pagePath
                   numberOfItems:(NSUInteger)numberOfItems
                         success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                         failure:(void (^)(NSError *))failure;

/**
 Adds a document to the receiver folder.

 @param document A `MDLDocmuent` to add to the current folder.
 @param client The API client performing the request.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)addDocument:(MDLDocument *)document
         withClient:(MDLMendeleyAPIClient *)client
            success:(void (^)())success
            failure:(void (^)(NSError *))failure;

/**
 Sends a delete document from folder API request using the shared client.

 @param document The document to remove.
 @param client The API client performing the request.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)removeDocument:(MDLDocument *)document
            withClient:(MDLMendeleyAPIClient *)client
               success:(void (^)())success
               failure:(void (^)(NSError *))failure;

@end
