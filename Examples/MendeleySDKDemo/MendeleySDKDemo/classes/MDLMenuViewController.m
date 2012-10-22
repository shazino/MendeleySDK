//
//  MDLMenuViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 16/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLMenuViewController.h"

#import "MDLTopViewController.h"
#import "MDLPublication.h"
#import "MDLAuthor.h"
#import "MDLDocument.h"
#import "MDLGroup.h"

@implementation MDLMenuViewController

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MDLTopPublicationsSegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLPublication class];
    }
    else if ([segue.identifier isEqualToString:@"MDLTopAuthorsSegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLAuthor class];
    }
    else if ([segue.identifier isEqualToString:@"MDLTopDocumentsSegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLDocument class];
    }
    else if ([segue.identifier isEqualToString:@"MDLTopGroupsSegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLGroup class];
    }
}

@end
