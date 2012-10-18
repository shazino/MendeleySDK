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

@end

@implementation MDLUserProfileViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MDLUser fetchMyUserProfileSuccess:^(MDLUser *user) {
        self.nameLabel.text = user.name;
        self.locationLabel.text = user.location;
        self.categoryLabel.text = user.category.name;
        self.interestsLabel.text = user.researchInterests;
        [self.profileImageView setImageWithURL:user.photoURL placeholderImage:nil];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

@end
