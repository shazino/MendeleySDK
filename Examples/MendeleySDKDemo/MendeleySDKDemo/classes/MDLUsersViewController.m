//
//  MDLUsersViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 18/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLUsersViewController.h"
#import "MDLUser.h"
#import "MDLUserProfileViewController.h"

@implementation MDLUsersViewController

- (void)setUsers:(NSArray *)users
{
    _users = users;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLUserCell" forIndexPath:indexPath];
    MDLUser *user = self.users[indexPath.row];
    cell.textLabel.text = user.name;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MDLUserProfileViewController class]])
    {
        MDLUserProfileViewController *userViewController = (MDLUserProfileViewController *)segue.destinationViewController;
        MDLUser *user = self.users[self.tableView.indexPathForSelectedRow.row];
        userViewController.user = user;
    }
}
@end
