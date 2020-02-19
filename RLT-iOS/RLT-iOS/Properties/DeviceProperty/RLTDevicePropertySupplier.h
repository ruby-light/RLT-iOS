//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSObject *_Nullable (^RLTDevicePropertySupplierGetValueCallback)(void);

@protocol RLTDevicePropertySupplierProtocol <NSObject>
- (NSObject *)getValue;
@end

@interface RLTDevicePropertySupplier : NSObject <RLTDevicePropertySupplierProtocol>

+ (id <RLTDevicePropertySupplierProtocol>)supplierWithCallback:(RLTDevicePropertySupplierGetValueCallback)callback;

@end

NS_ASSUME_NONNULL_END
