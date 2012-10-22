//
//  MDLDocumentSearchViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 11/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLDocumentSearchViewController.h"
#import "MDLDocumentSearchResultsViewController.h"

@interface MDLDocumentSearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *genericTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorsTextField;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;

@end

@implementation MDLDocumentSearchViewController

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isMemberOfClass:[MDLDocumentSearchResultsViewController class]])
    {
        MDLDocumentSearchResultsViewController *resultsController = (MDLDocumentSearchResultsViewController *)segue.destinationViewController;
        resultsController.searchGenericTerms = self.genericTextField.text;
        resultsController.searchAuthors = self.authorsTextField.text;
        resultsController.searchTitle = self.titleTextField.text;
        resultsController.searchYear = [[NSNumberFormatter new] numberFromString:self.yearTextField.text];
        resultsController.searchTags = self.tagsTextField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self performSegueWithIdentifier:@"MDLSearchSegue" sender:nil];
    return NO;
}

@end
