//
//  MDLGroupsViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 20/11/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLGroupsViewController.h"
#import "MDLGroupViewController.h"
#import "MDLGroup.h"

@interface MDLGroupsViewController ()

@property (nonatomic, strong) NSArray *groups;

- (void)showAlertViewWithError:(NSError *)error;

@end

@implementation MDLGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inUserLibrary = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MDLGroup fetchGroupsInUserLibrarySuccess:^(NSArray *groups) {
        self.groups = groups;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self showAlertViewWithError:error];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MDLGroupViewController class]])
    {
        ((MDLGroupViewController *)segue.destinationViewController).group = self.groups[self.tableView.indexPathForSelectedRow.row];
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
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLGroupCell" forIndexPath:indexPath];
    MDLGroup *group = self.groups[indexPath.row];
    cell.textLabel.text = group.name;
    return cell;
}

@end
