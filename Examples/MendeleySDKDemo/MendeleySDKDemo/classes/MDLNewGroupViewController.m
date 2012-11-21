//
//  MDLNewGroupViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 20/11/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLNewGroupViewController.h"

#import "MDLGroup.h"

@interface MDLNewGroupViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@end

@implementation MDLNewGroupViewController

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
