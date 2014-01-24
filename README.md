# MendeleySDK
**Objective-C client for the Mendeley Open API.**
[![Build Status](https://travis-ci.org/shazino/MendeleySDK.png?branch=master)](https://travis-ci.org/shazino/MendeleySDK)

MendeleySDK is a [Mendeley API](http://apidocs.mendeley.com) client for iOS and Mac OS X, built on top of [AFNetworking](http://www.github.com/AFNetworking/AFNetworking) and [AFOAuth1Client](http://www.github.com/AFNetworking/AFOAuth1Client).

![Demo app screenshot paper](https://github.com/shazino/MendeleySDK/wiki/images/demo-app-screenshot-paper.png) ![Demo app screenshot publication](https://github.com/shazino/MendeleySDK/wiki/images/demo-app-screenshot-pub.png)

## Getting Started

### Installation

[CocoaPods](http://cocoapods.org) is the recommended way to add MendeleySDK to your project.

Here’s an example podfile that installs MendeleySDK and its dependency, AFOAuth1Client. 

```ruby
platform :ios, '5.0'

pod 'MendeleySDK', '1.3.2'
```

### App credentials

Define your API consumer key and secret (in your AppDelegate.m, for instance):

```objective-c
NSString * const MDLConsumerKey    = @"###my_consumer_key###";
NSString * const MDLConsumerSecret = @"###my_consumer_secret###";
```

If you don’t have a consumer key and secret, go to the [Mendeley Developers Portal](http://dev.mendeley.com/applications/register/) and register your application first.

### OAuth callback URL

The Mendeley Open API uses [3leg OAuth 1.0](http://apidocs.mendeley.com/home/authentication) authentication. In order to gain access to protected resources, your application will open Mobile Safari and prompt for user credentials. iOS will then switch back to your application using a custom URL scheme. It means that you need to set it up in your Xcode project.

- Open the project editor, select your main target, click the Info button.
- Add a URL Type, and type a unique URL scheme (for instance ’mymendeleyclient’).

![Xcode URL types](https://github.com/shazino/MendeleySDK/wiki/images/Xcode-URL-types.png)

- Update your app delegate to notify MendeleySDK as following:

```objective-c
#import "AFOAuth1Client.h"

NSString * const MDLURLScheme = @"##my_URL_scheme##";

(…)

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:MDLURLScheme])
    {
        NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:@{kAFApplicationLaunchOptionsURLKey: url}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return YES;
}
```
_Note: you can skip this step if you only use public resources_

Okay, you should be ready to go now! You can also take a look at the demo iOS app and see how things work.

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

MendeleySDK requires Xcode 4.4 with either the [iOS 5.0](http://developer.apple.com/library/ios/#releasenotes/General/WhatsNewIniPhoneOS/Articles/iOS5.html) or [Mac OS 10.6](http://developer.apple.com/library/mac/#releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_6.html#//apple_ref/doc/uid/TP40008898-SW7) ([64-bit with modern Cocoa runtime](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtVersionsPlatforms.html)) SDK, as well as [AFOAuth1Client](https://github.com/AFNetworking/AFOAuth1Client).

## Credits

MendeleySDK is developed by [shazino](http://www.shazino.com).

## License

MendeleySDK is available under the MIT license. See the LICENSE file for more info.
