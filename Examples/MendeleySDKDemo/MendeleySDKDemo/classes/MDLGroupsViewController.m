//
// MDLGroupsViewController.m
//
// Copyright (c) 2012-2016 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLGroupsViewController.h"

#import <MendeleySDK/MDLGroup.h>
#import <MendeleySDK/MDLResponseInfo.h>

#import "MDLGroupViewController.h"

#import "UIViewController+MDLError.h"


@interface MDLGroupsViewController ()

@property (nonatomic, strong) NSArray *groups;

@end


@implementation MDLGroupsViewController

- (void)fetchGroupAtPage:(NSString *)page {
    [MDLGroup
     fetchGroupsForCurrentUserWithClient:self.APIClient
     atPage:page
     numberOfItems:1
     success:^(MDLResponseInfo *info, NSArray *groups) {
         self.groups = [self.groups arrayByAddingObjectsFromArray:groups];
         if (info.nextPagePath) {
             [self fetchGroupAtPage:info.nextPagePath];
         }
         else {
             [self.tableView reloadData];
         }
     }
     failure:^(NSError *error) {
         [self showAlertViewWithError:error];
     }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.groups = @[];

    [self fetchGroupAtPage:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setAPIClient:)]) {
        [segue.destinationViewController setAPIClient:self.APIClient];
    }

    if ([segue.destinationViewController isKindOfClass:[MDLGroupViewController class]]) {
        ((MDLGroupViewController *)segue.destinationViewController).group = self.groups[self.tableView.indexPathForSelectedRow.row];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLGroupCell" forIndexPath:indexPath];
    MDLGroup *group = self.groups[indexPath.row];
    cell.textLabel.text = group.name;
    return cell;
}

@end
