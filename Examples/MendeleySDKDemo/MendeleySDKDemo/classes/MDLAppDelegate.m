//
//  MDLAppDelegate.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 09/10/12.
//  Copyright (c) 2012 shazino. All rights reserved.
//

#import "MDLAppDelegate.h"
#import "AFOAuth1Client.h"
#import "AFNetworkActivityIndicatorManager.h"

NSString * const kMDLConsumerKey    = @"##consumer_key##";
NSString * const kMDLConsumerSecret = @"##consumer_secret##";
NSString * const kMDLURLScheme      = @"mdl-mendeleysdkdemo";

@implementation MDLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.7 green:0 blue:0 alpha:1]];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{   
    if ([[url scheme] isEqualToString:kMDLURLScheme])
    {
        NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return YES;
}

@end
