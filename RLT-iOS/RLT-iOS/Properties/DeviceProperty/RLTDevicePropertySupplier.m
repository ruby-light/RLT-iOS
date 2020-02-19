//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTDevicePropertySupplier.h"
#import "RLTLogger.h"

@interface RLTDevicePropertySupplier ()
@property(nonatomic, readwrite, copy) RLTDevicePropertySupplierGetValueCallback callback;
@end

@implementation RLTDevicePropertySupplier

- (instancetype)initWithCallback:(RLTDevicePropertySupplierGetValueCallback)callback {
    self = [super init];
    if (self) {
        self.callback = callback;
    }
    return self;
}

+ (id <RLTDevicePropertySupplierProtocol>)supplierWithCallback:(RLTDevicePropertySupplierGetValueCallback)callback {
    return [[self alloc] initWithCallback:callback];
}

#pragma mark RLTDevicePropertySupplierProtocol

NS_ASSUME_NONNULL_BEGIN

- (NSObject *)getValue {
    if (self.callback) {
        return self.callback();
    }
    return nil;
}

NS_ASSUME_NONNULL_END

@end
