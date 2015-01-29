//
//  MendeleySDKDemoOSXTests.m
//  MendeleySDKDemoOSXTests
//
//  Created by Damien Mathieu on 29/07/2013.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "MendeleySDKDemoOSXTests.h"

#import <MendeleySDK.h>

@implementation MendeleySDKDemoOSXTests

- (void)testInit
{
    [MDLMendeleyAPIClient configureSharedClientWithClientID:@"testID"
                                                     secret:@"testSecret"
                                                redirectURI:@"testURI"];
    XCTAssertNotNil([MDLMendeleyAPIClient sharedClient], @"The Mendeley SDK should be accessible");
}

@end
