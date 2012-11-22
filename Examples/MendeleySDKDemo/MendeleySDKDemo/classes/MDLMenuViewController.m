//
// MDLMenuViewController.m
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
