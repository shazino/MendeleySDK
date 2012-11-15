//
//  MDLDocumentCreatorViewController.h
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 09/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDLDocumentCreatorViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UILabel *activityStatusLabel;

- (IBAction)upload:(id)sender;
- (IBAction)cancel:(id)sender;

@end
