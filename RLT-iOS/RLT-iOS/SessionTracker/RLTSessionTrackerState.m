//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTSessionTrackerState.h"
#import "RLTSessionTracker.h"

@implementation RLTSessionTrackerState

- (instancetype)initWithTracker:(RLTSessionTracker *)sessionTracker {
    self = [super init];
    if (self) {
        self.sessionTracker = sessionTracker;
    }
    return self;
}

- (id <RLTSessionTrackerState>)toBackground:(RLTSessionTrackerListener *)listener timer:(NSTimer *)timer {
    NSAssert(NO, @"Must be overriden!");
    return nil;
}

- (id <RLTSessionTrackerState>)toForeground:(RLTSessionTrackerListener *)listener timer:(NSTimer *)timer {
    NSAssert(NO, @"Must be overriden!");
    return nil;
}

- (id <RLTSessionTrackerState>)sessionExpirationEventOn:(id <RLTSessionTrackerState>)state listener:(RLTSessionTrackerListener *)listener {
    NSAssert(NO, @"Must be overriden!");
    return nil;
}

@end