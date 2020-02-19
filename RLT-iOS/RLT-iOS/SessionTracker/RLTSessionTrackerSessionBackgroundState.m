//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTSessionTrackerSessionBackgroundState.h"
#import "RLTUtils.h"
#import "RLTSessionTracker.h"
#import "RLTSessionTrackerSessionForegroundState.h"
#import "RLTSessionTrackerBackgroundState.h"
#import "RLTLogger.h"


@interface RLTSessionTrackerSessionBackgroundState ()
@property(nonatomic, readwrite) NSTimeInterval startSession;
@property(nonatomic, readwrite) NSTimeInterval startBackground;
@property(nonatomic) NSTimer *timer;
@property(nonatomic) NSTimeInterval timeout;
@end

@implementation RLTSessionTrackerSessionBackgroundState

- (instancetype)initWithTracker:(RLTSessionTracker *)sessionTracker startSession:(NSTimeInterval)startSession startBackground:(NSTimeInterval)startBackground {
    self = [super initWithTracker:sessionTracker];
    if (self) {
        self.timeout = 30.0f;
        self.startSession = startSession;
        self.startBackground = startBackground;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(onTimerFired:) userInfo:nil repeats:NO];
    }
    return self;
}

- (id <RLTSessionTrackerState>)toForeground:(RLTSessionTrackerListener *)listener timer:(NSTimer *)timer {
    NSTimeInterval time = [RLTUtils systemUptime];

    [self.timer invalidate];
    self.timer = nil;

    if ((time - _startBackground) < self.timeout) {
        return [[RLTSessionTrackerSessionForegroundState alloc] initWithTracker:self.sessionTracker startSession:self.startSession];
    } else {
        listener.sessionEndedCallback(self.startBackground - self.startSession);
        listener.sessionStartedCallback(NO);
        return [[RLTSessionTrackerSessionForegroundState alloc] initWithTracker:self.sessionTracker startSession:time];
    }
}

- (id <RLTSessionTrackerState>)sessionExpirationEventOn:(id <RLTSessionTrackerState>)state listener:(RLTSessionTrackerListener *)listener {
    if (state == self) {
        listener.sessionEndedCallback(self.startBackground - self.startSession);
        return [[RLTSessionTrackerBackgroundState alloc] initWithTracker:self.sessionTracker coldStart:NO];
    }
    return self;
}

#pragma mark Internal

- (void)onTimerFired:(NSTimer *)timer {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRLTSessionTrackerSessionExpiredNotification object:self];
}

@end
