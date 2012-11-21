//
//  MDLNewFolderViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 21/11/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLNewFolderViewController.h"
#import "MDLFolder.h"

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

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    if ([self.nameTextField.text length] > 0)
    {
        self.nameTextField.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [MDLFolder createFolderWithName:self.nameTextField.text parent:self.parentFolder success:^(MDLFolder *folder) {
            [[[UIAlertView alloc] initWithTitle:@"Folder Created" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.nameTextField.enabled = YES;
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
