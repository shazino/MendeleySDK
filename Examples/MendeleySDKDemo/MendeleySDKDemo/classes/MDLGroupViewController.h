//
//  MDLGroupViewController.h
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 18/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDLGroup;

@interface MDLGroupViewController : UIViewController

@property (nonatomic, strong) MDLGroup *group;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *ownerLabel;
@property (nonatomic, weak) IBOutlet UILabel *publicLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfDocumentsLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfAdminsLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfMembersLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfFollowersLabel;

- (IBAction)openWebGroupProfile:(id)sender;
- (IBAction)deleteGroup:(id)sender;
- (IBAction)leaveGroup:(id)sender;
- (IBAction)unfollowGroup:(id)sender;
- (IBAction)showActions:(id)sender;

@end
