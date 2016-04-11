//
// MDLAnnotation.h
//
// Copyright (c) 2015-2016 shazino (shazino SAS), http://www.shazino.com/
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

@class MDLMendeleyAPIClient, MDLResponseInfo;
@class MDLDocument, MDLGroup;


/**
 `MDLAnnotation` represents an annotation, as described by Mendeley.
 */

@interface MDLAnnotation : MDLMendeleyAPIObject

/**
 RGB values.
 ```
 { "r": 255,
   "g": 255,
   "b": 0 }
 ```
 */
@property (nonatomic, copy, nullable) NSDictionary <NSString *, __kindof NSObject *> *colorRGB;

@property (nonatomic, copy, nullable) NSString *creationDateString;

/**
 Text value of the annotation.
 */
@property (nonatomic, copy, nullable) NSString *text;

/**
 Wrapper object contains page and coordinates of the annotation bounding box.
 ```
 [ { "top_left": {
       "x": 269.035,
       "y": 695.428 },
     "bottom_right": {
       "x": 269.035,
       "y": 695.428
     },
     "page": 1 }
 ]
 ```
 */
@property (nonatomic, copy, nullable) NSArray <NSDictionary *> *positions;

/**
 Public, group or private.
 */
@property (nonatomic, copy, nullable) NSString *privacyLevel;

/**
 UUID of the document which the file is attached to.
 */
@property (nonatomic, copy, nullable) NSString *documentIdentifier;

/**
 UUID of the user that created the annotation.
 */
@property (nonatomic, copy, nullable) NSString *profileIdentifier;

/**
 Filehash of which the annotation belongs to.
 */
@property (nonatomic, copy, nullable) NSString *fileHash;

@property (nonatomic, copy, nullable) NSString *modificationDateString;

+ (void)fetchAnnotationsWithClient:(nonnull MDLMendeleyAPIClient *)client
                       forDocument:(nonnull MDLDocument *)document
                          forGroup:(nullable MDLGroup *)group
                            atPage:(nullable NSString *)pagePath
                     numberOfItems:(NSUInteger)numberOfItems
                           success:(nullable void (^)(MDLResponseInfo * __nonnull info, NSArray * __nonnull annotations))success
                           failure:(nullable void (^)(NSError * __nullable))failure;

@end
