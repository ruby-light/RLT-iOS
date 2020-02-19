//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTEventProperties.h"

NS_ASSUME_NONNULL_BEGIN

@implementation RLTEventProperties

+ (instancetype)instance {
    return [[RLTEventProperties alloc] init];
}

- (instancetype)set:(id _Nullable)value forKey:(NSString *)key {
    if (key) {
        if (value) {
            self.properties[key] = value;
        } else {
            self.properties[key] = [NSNull null];
        }
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END