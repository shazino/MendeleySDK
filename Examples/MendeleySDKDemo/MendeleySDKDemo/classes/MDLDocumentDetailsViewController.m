//
// MDLDocumentDetailsViewController.m
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

#import "MDLDocumentDetailsViewController.h"

#import "MDLDocument.h"
#import "MDLAuthor.h"
#import "MDLFile.h"
#import "MDLDocumentsViewController.h"
#import "MDLFilesViewController.h"

#import "UIViewController+MDLError.h"


@interface MDLDocumentDetailsViewController () <UIActionSheetDelegate>

- (void)updateOutletsWithDocument:(MDLDocument *)document;

@end


@implementation MDLDocumentDetailsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateOutletsWithDocument:self.document];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self updateOutletsWithDocument:self.document];

    [self.document
     fetchDetailsWithClient:self.APIClient
     view:nil
     success:^(MDLDocument *document) {
         [self updateOutletsWithDocument:document];
     }
     failure:^(NSError *error) {
         [self showAlertViewWithError:error];
     }];
}

- (void)updateOutletsWithDocument:(MDLDocument *)document {
    if (!document) {
        return;
    }

    self.titleLabel.text = document.title;
    self.typeLabel.text = document.type;
    self.abstractTextView.text = document.abstract;

    NSMutableString *authors = [NSMutableString string];
    [document.authors enumerateObjectsUsingBlock:^(MDLAuthor *author, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [authors appendString:NSLocalizedString(@"By ", nil)];
        }

        [authors appendString:author.lastName];
        if (idx < document.authors.count-1) {
            [authors appendString:NSLocalizedString(@", ", nil)];
        }
    }];

    self.authorsLabel.text = authors;
    self.publicationLabel.text = (document.source || document.year) ? [NSString stringWithFormat:@"%@ (%@)", (document.source) ?: @"?", (document.year) ?: @"?"] : @"";

//    self.filesButton.enabled = (document.files.count > 0);
//    [self.filesButton setTitle:(document.files.count > 0) ? @"Files" : @"No Files" forState:UIControlStateNormal];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[MDLFilesViewController class]]) {
//        MDLFilesViewController *filesViewController = (MDLFilesViewController *)segue.destinationViewController;
//        filesViewController.files = self.document.files;
    }
}

#pragma mark - Actions

- (IBAction)presentActions:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:
                                  NSLocalizedString(@"Open in Safari", nil),
                                  NSLocalizedString(@"Import to User Library", nil), nil];

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [actionSheet showFromBarButtonItem:sender animated:YES];
    }
}

- (IBAction)openMendeleyURL:(id)sender {
    [[UIApplication sharedApplication] openURL:self.document.mendeleyURL];
}

- (IBAction)importToUserLibrary:(id)sender {
//    [self.document
//     importToUserLibraryWithClient:self.APIClient
//     success:^(NSString *newDocumentIdentifier) {
//         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"File Imported", nil)
//                                     message:nil
//                                    delegate:nil
//                           cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                           otherButtonTitles:nil] show];
//     }
//     failure:^(NSError *error) {
//         [self showAlertViewWithError:error];
//     }];
}


#pragma mark - Action sheet delegate

- (void) actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self openMendeleyURL:nil];
            break;

        case 1:
            [self importToUserLibrary:nil];
            break;
    }
}

@end
