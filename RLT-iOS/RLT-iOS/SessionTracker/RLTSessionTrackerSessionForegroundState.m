//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTSessionTrackerSessionForegroundState.h"
#import "RLTUtils.h"
#import "RLTSessionTrackerSessionBackgroundState.h"
#import "RLTLogger.h"


@interface RLTSessionTrackerSessionForegroundState ()
@property(nonatomic, readwrite) NSTimeInterval startSession;
@end

@implementation RLTSessionTrackerSessionForegroundState

- (instancetype)initWithTracker:(RLTSessionTracker *)sessionTracker startSession:(NSTimeInterval)startSession {
    self = [super initWithTracker:sessionTracker];
    if (self) {
        self.startSession = startSession;
    }
    return self;
}

- (id <RLTSessionTrackerState>)toBackground:(RLTSessionTrackerListener *)listener timer:(NSTimer *)timer {
    NSTimeInterval time = [RLTUtils systemUptime];
    return [[RLTSessionTrackerSessionBackgroundState alloc] initWithTracker:self.sessionTracker startSession:self.startSession startBackground:time];
}

- (id <RLTSessionTrackerState>)toForeground:(RLTSessionTrackerListener *)listener timer:(NSTimer *)timer {
    //do nothing. this may happen e.g. after siri is closed
    return self;
}
@end
