//
// MDLAuthor.h
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

/**
 `MDLAuthor` represents a document’s author, as described by Mendeley.
 */

@interface MDLAuthor : NSObject

/**
 The author forename
 */
@property (copy, nonatomic) NSString *forename;

/**
 The author surname
 */
@property (copy, nonatomic) NSString *surname;

/**
 Creates a `MDLAuthor` and initializes its forename and surname properties.
 
 @param forename The forename of the author.
 @param surname The surname of the author.
 
 @return  The newly-initialized author.
 */
+ (MDLAuthor *)authorWithForename:(NSString *)forename surname:(NSString *)surname;

/**
 Sends a top authors API request using the shared client and fetches the response as an array of `MDLAuthor`.
 
 @param disciplineIdentifier If not `nil`, the identifier of the discipline, otherwise across all disciplines.
 @param upAndComing If true, results apply to ‘trending’ authors.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `MDLAuthor` objects.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)topAuthorsInPublicLibraryForDiscipline:(NSNumber *)disciplineIdentifier upAndComing:(BOOL)upAndComing success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

@end
