//
// MDLDocument.h
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

#import "MDLMendeleyAPIObject.h"

extern NSString * __nonnull const MDLDocumentTypeGeneric;
extern NSString * __nonnull const MDLDocumentTypeJournal;

extern NSString * __nonnull const MDLDocumentViewAll;
extern NSString * __nonnull const MDLDocumentViewBIB;
extern NSString * __nonnull const MDLDocumentViewClient;
extern NSString * __nonnull const MDLDocumentViewTags;
extern NSString * __nonnull const MDLDocumentViewPatent;

@class MDLGroup, MDLFile, MDLProfile, MDLPerson;
@class MDLMendeleyAPIClient, MDLResponseInfo;
@class AFHTTPRequestOperation;

/**
 `MDLDocument` represents a user’s document, as described by Mendeley.
 */

@interface MDLDocument : MDLMendeleyAPIObject

//*************************
// Core Document Attributes
//*************************

/**
 The title of the document.
 */
@property (nonatomic, copy, nullable) NSString *title;

/**
 The type of the document. This is `@"generic"` by default.
 */
@property (nonatomic, copy, nullable) NSString *type;

/**
 The user that added the document to the system.
 */
@property (nonatomic, strong, nullable) MDLProfile *user;

/**
 The group of the document, if it belongs to one.
 */
@property (nonatomic, strong, nullable) MDLGroup *group;

@property (nonatomic, copy, nullable) NSString *creationDateString;

@property (nonatomic, copy, nullable) NSString *modificationDateString;

/**
 The abstract of the document.
 */
@property (nonatomic, copy, nullable) NSString *abstract;

/**
 The publication outlet of the document.
 */
@property (nonatomic, strong, nullable) NSString *source;

/**
 The year of the document.
 */
@property (nonatomic, strong, nullable) NSNumber *year;

/**
 The authors of the document.
 */
@property (nonatomic, strong, nullable) NSArray <MDLPerson *> *authors;

/**
 The document identifiers.
 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *, NSString *> *identifiers;

/**
 The keywords of the document.
 */
@property (nonatomic, strong, nullable) NSArray <NSString *> *keywords;


//***************************
// Catalog Document Attribute
//***************************

/**
 This is a catalog document.
 */
@property (nonatomic, assign) BOOL isCatalogDocument;


//*******************************
// Additional Document Attributes
//*******************************

/**
 The publication month of the document.
 */
@property (nonatomic, copy, nullable) NSNumber *month;

/**
 The publication day of the document.
 */
@property (nonatomic, copy, nullable) NSNumber *day;

/**
 The revision of the document.
 */
@property (nonatomic, copy, nullable) NSString *revision;

/**
 The pages of the document.
 */
@property (nonatomic, copy, nullable) NSString *pages;

/**
 The volume of the document.
 */
@property (nonatomic, copy, nullable) NSString *volume;

/**
 The issue of the document.
 */
@property (nonatomic, copy, nullable) NSString *issue;

/**
 The websites of the document.
 */
@property (nonatomic, copy, nullable) NSArray <NSURL *> *websitesURLs;

/**
 The publisher of the document.
 */
@property (nonatomic, copy, nullable) NSString *publisher;

/**
 The city of the document.
 */
@property (nonatomic, copy, nullable) NSString *city;

/**
 The edition of the document.
 */
@property (nonatomic, copy, nullable) NSString *edition;

/**
 The institution of the document.
 */
@property (nonatomic, copy, nullable) NSString *institution;

/**
 The series of the document.
 */
@property (nonatomic, copy, nullable) NSString *series;

/**
 The chapter of the document.
 */
@property (nonatomic, copy, nullable) NSString *chapter;

/**
 The editors of the document.
 */
@property (nonatomic, strong, nullable) NSArray <MDLPerson *> *editors;

/**
 The tags of the document.
 */
@property (nonatomic, copy, nullable) NSArray <NSString *> *tags;

/**
 The read status of the document
 */
@property (nonatomic, copy, nullable) NSNumber *read;

/**
 The star status of the document
 */
@property (nonatomic, copy, nullable) NSNumber *starred;

/**
 The authored status of the document
 */
@property (nonatomic, copy, nullable) NSNumber *authored;

/**
 The confirmed status of the document
 */
@property (nonatomic, copy, nullable) NSNumber *confirmed;

/**
 The hidden status of the document
 */
@property (nonatomic, copy, nullable) NSNumber *hidden;

/**
 Whetever it has file(s) attached.
 */
@property (nonatomic, copy, nullable) NSNumber *fileAttached;

/**
 The citation key of the document.
 */
@property (nonatomic, copy, nullable) NSString *citationKey;

/**
 The source type of the document.
 */
@property (nonatomic, copy, nullable) NSString *sourceType;

/**
 The language of the document.
 */
@property (nonatomic, copy, nullable) NSString *language;

/**
 The short title of the document.
 */
@property (nonatomic, copy, nullable) NSString *shortTitle;

/**
 The reprint edition of the document.
 */
@property (nonatomic, copy, nullable) NSString *reprintEdition;

/**
 The genre of the document.
 */
@property (nonatomic, copy, nullable) NSString *genre;

/**
 The country of the document.
 */
@property (nonatomic, copy, nullable) NSString *country;

/**
 The translators of the document.
 */
@property (nonatomic, strong, nullable) NSArray <MDLPerson *> *translators;

/**
 The series editor of the document.
 */
@property (nonatomic, copy, nullable) NSString *seriesEditor;

/**
 The code of the document.
 */
@property (nonatomic, copy, nullable) NSString *code;

/**
 The medium of the document.
 */
@property (nonatomic, copy, nullable) NSString *medium;

/**
 The user context of the document.
 */
@property (nonatomic, copy, nullable) NSString *userContext;

/**
 The department of the document.
 */
@property (nonatomic, copy, nullable) NSString *department;

/**
 The patent owner of the document.
 */
@property (nonatomic, copy, nullable) NSString *patentOwner;

/**
 The patent application number of the document.
 */
@property (nonatomic, copy, nullable) NSString *patentApplicationNumber;

/**
 The patent legal status of the document.
 */
@property (nonatomic, copy, nullable) NSString *patentLegalStatus;


/**
 For catalog documents only.
 The Mendeley URL of the document.
 */
@property (nonatomic, strong, nullable) NSURL *mendeleyURL;


/**
 Sends an API search request with generic terms using the shared client.

 @param terms The terms for the search query
 @param pageIndex The page index. `O` is first page.
 @param count The number of items returned per page.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes five arguments: an array of `MDLDocument` objects for the match, the total number of results, the total number of pages, the index of the current page, and the number of items per page.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)searchWithClient:(nonnull MDLMendeleyAPIClient *)client
                   terms:(nonnull NSString *)terms
                    view:(nullable NSString *)view
                  atPage:(nullable NSString *)pagePath
           numberOfItems:(NSUInteger)numberOfItems
                 success:(nullable void (^)(MDLResponseInfo * __nonnull info, NSArray * __nonnull documents))success
                 failure:(nullable void (^)(NSError * __nullable))failure;

/**
 Sends an API search request with specific terms using the shared client.
 
 @param genericTerms The terms for the search query
 @param authors The authors for the search query
 @param title The title for the search query
 @param year The year for the search query
 @param tags The tags for the search query
 @param pageIndex The page index. `O` is first page.
 @param count The number of items returned per page.
 @param success A block object to be executed when the request operation finishes successfully.
  This block has no return value and takes five arguments: an array of `MDLDocument` objects for the match, the total number of results, the total number of pages, the index of the current page, and the number of items per page.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)searchWithClient:(nonnull MDLMendeleyAPIClient *)client
                 authors:(nullable NSString *)authors
                   title:(nullable NSString *)title
                    year:(nullable NSNumber *)year
                    view:(nullable NSString *)view
                  atPage:(nullable NSString *)pagePath
           numberOfItems:(NSUInteger)numberOfItems
                 success:(nullable void (^)(MDLResponseInfo * __nonnull info, NSArray * __nonnull documents))success
                 failure:(nullable void (^)(NSError * __nullable))failure;


/**
 Sends an API details request for the current document using the shared client.

 @param success A block object to be executed when the request operation finishes successfully.
 This block has no return value and takes one argument: the current document with its newly assigned details.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data.
 This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchWithClient:(nonnull MDLMendeleyAPIClient *)client
                   view:(nullable NSString *)view
                success:(nullable void (^)(MDLDocument * __nonnull))success
                failure:(nullable void (^)(NSError * __nullable))failure;


/**
 Sends an API upload request using the shared client.

 @param fileURL The local URL for the file to upload.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: a `MDLFile` for the newly-uploaded file.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return A new HTTP request operation
 */
- (nullable AFHTTPRequestOperation *)uploadFileWithClient:(nonnull MDLMendeleyAPIClient *)client
                                                    atURL:(nonnull NSURL *)fileURL
                                              contentType:(nonnull NSString *)contentType
                                                 fileName:(nonnull NSString *)fileName
                                                  success:(nullable void (^)(MDLFile * __nonnull newFile))success
                                                  failure:(nullable void (^)(NSError * __nullable))failure;

/**
 Sends an update document API request using the shared client.
 
 @param read The read status.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: a `MDLDocument` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)markAsRead:(BOOL)read
        withClient:(nonnull MDLMendeleyAPIClient *)client
           success:(nullable void (^)(MDLDocument * __nonnull))success
           failure:(nullable void (^)(NSError * __nullable))failure;

/**
 Sends an update document API request using the shared client.
 
 @param starred The starred status.
 @param success A block object to be executed when the request operation finishes successfully.
  This block has no return value and takes one argument: a `MDLDocument` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)markAsStarred:(BOOL)starred
           withClient:(nonnull MDLMendeleyAPIClient *)client
              success:(nullable void (^)(MDLDocument * __nonnull))success
              failure:(nullable void (^)(NSError * __nullable))failure;

/**
 Sends an update document API request using the shared client.

 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: a `MDLDocument` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)moveToTrashWithClient:(nonnull MDLMendeleyAPIClient *)client
                      success:(nullable void (^)(MDLDocument * __nonnull))success
                      failure:(nullable void (^)(NSError * __nullable))failure;

@end
