# MendeleySDK
**Objective-C client for the Mendeley Open API.**

> _This is still in early stages of development, so proceed with caution when using this in a production application.
> Any bug reports, feature requests, or general feedback at this point would be greatly appreciated._

MendeleySDK is a [Mendeley API](http://apidocs.mendeley.com) client for iOS and Mac OS X. It’s built on top of [AFNetworking](http://www.github.com/AFNetworking/AFNetworking) and [AFOAuth1Client](http://www.github.com/AFNetworking/AFOAuth1Client) to deal with network operations and authentication.

## Getting Started

### Installation

Drag and drop sources for AFOAuth1Client, AFNetworking, and MendeleySDK into your Xcode project. At this point, AFOAuth1Client and AFNetworking don’t use ARC, so you’ll need to set the `-fno-objc-arc` compiler flag for all their files.

Define your API consumer key and secret (in your AppDelegate.m, for instance):

```objective-c
NSString * const kMDLConsumerKey    = @"###my_consumer_key###";
NSString * const kMDLConsumerSecret = @"###my_consumer_secret###";
```

### Authentication

The Mendeley Open API uses [3leg OAuth 1.0](http://apidocs.mendeley.com/home/authentication) authentication. The application will open Mobile Safari to prompt for user credentials (Mendeley account). iOS will then switch back to your application using a custom URL scheme. It means that you need to it set up in your Xcode project.

- Open the project editor, select your main target, click the Info button.
- Add a URL Type, and type a unique URL scheme (for instance ’mymendeleyclient’).
- Update your app delegate to notify the Mendeley SDK as following:

```objective-c
#import "AFOAuth1Client.h"

NSString * const kMDLURLScheme = @"###my_URL_scheme###";

(…)

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:kMDLURLScheme])
    {
        NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return YES;
}
```

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

MendeleySDK was created by [shazino](http://www.shazino.com).

## License

MendeleySDK is available under the MIT license. See the LICENSE file for more info.