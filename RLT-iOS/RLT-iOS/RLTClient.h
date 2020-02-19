//
// Created by Alexey Chirkov on 27/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTEventProperties.h"
#import "RLTUserProperties.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RLTClient <NSObject>

- (id <RLTClient>)setUserId:(NSString *)userId;

- (id <RLTClient>)resetUserId:(BOOL)regenerateDeviceId;

- (id <RLTClient>)logUserProperties:(RLTUserProperties *)userProperties;

- (id <RLTClient>)logEvent:(NSString *)eventName;

- (id <RLTClient>)logEvent:(NSString *)eventName eventProperties:(RLTEventProperties *_Nullable)eventProperties;

- (void)flush;

@end

NS_ASSUME_NONNULL_END