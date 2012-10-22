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
#import "MDLPublication.h"
#import "MDLDocumentSearchResultsViewController.h"

@interface MDLDocumentDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorsLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicationLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextView *abstractTextView;
@property (weak, nonatomic) IBOutlet UIButton *mendeleyURLButton;

- (void)updateOutletsWithDocument:(MDLDocument *)document;
- (IBAction)openMendeleyURL:(id)sender;

@end

@implementation MDLDocumentDetailsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateOutletsWithDocument:nil];
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
    self.publicationLabel.text = (document.publication || document.year) ? [NSString stringWithFormat:@"%@ (%@)", document.publication.name, [document.year stringValue]] : @"";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MDLDocumentSearchResultsViewController class]])
    {
        MDLDocumentSearchResultsViewController *resultsViewController = (MDLDocumentSearchResultsViewController *)segue.destinationViewController;
        resultsViewController.relatedToDocument = self.document;
    }
}

#pragma mark - Actions

- (IBAction)openMendeleyURL:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.document.mendeleyURL];
}

@end
