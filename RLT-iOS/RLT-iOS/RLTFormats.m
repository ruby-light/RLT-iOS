//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTFormats.h"
#import "RLTBaseProperties.h"
#import "RLTUtils.h"
#import "RLTLogger.h"
#import "RLTUserPropertyValue.h"
#import "RLTDevicePropertySupplier.h"
#import "RLTReport.h"

NSString *const RLT__LIBRARY_NAME = @"RLT-iOS";
NSString *const RLT__LIBRARY_VERSION = @"1.0.1";

NSString *const RLT__SERVER_URL = @"http://localhost:8889";
NSString *const RLT__API_VERSION = @"1";

NSString *const RLT__REPORTS_FIELD__UPLOAD_TIME = @"t";
NSString *const RLT__REPORTS_FIELD__LIBRARY = @"l";
NSString *const RLT__REPORTS_FIELD__DEVICE = @"d";
NSString *const RLT__REPORTS_FIELD__REPORTS = @"r";

NSString *const RLT__LIBRARY_FIELD__NAME = @"n";
NSString *const RLT__LIBRARY_FIELD__VERSION = @"v";

NSString *const RLT__REPORT_FIELD__DEVICE_ID = @"di";
NSString *const RLT__REPORT_FIELD__USER_ID = @"ui";
NSString *const RLT__REPORT_FIELD__TIME = @"t";
NSString *const RLT__REPORT_FIELD__SEQUENCE = @"s";
NSString *const RLT__REPORT_FIELD__EVENT = @"e";
NSString *const RLT__REPORT_FIELD__USER = @"u";

NSString *const RLT__EVENT_FIELD__NAME = @"n";
NSString *const RLT__EVENT_FIELD__NAME_WARNING = @"nw";

NSString *const RLT__CONTENT_FIELD__PROPERTIES = @"p";
NSString *const RLT__CONTENT_FIELD__PROPERTIES_WARNING = @"pw";

NSString *const RLT__PROPERTY_FIELD__NAME = @"n";
NSString *const RLT__PROPERTY_FIELD__NAME_WARNING = @"nw";
NSString *const RLT__PROPERTY_FIELD__VALUE = @"v";
NSString *const RLT__PROPERTY_FIELD__VALUE_WARNING = @"vw";
NSString *const RLT__PROPERTY_FIELD__OPERATION = @"o";

NSString *const RLT__WARNING_TRUNCATED = @"truncated";
NSString *const RLT__WARNING_UNSUPPORTED_TYPE = @"unsupportedType";
NSString *const RLT__WARNING_RESOLVE_ERROR = @"resolveError";

NSString *const RLT__PROPERTY_OPERATION__SET = @"s";
NSString *const RLT__PROPERTY_OPERATION__UNSET = @"u";

NSString *const RLT__DEFAULT_EVENTS__START_APP = @"StartApp";
NSString *const RLT__DEFAULT_EVENTS__START_SESSION = @"StartSession";

int const PROPERTIES_MAX_COUNT = 128;

int const EVENT_NAME_MAX_LENGTH = 64;
int const PROPERTY_NAME_MAX_LENGTH = 512;
int const PROPERTY_VALUE_MAX_LENGTH = 1024;

@implementation RLTFormats

NS_ASSUME_NONNULL_BEGIN

+ (NSMutableDictionary *_Nullable)buildPropertiesContent:(RLTBaseProperties *_Nullable)properties {
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    if (properties.properties) {
        [self putPropertiesList:properties.properties.keyEnumerator propertyNameSupplier:^NSString *(NSString *property) {
            return property;
        } propertyValueSupplier:^id(NSString *property) {
            return properties.properties[property];
        } dictionary:content];
    }
    return content.count > 0 ? content : nil;
}

+ (NSDictionary *)buildEventContent:(NSString *)eventName eventProperties:(RLTBaseProperties *_Nullable)eventProperties {
    if (![eventName isKindOfClass:[NSString class]]) {
        RLTLoggerError(nil, @"EventName must be NSString! Passed type '%@'", NSStringFromClass(eventName.class));
        return nil;
    }
    NSMutableDictionary *content = [RLTFormats buildPropertiesContent:eventProperties] ?: [[NSMutableDictionary alloc] init];
    [RLTFormats putEventName:content value:eventName];
    return content;
}

+ (NSDictionary *)buildPropertyContent:(NSString *)propertyName propertyValue:(NSObject *)propertyValue {
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyName:content name:propertyName];
    [RLTFormats putPropertyValue:content value:propertyValue];
    return content;
}

+ (NSDictionary *)buildReport:(NSString *)deviceId userId:(NSString *_Nullable)userId time:(int64_t)time sequence:(int64_t)sequence userContent:(NSDictionary *_Nullable)userContent eventContent:(NSDictionary *_Nullable)eventContent {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    result[RLT__REPORT_FIELD__DEVICE_ID] = deviceId;
    result[RLT__REPORT_FIELD__USER_ID] = userId;
    result[RLT__REPORT_FIELD__TIME] = @(time);
    result[RLT__REPORT_FIELD__SEQUENCE] = @(sequence);
    result[RLT__REPORT_FIELD__USER] = userContent;
    result[RLT__REPORT_FIELD__EVENT] = eventContent;
    return result;
}

+ (NSString *)buildUploadReportsContent:(NSString *_Nullable)deviceContent reports:(NSArray<NSString *> *)reports {
    NSString *uploadTime = [NSString stringWithFormat:@"\"%@\":%@,", RLT__REPORTS_FIELD__UPLOAD_TIME, @([RLTUtils currentTimeMillis])];
    NSString *libraryPart = [NSString stringWithFormat:@"\"%@\":{\"%@\":\"%@\",\"%@\":\"%@\"},", RLT__REPORTS_FIELD__LIBRARY, RLT__LIBRARY_FIELD__NAME, RLT__LIBRARY_NAME, RLT__LIBRARY_FIELD__VERSION, RLT__LIBRARY_VERSION];
    NSString *devicePart = ![RLTUtils isStringEmpty:deviceContent] ? [NSString stringWithFormat:@"\"%@\":%@,", RLT__REPORTS_FIELD__DEVICE, deviceContent] : @"";
    NSString *reportsPart = reports.count > 0 ? [NSString stringWithFormat:@"\"%@\":[%@]", RLT__REPORTS_FIELD__REPORTS, [reports componentsJoinedByString:@","]] : @"";
    return [NSString stringWithFormat:@"{%@%@%@%@}", uploadTime, libraryPart, devicePart, reportsPart];
}

+ (NSString *)buildUploadReportsContent:(NSArray<RLTReport *> *)reports maxSequence:(NSInteger *)maxSequence {
    NSAssert(reports.count > 0, @"Reports must not be empty");
    NSString *deviceContent = nil;
    NSArray<NSString *> *uploadReportsContent = [self getUploadReports:reports deviceContent:&deviceContent maxSequence:maxSequence];
    NSString *result = [RLTFormats buildUploadReportsContent:deviceContent reports:uploadReportsContent];
    return result;
}

NS_ASSUME_NONNULL_END

#pragma mark Internal

+ (NSArray <NSString *> *)getUploadReports:(NSArray<RLTReport *> *)reports deviceContent:(NSString **)deviceContent maxSequence:(NSInteger *)maxSequence{
    NSAssert(reports.count > 0, @"Reports must not be empty");
    NSMutableArray <NSString *> *result = [[NSMutableArray alloc] init];

    RLTReport *report = reports.firstObject;
    [result addObject:report.content];

    __block int maximalSequence = report.sequence;
    __block NSString *currentDeviceContent = report.device;

    [reports enumerateObjectsUsingBlock:^(RLTReport *nextReport, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            return;
        }
        NSString *nextDeviceContent = nextReport.device;

        if (nextDeviceContent == currentDeviceContent || [nextDeviceContent isEqual:currentDeviceContent]) {
            maximalSequence = nextReport.sequence;
            currentDeviceContent = nextDeviceContent;
            [result addObject:nextReport.content];
            return;
        }
        *stop = YES;
    }];

    *maxSequence = maximalSequence;
    *deviceContent = currentDeviceContent;

    return result;
}

+ (void)putPropertiesList:(NSEnumerator *)properties propertyNameSupplier:(RLTFormatsPutPropertiesListNameSupplierCallback)propertyNameSupplier propertyValueSupplier:(RLTFormatsPutPropertiesListValueSupplierCallback)propertyValueSupplier dictionary:(NSMutableDictionary *)dictionary {
    NSMutableArray <NSDictionary *> *result = [[NSMutableArray alloc] init];
    __block NSString *warning = nil;
    NSString *property = nil;
    while ((property = [properties nextObject])) {
        if (result.count >= PROPERTIES_MAX_COUNT) {
            warning = RLT__WARNING_TRUNCATED;
            break;
        }
        NSString *propertyName = propertyNameSupplier(property);
        id propertyValue = propertyValueSupplier(property);
        NSDictionary *propertyContent = [RLTFormats buildPropertyContent:propertyName propertyValue:propertyValue];
        if (propertyContent) {
            [result addObject:propertyContent];
        }
    }
    if (result.count > 0) {
        dictionary[RLT__CONTENT_FIELD__PROPERTIES] = result;
        if (warning) {
            dictionary[RLT__CONTENT_FIELD__PROPERTIES_WARNING] = warning;
        }
    }
}

+ (void)putPropertyName:(NSMutableDictionary *)dictionary name:(NSString *)name {
    if (name.length > PROPERTY_NAME_MAX_LENGTH) {
        dictionary[RLT__PROPERTY_FIELD__NAME] = [name substringToIndex:PROPERTY_NAME_MAX_LENGTH];
        dictionary[RLT__PROPERTY_FIELD__NAME_WARNING] = RLT__WARNING_TRUNCATED;
    } else {
        dictionary[RLT__PROPERTY_FIELD__NAME] = name;
    }
}

+ (void)putPropertyValue:(NSMutableDictionary *)dictionary value:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        NSString *stringValue = (NSString *) value;
        if (stringValue.length > PROPERTY_VALUE_MAX_LENGTH) {
            dictionary[RLT__PROPERTY_FIELD__VALUE] = [stringValue substringToIndex:PROPERTY_VALUE_MAX_LENGTH];
            dictionary[RLT__PROPERTY_FIELD__VALUE_WARNING] = RLT__WARNING_TRUNCATED;
        } else {
            dictionary[RLT__PROPERTY_FIELD__VALUE] = stringValue;
        }
    } else if ([value isKindOfClass:[RLTUserPropertyValue class]]) {
        RLTUserPropertyValue *userPropertyValue = (RLTUserPropertyValue *) value;
        [RLTFormats putPropertyValue:dictionary value:userPropertyValue.value];
        dictionary[RLT__PROPERTY_FIELD__OPERATION] = userPropertyValue.operation;
    } else if ([value isKindOfClass:[RLTDevicePropertySupplier class]]) {
        RLTDevicePropertySupplier *devicePropertySupplier = (RLTDevicePropertySupplier *) value;
        @try {
            [RLTFormats putPropertyValue:dictionary value:[devicePropertySupplier getValue]];
        }
        @catch (NSException *exception) {
            dictionary[RLT__PROPERTY_FIELD__VALUE_WARNING] = RLT__WARNING_RESOLVE_ERROR;
            RLTLoggerException(exception, @"Error resolve property value from supplier '%@'", value);
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *numberValue = (NSNumber *) value;
        Boolean isFloatType = CFNumberIsFloatType((__bridge CFNumberRef) numberValue);
        if (isFloatType) {
            dictionary[RLT__PROPERTY_FIELD__VALUE_WARNING] = RLT__WARNING_UNSUPPORTED_TYPE;
            RLTLoggerWarn(@"Unsupported NSNumber property value type: %@", value);
        } else {
            dictionary[RLT__PROPERTY_FIELD__VALUE] = numberValue;
        }
    } else if (value == nil || [value isKindOfClass:[NSNull class]]) {
        dictionary[RLT__PROPERTY_FIELD__VALUE] = [NSNull null];
    } else {
        dictionary[RLT__PROPERTY_FIELD__VALUE_WARNING] = RLT__WARNING_UNSUPPORTED_TYPE;
        RLTLoggerWarn(@"Unsupported unknown property value type: value='%@'", value);
    }
}

+ (void)putEventName:(NSMutableDictionary *)dictionary value:(NSString *)value {
    if (value.length > EVENT_NAME_MAX_LENGTH) {
        dictionary[RLT__EVENT_FIELD__NAME] = [value substringToIndex:EVENT_NAME_MAX_LENGTH];
        dictionary[RLT__EVENT_FIELD__NAME_WARNING] = RLT__WARNING_TRUNCATED;
    } else {
        dictionary[RLT__EVENT_FIELD__NAME] = value;
    }
}

@end
