//
// MDLResponseInfo.m
//
// Copyright (c) 2015-2016 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLResponseInfo.h"

#import "MDLMendeleyAPIClient.h"


@implementation MDLResponseInfo

+ (nullable NSString *)substringOfString:(nonnull NSString *)string
                                 between:(nonnull NSString *)startString
                                     and:(nonnull NSString *)endString {
    NSRange rangeOfStartMark = [string rangeOfString:startString];
    if (rangeOfStartMark.location == NSNotFound) {
        return nil;
    }

    NSUInteger location = rangeOfStartMark.location + rangeOfStartMark.length;

    NSRange rangeOfEndMark = [string rangeOfString:endString
                              options:kNilOptions
                              range:NSMakeRange(location, string.length - location)];

    if (rangeOfEndMark.location == NSNotFound) {
        return nil;
    }

    NSRange range = NSMakeRange(location, rangeOfEndMark.location - location);
    return [string substringWithRange:range];
}

+ (nonnull instancetype)infoWithHTTPResponse:(nonnull NSHTTPURLResponse *)response {
    MDLResponseInfo *info = [self new];
    NSString *link = [response.allHeaderFields objectForKey:@"Link"];
    NSArray <NSString *> *components = [link componentsSeparatedByString:@","];

    for (NSString *component in components) {
        NSString *path = [self substringOfString:component between:[@"<" stringByAppendingString:MDLMendeleyAPIBaseURLString] and:@">"];
        NSString *rel  = [self substringOfString:component between:@"rel=\"" and:@"\""];
        if ([rel isEqualToString:@"next"]) {
            info.nextPagePath = path;
        }
        else if ([rel isEqualToString:@"previous"]) {
            info.previousPagePath = path;
        }
        else if ([rel isEqualToString:@"first"]) {
            info.firstPagePath = path;
        }
        else if ([rel isEqualToString:@"last"]) {
            info.lastPagePath = path;
        }
    }

    return info;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@\n(first: %@,\n previous: %@,\n next: %@,\n last: %@)",
            [super description], self.firstPagePath, self.previousPagePath, self.nextPagePath, self.lastPagePath];
}

@end
