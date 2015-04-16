//
//  MendeleySDKDemoTests.m
//  MendeleySDKDemoTests
//
//  Created by Damien Mathieu on 29/07/2013.
//  Copyright (c) 2013-2015 shazino. All rights reserved.
//

#import "MendeleySDKDemoTests.h"
#import <MendeleySDK.h>

@implementation MendeleySDKDemoTests

- (void)testInit
{
    XCTAssertNotNil([MDLMendeleyAPIClient sharedClient], @"The Mendeley SDK should be accessible");
}

@end
