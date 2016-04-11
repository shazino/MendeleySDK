//
//  MDLAuthenticationWebViewController.h
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 1/15/14.
//  Copyright (c) 2014-2016 shazino. All rights reserved.
//

@import UIKit;

@protocol MDLAuthenticationWebViewDelegate;

@interface MDLAuthenticationWebViewController : UIViewController

@property (nonatomic, strong) NSURL *authenticationWebURL;
@property (nonatomic, weak)   id <MDLAuthenticationWebViewDelegate> delegate;

- (IBAction)cancel:(id)sender;

@end


@protocol MDLAuthenticationWebViewDelegate <NSObject>

- (void)authenticationWebViewControllerDidCancel:(MDLAuthenticationWebViewController *)viewController;
- (void)authenticationWebViewController:(MDLAuthenticationWebViewController *)viewController
                     didFailWithError:(NSError *)error;
- (void)authenticationWebViewController:(MDLAuthenticationWebViewController *)viewController
               didGetAuthenticationCode:(NSString *)code;

@end