//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTDevicePropertySupplier.h"

NS_ASSUME_NONNULL_BEGIN

@interface RLTDevicePropertyConfig : NSObject
@property(nonatomic, readonly) NSMutableDictionary <NSString *, RLTDevicePropertySupplier *> *properties;

- (instancetype)trackPlatform;

- (instancetype)trackModel;

- (instancetype)trackBrand;

- (instancetype)trackManufacturer;

- (instancetype)trackOsVersion;

- (instancetype)trackAppVersion;

- (instancetype)trackCountry;

- (instancetype)trackLanguage;

- (instancetype)trackCarrier;

- (instancetype)trackCacheProperty:(NSString *)propertyName callback:(RLTDevicePropertySupplierGetValueCallback)callback;

- (instancetype)trackProperty:(NSString *)propertyName callback:(RLTDevicePropertySupplierGetValueCallback)callback;

@end

NS_ASSUME_NONNULL_END