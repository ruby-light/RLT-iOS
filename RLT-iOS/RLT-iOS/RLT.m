//
// Created by Alexey Chirkov on 27/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLT.h"
#import "RLTClientWrapper.h"
#import "RLTClientImpl.h"

@interface RLT ()
@property(nonatomic) RLTClientWrapper *clientWrapper;
@end

@implementation RLT

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clientWrapper = [[RLTClientWrapper alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static RLT *_id = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _id = [[RLT alloc] init];
    });
    return _id;
}

- (id <RLTClient>)initializeWithApiKey:(NSString *)apiKey {
    return [self initializeWithApiKey:apiKey initConfig:[[RLTInitConfig alloc] init]];
}

+ (id <RLTClient>)initializeWithApiKey:(NSString *)apiKey {
    return [[RLT sharedInstance] initializeWithApiKey:apiKey];
}

- (id <RLTClient>)initializeWithApiKey:(NSString *)apiKey initConfig:(RLTInitConfig *)initConfig {
    RLTClientWrapper *clientWrapper = self.clientWrapper;
    if (clientWrapper.client) {
        RLTLoggerWarn(@"Ignore initialize. Statistics yet initialized.");
    } else {
        [RLTLogger setLogger:initConfig.logger];
        clientWrapper.client = [[RLTClientImpl alloc] initWithApiKey:apiKey initConfig:initConfig];
    }
    return clientWrapper;
}

+ (id <RLTClient>)initializeWithApiKey:(NSString *)apiKey initConfig:(RLTInitConfig *)initConfig {
    return [[RLT sharedInstance] initializeWithApiKey:apiKey initConfig:initConfig];
}

- (id <RLTClient>)getClient {
    return self.clientWrapper;
}

+ (id <RLTClient>)getClient {
    return [[RLT sharedInstance] getClient];
}

#pragma mark Client

+ (id <RLTClient>)setUserId:(NSString *)userId {
    return [[RLT getClient] setUserId:userId];
}

+ (id <RLTClient>)resetUserId:(BOOL)regenerateDeviceId {
    return [[RLT getClient] resetUserId:regenerateDeviceId];
}

+ (id <RLTClient>)logUserProperties:(RLTUserProperties *)userProperties {
    return [[RLT getClient] logUserProperties:userProperties];
}

+ (id <RLTClient>)logEvent:(NSString *)eventName {
    return [[RLT getClient] logEvent:eventName];
}

+ (id <RLTClient>)logEvent:(NSString *)eventName eventProperties:(RLTEventProperties *)eventProperties {
    return [[RLT getClient] logEvent:eventName eventProperties:eventProperties];
}

+ (void)flush {
    [[RLT getClient] flush];
}

@end
