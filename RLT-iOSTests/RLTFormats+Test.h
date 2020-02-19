//
// Created by Alexey Chirkov on 06/02/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTFormats.h"

@interface RLTFormats (Test)

+ (NSDictionary *)buildPropertyContent:(NSString *)propertyName propertyValue:(NSObject *)propertyValue;

+ (void)putPropertiesList:(NSEnumerator *)properties propertyNameSupplier:(RLTFormatsPutPropertiesListNameSupplierCallback)propertyNameSupplier propertyValueSupplier:(RLTFormatsPutPropertiesListValueSupplierCallback)propertyValueSupplier dictionary:(NSMutableDictionary *)dictionary;

+ (NSArray <NSString *> *)getUploadReports:(NSArray<RLTReport *> *)reports deviceContent:(NSString **)deviceContent maxSequence:(NSInteger *)maxSequence;

+ (void)putPropertyName:(NSMutableDictionary *)dictionary name:(NSString *)name;

+ (void)putPropertyValue:(NSMutableDictionary *)dictionary value:(id)value;

+ (void)putEventName:(NSMutableDictionary *)dictionary value:(NSString *)value;

@end