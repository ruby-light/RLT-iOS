//
// Created by Alexey Chirkov on 27/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTLogger.h"
#import "RLTClient.h"
#import "RLTInitConfig.h"
#import "RLTEventProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface RLT : NSObject

+ (instancetype)sharedInstance;

+ (id <RLTClient>)initializeWithApiKey:(NSString *)apiKey;

- (id <RLTClient>)initializeWithApiKey:(NSString *)apiKey;

+ (id <RLTClient>)initializeWithApiKey:(NSString *)apiKey initConfig:(RLTInitConfig *)initConfig;

- (id <RLTClient>)initializeWithApiKey:(NSString *)apiKey initConfig:(RLTInitConfig *)initConfig;

+ (id <RLTClient>)getClient;

- (id <RLTClient>)getClient;

#pragma mark Client

+ (id <RLTClient>)setUserId:(NSString *)userId;

+ (id <RLTClient>)resetUserId:(BOOL)regenerateDeviceId;

+ (id <RLTClient>)logUserProperties:(RLTUserProperties *)userProperties;

+ (id <RLTClient>)logEvent:(NSString *)eventName;

+ (id <RLTClient>)logEvent:(NSString *)eventName eventProperties:(RLTEventProperties *)eventProperties;

+ (void)flush;

@end

NS_ASSUME_NONNULL_END
