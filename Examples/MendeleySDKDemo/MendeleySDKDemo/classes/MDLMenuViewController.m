//
//  MDLMenuViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 16/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLMenuViewController.h"

#import "MDLTopViewController.h"
#import "MDLDocumentSearchResultsViewController.h"
#import "MDLPublication.h"
#import "MDLAuthor.h"
#import "MDLDocument.h"
#import "MDLGroup.h"
#import "MDLTag.h"

@implementation MDLMenuViewController

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MDLTopPublicationsSegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLPublication class];
    }
    else if ([segue.identifier isEqualToString:@"MDLTopPublicationsUserLibrarySegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLPublication class];
        ((MDLTopViewController *)segue.destinationViewController).inUserLibrary = YES;
    }
    else if ([segue.identifier isEqualToString:@"MDLTopAuthorsSegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLAuthor class];
    }
    else if ([segue.identifier isEqualToString:@"MDLTopAuthorsUserLibrarySegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLAuthor class];
        ((MDLTopViewController *)segue.destinationViewController).inUserLibrary = YES;
    }
    else if ([segue.identifier isEqualToString:@"MDLTopDocumentsSegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLDocument class];
    }
    else if ([segue.identifier isEqualToString:@"MDLTopGroupsSegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLGroup class];
    }
    else if ([segue.identifier isEqualToString:@"MDLLastTagsUserLibrarySegue"])
    {
        ((MDLTopViewController *)segue.destinationViewController).entityClass = [MDLTag class];
        ((MDLTopViewController *)segue.destinationViewController).inUserLibrary = YES;
    }
    else if ([segue.identifier isEqualToString:@"MDLDocumentsUserLibrarySegue"])
    {
        ((MDLDocumentSearchResultsViewController *)segue.destinationViewController).fetchUserLibrary = YES;
    }
    else if ([segue.identifier isEqualToString:@"MDLAuthoredUserLibrarySegue"])
    {
        ((MDLDocumentSearchResultsViewController *)segue.destinationViewController).fetchAuthoredDocuments = YES;
    }
}

@end
