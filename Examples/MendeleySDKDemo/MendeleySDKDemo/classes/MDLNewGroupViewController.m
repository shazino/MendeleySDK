//
// MDLNewGroupViewController.m
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

#import "MDLNewGroupViewController.h"

#import "MDLGroup.h"

@interface MDLNewGroupViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@end

@implementation MDLNewGroupViewController

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    if ([self.nameTextField.text length] > 0)
    {
        self.nameTextField.enabled = NO;
        self.typeSegmentedControl.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [MDLGroup createGroupWithName:self.nameTextField.text type:self.typeSegmentedControl.selectedSegmentIndex success:^(MDLGroup *group) {
            [[[UIAlertView alloc] initWithTitle:@"Group Created" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.nameTextField.enabled = YES;
            self.typeSegmentedControl.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
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
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
