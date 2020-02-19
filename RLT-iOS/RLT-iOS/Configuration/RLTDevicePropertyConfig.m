//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLTDevicePropertyConfig.h"
#import "RLTDevicePropertyCacheSupplier.h"
#import "RLTDevicePropertyFactory.h"
#import "RLTLogger.h"

@interface RLTDevicePropertyConfig ()
@property(nonatomic) NSMutableDictionary <NSString *, RLTDevicePropertySupplier *> *properties;
@end

@implementation RLTDevicePropertyConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.properties = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)trackPlatform {
    return [self trackCacheProperty:@"platform" callback:^NSObject * {
        return @"ios";
    }];
}

- (instancetype)trackModel {
    return [self trackCacheProperty:@"model" callback:^NSObject * {
        return [RLTDevicePropertyFactory getHWMachine];
    }];
}

- (instancetype)trackBrand {
    return [self trackCacheProperty:@"brand" callback:^NSObject * {
        return @"Apple";
    }];
}

- (instancetype)trackManufacturer {
    return [self trackCacheProperty:@"manufacturer" callback:^NSObject * {
        return @"Apple";
    }];
}

- (instancetype)trackOsVersion {
    return [self trackCacheProperty:@"osVersion" callback:^NSObject * {
        return [[UIDevice currentDevice] systemVersion];
    }];
}

- (instancetype)trackAppVersion {
    return [self trackCacheProperty:@"appVersion" callback:^NSObject * {
        return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    }];
}

- (instancetype)trackCountry {
    return [self trackCacheProperty:@"country" callback:^NSObject * {
        return [RLTDevicePropertyFactory countryISOCode];
    }];
}

- (instancetype)trackLanguage {
    return [self trackCacheProperty:@"language" callback:^NSObject * {
        return [RLTDevicePropertyFactory language];
    }];
}

- (instancetype)trackCarrier {
    return [self trackCacheProperty:@"carrier" callback:^NSObject * {
        return [RLTDevicePropertyFactory carrier];
    }];
}

- (instancetype)trackCacheProperty:(NSString *)propertyName callback:(RLTDevicePropertySupplierGetValueCallback)callback {
    self.properties[propertyName] = [RLTDevicePropertyCacheSupplier supplierWithCallback:callback];
    return self;
}

- (instancetype)trackProperty:(NSString *)propertyName callback:(RLTDevicePropertySupplierGetValueCallback)callback {
    self.properties[propertyName] = [RLTDevicePropertySupplier supplierWithCallback:callback];
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToConfig:other];
}

- (BOOL)isEqualToConfig:(RLTDevicePropertyConfig *)config {
    if (self == config)
        return YES;
    if (config == nil)
        return NO;
    if (self.properties != config.properties && ![self.properties isEqualToDictionary:config.properties])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.properties hash];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.properties=%@", self.properties];
    [description appendString:@">"];
    return description;
}

@end