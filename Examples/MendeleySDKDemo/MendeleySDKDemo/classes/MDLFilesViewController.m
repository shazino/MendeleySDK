//
// MDLFilesViewController.m
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
