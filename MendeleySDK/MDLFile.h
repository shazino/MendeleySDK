//
// MDLFile.h
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

@class MDLMendeleyAPIClient, MDLDocument, AFHTTPRequestOperation;

/**
 `MDLFile` represents a document’s file, as described by Mendeley.
 */

@interface MDLFile : NSObject

/**
 The file identifier.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 The file name.
 */
@property (nonatomic, copy) NSString *fileName;

/**
 The file MIME type.
 */
@property (nonatomic, copy) NSString *MIMEType;

/**
 The file hash.
 */
@property (nonatomic, copy) NSString *fileHash;

/**
 The file size (in bytes).
 */
@property (nonatomic, copy) NSNumber *sizeInBytes;


/**
 Downloads the file to a local destination.

 @param client The API client performing the request.
 @param path The path to the file to download to.
 @param progress A block object to be called when an undetermined number of bytes have been downloaded from the server. 
  This block has no return value and takes three arguments: the number of bytes read since the last time the download progress block was called, the total bytes read, and the total bytes expected to be read during the request, as initially determined by the expected content size of the `NSHTTPURLResponse` object. 
  This block may be called multiple times, and will execute on the main thread.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return A new HTTP request operation
 */
- (AFHTTPRequestOperation *)downloadWithClient:(MDLMendeleyAPIClient *)client
                                  toFileAtPath:(NSString *)path
                                      progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
                                       success:(void (^)())success
                                       failure:(void (^)(NSError *))failure;

@end
