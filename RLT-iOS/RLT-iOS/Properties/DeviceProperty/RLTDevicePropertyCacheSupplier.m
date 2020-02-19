//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTDevicePropertyCacheSupplier.h"
#import "RLTLogger.h"

@interface RLTDevicePropertyCacheSupplier ()
@property(nonatomic) NSObject *value;
@end

@implementation RLTDevicePropertyCacheSupplier

- (NSObject *)getValue {
    if (!self.value) {
        self.value = [super getValue];
    }
    return self.value;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToSupplier:other];
}

- (BOOL)isEqualToSupplier:(RLTDevicePropertyCacheSupplier *)supplier {
    if (self == supplier)
        return YES;
    if (supplier == nil)
        return NO;
    if (self.value != supplier.value && ![self.value isEqual:supplier.value])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.value hash];
}


@end