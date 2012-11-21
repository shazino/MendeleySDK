//
//  MDLGroupViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 18/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLGroupViewController.h"

#import "MDLGroup.h"
#import "MDLUser.h"
#import "MDLCategory.h"
#import "MDLDocumentSearchResultsViewController.h"
#import "MDLUsersViewController.h"

@interface MDLGroupViewController () <UIActionSheetDelegate>

- (void)showAlertViewWithError:(NSError *)error;

@end


@implementation MDLGroupViewController

- (void)setGroup:(MDLGroup *)group
{
    _group = group;
    
    self.nameLabel.text = self.group.name;
    self.categoryLabel.text = self.group.category.name;
    self.ownerLabel.text = self.group.owner.name;
    switch (self.group.type)
    {
        case MDLGroupTypePrivate:
            self.publicLabel.text = @"Private";
            break;
        case MDLGroupTypeInvite:
            self.publicLabel.text = @"Invite";
            break;
        case MDLGroupTypeOpen:
            self.publicLabel.text = @"Open";
            break;
    }
    self.numberOfDocumentsLabel.text = [self.group.numberOfDocuments stringValue];
    self.numberOfAdminsLabel.text = [self.group.numberOfAdmins stringValue];
    self.numberOfMembersLabel.text = [self.group.numberOfMembers stringValue];
    self.numberOfFollowersLabel.text = [self.group.numberOfFollowers stringValue];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.group = self.group;
    
    [self.group fetchDetailsSuccess:^(MDLGroup *group) {
        self.group = group;
        
        [self.group fetchPeopleSuccess:^(MDLGroup *group) {
            self.group = group;
        } failure:^(NSError *error) {
            [self showAlertViewWithError:error];
        }];
    } failure:^(NSError *error) {
        [self showAlertViewWithError:error];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[MDLUsersViewController class]])
    {
        MDLUsersViewController *usersViewController = (MDLUsersViewController *)segue.destinationViewController;
        NSArray *users;
        if ([segue.identifier isEqualToString:@"MDLPushAdminsSegue"])
            users = self.group.admins;
        else if ([segue.identifier isEqualToString:@"MDLPushMembersSegue"])
            users = self.group.members;
        else if ([segue.identifier isEqualToString:@"MDLPushFollowersSegue"])
            users = self.group.followers;
        usersViewController.users = users;
    }
    else if ([segue.destinationViewController isKindOfClass:[MDLDocumentSearchResultsViewController class]])
    {
        ((MDLDocumentSearchResultsViewController *)segue.destinationViewController).group = self.group;
    }
}

- (void)showAlertViewWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - Actions

- (IBAction)showActions:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Leave", @"Unfollow", @"Open on Mendeley.com", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)openWebGroupProfile:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.group.mendeleyURL];
}

- (IBAction)deleteGroup:(id)sender
{
    [self.group deleteSuccess:^{ [self.navigationController popViewControllerAnimated:YES]; }
                      failure:^(NSError *error) { [self showAlertViewWithError:error]; }];
}

- (IBAction)leaveGroup:(id)sender
{
    [self.group leaveSuccess:^{ [[[UIAlertView alloc] initWithTitle:@"Group Left" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show]; }
                      failure:^(NSError *error) { [self showAlertViewWithError:error]; }];
}

- (IBAction)unfollowGroup:(id)sender
{
    [self.group unfollowSuccess:^{ [[[UIAlertView alloc] initWithTitle:@"Group Unfollowed" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show]; }
                        failure:^(NSError *error) { [self showAlertViewWithError:error]; }];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self deleteGroup:nil];
            break;
        case 1:
            [self leaveGroup:nil];
            break;
        case 2:
            [self unfollowGroup:nil];
            break;
        case 3:
            [self openWebGroupProfile:nil];
            break;
    }
}

@end
