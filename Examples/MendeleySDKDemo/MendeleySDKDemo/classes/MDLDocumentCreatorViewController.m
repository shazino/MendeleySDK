//
// MDLDocumentCreatorViewController.m
//
// Copyright (c) 2012 shazino (shazino SAS), http://www.shazino.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
        [MDLDocument createDocumentWithTitle:documentTitle parameters:@{@"year" : @"2012", @"authors" : @[@"Me"]} success:^(MDLDocument *document) {
            self.activityStatusLabel.text = [NSString stringWithFormat:@"Document created\nTitle: %@\nType: %@\nId: %@", document.title, document.type, document.identifier];
            [document uploadFileAtURL:fileURL success:^() {
                self.activityStatusLabel.text = [NSString stringWithFormat:@"Document created and uploaded\nTitle: %@\nType: %@\nId: %@", document.title, document.type, document.identifier];
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
