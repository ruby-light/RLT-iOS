//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLTBaseProperties;
@class RLTReport;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const RLT__LIBRARY_NAME;
extern NSString *const RLT__LIBRARY_VERSION;

extern NSString *const RLT__SERVER_URL;
extern NSString *const RLT__API_VERSION;

extern NSString *const RLT__REPORTS_FIELD__UPLOAD_TIME;
extern NSString *const RLT__REPORTS_FIELD__LIBRARY;
extern NSString *const RLT__REPORTS_FIELD__DEVICE;
extern NSString *const RLT__REPORTS_FIELD__REPORTS;

extern NSString *const RLT__LIBRARY_FIELD__NAME;
extern NSString *const RLT__LIBRARY_FIELD__VERSION;

extern NSString *const RLT__REPORT_FIELD__DEVICE_ID;
extern NSString *const RLT__REPORT_FIELD__USER_ID;
extern NSString *const RLT__REPORT_FIELD__TIME;
extern NSString *const RLT__REPORT_FIELD__SEQUENCE;
extern NSString *const RLT__REPORT_FIELD__EVENT;
extern NSString *const RLT__REPORT_FIELD__USER;

extern NSString *const RLT__EVENT_FIELD__NAME;
extern NSString *const RLT__EVENT_FIELD__NAME_WARNING;

extern NSString *const RLT__CONTENT_FIELD__PROPERTIES;
extern NSString *const RLT__CONTENT_FIELD__PROPERTIES_WARNING;

extern NSString *const RLT__PROPERTY_FIELD__NAME;
extern NSString *const RLT__PROPERTY_FIELD__NAME_WARNING;
extern NSString *const RLT__PROPERTY_FIELD__VALUE;
extern NSString *const RLT__PROPERTY_FIELD__VALUE_WARNING;
extern NSString *const RLT__PROPERTY_FIELD__OPERATION;

extern NSString *const RLT__WARNING_TRUNCATED;
extern NSString *const RLT__WARNING_UNSUPPORTED_TYPE;
extern NSString *const RLT__WARNING_RESOLVE_ERROR;

extern NSString *const RLT__PROPERTY_OPERATION__SET;
extern NSString *const RLT__PROPERTY_OPERATION__UNSET;

extern NSString *const RLT__DEFAULT_EVENTS__START_APP;
extern NSString *const RLT__DEFAULT_EVENTS__START_SESSION;

extern int const PROPERTIES_MAX_COUNT;

extern int const EVENT_NAME_MAX_LENGTH;
extern int const PROPERTY_NAME_MAX_LENGTH;
extern int const PROPERTY_VALUE_MAX_LENGTH;

typedef NSString *_Nonnull (^RLTFormatsPutPropertiesListNameSupplierCallback)(NSString *property);

typedef id _Nonnull (^RLTFormatsPutPropertiesListValueSupplierCallback)(NSString *property);

@interface RLTFormats : NSObject

+ (NSMutableDictionary *_Nullable)buildPropertiesContent:(RLTBaseProperties *_Nullable)properties;

+ (NSDictionary *)buildEventContent:(NSString *)eventName eventProperties:(RLTBaseProperties *_Nullable)eventProperties;

+ (NSDictionary *)buildReport:(NSString *)deviceId userId:(NSString *_Nullable)userId time:(int64_t)time sequence:(int64_t)sequence userContent:(NSDictionary *_Nullable)userContent eventContent:(NSDictionary *_Nullable)eventContent;

+ (NSString *)buildUploadReportsContent:(NSString *_Nullable)deviceContent reports:(NSArray<NSString *> *)reports;

+ (NSString *)buildUploadReportsContent:(NSArray<RLTReport *> *)reports maxSequence:(NSInteger *)maxSequence;

@end

NS_ASSUME_NONNULL_END
