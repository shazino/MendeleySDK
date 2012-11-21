//
//  MDLDocumentSearchResultsViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 11/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLDocumentSearchResultsViewController.h"

#import "MDLDocument.h"
#import "MDLCategory.h"
#import "MDLGroup.h"
#import "MDLDocumentDetailsViewController.h"

@interface MDLDocumentSearchResultsViewController ()

@property (nonatomic, strong) NSArray *searchResults;

- (void)showAlertViewWithError:(NSError *)error;
- (IBAction)addDocument:(id)sender;
- (void)reloadUserLibrary;

@end

@implementation MDLDocumentSearchResultsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.fetchUserLibrary)
    {
        self.navigationItem.title = @"All Documents";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDocument:)];
    }
    else if (self.fetchAuthoredDocuments)
        self.navigationItem.title = @"My Publications";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    void (^errorHandler)(NSError*) = ^(NSError *error) { [self showAlertViewWithError:error]; };
    
    if (self.fetchUserLibrary)
    {
        [self reloadUserLibrary];
    }
    else if (self.fetchAuthoredDocuments)
    {
        [MDLDocument fetchAuthoredDocumentsInUserLibraryAtPage:0 count:20 success:^(NSArray *documents, NSUInteger totalResults, NSUInteger totalPages, NSUInteger pageIndex, NSUInteger itemsPerPage) {
            self.searchResults = documents;
            [self.tableView reloadData];
            for (MDLDocument *document in self.searchResults)
            {
                [document fetchDetailsSuccess:^(MDLDocument *document) {
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.searchResults indexOfObject:document] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                } failure:errorHandler];
            }
        } failure:errorHandler];
    }
    else if (self.relatedToDocument)
    {
        [self.relatedToDocument fetchRelatedDocumentsAtPage:0 count:20 success:^(NSArray *documents) {
            self.searchResults = documents;
            [self.tableView reloadData];
        } failure:errorHandler];
    }
    else if (self.group)
    {
        [self.group fetchDocumentsAtPage:0 count:20 success:^(NSArray *documents, NSUInteger totalResults, NSUInteger totalPages, NSUInteger pageIndex, NSUInteger itemsPerPage) {
            self.searchResults = documents;
            [self.tableView reloadData];
            
            for (MDLDocument *document in self.searchResults)
            {
                [document fetchDetailsSuccess:^(MDLDocument *document) {
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.searchResults indexOfObject:document] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                } failure:errorHandler];
            }
        } failure:errorHandler];
    }
    else
    {
        [MDLDocument searchWithGenericTerms:self.searchGenericTerms authors:self.searchAuthors title:self.searchTitle year:self.searchYear tags:self.searchTags atPage:0 count:20 success:^(NSArray *documents, NSUInteger totalResults, NSUInteger totalPages, NSUInteger pageIndex, NSUInteger itemsPerPage) {
            self.searchResults = documents;
            [self.tableView reloadData];
        } failure:errorHandler];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MDLDocumentDetailsViewController class]])
    {
        MDLDocumentDetailsViewController *detailsViewController = (MDLDocumentDetailsViewController *)segue.destinationViewController;
        detailsViewController.document = self.searchResults[self.tableView.indexPathForSelectedRow.row];
    }
}

- (void)showAlertViewWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLDocumentCell"];
    
    MDLDocument *document = self.searchResults[indexPath.row];
    cell.textLabel.text = (document.title) ? document.title : @"?";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"DOI: %@, ID: %@", (document.DOI) ? document.DOI : @"?", document.identifier];
    
    return cell;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.fetchUserLibrary;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        MDLDocument *document = self.searchResults[indexPath.row];
        [document deleteSuccess:^{
            [self reloadUserLibrary];
        } failure:^(NSError *error) { [self showAlertViewWithError:error]; }];
    }
}

#pragma mark - Actions

- (IBAction)addDocument:(id)sender
{
    [self performSegueWithIdentifier:@"MDLAddDocumentSegue" sender:sender];
}

- (void)reloadUserLibrary
{
    [MDLDocument fetchDocumentsInUserLibraryAtPage:0 count:20 success:^(NSArray *documents, NSUInteger totalResults, NSUInteger totalPages, NSUInteger pageIndex, NSUInteger itemsPerPage) {
        self.searchResults = documents;
        [self.tableView reloadData];
        for (MDLDocument *document in self.searchResults)
        {
            [document fetchDetailsSuccess:^(MDLDocument *document) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.searchResults indexOfObject:document] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            } failure:^(NSError *error) { [self showAlertViewWithError:error]; }];
        }
    } failure:^(NSError *error) { [self showAlertViewWithError:error]; }];
}

@end
