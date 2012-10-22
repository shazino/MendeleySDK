//
//  MDLUserProfileViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 18/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLUserProfileViewController.h"
#import "MDLUser.h"
#import "MDLCategory.h"
#import "AFNetworking.h"

@interface MDLUserProfileViewController ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *interestsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

- (IBAction)openWebUserProfile:(id)sender;

@end

@implementation MDLUserProfileViewController

- (void)setUser:(MDLUser *)user
{
    _user = user;
    self.nameLabel.text = user.name;
    self.locationLabel.text = user.location;
    self.categoryLabel.text = user.category.name;
    self.interestsLabel.text = user.researchInterests;
    [self.profileImageView setImageWithURL:user.photoURL placeholderImage:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.user)
    {
        [self.user fetchProfileSuccess:^(MDLUser *user) {
            self.user = user;
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
    else
    {
        [MDLUser fetchMyUserProfileSuccess:^(MDLUser *user) {
            self.user = user;
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}

#pragma mark - Actions

- (IBAction)openWebUserProfile:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.user.mendeleyURL];
}

@end
