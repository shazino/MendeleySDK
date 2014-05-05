//
//  MDLAuthenticationWebViewController.m
//  MendeleySDKDemo
//
//  Created by Vincent Tourraine on 1/15/14.
//  Copyright (c) 2014 shazino. All rights reserved.
//

#import "MDLAuthenticationWebViewController.h"

#import <MDLMendeleyAPIClient.h>

@interface MDLAuthenticationWebViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@end


@implementation MDLAuthenticationWebViewController

#pragma mark - View lifecycle

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    self.view = view;
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.delegate         = self;
    [view addSubview:webView];
    self.webView = webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Login with Mendeley", nil);
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    if (self.authenticationWebURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.authenticationWebURL];
        [self.webView loadRequest:request];
    }
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    if (self.webView.isLoading)
        [self.webView stopLoading];
    
    [self.delegate authenticationWebViewControllerDidCancel:self];
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (request.URL.path && [request.URL.path rangeOfString:@"forgot"].location != NSNotFound) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    NSRange codeRange = [request.URL.query rangeOfString:@"code="];
    if (request.URL.query && codeRange.location != NSNotFound) {
        NSString *code = [request.URL.query substringFromIndex:codeRange.location + codeRange.length];
        [self.delegate authenticationWebViewController:self didGetAuthenticationCode:code];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code == NSURLErrorCancelled)
        return;
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])
        return;

    [self.delegate authenticationWebViewController:self didFailWithError:error];
}

@end
