//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTSessionTrackerListener.h"
#import "RLTLogger.h"


@implementation RLTSessionTrackerListener

+ (instancetype)listenerWithSessionStartedCallback:(RLTSessionTrackerListenerSessionStartedCallback)sessionStartedCallback sessionEndedCallback:(RLTSessionTrackerListenerSessionEndedCallback)sessionEndedCallback {
    RLTSessionTrackerListener *sessionTrackerListener = [[self alloc] init];
    sessionTrackerListener.sessionStartedCallback = sessionStartedCallback;
    sessionTrackerListener.sessionEndedCallback = sessionEndedCallback;
    return sessionTrackerListener;
}

@end