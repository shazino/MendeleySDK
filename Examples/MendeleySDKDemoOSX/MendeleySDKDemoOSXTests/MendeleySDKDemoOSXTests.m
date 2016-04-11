//
//  MendeleySDKDemoOSXTests.m
//  MendeleySDKDemoOSXTests
//
//  Created by Damien Mathieu on 29/07/2013.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

#import "MendeleySDKDemoOSXTests.h"

#import <MendeleySDK.h>

@implementation MendeleySDKDemoOSXTests

- (void)testInit {
    MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient clientWithClientID:@"testID"
                                                                     secret:@"testSecret"
                                                                redirectURI:@"testURI"];
    XCTAssertNotNil(client, @"The Mendeley SDK client should be accessible");
}

@end
