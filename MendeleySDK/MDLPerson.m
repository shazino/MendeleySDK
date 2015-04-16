//
// MDLPerson.m
//
// Copyright (c) 2012-2015 shazino (shazino SAS), http://www.shazino.com/
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

#import "MDLPerson.h"

@implementation MDLPerson

+ (NSString *)path {
    return @"/profile";
}

+ (instancetype)personWithFirstName:(NSString *)firstName
                           lastName:(NSString *)lastName {
    MDLPerson *author = [MDLPerson new];
    author.firstName = firstName;
    author.lastName  = lastName;
    return author;
}

+ (NSArray *)personsFromServerResponseObject:(id)responseObject {
    if (![responseObject isKindOfClass:NSArray.class]) {
        return nil;
    }

    NSArray *responseArray = responseObject;
    NSMutableArray *persons = [NSMutableArray arrayWithCapacity:responseArray.count];
    for (NSDictionary *personAttributes in responseArray) {
        if (![personAttributes isKindOfClass:NSDictionary.class]) {
            continue;
        }

        MDLPerson *person = [MDLPerson personWithFirstName:personAttributes[@"first_name"]
                                                  lastName:personAttributes[@"last_name"]];
        if (person) {
            [persons addObject:person];
        }
    }

    return persons;
}

- (NSDictionary *)requestObject {
    return @{@"first_name": self.firstName ?: @"",
             @"last_name":  self.lastName ?: @"" };
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ (first name: %@; last name: %@)",
            [super description], self.firstName, self.lastName];
}

@end
