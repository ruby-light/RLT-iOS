//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLTConfiguration;

@interface RLTIdentifyStorage : NSObject

@property(nonatomic) NSString *deviceId;
@property(nonatomic) NSString *userId;

- (instancetype)initWithConfiguration:(RLTConfiguration *)configuration;

- (void)removeAllData;

@end