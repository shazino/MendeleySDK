//
// MDLNewFolderViewController.m
//
// Copyright (c) 2012-2016 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLNewFolderViewController.h"
#import "MDLFolder.h"

#import "UIViewController+MDLError.h"


@interface MDLNewFolderViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@end


@implementation MDLNewFolderViewController

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    if (self.nameTextField.text.length > 0) {
        self.nameTextField.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;

        [MDLFolder
         createFolderWithClient:self.APIClient
         name:self.nameTextField.text
         parent:self.parentFolder
         success:^(MDLMendeleyAPIObject *folder) {
             [[[UIAlertView alloc]
               initWithTitle:NSLocalizedString(@"Folder Created", nil)
               message:nil
               delegate:self
               cancelButtonTitle:NSLocalizedString(@"OK", nil)
               otherButtonTitles:nil] show];
        }
         failure:^(NSError *error) {
             [self showAlertViewWithError: error];
             self.nameTextField.enabled = YES;
             self.navigationItem.rightBarButtonItem.enabled = YES;
         }];
    }
    else {
        [self.nameTextField becomeFirstResponder];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - Alert view delegate

- (void)        alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
