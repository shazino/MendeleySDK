# MendeleySDK
**Objective-C client for the Mendeley Open API.**
[![Build Status](https://travis-ci.org/shazino/MendeleySDK.png?branch=master)](https://travis-ci.org/shazino/MendeleySDK)

MendeleySDK is a [Mendeley API](http://apidocs.mendeley.com) client for iOS and OS X,
 built on top of [AFNetworking](http://www.github.com/AFNetworking/AFNetworking)
 and [AFOAuth2Client](http://www.github.com/AFNetworking/AFOAuth2Client).

![Demo app screenshot paper](https://github.com/shazino/MendeleySDK/wiki/images/demo-app-screenshot-paper.png) 
![Demo app screenshot publication](https://github.com/shazino/MendeleySDK/wiki/images/demo-app-screenshot-pub.png)

## Getting Started

### Installation

[CocoaPods](http://cocoapods.org) is the recommended way to add MendeleySDK to your project.

Here’s an example podfile that installs MendeleySDK and its dependency, AFOAuth2Client. 

```ruby
platform :ios, '5.0'

pod 'MendeleySDK', '1.3.2'
```

### App credentials

Configure the shared API client by calling `configureSharedClientWithClientID:secret:redirectURI:` with your application consumer key, secret, and redirect URI (in your `application:didFinishLaunchingWithOptions:`, for instance):

```objective-c
[MDLMendeleyAPIClient configureSharedClientWithClientID:@"###my_consumer_key###"
                                                 secret:@"###my_consumer_secret###"
                                            redirectURI:@"###mdl-custom-scheme://oauth?###"];
```

If you don’t have a consumer key and secret, go to the [Mendeley Developers Portal](https://sites.google.com/site/mendeleyapi/home/authentication) and register your application first.

**Note: if you already had an application for OAuth 1.0, you’ll need to register a new application for OAuth 2.0.**

### OAuth authorization flow

Once the API client is configured, you need to present a web browser with a `authenticationWebURL` request. This page will make sure that your application is properly recognized, and prompt the user for his credentials. You can either use an in-app `UIWebView`, or open Safari and catch the response with a custom URL scheme. 

After being logged in, you’ll get an authorization code. You can then validate this code in order to obtain the access and refresh tokens with `validateOAuthCode:success:failure:`.

Okay, you should be ready to go now! You can also take a look at the demo apps and see how things work.

## Examples

### How to create a new document

```objective-c
[MDLDocument createNewDocumentWithTitle:@"title" success:^(MDLDocument *document) {
     /* ... */
} failure:^(NSError *error) {
    /* ... */
}];
```

### How to upload a file

```objective-c
MDLDocument *document;
[document uploadFileAtURL:localFileURL success:^() {
    /* ... */
} failure:^(NSError *error) {
    /* ... */
}];
```

## References

- [Documentation](http://shazino.github.com/MendeleySDK/)
- [Changelog](https://github.com/shazino/MendeleySDK/wiki/Changelog)
- [Contribute](https://github.com/shazino/MendeleySDK/wiki/Contribute)

## Requirements

MendeleySDK requires Xcode 4.4 with either the
 [iOS 5.0](http://developer.apple.com/library/ios/#releasenotes/General/WhatsNewIniPhoneOS/Articles/iOS5.html)
 or [Mac OS 10.6](http://developer.apple.com/library/mac/#releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_6.html#//apple_ref/doc/uid/TP40008898-SW7)
 ([64-bit with modern Cocoa runtime](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtVersionsPlatforms.html)) SDK,
 as well as [AFOAuth2Client](https://github.com/AFNetworking/AFOAuth2Client).

## Credits

MendeleySDK is developed by [shazino](http://www.shazino.com).

## License

MendeleySDK is available under the MIT license. See the LICENSE file for more info.
