//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTSessionTrackerBackgroundState.h"
#import "RLTSessionTrackerListener.h"
#import "RLTUtils.h"
#import "RLTSessionTrackerSessionForegroundState.h"
#import "RLTLogger.h"

@interface RLTSessionTrackerBackgroundState ()
@property(nonatomic, readwrite) BOOL coldStart;
@end

@implementation RLTSessionTrackerBackgroundState

- (instancetype)initWithTracker:(RLTSessionTracker *)sessionTracker coldStart:(BOOL)coldStart {
    self = [super initWithTracker:sessionTracker];
    if (self) {
        self.coldStart = coldStart;
    }
    return self;
}

- (id <RLTSessionTrackerState>)toForeground:(RLTSessionTrackerListener *)listener timer:(NSTimer *)timer {
    NSTimeInterval startSession = [RLTUtils systemUptime];
    [timer invalidate];

    listener.sessionStartedCallback(_coldStart);
    return [[RLTSessionTrackerSessionForegroundState alloc] initWithTracker:self.sessionTracker startSession:startSession];
}

@end
