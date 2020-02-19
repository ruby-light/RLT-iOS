//
// Created by Alexey Chirkov on 27/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTClientWrapper.h"
#import "RLTLogger.h"

@protocol RLTEventPropertiesProtocol;

@interface RLTClientWrapper ()
@end

@implementation RLTClientWrapper

- (id <RLTClient>)setUserId:(NSString *)userId {
    if (![self.client setUserId:userId]) {
        RLTLoggerWarn(@"Ignore setUserId, statistics not initialized");
    }
    return self;
}

- (id <RLTClient>)resetUserId:(BOOL)regenerateDeviceId {
    if (![self.client resetUserId:regenerateDeviceId]) {
        RLTLoggerWarn(@"Ignore resetUserId, statistics not initialized");
    }
    return self;
}

- (id <RLTClient>)logUserProperties:(RLTUserProperties *)userProperties {
    if (![self.client logUserProperties:userProperties]) {
        RLTLoggerWarn(@"Ignore logUserProperties, statistics not initialized");
    }
    return self;
}

- (id <RLTClient>)logEvent:(NSString *)eventName {
    if (![self.client logEvent:eventName]) {
        RLTLoggerWarn(@"Ignore logEvent, statistics not initialized");
    }
    return self;
}

- (id <RLTClient>)logEvent:(NSString *)eventName eventProperties:(RLTEventProperties *_Nullable)eventProperties {
    if (![self.client logEvent:eventName eventProperties:eventProperties]) {
        RLTLoggerWarn(@"Ignore logEvent:eventProperties, statistics not initialized");
    }
    return self;
}

- (void)flush {
    [self.client flush];
}


@end