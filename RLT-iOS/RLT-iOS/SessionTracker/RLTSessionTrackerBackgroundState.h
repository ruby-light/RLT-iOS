//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTSessionTrackerState.h"

@interface RLTSessionTrackerBackgroundState : RLTSessionTrackerState
@property(nonatomic, readonly) BOOL coldStart;

- (instancetype)initWithTracker:(RLTSessionTracker *)sessionTracker coldStart:(BOOL)coldStart;

@end