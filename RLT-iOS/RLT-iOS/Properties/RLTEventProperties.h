//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTBaseProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface RLTEventProperties : RLTBaseProperties

+ (instancetype)instance;

- (instancetype)set:(id _Nullable)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END