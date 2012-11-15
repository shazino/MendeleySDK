//
// MDLFile.h
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
 `MDLFile` represents a document’s file, as described by Mendeley.
 */

@interface MDLFile : NSObject

/**
 The file added date.
 */
@property (strong, nonatomic) NSDate *dateAdded;

/**
 The file extension.
 */
@property (copy, nonatomic) NSString *extension;

/**
 The file hash.
 */
@property (copy, nonatomic) NSString *hash;

/**
 The file size.
 */
@property (strong, nonatomic) NSNumber *size;

/**
 The file document.
 */
@property (weak, nonatomic) MDLDocument *document;

/**
 Creates a `MDLFile` and initializes its date added, extension, hash, and size properties.
 
 @param dateAdded The date added of the file.
 @param extension The extension of the file.
 @param hash The hash of the file.
 @param size The size of the file.
 @param document The document of the file.
 
 @return  The newly-initialized file.
 */
+ (MDLFile *)fileWithDateAdded:(NSDate *)dateAdded extension:(NSString *)extension hash:(NSString *)hash size:(NSNumber *)size document:(MDLDocument *)document;

/**
 Sends a download file API request using the shared client.
 
 @param path The path to the file to download to.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @see [API documentation: Download file](http://apidocs.mendeley.com/home/user-specific-methods/download-file)
 */
- (void)downloadToFileAtPath:(NSString *)path success:(void (^)())success failure:(void (^)(NSError *))failure;

@end
