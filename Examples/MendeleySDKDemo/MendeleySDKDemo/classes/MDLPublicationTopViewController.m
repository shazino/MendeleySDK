//
//  MDLPublicationTopViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 16/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLPublicationTopViewController.h"

#import "MDLPublication.h"

@interface MDLPublicationTopViewController ()

@property NSArray *publications;
@property NSNumber *disciplineIdentifier;
@property (getter = isUpAndComing) BOOL upAndComing;

- (void)fetchTopPublicationForDiscipline:(NSNumber *)disciplineIdentifier upAndComing:(BOOL)upAndComing;
- (IBAction)switchValueChanged:(UISwitch *)sender;

@end

@implementation MDLPublicationTopViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.upAndComing = NO;
    self.disciplineIdentifier = @10;
    
    [self fetchTopPublicationForDiscipline:self.disciplineIdentifier upAndComing:self.isUpAndComing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.publications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDLPublicationCell" forIndexPath:indexPath];
    
    MDLPublication *publication = self.publications[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, publication.name];
    
    return cell;
}

#pragma mark - Actions

- (void)fetchTopPublicationForDiscipline:(NSNumber *)disciplineIdentifier upAndComing:(BOOL)upAndComing
{
    [MDLPublication topPublicationsInPublicLibraryForDiscipline:disciplineIdentifier upAndComing:upAndComing success:^(NSArray *publications) {
        self.publications = publications;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (IBAction)switchValueChanged:(UISwitch *)sender
{
    self.upAndComing = sender.isOn;
    [self fetchTopPublicationForDiscipline:self.disciplineIdentifier upAndComing:self.isUpAndComing];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterNoStyle;
    self.disciplineIdentifier = [numberFormatter numberFromString:textField.text];
    textField.text = [self.disciplineIdentifier stringValue];
    [textField resignFirstResponder];
    
    [self fetchTopPublicationForDiscipline:self.disciplineIdentifier upAndComing:self.isUpAndComing];
    
    return NO;
}

@end
