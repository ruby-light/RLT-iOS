//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLTDevicePropertyFactory : NSObject
+ (NSString *)getHWMachine;

+ (NSString *)countryISOCode;

+ (NSString *)language;

+ (NSString *)carrier;
@end