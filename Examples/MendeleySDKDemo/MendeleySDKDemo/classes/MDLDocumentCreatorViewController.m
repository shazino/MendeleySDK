//
//  MDLDocumentCreatorViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 09/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLDocumentCreatorViewController.h"

#import "MDLDocument.h"

@interface MDLDocumentCreatorViewController ()

- (void)generatePDFAtURL:(NSURL *)fileURL content:(NSString *)fileContent;

@end

@implementation MDLDocumentCreatorViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityStatusLabel.text = @"";
}

#pragma mark - Actions

- (void)generatePDFAtURL:(NSURL *)fileURL content:(NSString *)fileContent
{
    NSMutableData *PDFData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(PDFData, CGRectZero, nil);
    UIGraphicsBeginPDFPage();
    [fileContent drawAtPoint:CGPointMake(100, 100) withFont:[UIFont systemFontOfSize:16]];
    UIGraphicsEndPDFContext();
    
    [PDFData writeToURL:fileURL atomically:YES];
}

- (IBAction)upload:(id)sender
{
    [self.nameTextField resignFirstResponder];
    [self.contentTextView resignFirstResponder];
    
    NSString *documentTitle = self.nameTextField.text;
    NSString *documentContent = self.contentTextView.text;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = paths[0];
    NSString *filePath = [[cachePath stringByAppendingPathComponent:documentTitle] stringByAppendingPathExtension:@"pdf"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [self generatePDFAtURL:fileURL content:documentContent];
    
    if ([documentTitle length] > 0)
    {
        self.activityStatusLabel.text = @"Creating document...";
        [MDLDocument documentWithTitle:documentTitle success:^(MDLDocument *document) {
            self.activityStatusLabel.text = [NSString stringWithFormat:@"Document created\nTitle: %@\nType: %@\nId: %@", document.title, document.type, document.documentIdentifier];
            [document uploadFileAtURL:fileURL success:^() {
                self.activityStatusLabel.text = [NSString stringWithFormat:@"Document created and uploaded\nTitle: %@\nType: %@\nId: %@", document.title, document.type, document.documentIdentifier];
            } failure:^(NSError *error) {
                self.activityStatusLabel.text = [NSString stringWithFormat:@"Document created, but cannot upload file\n(Error: %@)", [error localizedDescription]];
            }];
        } failure:^(NSError *error) {
            self.activityStatusLabel.text = [NSString stringWithFormat:@"Cannot create new document\n(Error: %@)", [error localizedDescription]];
        }];
    }
    else
    {
        [self.nameTextField becomeFirstResponder];
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField)
        [self.contentTextView becomeFirstResponder];
    return NO;
}

- (IBAction)textFieldEditingChanged:(id)sender
{
    self.uploadButton.enabled = ([self.nameTextField.text length] > 0);
}

@end
