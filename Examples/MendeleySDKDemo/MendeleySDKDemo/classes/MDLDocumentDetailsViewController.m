//
//  MDLDocumentDetailsViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 15/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLDocumentDetailsViewController.h"

#import "MDLDocument.h"
#import "MDLAuthor.h"
#import "MDLFile.h"
#import "MDLPublication.h"
#import "MDLDocumentSearchResultsViewController.h"
#import "MDLFilesViewController.h"

@interface MDLDocumentDetailsViewController ()

- (void)updateOutletsWithDocument:(MDLDocument *)document;
- (IBAction)openMendeleyURL:(id)sender;

@end

@implementation MDLDocumentDetailsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateOutletsWithDocument:self.document];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    [self updateOutletsWithDocument:self.document];
    
    [self.document fetchDetailsSuccess:^(MDLDocument *document) {
        [self updateOutletsWithDocument:document];
    } failure:^(NSError *error) {
        
    }];
}

- (void)updateOutletsWithDocument:(MDLDocument *)document
{
    if (!document)
        return;
    
    self.titleLabel.text = document.title;
    self.typeLabel.text = document.type;
    self.abstractTextView.text = document.abstract;
    
    NSMutableString *authors = [NSMutableString string];
    [document.authors enumerateObjectsUsingBlock:^(MDLAuthor *author, NSUInteger idx, BOOL *stop) {
        if (idx == 0)
            [authors appendString:@"By "];
        [authors appendString:author.name];
        if (idx < [document.authors count]-1)
            [authors appendString:@", "];
    }];
    self.authorsLabel.text = authors;
    self.publicationLabel.text = (document.publication || document.year) ? [NSString stringWithFormat:@"%@ (%@)", (document.publication) ? document.publication.name : @"?", (document.year) ? document.year : @"?"] : @"";
    self.relatedDocumentsButton.enabled = !document.isInUserLibrary;
    
    self.filesButton.enabled = ([document.files count] > 0);
    [self.filesButton setTitle:([document.files count] > 0) ? @"Files" : @"No Files" forState:UIControlStateNormal];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MDLDocumentSearchResultsViewController class]])
    {
        MDLDocumentSearchResultsViewController *resultsViewController = (MDLDocumentSearchResultsViewController *)segue.destinationViewController;
        resultsViewController.relatedToDocument = self.document;
    }
    else if ([segue.destinationViewController isKindOfClass:[MDLFilesViewController class]])
    {
        MDLFilesViewController *filesViewController = (MDLFilesViewController *)segue.destinationViewController;
        filesViewController.files = self.document.files;
    }
}

#pragma mark - Actions

- (IBAction)openMendeleyURL:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.document.mendeleyURL];
}

@end
