//
//  MDLCategoriesViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 16/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLCategoriesViewController.h"

#import "MDLCategory.h"
#import "MDLCategoryViewController.h"

@interface MDLCategoriesViewController ()

@property NSArray *categories;

@end

@implementation MDLCategoriesViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MDLCategory fetchCategoriesSuccess:^(NSArray *results) {
        self.categories = [results sortedArrayUsingComparator:^NSComparisonResult(MDLCategory *obj1, MDLCategory *obj2) { return [obj1.identifier compare:obj2.identifier]; }];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MDLCategoryViewController class]])
    {
        MDLCategoryViewController *tagsViewController = (MDLCategoryViewController *)segue.destinationViewController;
        tagsViewController.category = self.categories[self.tableView.indexPathForSelectedRow.row];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLCategoryCell" forIndexPath:indexPath];
    
    MDLCategory *category = self.categories[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"#%@ %@", category.identifier, category.name];
    
    return cell;
}

@end
