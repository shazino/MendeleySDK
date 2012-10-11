//
//  MDLDocumentSearchViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 11/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLDocumentSearchViewController.h"

#import "MDLDocument.h"

@interface MDLDocumentSearchViewController ()

@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation MDLDocumentSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MDLDocumentCell"];
    
    MDLDocument *document = self.searchResults[indexPath.row];
    cell.textLabel.text = document.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"DOI: %@, ID: %@", document.DOI, document.documentIdentifier];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchResults = nil;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *terms = searchBar.text;
    
    [MDLDocument searchWithTerms:terms success:^(NSArray *documents) {
        self.searchResults = documents;
        [self.searchDisplayController.searchResultsTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

@end
