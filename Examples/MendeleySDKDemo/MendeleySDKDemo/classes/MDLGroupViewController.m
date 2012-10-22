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
#import "MDLUsersViewController.h"

@interface MDLGroupViewController ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *ownerLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfDocumentsLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfAdminsLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfMembersLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfFollowersLabel;

- (IBAction)openWebGroupProfile:(id)sender;

@end

@implementation MDLGroupViewController

- (void)setGroup:(MDLGroup *)group
{
    _group = group;
    
    self.nameLabel.text = self.group.name;
    self.categoryLabel.text = self.group.category.name;
    self.ownerLabel.text = self.group.owner.name;
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
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
}

#pragma mark - Actions

- (IBAction)openWebGroupProfile:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.group.mendeleyURL];
}

@end
