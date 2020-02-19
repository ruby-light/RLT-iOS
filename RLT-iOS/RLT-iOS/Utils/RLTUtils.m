//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTUtils.h"
#import "RLTLogger.h"
#include <sys/sysctl.h>

@implementation RLTUtils

+ (NSString *_Nullable)stringOrNilOfEmpty:(NSString *_Nullable)value {
    return [RLTUtils isStringEmpty:value] ? nil : value;
}

+ (BOOL)isStringEmpty:(NSString *_Nullable)value {
    return value.length == 0;
}

+ (int64_t)currentTimeMillis {
    return (int64_t) ([[NSDate date] timeIntervalSince1970] * 1000);
}

+ (NSString *_Nullable)toJson:(NSObject *_Nullable)value {
    return [RLTUtils toJson:value options:0];
}

+ (NSString *_Nullable)toJson:(NSObject *_Nullable)value options:(NSJSONWritingOptions)options {
    if (!value) {
        return nil;
    }
    NSString *jsonString = nil;
    @try {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:value options:options error:&error];
        if (!data || error) {
            RLTLoggerError(error, @"JSON parsing failed. Initial object: %@.", value);
            return nil;
        }
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
        RLTLoggerException(exception, @"JSON parsing failed. Initial object: %@.", value);
    }
    return jsonString;
}

+ (BOOL)deserializeJSONObjectFrom:(NSData *)data result:(id _Nonnull *_Nonnull)result resultClass:(Class)resultClass {
    NSError *deserializeError;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializeError];
    if (deserializeError) {
        RLTLoggerError(deserializeError, @"JSON deserialization error");
        return NO;
    }
    if ([obj isKindOfClass:resultClass]) {
        *result = obj;
        return YES;
    }
    return NO;
}

/**
 * Device system uptime.
 * Do not take into consideration time zones changes.
 */
+ (NSTimeInterval)systemUptime {
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;

    (void) time(&now);

    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptime = now - boottime.tv_sec;
    }
    return uptime;
}

@end
