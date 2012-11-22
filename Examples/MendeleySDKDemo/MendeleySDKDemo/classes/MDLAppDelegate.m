//
// MDLAppDelegate.m
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
