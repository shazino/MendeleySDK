# MendeleySDK
**Objective-C client for the Mendeley API.**
[![Build Status](https://travis-ci.org/shazino/MendeleySDK.png?branch=master)](https://travis-ci.org/shazino/MendeleySDK)

MendeleySDK is a [Mendeley API](http://dev.mendeley.com) client for iOS and OS X, built on top of [AFNetworking](http://www.github.com/AFNetworking/AFNetworking) and [AFOAuth2Client](http://www.github.com/AFNetworking/AFOAuth2Client).

![Demo app screenshot paper](https://github.com/shazino/MendeleySDK/wiki/images/demo-app-screenshot-paper.png) 


## Getting Started

### Installation

[CocoaPods](http://cocoapods.org) is the recommended way to add MendeleySDK to your project.

Here’s an example podfile that installs MendeleySDK and its dependency, AFOAuth2Client. 

```ruby
platform :ios, '5.0'

pod 'MendeleySDK', '2.1'
```

### App credentials

Configure your API client by calling `clientWithClientID:secret:redirectURI:` with your application client ID, client secret, and redirect URI (in your `application:didFinishLaunchingWithOptions:`, for instance):

```objective-c
MDLMendeleyAPIClient *APIClient = [MDLMendeleyAPIClient clientWithClientID:@"###my_client_ID###"
                                                                    secret:@"###my_client_secret###"
                                                               redirectURI:@"###mdl-custom-scheme://oauth?###"];
```

If you don’t have a consumer key and secret, go to the [Mendeley Developers Portal](http://dev.mendeley.com) and register your application first.


### OAuth authorization flow

Once the API client is configured, you need to present a web browser with a `authenticationWebURL` request. This page will make sure that your application is properly recognized, and prompt the user for his credentials. You can either use an in-app `UIWebView`, or open Safari and catch the response with a custom URL scheme. 

After being logged in, you’ll get an authorization code. You can then validate this code in order to obtain the access and refresh tokens with `validateOAuthCode:success:failure:`.

As of today, MendeleySDK doesn’t support the client credentials flow for public resources.

Okay, you should be ready to go now! You can also take a look at the demo apps and see how things work.


## Examples

### How to create a new document

```objective-c
MDLDocument *document = [[MDLDocument alloc] init];
document.title = @"My Title";
[document createWithClient:self.APIClient success:^(MDLObject *document) {
     /* ... */
} failure:^(NSError *error) {
    /* ... */
}];
```

### How to upload a file

```objective-c
MDLDocument *document;
[document uploadFileWithClient:self.APIClient 
                         atURL:localFileURL
                   contentType:@"application/pdf"
                      fileName:@"file.pdf"
                       success:^(MDLFile *newFile) {
                       /* ... */
                   } 
                   failure:^(NSError *error) {
                   /* ... */
               }];
```


## References

- [Documentation (CocoaDocs)](http://cocoadocs.org/docsets/MendeleySDK)


## Requirements

MendeleySDK requires Xcode 7.0 with either the iOS 5.0 or OS X 10.7 SDK,
 as well as [AFOAuth2Client](https://github.com/AFNetworking/AFOAuth2Client).


## Credits

MendeleySDK is developed by [shazino](http://www.shazino.com).


## License

MendeleySDK is available under the MIT license. See the LICENSE file for more info.
