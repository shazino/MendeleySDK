//
//  MDLNewFolderViewController.h
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 21/11/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDLFolder;
@interface MDLNewFolderViewController : UIViewController

@property (nonatomic, weak) MDLFolder *parentFolder;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
