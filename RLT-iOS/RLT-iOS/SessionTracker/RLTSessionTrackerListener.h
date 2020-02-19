//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RLTSessionTrackerListenerSessionStartedCallback)(BOOL firstSession);

typedef void (^RLTSessionTrackerListenerSessionEndedCallback)(NSTimeInterval duration);

@interface RLTSessionTrackerListener : NSObject

@property(nonatomic, copy) RLTSessionTrackerListenerSessionStartedCallback sessionStartedCallback;
@property(nonatomic, copy) RLTSessionTrackerListenerSessionEndedCallback sessionEndedCallback;

+ (instancetype)listenerWithSessionStartedCallback:(RLTSessionTrackerListenerSessionStartedCallback)sessionStartedCallback sessionEndedCallback:(RLTSessionTrackerListenerSessionEndedCallback)sessionEndedCallback;

@end