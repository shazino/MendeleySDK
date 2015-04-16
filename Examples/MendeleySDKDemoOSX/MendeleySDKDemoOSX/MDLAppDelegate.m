//
//  MDLAppDelegate.m
//  MendeleySDKDemoOSX
//
//  Created by Damien Mathieu on 29/07/2013.
//  Copyright (c) 2013-2014 shazino. All rights reserved.
//

#import "MDLAppDelegate.h"

#import <MendeleySDK.h>

NSString * const MDLClientID     = @"##client_id##";
NSString * const MDLClientSecret = @"##client_secret##";
NSString * const MDLURLScheme    = @"mdl-mendeleysdkdemo";

@implementation MDLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // MDLMendeleyAPIClient *client = [MDLMendeleyAPIClient clientWithClientID:MDLClientID
    //                                                                  secret:MDLClientSecret
    //                                                             redirectURI:MDLURLScheme];
}

@end
