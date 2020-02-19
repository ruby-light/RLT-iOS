//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTSessionTrackerListener.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kRLTSessionTrackerSessionExpiredNotification;

@interface RLTSessionTracker : NSObject

+ (instancetype)enableSessionTracking:(NSTimeInterval)timeout listener:(RLTSessionTrackerListener *)listener;

@end

NS_ASSUME_NONNULL_END
