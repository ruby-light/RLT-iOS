//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTDevicePropertyConfig.h"

@protocol RLTLoggerProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface RLTInitConfig : NSObject

@property(nonatomic) NSString *_Nullable serverUrl;
@property(nonatomic) RLTDevicePropertyConfig *_Nullable devicePropertyConfig;
@property(nonatomic) NSString *_Nullable initialDeviceId;
@property(nonatomic) NSString *_Nullable initialUserId;

@property(nonatomic) NSURLSession *_Nullable URLSession;

@property(nonatomic) BOOL enableStartAppEvent;
@property(nonatomic) BOOL enableSessionTracking;
@property(nonatomic) NSTimeInterval sessionTimeout;

@property(nonatomic) NSTimeInterval uploadTimeout;
@property(nonatomic) int uploadReportsCount;
@property(nonatomic) NSTimeInterval uploadReportsPeriod;

@property(nonatomic) id<RLTLoggerProtocol>_Nullable logger;

@property(nonatomic) BOOL dryRunEnabled;

@end

NS_ASSUME_NONNULL_END