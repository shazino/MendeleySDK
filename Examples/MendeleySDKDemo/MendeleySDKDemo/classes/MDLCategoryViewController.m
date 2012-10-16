//
//  MDLCategoryViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 16/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLCategoryViewController.h"

#import "MDLCategory.h"
#import "MDLTag.h"
#import "MDLSubcategory.h"

enum MDLTagsViewSections {
    MDLTagsViewSectionSubcategories = 0,
    MDLTagsViewSectionTags,
    MDLTagsViewNumberOfSections
    };
    
@interface MDLCategoryViewController ()

@property NSArray *subcategories;
@property NSArray *tags;

@end

@implementation MDLCategoryViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.category.name;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.category lastTagsInPublicLibrarSuccess:^(NSArray *results) {
        self.tags = results;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
    
    [self.category subcategoriesSuccess:^(NSArray *results) {
        self.subcategories = [results sortedArrayUsingComparator:^NSComparisonResult(MDLSubcategory *obj1, MDLSubcategory *obj2) { return [obj1.identifier compare:obj2.identifier]; }];;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MDLTagsViewNumberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case MDLTagsViewSectionSubcategories:
            return @"Subcategories";
            break;
        case MDLTagsViewSectionTags:
            return @"Tags";
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case MDLTagsViewSectionSubcategories:
            return [self.subcategories count];
            break;
        case MDLTagsViewSectionTags:
            return [self.tags count];
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLTagCell" forIndexPath:indexPath];
    
    switch (indexPath.section)
    {
        case MDLTagsViewSectionSubcategories:
        {
            MDLSubcategory *subcategory = self.subcategories[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"#%@ %@", subcategory.identifier, subcategory.name];
            break;
        }
        case MDLTagsViewSectionTags:
        {
            MDLTag *tag = self.tags[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", tag.name, [tag.count stringValue]];
            break;
        }
    }
    
    return cell;
}

@end
