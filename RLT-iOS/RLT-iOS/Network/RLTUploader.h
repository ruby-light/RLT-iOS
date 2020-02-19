//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLTConfiguration;

NS_ASSUME_NONNULL_BEGIN

typedef void (^RLTUploaderFlushCallback)(BOOL success);

@interface RLTUploader : NSObject

- (instancetype)initWithConfiguration:(RLTConfiguration *)configuration;

- (void)uploadReports:(NSString *)reportsContent callback:(RLTUploaderFlushCallback)callback;

@end

NS_ASSUME_NONNULL_END