//
// Created by Alexey Chirkov on 20/02/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RLTSessionTrackerDelegate <NSObject>

/**
 * Called when "StartSession" event is logged
 */
- (void)onStartSessionEvent;

/**
 * Called when "StartApp" event is logged
 */
- (void)onStartAppEvent;

@end