//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTUploader.h"
#import "RLTConfiguration.h"
#import "RLTLogger.h"
#import "RLTFormats.h"
#import "RLTDeflate.h"

#define USE_DEFLATE YES

@interface RLTUploader ()
@property(nonatomic, weak) RLTConfiguration *configuration;
@end

@implementation RLTUploader

- (instancetype)initWithConfiguration:(RLTConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.configuration = configuration;
    }
    return self;
}

- (void)uploadReports:(NSString *)reportsContent callback:(RLTUploaderFlushCallback)callback {
    RLTLoggerLog(@"Will upload reports: %@", reportsContent);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.configuration.serverUrl]];
    [request setTimeoutInterval:self.configuration.uploadTimeout];

    NSData *data = [reportsContent dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%@/%@", RLT__LIBRARY_NAME, RLT__LIBRARY_VERSION] forHTTPHeaderField:@"User-Agent"];
    [request setValue:RLT__API_VERSION forHTTPHeaderField:@"Api-Version"];
    [request setValue:self.configuration.apiKey forHTTPHeaderField:@"Api-Key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (USE_DEFLATE) {
        data = [RLTDeflate rlt_compress:data];
        [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    }

    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long) [data length]] forHTTPHeaderField:@"Content-Length"];

    [request setHTTPBody:data];

    [[self.configuration.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL success = NO;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (httpResponse) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
            NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
            NSInteger statusCode = httpResponse.statusCode;
            if (statusCode == 200) {
                RLTLoggerLog( @"Events uploaded. Response text: '%@'", responseText);
                success = YES;
            } else {
                RLTLoggerError(nil, @"Events upload failed with HTTP status code: %li. Response text: '%@'", (long) statusCode, responseText);
            }
        } else if (error) {
            RLTLoggerError(error, @"Events upload failed");
        }

        callback(success);
    }] resume];
}

@end
