//
//  MDLTopViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 16/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLTopViewController.h"

#import "MDLPublication.h"
#import "MDLAuthor.h"

@interface MDLTopViewController ()

@property NSArray *topResults;
@property NSNumber *disciplineIdentifier;
@property (getter = isUpAndComing) BOOL upAndComing;

- (void)fetchTopForDiscipline:(NSNumber *)disciplineIdentifier upAndComing:(BOOL)upAndComing;
- (IBAction)switchValueChanged:(UISwitch *)sender;

@end

@implementation MDLTopViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.upAndComing = NO;
    self.disciplineIdentifier = nil;
    self.navigationItem.title = [NSString stringWithFormat:@"Top %@s", [NSStringFromClass(self.entityClass) stringByReplacingOccurrencesOfString:@"MDL" withString:@""]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchTopForDiscipline:self.disciplineIdentifier upAndComing:self.isUpAndComing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.topResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLTopCell" forIndexPath:indexPath];
    
    id result = self.topResults[indexPath.row];
    NSString *resultName;
    if ([result isKindOfClass:[MDLPublication class]])
        resultName = ((MDLPublication *)result).name;
    else if ([result isKindOfClass:[MDLAuthor class]])
        resultName = ((MDLAuthor *)result).surname;
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, resultName];
    
    
    return cell;
}

#pragma mark - Actions

- (void)fetchTopForDiscipline:(NSNumber *)disciplineIdentifier upAndComing:(BOOL)upAndComing
{
    if (self.entityClass == [MDLPublication class])
    {
        [MDLPublication topPublicationsInPublicLibraryForDiscipline:disciplineIdentifier upAndComing:upAndComing success:^(NSArray *results) {
            self.topResults = results;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
    else if (self.entityClass == [MDLAuthor class])
    {
        [MDLAuthor topAuthorsInPublicLibraryForDiscipline:disciplineIdentifier upAndComing:upAndComing success:^(NSArray *results) {
            self.topResults = results;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }
}

- (IBAction)switchValueChanged:(UISwitch *)sender
{
    self.upAndComing = sender.isOn;
    [self fetchTopForDiscipline:self.disciplineIdentifier upAndComing:self.isUpAndComing];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterNoStyle;
    self.disciplineIdentifier = [numberFormatter numberFromString:textField.text];
    textField.text = [self.disciplineIdentifier stringValue];
    [textField resignFirstResponder];
    
    [self fetchTopForDiscipline:self.disciplineIdentifier upAndComing:self.isUpAndComing];
    
    return NO;
}

@end
