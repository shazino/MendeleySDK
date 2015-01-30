//
// MDLGroupViewController.m
//
// Copyright (c) 2012-2013 shazino (shazino SAS), http://www.shazino.com/
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
#import "MDLProfile.h"
#import "MDLDocumentsViewController.h"
#import "MDLUsersViewController.h"

#import "UIViewController+MDLError.h"

@interface MDLGroupViewController () <UIActionSheetDelegate>

@end


@implementation MDLGroupViewController

- (void)setGroup:(MDLGroup *)group {
    _group = group;

    self.nameLabel.text        = self.group.name;
    self.ownerLabel.text       = self.group.owner.displayName;
    self.disciplineLabel.text  = [self.group.disciplines componentsJoinedByString:@", "];
    self.descriptionLabel.text = self.group.groupDescription;

    switch (self.group.accessLevel) {
        case MDLGroupAccessLevelPrivate:
            self.publicLabel.text = @"Private";
            break;

        case MDLGroupAccessLevelInvite:
            self.publicLabel.text = @"Invite";
            break;

        case MDLGroupAccessLevelOpen:
            self.publicLabel.text = @"Open";
            break;
    }

    self.numberOfDocumentsLabel.text = [@(self.group.documents.count) stringValue];
    self.numberOfAdminsLabel.text    = [@(self.group.admins.count)    stringValue];
    self.numberOfMembersLabel.text   = [@(self.group.members.count)   stringValue];
    self.numberOfFollowersLabel.text = [@(self.group.followers.count) stringValue];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.group = self.group;

    [self.group
     fetchDetailsWithClient:self.APIClient
     success:^(MDLGroup *group) {
         self.group = group;

         [self.group
          fetchPeopleWithClient:self.APIClient
          atPage:nil
          numberOfItems:0
          success:^(MDLResponseInfo *info, MDLGroup *group) {
              self.group = group;
          }
          failure:^(NSError *error) {
              [self showAlertViewWithError:error];
          }];
     }
     failure:^(NSError *error) {
         [self showAlertViewWithError:error];
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setAPIClient:)]) {
        [segue.destinationViewController setAPIClient:self.APIClient];
    }

    if ([segue.destinationViewController isKindOfClass:[MDLUsersViewController class]]) {
        MDLUsersViewController *usersViewController = (MDLUsersViewController *)segue.destinationViewController;
        NSArray *users;
        if ([segue.identifier isEqualToString:@"MDLPushAdminsSegue"]) {
            users = self.group.admins;
        }
        else if ([segue.identifier isEqualToString:@"MDLPushMembersSegue"]) {
            users = self.group.members;
        }
        else if ([segue.identifier isEqualToString:@"MDLPushFollowersSegue"]) {
            users = self.group.followers;
        }
        usersViewController.users = users;
    }
    else if ([segue.destinationViewController isKindOfClass:[MDLDocumentsViewController class]]) {
        ((MDLDocumentsViewController *)segue.destinationViewController).group = self.group;
    }
}


#pragma mark - Actions

- (IBAction)showActions:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Open on Mendeley.com", nil), nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)openWebGroupProfile:(id)sender {
    [[UIApplication sharedApplication] openURL:self.group.mendeleyURL];
}


#pragma mark - Action sheet delegate

- (void) actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self openWebGroupProfile:nil];
    }
}

@end
