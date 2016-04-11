//
//  MendeleySDKDemoTests.m
//  MendeleySDKDemoTests
//
//  Created by Damien Mathieu on 29/07/2013.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

#import "MendeleySDKDemoTests.h"
#import <MendeleySDK.h>

@implementation MendeleySDKDemoTests

- (void)testInit
{
    XCTAssertNotNil([MDLMendeleyAPIClient clientWithClientID:@"" secret:@"" redirectURI:@""], @"The Mendeley SDK should be accessible");
}

@end
