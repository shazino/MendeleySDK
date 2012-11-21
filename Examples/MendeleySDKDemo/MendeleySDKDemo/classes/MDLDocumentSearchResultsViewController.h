//
//  MDLDocumentSearchResultsViewController.h
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 11/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDLDocument, MDLGroup;

@interface MDLDocumentSearchResultsViewController : UITableViewController

@property (nonatomic, copy) NSString *searchGenericTerms;
@property (nonatomic, copy) NSString *searchAuthors;
@property (nonatomic, copy) NSString *searchTitle;
@property (nonatomic, copy) NSNumber *searchYear;
@property (nonatomic, copy) NSString *searchTags;
@property (nonatomic, weak) MDLDocument *relatedToDocument;
@property BOOL fetchUserLibrary;
@property BOOL fetchAuthoredDocuments;
@property (nonatomic, strong) MDLGroup *group;

@end
