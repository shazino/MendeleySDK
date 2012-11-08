//
//  MDLTopViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 16/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLTopViewController.h"

#import "MDLPublication.h"
#import "MDLAuthor.h"
#import "MDLDocument.h"
#import "MDLGroup.h"
#import "MDLTag.h"
#import "MDLDocumentDetailsViewController.h"
#import "MDLGroupViewController.h"

@interface MDLTopViewController ()

@property NSArray *topResults;
@property NSString *categoryIdentifier;
@property (getter = isUpAndComing) BOOL upAndComing;

- (void)fetchTopForCategory:(NSString *)categoryIdentifier upAndComing:(BOOL)upAndComing;
- (IBAction)switchValueChanged:(UISwitch *)sender;
- (void)showAlertViewWithError:(NSError *)error;

@end

@implementation MDLTopViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isInUserLibrary)
        self.tableView.tableHeaderView = nil;
    
    self.upAndComing = NO;
    self.categoryIdentifier = nil;
    self.navigationItem.title = [NSString stringWithFormat:@"Top %@s", [NSStringFromClass(self.entityClass) stringByReplacingOccurrencesOfString:@"MDL" withString:@""]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchTopForCategory:self.categoryIdentifier upAndComing:self.isUpAndComing];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MDLDocumentDetailsViewController class]])
    {
        MDLDocumentDetailsViewController *detailsViewController = (MDLDocumentDetailsViewController *)segue.destinationViewController;
        detailsViewController.document = self.topResults[self.tableView.indexPathForSelectedRow.row];
    }
    else if ([segue.destinationViewController isKindOfClass:[MDLGroupViewController class]])
    {
        MDLGroupViewController *detailsViewController = (MDLGroupViewController *)segue.destinationViewController;
        detailsViewController.group = self.topResults[self.tableView.indexPathForSelectedRow.row];
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
    return [self.topResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLTopCell" forIndexPath:indexPath];
    
    id result = self.topResults[indexPath.row];
    NSString *resultName;
    if ([result isKindOfClass:[MDLPublication class]])
        resultName = ((MDLPublication *)result).name;
    else if ([result isKindOfClass:[MDLAuthor class]])
        resultName = ((MDLAuthor *)result).name;
    else if ([result isKindOfClass:[MDLDocument class]])
        resultName = ((MDLDocument *)result).title;
    else if ([result isKindOfClass:[MDLGroup class]])
        resultName = ((MDLGroup *)result).name;
    else if ([result isKindOfClass:[MDLTag class]])
        resultName = [NSString stringWithFormat:@"%@ (%@)", ((MDLTag *)result).name, ((MDLTag *)result).count];
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, resultName];
    
    cell.accessoryType = ([result isKindOfClass:[MDLDocument class]]) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.selectionStyle = ([result isKindOfClass:[MDLDocument class]]) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.entityClass == [MDLDocument class])
        [self performSegueWithIdentifier:@"MDLDocumentDetailsSegue" sender:nil];
    else if (self.entityClass == [MDLGroup class])
        [self performSegueWithIdentifier:@"MDLGroupDetailsSegue" sender:nil];
}

#pragma mark - Actions

- (void)fetchTopForCategory:(NSString *)categoryIdentifier upAndComing:(BOOL)upAndComing
{
    void (^success)(NSArray *) = ^(NSArray *results) {
        self.topResults = results;
        [self.tableView reloadData];
    };
    
    void (^failure)(NSError *) = ^(NSError *error) {
        [self showAlertViewWithError:error];
    };
             
    if (self.entityClass == [MDLPublication class])
    {
        if (self.isInUserLibrary)
            [MDLPublication topPublicationsInUserLibrarySuccess:success failure:failure];
        else
            [MDLPublication topPublicationsInPublicLibraryForCategory:categoryIdentifier upAndComing:upAndComing success:success failure:failure];
    }
    else if (self.entityClass == [MDLAuthor class])
    {
        if (self.isInUserLibrary)
            [MDLAuthor topAuthorsInUserLibrarySuccess:success failure:failure];
        else
            [MDLAuthor topAuthorsInPublicLibraryForCategory:categoryIdentifier upAndComing:upAndComing success:success failure:failure];
    }
    else if (self.entityClass == [MDLDocument class])
    {
        [MDLDocument topDocumentsInPublicLibraryForCategory:categoryIdentifier upAndComing:upAndComing success:success failure:failure];
    }
    else if (self.entityClass == [MDLGroup class])
    {
        [MDLGroup topGroupsInPublicLibraryForCategory:categoryIdentifier atPage:0 count:20 success:^(NSArray *results, NSUInteger totalResults, NSUInteger totalPages, NSUInteger pageIndex, NSUInteger itemsPerPage) {
            self.topResults = results;
            [self.tableView reloadData];
        } failure:failure];
    }
    else if (self.entityClass == [MDLTag class])
    {
        [MDLTag lastTagsInUserLibrarySuccess:success failure:failure];
    }
}

- (IBAction)switchValueChanged:(UISwitch *)sender
{
    self.upAndComing = sender.isOn;
    [self fetchTopForCategory:self.categoryIdentifier upAndComing:self.isUpAndComing];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.categoryIdentifier = textField.text;
    [textField resignFirstResponder];
    
    [self fetchTopForCategory:self.categoryIdentifier upAndComing:self.isUpAndComing];
    
    return NO;
}

@end
