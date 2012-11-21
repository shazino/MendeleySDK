//
//  MDLNewGroupViewController.h
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 20/11/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDLNewGroupViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *typeSegmentedControl;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
