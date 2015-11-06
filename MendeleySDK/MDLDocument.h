//
// MDLDocument.h
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

#import "MDLMendeleyAPIObject.h"

extern NSString * const MDLDocumentTypeGeneric;
extern NSString * const MDLDocumentTypeJournal;

extern NSString * const MDLDocumentViewAll;
extern NSString * const MDLDocumentViewBIB;
extern NSString * const MDLDocumentViewClient;
extern NSString * const MDLDocumentViewTags;
extern NSString * const MDLDocumentViewPatent;

@class MDLGroup, MDLFile, MDLProfile;
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
@property (copy, nonatomic) NSString *title;

/**
 The type of the document. This is `@"generic"` by default.
 */
@property (copy, nonatomic) NSString *type;

/**
 The user that added the document to the system.
 */
@property (strong, nonatomic) MDLProfile *user;

/**
 The group of the document, if it belongs to one.
 */
@property (strong, nonatomic) MDLGroup *group;

@property (nonatomic, copy) NSString *creationDateString;

@property (nonatomic, copy) NSString *modificationDateString;

/**
 The abstract of the document.
 */
@property (copy, nonatomic) NSString *abstract;

/**
 The publication outlet of the document.
 */
@property (strong, nonatomic) NSString *source;

/**
 The year of the document.
 */
@property (strong, nonatomic) NSNumber *year;

/**
 The authors of the document (array of `MDLPerson`).
 */
@property (strong, nonatomic) NSArray *authors;

/**
 The document identifiers.
 */
@property (strong, nonatomic) NSDictionary *identifiers;

/**
 The keywords of the document.
 */
@property (strong, nonatomic) NSArray *keywords;


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
@property (copy, nonatomic) NSNumber *month;

/**
 The publication day of the document.
 */
@property (copy, nonatomic) NSNumber *day;

/**
 The revision of the document.
 */
@property (copy, nonatomic) NSString *revision;

/**
 The pages of the document.
 */
@property (copy, nonatomic) NSString *pages;

/**
 The volume of the document.
 */
@property (copy, nonatomic) NSString *volume;

/**
 The issue of the document.
 */
@property (copy, nonatomic) NSString *issue;

/**
 The websites of the document.
 */
@property (copy, nonatomic) NSArray *websitesURLs;

/**
 The publisher of the document.
 */
@property (copy, nonatomic) NSString *publisher;

/**
 The city of the document.
 */
@property (copy, nonatomic) NSString *city;

/**
 The edition of the document.
 */
@property (copy, nonatomic) NSString *edition;

/**
 The institution of the document.
 */
@property (copy, nonatomic) NSString *institution;

/**
 The series of the document.
 */
@property (copy, nonatomic) NSString *series;

/**
 The chapter of the document.
 */
@property (copy, nonatomic) NSString *chapter;

/**
 The editors of the document (array of `MDLPerson`).
 */
@property (copy, nonatomic) NSArray *editors;

/**
 The tags of the document.
 */
@property (copy, nonatomic) NSArray *tags;

/**
 The read status of the document
 */
@property (copy, nonatomic) NSNumber *read;

/**
 The star status of the document
 */
@property (copy, nonatomic) NSNumber *starred;

/**
 The authored status of the document
 */
@property (copy, nonatomic) NSNumber *authored;

/**
 The confirmed status of the document
 */
@property (copy, nonatomic) NSNumber *confirmed;

/**
 The hidden status of the document
 */
@property (copy, nonatomic) NSNumber *hidden;

/**
 Whetever it has file(s) attached.
 */
@property (copy, nonatomic) NSNumber *fileAttached;

/**
 The citation key of the document.
 */
@property (copy, nonatomic) NSString *citationKey;

/**
 The source type of the document.
 */
@property (copy, nonatomic) NSString *sourceType;

/**
 The language of the document.
 */
@property (copy, nonatomic) NSString *language;

/**
 The short title of the document.
 */
@property (copy, nonatomic) NSString *shortTitle;

/**
 The reprint edition of the document.
 */
@property (copy, nonatomic) NSString *reprintEdition;

/**
 The genre of the document.
 */
@property (copy, nonatomic) NSString *genre;

/**
 The country of the document.
 */
@property (copy, nonatomic) NSString *country;

/**
 The translators of the document (array of `MDLPerson`).
 */
@property (copy, nonatomic) NSArray *translators;

/**
 The series editor of the document.
 */
@property (copy, nonatomic) NSString *seriesEditor;

/**
 The code of the document.
 */
@property (copy, nonatomic) NSString *code;

/**
 The medium of the document.
 */
@property (copy, nonatomic) NSString *medium;

/**
 The user context of the document.
 */
@property (copy, nonatomic) NSString *userContext;

/**
 The department of the document.
 */
@property (copy, nonatomic) NSString *department;

/**
 The patent owner of the document.
 */
@property (copy, nonatomic) NSString *patentOwner;

/**
 The patent application number of the document.
 */
@property (copy, nonatomic) NSString *patentApplicationNumber;

/**
 The patent legal status of the document.
 */
@property (copy, nonatomic) NSString *patentLegalStatus;


/**
 For catalog documents only.
 The Mendeley URL of the document.
 */
@property (strong, nonatomic) NSURL *mendeleyURL;


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
+ (void)searchWithClient:(MDLMendeleyAPIClient *)client
                   terms:(NSString *)terms
                    view:(NSString *)view
                  atPage:(NSString *)pagePath
           numberOfItems:(NSUInteger)numberOfItems
                 success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                 failure:(void (^)(NSError *))failure;

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
+ (void)searchWithClient:(MDLMendeleyAPIClient *)client
                 authors:(NSString *)authors
                   title:(NSString *)title
                    year:(NSNumber *)year
                    view:(NSString *)view
                  atPage:(NSString *)pagePath
           numberOfItems:(NSUInteger)numberOfItems
                 success:(void (^)(MDLResponseInfo *info, NSArray *documents))success
                 failure:(void (^)(NSError *))failure;


/**
 Sends an API details request for the current document using the shared client.

 @param success A block object to be executed when the request operation finishes successfully.
 This block has no return value and takes one argument: the current document with its newly assigned details.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data.
 This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchWithClient:(MDLMendeleyAPIClient *)client
                   view:(NSString *)view
                success:(void (^)(MDLDocument *))success
                failure:(void (^)(NSError *))failure;


/**
 Sends an API upload request using the shared client.

 @param fileURL The local URL for the file to upload.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: a `MDLFile` for the newly-uploaded file.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 
 @return A new HTTP request operation
 */
- (AFHTTPRequestOperation *)uploadFileWithClient:(MDLMendeleyAPIClient *)client
                                           atURL:(NSURL *)fileURL
                                     contentType:(NSString *)contentType
                                        fileName:(NSString *)fileName
                                         success:(void (^)(MDLFile *newFile))success
                                         failure:(void (^)(NSError *))failure;

/**
 Sends an update document API request using the shared client.
 
 @param read The read status.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: a `MDLDocument` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)markAsRead:(BOOL)read
        withClient:(MDLMendeleyAPIClient *)client
           success:(void (^)(MDLDocument *))success
           failure:(void (^)(NSError *))failure;

/**
 Sends an update document API request using the shared client.
 
 @param starred The starred status.
 @param success A block object to be executed when the request operation finishes successfully.
  This block has no return value and takes one argument: a `MDLDocument` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)markAsStarred:(BOOL)starred
           withClient:(MDLMendeleyAPIClient *)client
              success:(void (^)(MDLDocument *))success
              failure:(void (^)(NSError *))failure;

/**
 Sends an update document API request using the shared client.

 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: a `MDLDocument` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)moveToTrashWithClient:(MDLMendeleyAPIClient *)client
                      success:(void (^)(MDLDocument *))success
                      failure:(void (^)(NSError *))failure;

@end
