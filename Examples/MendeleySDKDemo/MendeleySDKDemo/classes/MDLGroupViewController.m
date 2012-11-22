//
// MDLGroupViewController.m
//
// Copyright (c) 2012 shazino (shazino SAS), http://www.shazino.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
