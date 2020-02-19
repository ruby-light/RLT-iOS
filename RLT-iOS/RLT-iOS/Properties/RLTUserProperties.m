//
// Created by Alexey Chirkov on 27/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTUserProperties.h"
#import "RLTFormats.h"
#import "RLTUserPropertyValue.h"
#import "RLTLogger.h"

NS_ASSUME_NONNULL_BEGIN

@implementation RLTUserProperties

+ (instancetype)instance {
    return [[RLTUserProperties alloc] init];
}

- (instancetype)set:(NSString *_Nullable)value forKey:(NSString *)key {
    if (key) {
        RLTUserPropertyValue *userPropertiesValue = [[RLTUserPropertyValue alloc] initWithOperation:RLT__PROPERTY_OPERATION__SET value:value];
        self.properties[key] = userPropertiesValue;
    }
    return self;
}

- (instancetype)unset:(NSString *)key {
    if (key) {
        RLTUserPropertyValue *userPropertiesValue = [[RLTUserPropertyValue alloc] initWithOperation:RLT__PROPERTY_OPERATION__UNSET value:[NSNull null]];
        self.properties[key] = userPropertiesValue;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END