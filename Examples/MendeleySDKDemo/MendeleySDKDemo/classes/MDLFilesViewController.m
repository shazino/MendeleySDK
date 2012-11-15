//
//  MDLFilesViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 15/11/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLFilesViewController.h"
#import "MDLFile.h"

@interface MDLFilesViewController () <UIDocumentInteractionControllerDelegate>

- (void)showAlertViewWithError:(NSError *)error;

@end

@implementation MDLFilesViewController

- (void)showAlertViewWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLFileCell" forIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    MDLFile *file = self.files[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ file", [file.extension uppercaseString]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%d Kb)", [dateFormatter stringFromDate:file.dateAdded], [file.size intValue]/1000];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MDLFile *file = self.files[indexPath.row];
    NSString *path = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"file"] stringByAppendingPathExtension:file.extension];
    [file downloadToFileAtPath:path success:^{
        UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
        interactionController.delegate = self;
        [interactionController presentPreviewAnimated:YES];
    } failure:^(NSError *error) { [self showAlertViewWithError:error]; }];
}

#pragma mark - Document interaction controller delegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self.navigationController;
}

@end
