//
//  MDLDocumentDetailsViewController.h
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 15/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDLDocument;

@interface MDLDocumentDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorsLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicationLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextView *abstractTextView;
@property (weak, nonatomic) IBOutlet UIButton *relatedDocumentsButton;
@property (weak, nonatomic) IBOutlet UIButton *filesButton;

@property (nonatomic, strong) MDLDocument *document;

@end
