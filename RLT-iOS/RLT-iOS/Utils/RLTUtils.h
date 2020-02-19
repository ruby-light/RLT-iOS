//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RLTUtils : NSObject

+ (NSString *_Nullable)stringOrNilOfEmpty:(NSString *_Nullable)value;

+ (BOOL)isStringEmpty:(NSString *_Nullable)value;

+ (int64_t)currentTimeMillis;

+ (NSString *_Nullable)toJson:(NSObject *_Nullable)value;

+ (NSString *_Nullable)toJson:(NSObject *_Nullable)value options:(NSJSONWritingOptions)options;

+ (BOOL)deserializeJSONObjectFrom:(NSData *)data result:(id _Nonnull *_Nonnull)result resultClass:(Class)resultClass;

+ (NSTimeInterval)systemUptime;

@end

NS_ASSUME_NONNULL_END
