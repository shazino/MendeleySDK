//
// MDLDocumentSearchViewController.m
//
// Copyright (c) 2012-2013 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLDocumentSearchViewController.h"

#import "MDLDocumentsViewController.h"

@interface MDLDocumentSearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *genericTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorsTextField;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;

@end


@implementation MDLDocumentSearchViewController

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setAPIClient:)]) {
        [segue.destinationViewController setAPIClient:self.APIClient];
    }

    if ([segue.destinationViewController isMemberOfClass:[MDLDocumentsViewController class]]) {
        MDLDocumentsViewController *resultsController = (MDLDocumentsViewController *)segue.destinationViewController;
        resultsController.searchGenericTerms = self.genericTextField.text;
        resultsController.searchAuthors      = self.authorsTextField.text;
        resultsController.searchTitle        = self.titleTextField.text;
        resultsController.searchYear         = [[NSNumberFormatter new] numberFromString:self.yearTextField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self performSegueWithIdentifier:@"MDLSearchSegue" sender:nil];
    return NO;
}

@end
