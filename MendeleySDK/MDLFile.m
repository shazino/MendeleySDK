//
// MDLFile.m
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

#import "MDLFile.h"

#import "MDLMendeleyAPIClient.h"
#import "MDLDocument.h"
#import "MDLGroup.h"

@implementation MDLFile

+ (NSString *)objectType {
    return MDLMendeleyObjectTypeFile;
}

+ (NSString *)path {
    return @"/files";
}

- (void)updateWithServerResponseObject:(id)responseObject {
    [super updateWithServerResponseObject:responseObject];

    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return;
    }

    self.fileName           = responseObject[@"file_name"];
    self.MIMEType           = responseObject[@"mime_type"];
    self.fileHash           = responseObject[@"filehash"];
    self.sizeInBytes        = responseObject[@"size"];
    self.documentIdentifier = responseObject[@"document_id"];
}

- (AFHTTPRequestOperation *)downloadWithClient:(MDLMendeleyAPIClient *)client
                                  toFileAtPath:(NSString *)path
                                      progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
                                       success:(void (^)())success
                                       failure:(void (^)(NSError *))failure {
    return [client getPath:self.objectPath
                parameters:nil
  outputStreamToFileAtPath:path
                  progress:progress
                   success:^(AFHTTPRequestOperation *requestOperation, id responseObject) {
                       if (success) {
                           success();
                       }
                   }
                   failure:failure];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ (hash: %@; MIME type: %@; size: %@)",
            [super description], self.fileHash, self.MIMEType, self.sizeInBytes];
}

@end
