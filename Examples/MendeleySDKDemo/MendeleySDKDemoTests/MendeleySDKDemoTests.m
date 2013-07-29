//
//  MendeleySDKDemoTests.m
//  MendeleySDKDemoTests
//
//  Created by Damien Mathieu on 29/07/2013.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "MendeleySDKDemoTests.h"
#import <MendeleySDK.h>

@implementation MendeleySDKDemoTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testInit
{
    STAssertNotNil([MDLMendeleyAPIClient sharedClient], @"The Mendeley SDK should be accessible");
    STFail(@"hey");
}



@end
