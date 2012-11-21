//
// MDLFolder.h
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

@class MDLDocument;

/**
 `MDLFolder` represents a folder, as described by Mendeley.
 */

@interface MDLFolder : NSObject

/**
 The folder identifier.
 */
@property (copy, nonatomic) NSString *identifier;

/**
 The folder name.
 */
@property (copy, nonatomic) NSString *name;

/**
 The folder parent.
 */
@property (weak, nonatomic) MDLFolder *parent;

/**
 The folder parent identifier.
 */
@property (copy, nonatomic) NSString *parentIdentifier;

/**
 The folder subfolders.
 */
@property (strong, nonatomic) NSArray *subfolders;

/**
 The folder number of documents.
 */
@property (strong, nonatomic) NSNumber *numberOfDocmuents;

/**
 The folder documents.
 */
@property (strong, nonatomic) NSArray *documents;

/**
 Creates a `MDLFolder` and sends an API creation request using the shared client.
 
 @param name The name of the folder.
 @param parent The parent folder. If parent = `nil`, the folder is created at the root level.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the created `MDLFolder` with its newly assigned folder identifier.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return  The newly-initialized folder, with folder identifier = `nil`.
 
 @see [API documentation: Create Folder](http://apidocs.mendeley.com/user-library-create-folder)
 */
+ (MDLFolder *)createFolderWithName:(NSString *)name parent:(MDLFolder *)parent success:(void (^)(MDLFolder *))success failure:(void (^)(NSError *))failure;

/**
 Sends a folder API request using the shared client.
 
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `MDLFolder` objects.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Folders](http://apidocs.mendeley.com/home/user-specific-methods/user-library-folder)
 */
+ (void)fetchFoldersInUserLibrarySuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

/**
 Sends a folders documents API request for the current document using the shared client.
 
 @param pageIndex The page index. `O` is first page.
 @param count The number of items returned per page.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes five arguments: an array of `MDLDocument` objects, the total number of results, the total number of pages, the index of the current page, and the number of items per page.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: User Library Folder Documents](http://apidocs.mendeley.com/user-library-folder-documents)
 */
- (void)fetchDocumentsAtPage:(NSUInteger)pageIndex count:(NSUInteger)count success:(void (^)(NSArray *, NSUInteger, NSUInteger, NSUInteger, NSUInteger))success failure:(void (^)(NSError *))failure;

/**
 Sends a add document to folder API request using the shared client.
 
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: User Library Add document to folder](http://apidocs.mendeley.com/user-library-add-document-to-folder)
 */
- (void)addDocument:(MDLDocument *)document success:(void (^)())success failure:(void (^)(NSError *))failure;

/**
 Sends a delete folder API request using the shared client.
 
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Delete Folder](http://apidocs.mendeley.com/user-library-delete-folder)
 */
- (void)deleteSuccess:(void (^)())success failure:(void (^)(NSError *))failure;

/**
 Sends a delete document from folder API request using the shared client.
 
 @param document The document to remove.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Delete document from folder](http://apidocs.mendeley.com/user-library-delete-document-from-folder)
 */
- (void)removeDocument:(MDLDocument *)document success:(void (^)())success failure:(void (^)(NSError *))failure;

@end
