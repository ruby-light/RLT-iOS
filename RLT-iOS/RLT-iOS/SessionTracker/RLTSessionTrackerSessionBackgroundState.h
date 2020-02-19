//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTSessionTrackerState.h"

@interface RLTSessionTrackerSessionBackgroundState : RLTSessionTrackerState

@property(nonatomic, readonly) NSTimeInterval startSession;
@property(nonatomic, readonly) NSTimeInterval startBackground;

- (instancetype)initWithTracker:(RLTSessionTracker *)sessionTracker startSession:(NSTimeInterval)startSession startBackground:(NSTimeInterval)startBackground;

@end