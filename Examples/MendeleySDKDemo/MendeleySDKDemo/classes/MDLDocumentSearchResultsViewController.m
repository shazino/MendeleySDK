//
//  MDLDocumentSearchResultsViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 11/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLDocumentSearchResultsViewController.h"

#import "MDLDocument.h"

@interface MDLDocumentSearchResultsViewController ()

@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation MDLDocumentSearchResultsViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MDLDocument searchWithGenericTerms:self.searchGenericTerms authors:self.searchAuthors title:self.searchTitle success:^(NSArray *documents) {
        self.searchResults = documents;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"DOI: %@, ID: %@", document.DOI, document.documentIdentifier];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
