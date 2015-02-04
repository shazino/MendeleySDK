//
// MDLFoldersViewController.m
//
// Copyright (c) 2012-2015 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLFoldersViewController.h"

#import "MDLFolder.h"
#import "MDLDocument.h"
#import "MDLNewFolderViewController.h"

#import "UIViewController+MDLError.h"


@interface MDLFoldersViewController ()

@property (strong, nonatomic) NSArray *folders;
@property (strong, nonatomic) NSArray *documents;

@end


typedef NS_ENUM(NSInteger, MDLFoldersViewSections) {
    MDLFoldersViewSectionSubfolders,
    MDLFoldersViewSectionDocuments
};

@implementation MDLFoldersViewController


#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.parentFolder) {
        self.title = self.parentFolder.name;

        [self.parentFolder
         fetchDocumentsWithClient:self.APIClient
         atPage:nil
         numberOfItems:0
         success:^(MDLResponseInfo *info, NSArray *documents) {
             self.documents = documents;
             [self.tableView reloadData];
         }
         failure:^(NSError *error) {
             [self showAlertViewWithError:error];
        }];
    }
    else {
        [MDLFolder
         fetchWithClient:self.APIClient
         atPage:0
         numberOfItems:0
         parameters:nil
         success:^(MDLResponseInfo *info, NSArray *folders) {
             self.folders = folders;
             [self.tableView reloadData];
         }
         failure:^(NSError *error) {
             [self showAlertViewWithError:error];
         }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setAPIClient:)]) {
        [segue.destinationViewController setAPIClient:self.APIClient];
    }

    if ([segue.destinationViewController isKindOfClass:[MDLFoldersViewController class]]) {
        MDLFolder *selectedFolder = self.folders[self.tableView.indexPathForSelectedRow.row];
        ((MDLFoldersViewController *)segue.destinationViewController).parentFolder = selectedFolder;
    }
    else if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *topViewController = ((UINavigationController *)segue.destinationViewController).topViewController;

        if ([topViewController respondsToSelector:@selector(setAPIClient:)]) {
            [(id)topViewController setAPIClient:self.APIClient];
        }

        if ([topViewController isKindOfClass:[MDLNewFolderViewController class]]) {
            ((MDLNewFolderViewController *)topViewController).parentFolder = self.parentFolder;
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case MDLFoldersViewSectionSubfolders:
            return [self.folders count];

        case MDLFoldersViewSectionDocuments:
            return [self.documents count];
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLFolderCell" forIndexPath:indexPath];

    switch (indexPath.section) {
        case MDLFoldersViewSectionSubfolders: {
            MDLFolder *folder = self.folders[indexPath.row];
            cell.textLabel.text = [@"📂 " stringByAppendingString:folder.name];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case MDLFoldersViewSectionDocuments: {
            MDLDocument *document = self.documents[indexPath.row];
            cell.textLabel.text = [@"📄 " stringByAppendingString:document.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MDLFoldersViewSectionSubfolders) {
        [self performSegueWithIdentifier:@"MDLPushSubfoldersSegue" sender:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case MDLFoldersViewSectionSubfolders:
            return @"Delete";

        case MDLFoldersViewSectionDocuments:
            return @"Remove From Folder";
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        switch (indexPath.section) {
            case MDLFoldersViewSectionSubfolders: {
                MDLFolder *folder = self.folders[indexPath.row];
                [folder
                 deleteWithClient:self.APIClient
                 success:^{
                     NSMutableArray *newFolders = [NSMutableArray arrayWithArray:self.folders];
                     [newFolders removeObject:folder];
                     self.folders = newFolders;
                     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                 }
                 failure:^(NSError *error) {
                     [self showAlertViewWithError:error];
                 }];
                break;
            }

            case MDLFoldersViewSectionDocuments: {
                MDLDocument *document = self.documents[indexPath.row];
                [self.parentFolder
                 removeDocument:document
                 withClient:self.APIClient
                 success:^{
                     NSMutableArray *newDocuments = [NSMutableArray arrayWithArray:self.documents];
                     [newDocuments removeObject:document];
                     self.documents = newDocuments;
                     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                 }
                 failure:^(NSError *error) {
                     [self showAlertViewWithError:error];
                 }];
                break;
            }
        }
    }
}

@end
