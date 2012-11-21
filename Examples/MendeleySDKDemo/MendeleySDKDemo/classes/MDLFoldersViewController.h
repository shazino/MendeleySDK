//
//  MDLFoldersViewController.h
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 21/11/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDLFolder;

@interface MDLFoldersViewController : UITableViewController

@property (strong, nonatomic) MDLFolder *parentFolder;

@end
