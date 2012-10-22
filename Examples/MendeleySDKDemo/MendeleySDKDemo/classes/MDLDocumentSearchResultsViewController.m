//
//  MDLDocumentSearchResultsViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 11/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLDocumentSearchResultsViewController.h"

#import "MDLDocument.h"
#import "MDLDocumentDetailsViewController.h"

@interface MDLDocumentSearchResultsViewController ()

@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation MDLDocumentSearchResultsViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.relatedToDocument)
    {
        [self.relatedToDocument fetchRelatedDocumentsAtPage:0 count:20 success:^(NSArray *documents) {
            self.searchResults = documents;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
    else
    {
        [MDLDocument searchWithGenericTerms:self.searchGenericTerms authors:self.searchAuthors title:self.searchTitle success:^(NSArray *documents) {
            self.searchResults = documents;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
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
    cell.textLabel.text = document.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"DOI: %@, ID: %@", document.DOI, document.identifier];
    
    return cell;
}

@end
