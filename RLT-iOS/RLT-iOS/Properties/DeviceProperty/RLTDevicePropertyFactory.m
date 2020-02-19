//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTDevicePropertyFactory.h"
#import <sys/sysctl.h>

@implementation RLTDevicePropertyFactory

+ (NSString *)getHWMachine {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *)countryISOCode {
    NSString *result = nil;
    Class CTTelephonyNetworkInfo = NSClassFromString(@"CTTelephonyNetworkInfo");
    SEL subscriberCellularProvider = NSSelectorFromString(@"subscriberCellularProvider");
    SEL isoCountryCode = NSSelectorFromString(@"isoCountryCode");
    if (CTTelephonyNetworkInfo && subscriberCellularProvider && isoCountryCode) {
        NSObject *networkInfo = [[NSClassFromString(@"CTTelephonyNetworkInfo") alloc] init];
        id carrier = nil;
        id (*imp1)(id, SEL) = (id (*)(id, SEL)) [networkInfo methodForSelector:subscriberCellularProvider];
        if (imp1) {
            carrier = imp1(networkInfo, subscriberCellularProvider);
        }
        NSString *icc = nil;
        NSString *(*imp2)(id, SEL) = (NSString *(*)(id, SEL)) [carrier methodForSelector:isoCountryCode];
        if (imp2) {
            icc = imp2(carrier, isoCountryCode);
        }
        if (icc.length > 0) {
            result = icc;
        }
    }
    if (result.length == 0) {
        NSLocale *locale = [NSLocale currentLocale];
        result = [locale objectForKey:NSLocaleCountryCode];
    }
    return [result lowercaseString];
}

+ (NSString *)language {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *language = [locale objectForKey:NSLocaleLanguageCode];
    return [language lowercaseString];
}

+ (NSString *)carrier {
    NSString *result = nil;
    Class CTTelephonyNetworkInfo = NSClassFromString(@"CTTelephonyNetworkInfo");
    SEL subscriberCellularProvider = NSSelectorFromString(@"subscriberCellularProvider");
    SEL carrierName = NSSelectorFromString(@"carrierName");
    if (CTTelephonyNetworkInfo && subscriberCellularProvider && carrierName) {
        NSObject *networkInfo = [[NSClassFromString(@"CTTelephonyNetworkInfo") alloc] init];
        id carrier = nil;
        id (*imp1)(id, SEL) = (id (*)(id, SEL)) [networkInfo methodForSelector:subscriberCellularProvider];
        if (imp1) {
            carrier = imp1(networkInfo, subscriberCellularProvider);
        }
        NSString *icc = nil;
        NSString *(*imp2)(id, SEL) = (NSString *(*)(id, SEL)) [carrier methodForSelector:carrierName];
        if (imp2) {
            icc = imp2(carrier, carrierName);
        }
        icc = [icc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (icc.length > 0) {
            result = icc;
        }
    }
    return result;
}

@end