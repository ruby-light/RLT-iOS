//
// Created by Alexey Chirkov on 27/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTBaseProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface RLTUserProperties : RLTBaseProperties

+ (instancetype)instance;

- (instancetype)set:(NSString *_Nullable)value forKey:(NSString *)key;

- (instancetype)unset:(NSString *)key;

@end

NS_ASSUME_NONNULL_END