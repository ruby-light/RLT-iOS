//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLTSessionTracker;
@class RLTSessionTrackerListener;

@protocol RLTSessionTrackerState <NSObject>
- (id <RLTSessionTrackerState>)toBackground:(RLTSessionTrackerListener *)listener timer:(NSTimer *)timer;

- (id <RLTSessionTrackerState>)toForeground:(RLTSessionTrackerListener *)listener timer:(NSTimer *)timer;

- (id <RLTSessionTrackerState>)sessionExpirationEventOn:(id <RLTSessionTrackerState>)state listener:(RLTSessionTrackerListener *)listener;
@end

@interface RLTSessionTrackerState : NSObject <RLTSessionTrackerState>

@property(nonatomic, weak) RLTSessionTracker *sessionTracker;

- (instancetype)initWithTracker:(RLTSessionTracker *)sessionTracker;

@end