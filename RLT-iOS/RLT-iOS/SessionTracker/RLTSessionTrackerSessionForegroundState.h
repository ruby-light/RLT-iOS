//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTSessionTrackerState.h"

@interface RLTSessionTrackerSessionForegroundState : RLTSessionTrackerState
@property(nonatomic, readonly) NSTimeInterval startSession;

- (instancetype)initWithTracker:(RLTSessionTracker *)sessionTracker startSession:(NSTimeInterval)startSession;
@end