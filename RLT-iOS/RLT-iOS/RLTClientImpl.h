//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTClient.h"

@class RLTInitConfig;

NS_ASSUME_NONNULL_BEGIN

@interface RLTClientImpl : NSObject <RLTClient>

- (id <RLTClient>)initWithApiKey:(NSString *)apiKey initConfig:(RLTInitConfig *)initConfig;

@end

NS_ASSUME_NONNULL_END