//
// MDLDocumentSearchResultsViewController.m
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

#import "MDLDocumentsViewController.h"

#import <MendeleySDK/MDLDocument.h>
#import <MendeleySDK/MDLGroup.h>
#import <MendeleySDK/MDLResponseInfo.h>

#import "MDLDocumentDetailsViewController.h"

#import "UIViewController+MDLError.h"


@interface MDLDocumentsViewController ()

@property (nonatomic, strong) NSArray *searchResults;

- (IBAction)addDocument:(id)sender;
- (void)reloadUserLibrary;

@end


@implementation MDLDocumentsViewController


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.fetchUserLibrary) {
        self.navigationItem.title = NSLocalizedString(@"All Documents", nil);
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDocument:)];
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    void (^errorHandler)(NSError*) = ^(NSError *error) { [self showAlertViewWithError:error]; };

    if (self.fetchUserLibrary) {
        [self reloadUserLibrary];
    }
    else if (self.group) {
        [MDLDocument
         fetchDocumentsInGroup:self.group
         withClient:self.APIClient
         view:nil
         atPage:nil
         numberOfItems:0
         success:^(MDLResponseInfo *info, NSArray *documents) {
             self.searchResults = documents;
             [self.tableView reloadData];

             for (MDLDocument *document in self.searchResults) {
                 [document
                  fetchDetailsWithClient:self.APIClient
                  view:nil
                  success:^(MDLDocument *document) {
                      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.searchResults indexOfObject:document] inSection:0];
                      [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                            withRowAnimation:UITableViewRowAnimationAutomatic];
                  }
                  failure:errorHandler];
             }
         }
         failure:errorHandler];
    }
    else if (self.searchAuthors.length > 0 ||
             self.searchTitle.length > 0 ||
             self.searchYear.integerValue > 0) {
        [MDLDocument
         searchWithClient:self.APIClient
         authors:self.searchAuthors
         title:self.searchTitle
         year:self.searchYear
         view:nil
         atPage:nil
         numberOfItems:0
         success:^(MDLResponseInfo *info, NSArray *documents) {
             self.searchResults = documents;
             [self.tableView reloadData];
         }
         failure:errorHandler];
    }
    else {
        self.searchResults = @[];
        [self searchGenericTermsAtPage:nil];
    }
}

- (void)searchGenericTermsAtPage:(NSString *)pagePath {
    [MDLDocument
     searchWithClient:self.APIClient
     terms:self.searchGenericTerms
     view:nil
     atPage:pagePath
     numberOfItems:100
     success:^(MDLResponseInfo *info, NSArray *documents) {
         self.searchResults = [self.searchResults arrayByAddingObjectsFromArray:documents];
         if (info.nextPagePath) {
             [self searchGenericTermsAtPage:info.nextPagePath];
         }
         else {
             [self.tableView reloadData];
         }
     }
     failure:^(NSError *error) {
         [self showAlertViewWithError:error];
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setAPIClient:)]) {
        [segue.destinationViewController setAPIClient:self.APIClient];
    }

    if ([segue.destinationViewController isKindOfClass:[MDLDocumentDetailsViewController class]]) {
        MDLDocumentDetailsViewController *detailsViewController = (MDLDocumentDetailsViewController *)segue.destinationViewController;
        detailsViewController.document = self.searchResults[self.tableView.indexPathForSelectedRow.row];
    }
    else if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = segue.destinationViewController;
        id viewController = navigationController.viewControllers.firstObject;
        if ([viewController respondsToSelector:@selector(setAPIClient:)]) {
            [viewController setAPIClient:self.APIClient];
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLDocumentCell"];

    MDLDocument *document = self.searchResults[indexPath.row];
    cell.textLabel.text = (document.title) ? document.title : @"?";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"ID: %@", document.identifier];

    return cell;
}


#pragma mark - Table view delegate

- (BOOL)    tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.fetchUserLibrary;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MDLDocument *document = self.searchResults[indexPath.row];
        [document deleteWithClient:self.APIClient
                           success:^{
                               [self reloadUserLibrary];
                           }
                           failure:^(NSError *error) {
                               [self showAlertViewWithError:error];
                           }];
    }
}


#pragma mark - Actions

- (IBAction)addDocument:(id)sender {
    [self performSegueWithIdentifier:@"MDLAddDocumentSegue" sender:sender];
}

- (void)reloadUserLibrary {
    [MDLDocument
     fetchDocumentsInUserLibraryWithClient:self.APIClient
     view:nil
     atPage:nil
     numberOfItems:0
     success:^(MDLResponseInfo *info, NSArray *documents) {
         self.searchResults = documents;
         [self.tableView reloadData];
     }
     failure:^(NSError *error) {
         [self showAlertViewWithError:error];
     }];
}

@end
