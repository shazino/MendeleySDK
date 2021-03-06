//
// MDLPerson.h
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

/**
 `MDLPerson` represents a person, as described by Mendeley.
 */

@interface MDLPerson : NSObject

/**
 The author forename
 */
@property (nonatomic, copy, nullable) NSString *firstName;

/**
 The author surname
 */
@property (nonatomic, copy, nullable) NSString *lastName;


/**
 Creates a `MDLAuthor` and initializes its name, forename, and surname property.
 
 @param forename The forename of the author.
 @param surname The surname of the author.
 
 @return  The newly-initialized author.
 */
+ (nonnull instancetype)personWithFirstName:(nonnull NSString *)firstName
                                   lastName:(nonnull NSString *)lastName;

+ (nullable NSArray <MDLPerson *> *)personsFromServerResponseObject:(nonnull id)responseObject;

- (nonnull NSDictionary <NSString *, __kindof NSObject *> *)requestObject;

@end
