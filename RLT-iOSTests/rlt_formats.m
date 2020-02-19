//
//  rlt_formats.m
//  rlt-analytics-tests
//
//  Created by Alexey Chirkov on 06/02/2020.
//  Copyright © 2020 Rubylight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLTFormats+Test.h"
#import "NSString+Test.h"
#import "RLTUserPropertyValue.h"
#import "RLTDevicePropertySupplier.h"
#import "RLTUserProperties.h"
#import "RLTEventProperties.h"
#import "RLTUtils.h"
#import "RLTReport.h"
#import "RLTLogger.h"
#import "RLTInitConfig.h"

@interface rlt_formats : XCTestCase

@end

@implementation rlt_formats

- (void)setUp {
    RLTInitConfig *initConfig = [[RLTInitConfig alloc] init];
    [RLTLogger setLogger:initConfig.logger];
}

- (void)tearDown {

}

- (void)testPutPropertiesList {
    NSArray *values = @[@"a1", @"a2"];

    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertiesList:values.objectEnumerator
             propertyNameSupplier:^NSString *(NSString *property) {
                 return property;
             }
            propertyValueSupplier:^id(NSString *property) {
                return [NSString stringWithFormat:@"%@v", property];
            }
                       dictionary:jsonObject];

    XCTAssertEqual(jsonObject.count, 1);

    NSArray <NSDictionary *> *list = jsonObject[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, 2);
    NSDictionary *p1 = list[0];
    NSDictionary *p2 = list[1];
    XCTAssertEqual(p1.count, 2);
    XCTAssertEqualObjects(p1[RLT__PROPERTY_FIELD__NAME], @"a1");
    XCTAssertEqualObjects(p1[RLT__PROPERTY_FIELD__VALUE], @"a1v");
    XCTAssertEqual(p2.count, 2);
    XCTAssertEqualObjects(p2[RLT__PROPERTY_FIELD__NAME], @"a2");
    XCTAssertEqualObjects(p2[RLT__PROPERTY_FIELD__VALUE], @"a2v");
}

- (void)testPutLongPropertiesList {
    //maximum items
    NSMutableArray <NSString *> *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < PROPERTIES_MAX_COUNT; ++i) {
        [array addObject:[NSString stringWithFormat:@"a%i", i]];
    }
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertiesList:array.objectEnumerator propertyNameSupplier:^NSString *(NSString *property) {
        return property;
    }       propertyValueSupplier:^id(NSString *property) {
        return [NSString stringWithFormat:@"%@v", property];
    }                  dictionary:jsonObject];
    XCTAssertEqual(jsonObject.count, 1);
    NSArray <NSDictionary *> *list = jsonObject[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, PROPERTIES_MAX_COUNT);

    //maximum+1 items
    array = [[NSMutableArray alloc] init];
    for (int i = 0; i <= PROPERTIES_MAX_COUNT; ++i) {
        [array addObject:[NSString stringWithFormat:@"a%i", i]];
    }
    jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertiesList:array.objectEnumerator propertyNameSupplier:^NSString *(NSString *property) {
        return property;
    }       propertyValueSupplier:^id(NSString *property) {
        return [NSString stringWithFormat:@"%@v", property];
    }                  dictionary:jsonObject];
    XCTAssertEqual(jsonObject.count, 2);

    XCTAssertEqualObjects(jsonObject[RLT__CONTENT_FIELD__PROPERTIES_WARNING], RLT__WARNING_TRUNCATED);
    list = jsonObject[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, PROPERTIES_MAX_COUNT);

    NSDictionary *p1 = list[0];
    XCTAssertEqual(p1.count, 2);
    XCTAssertEqualObjects(p1[RLT__PROPERTY_FIELD__NAME], @"a0");
    XCTAssertEqualObjects(p1[RLT__PROPERTY_FIELD__VALUE], @"a0v");
}

- (void)testBuildPropertyContent {
    NSDictionary *jsonObject = [RLTFormats buildPropertyContent:@"pr" propertyValue:@"abc"];
    XCTAssertEqual(jsonObject.count, 2);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__NAME], @"pr");
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE], @"abc");
}

- (void)testPutEventName {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putEventName:jsonObject value:@"abc"];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__EVENT_FIELD__NAME], @"abc");
}

- (void)testPutEventLongName {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putEventName:jsonObject value:[NSString stringWithLength:EVENT_NAME_MAX_LENGTH + 1]];
    XCTAssertEqual(jsonObject.count, 2);
    XCTAssertEqualObjects(jsonObject[RLT__EVENT_FIELD__NAME], [NSString stringWithLength:EVENT_NAME_MAX_LENGTH]);
    XCTAssertEqualObjects(jsonObject[RLT__EVENT_FIELD__NAME_WARNING], RLT__WARNING_TRUNCATED);
}

- (void)testPutPropertyName {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyName:jsonObject name:@"abc"];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__NAME], @"abc");
}

- (void)testPutPropertyLongName {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyName:jsonObject name:[NSString stringWithLength:PROPERTY_NAME_MAX_LENGTH + 1]];
    XCTAssertEqual(jsonObject.count, 2);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__NAME], [NSString stringWithLength:PROPERTY_NAME_MAX_LENGTH]);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__NAME_WARNING], RLT__WARNING_TRUNCATED);
}

- (void)testPutPropertyStringValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:@"abc"];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE], @"abc");
}

- (void)testPutPropertyBooleanValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:@(YES)];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE], @(YES));
}

- (void)testPutPropertyLongValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:@(123)];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE], @(123));
}

- (void)testPutPropertyLongStringValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:[NSString stringWithLength:PROPERTY_VALUE_MAX_LENGTH + 1]];
    XCTAssertEqual(jsonObject.count, 2);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE], [NSString stringWithLength:PROPERTY_VALUE_MAX_LENGTH]);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE_WARNING], RLT__WARNING_TRUNCATED);
}

- (void)testPutPropertyNilValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:nil];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE], [NSNull null]);
}

- (void)testPutPropertyNullValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:[NSNull null]];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE], [NSNull null]);
}

- (void)testPutPropertyWrongNumberValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:@(1.2f)];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE_WARNING], RLT__WARNING_UNSUPPORTED_TYPE);
}

- (void)testPutPropertyWrongValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:[NSDate date]];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE_WARNING], RLT__WARNING_UNSUPPORTED_TYPE);
}

- (void)testPutPropertyUserPropertyValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:[[RLTUserPropertyValue alloc] initWithOperation:RLT__PROPERTY_OPERATION__SET value:@"abc"]];
    XCTAssertEqual(jsonObject.count, 2);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE], @"abc");
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__OPERATION], RLT__PROPERTY_OPERATION__SET);

    NSMutableDictionary *jsonObject2 = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject2 value:[[RLTUserPropertyValue alloc] initWithOperation:RLT__PROPERTY_OPERATION__UNSET value:[NSNull null]]];
    XCTAssertEqual(jsonObject2.count, 2);
    XCTAssertEqualObjects(jsonObject2[RLT__PROPERTY_FIELD__VALUE], [NSNull null]);
    XCTAssertEqualObjects(jsonObject2[RLT__PROPERTY_FIELD__OPERATION], RLT__PROPERTY_OPERATION__UNSET);
}

- (void)testPutPropertySupplierValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:(id) [RLTDevicePropertySupplier supplierWithCallback:^NSObject * {
        return @"abc";
    }]];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE], @"abc");
}

- (void)testPutPropertySupplierErrorValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:(id) [RLTDevicePropertySupplier supplierWithCallback:^NSObject * {
        @throw [NSException exceptionWithName:@"exc" reason:nil userInfo:nil];
    }]];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE_WARNING], RLT__WARNING_RESOLVE_ERROR);
}

- (void)testPutPropertySupplierWrongNumberValue {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    [RLTFormats putPropertyValue:jsonObject value:(id) [RLTDevicePropertySupplier supplierWithCallback:^NSObject * {
        return @(1.2f);
    }]];
    XCTAssertEqual(jsonObject.count, 1);
    XCTAssertEqualObjects(jsonObject[RLT__PROPERTY_FIELD__VALUE_WARNING], RLT__WARNING_UNSUPPORTED_TYPE);
}

- (void)testEmptyUserProperties {
    RLTUserProperties *userProperties = [RLTUserProperties instance];
    XCTAssertNil([RLTFormats buildPropertiesContent:userProperties]);
}

- (void)testSetUserProperties {
    RLTUserProperties *userProperties = [[RLTUserProperties instance] set:@"1" forKey:@"a"];
    NSMutableDictionary *jsonObject = [RLTFormats buildPropertiesContent:userProperties];
    XCTAssertEqual(jsonObject.count, 1);
    NSArray <NSDictionary *> *list = jsonObject[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, 1);
    NSDictionary *obj = list[0];
    XCTAssertEqual(obj.count, 3);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__NAME], @"a");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__VALUE], @"1");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__OPERATION], RLT__PROPERTY_OPERATION__SET);
}

- (void)testUnsetUserProperties {
    RLTUserProperties *userProperties = [[RLTUserProperties instance] unset:@"a"];
    NSMutableDictionary *jsonObject = [RLTFormats buildPropertiesContent:userProperties];
    XCTAssertEqual(jsonObject.count, 1);
    NSArray <NSDictionary *> *list = jsonObject[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, 1);
    NSDictionary *obj = list[0];
    XCTAssertEqual(obj.count, 3);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__NAME], @"a");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__VALUE], [NSNull null]);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__OPERATION], RLT__PROPERTY_OPERATION__UNSET);
}

- (void)testDuplicateUserProperties {
    RLTUserProperties *userProperties = [[[RLTUserProperties instance]
            set:@"1" forKey:@"a"]
            set:@"2" forKey:@"a"];
    NSMutableDictionary *jsonObject = [RLTFormats buildPropertiesContent:userProperties];
    XCTAssertEqual(jsonObject.count, 1);
    NSArray <NSDictionary *> *list = jsonObject[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, 1);
    NSDictionary *obj = list[0];
    XCTAssertEqual(obj.count, 3);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__NAME], @"a");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__VALUE], @"2");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__OPERATION], RLT__PROPERTY_OPERATION__SET);
}

- (void)testEmptyEventProperties {
    RLTEventProperties *eventProperties = [RLTEventProperties instance];
    XCTAssertNil([RLTFormats buildPropertiesContent:eventProperties]);
}

- (void)testSetEventProperties {
    RLTEventProperties *eventProperties = [[RLTEventProperties instance] set:@"1" forKey:@"a"];
    NSMutableDictionary *jsonObject = [RLTFormats buildPropertiesContent:(id) eventProperties];
    XCTAssertEqual(jsonObject.count, 1);
    NSArray <NSDictionary *> *list = jsonObject[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, 1);
    NSDictionary *obj = list[0];
    XCTAssertEqual(obj.count, 2);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__NAME], @"a");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__VALUE], @"1");
}

- (void)testDuplicateEventProperties {
    RLTEventProperties *eventProperties = [[[RLTEventProperties instance]
            set:@"1" forKey:@"a"]
            set:@"2" forKey:@"a"];
    NSMutableDictionary *jsonObject = [RLTFormats buildPropertiesContent:(id) eventProperties];
    XCTAssertEqual(jsonObject.count, 1);
    NSArray <NSDictionary *> *list = jsonObject[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, 1);
    NSDictionary *obj = list[0];
    XCTAssertEqual(obj.count, 2);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__NAME], @"a");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__VALUE], @"2");
}

- (void)testNonStringEventProperties {
    RLTEventProperties *eventProperties = [[[[RLTEventProperties instance]
            set:@"1" forKey:@"a"]
            set:@2 forKey:@"NSNumber"]
            set:[NSDate date] forKey:@"NSDate"];
    NSMutableDictionary *jsonObject = [RLTFormats buildPropertiesContent:(id) eventProperties];
    XCTAssertEqual(jsonObject.count, 1);
    NSArray <NSDictionary *> *list = jsonObject[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, 3);
    NSDictionary *obj = list[0];
    XCTAssertEqual(obj.count, 2);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__NAME], @"a");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__VALUE], @"1");

    obj = list[1];
    XCTAssertEqual(obj.count, 2);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__NAME], @"NSNumber");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__VALUE], @2);

    obj = list[2];
    XCTAssertEqual(obj.count, 2);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__NAME], @"NSDate");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__VALUE_WARNING], RLT__WARNING_UNSUPPORTED_TYPE);
}

- (void)testBuildEventContent {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    NSDictionary *contentNil = [RLTFormats buildEventContent:nil eventProperties:nil];
#pragma clang diagnostic pop
    XCTAssertNil(contentNil);

#pragma clang diagnostic push
#pragma ide diagnostic ignored "NotSuperclass"
    NSDictionary *contentInvalidEventNameType = [RLTFormats buildEventContent:@(1) eventProperties:nil];
#pragma clang diagnostic pop
    XCTAssertNil(contentInvalidEventNameType);

    NSDictionary *contentEmpty = [RLTFormats buildEventContent:@"" eventProperties:nil];
    XCTAssertEqual(contentEmpty.count, 1);
    XCTAssertEqualObjects(contentEmpty[RLT__EVENT_FIELD__NAME], @"");

    NSDictionary *content = [RLTFormats buildEventContent:@"abc" eventProperties:nil];
    XCTAssertEqual(content.count, 1);
    XCTAssertEqualObjects(content[RLT__EVENT_FIELD__NAME], @"abc");

    NSDictionary *content2 = [RLTFormats buildEventContent:@"abc" eventProperties:[RLTEventProperties instance]];
    XCTAssertEqual(content2.count, 1);
    XCTAssertEqualObjects(content2[RLT__EVENT_FIELD__NAME], @"abc");

    NSDictionary *content3 = [RLTFormats buildEventContent:@"abc" eventProperties:[[RLTEventProperties instance] set:@"v1" forKey:@"p1"]];
    XCTAssertEqual(content3.count, 2);
    XCTAssertEqualObjects(content3[RLT__EVENT_FIELD__NAME], @"abc");
    NSArray <NSDictionary *> *list = content3[RLT__CONTENT_FIELD__PROPERTIES];
    XCTAssertEqual(list.count, 1);
    NSDictionary *obj = list[0];
    XCTAssertEqual(obj.count, 2);
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__NAME], @"p1");
    XCTAssertEqualObjects(obj[RLT__PROPERTY_FIELD__VALUE], @"v1");
}

- (void)testBuildReport {
    {
        NSDictionary *content = [RLTFormats buildReport:@"device" userId:nil time:123 sequence:1 userContent:nil eventContent:nil];
        XCTAssertEqual(content.count, 3);
        XCTAssertEqualObjects(content[RLT__REPORT_FIELD__DEVICE_ID], @"device");
        XCTAssertEqualObjects(content[RLT__REPORT_FIELD__TIME], @123);
        XCTAssertEqualObjects(content[RLT__REPORT_FIELD__SEQUENCE], @1);
    }
    {
        NSDictionary *content = [RLTFormats buildReport:@"device" userId:@"user" time:123 sequence:1 userContent:@{@"a": @"b"} eventContent:@{}];
        XCTAssertEqual(content.count, 6);
        XCTAssertEqualObjects(content[RLT__REPORT_FIELD__DEVICE_ID], @"device");
        XCTAssertEqualObjects(content[RLT__REPORT_FIELD__USER_ID], @"user");
        XCTAssertEqualObjects(content[RLT__REPORT_FIELD__TIME], @123);
        XCTAssertEqualObjects(content[RLT__REPORT_FIELD__SEQUENCE], @1);
        XCTAssertEqual(((NSDictionary *) content[RLT__REPORT_FIELD__EVENT]).count, 0);
        XCTAssertEqual(((NSDictionary *) content[RLT__REPORT_FIELD__USER]).count, 1);
    }
}

- (void)testBuildUploadReportsContent {
    {
        NSDictionary *rep = @{@"a": @"av"};
        NSString *content = [RLTFormats buildUploadReportsContent:nil reports:@[[RLTUtils toJson:rep]]];
        NSDictionary *jsonObject;
        XCTAssertTrue([RLTUtils deserializeJSONObjectFrom:[content dataUsingEncoding:NSUTF8StringEncoding] result:&jsonObject resultClass:NSDictionary.class]);
        XCTAssertEqual(jsonObject.count, 3);
        XCTAssertNotNil(jsonObject[RLT__REPORTS_FIELD__UPLOAD_TIME]);

        NSDictionary *library = jsonObject[RLT__REPORTS_FIELD__LIBRARY];
        XCTAssertEqual(library.count, 2);
        XCTAssertEqualObjects(library[RLT__LIBRARY_FIELD__NAME], RLT__LIBRARY_NAME);
        XCTAssertEqualObjects(library[RLT__LIBRARY_FIELD__VERSION], RLT__LIBRARY_VERSION);

        NSArray *reports = jsonObject[RLT__REPORTS_FIELD__REPORTS];
        XCTAssertEqual(reports.count, 1);
        XCTAssertEqualObjects(reports.firstObject, rep);
    }

    {
        NSDictionary *dev = @{@"d": @"dv"};
        NSDictionary *rep = @{@"a": @"av"};
        NSString *content = [RLTFormats buildUploadReportsContent:[RLTUtils toJson:dev] reports:@[[RLTUtils toJson:rep]]];
        NSDictionary *jsonObject;
        XCTAssertTrue([RLTUtils deserializeJSONObjectFrom:[content dataUsingEncoding:NSUTF8StringEncoding] result:&jsonObject resultClass:NSDictionary.class]);
        XCTAssertEqual(jsonObject.count, 4);
        XCTAssertNotNil(jsonObject[RLT__REPORTS_FIELD__UPLOAD_TIME]);

        NSDictionary *device = jsonObject[RLT__REPORTS_FIELD__DEVICE];
        XCTAssertEqual(device.count, 1);
        XCTAssertEqualObjects(device[@"d"], @"dv");

        NSArray *reports = jsonObject[RLT__REPORTS_FIELD__REPORTS];
        XCTAssertEqual(reports.count, 1);
        XCTAssertEqualObjects(reports.firstObject, rep);
    }
}

- (void)testUploadReportsSingle {
    {
        int sequence = 123;
        NSString *content = @"content";

        RLTReport *report = [RLTReport reportWithSequence:sequence content:content device:nil];
        NSArray <RLTReport *> *reports = @[report];

        NSString *deviceContent;
        NSInteger maxSequence = 0;
        NSArray<NSString *> *result = [RLTFormats getUploadReports:reports deviceContent:&deviceContent maxSequence:&maxSequence];

        XCTAssertEqual(maxSequence, sequence);
        XCTAssertNil(deviceContent);
        XCTAssertEqual(result.count, 1);
        XCTAssertEqualObjects(result.firstObject, content);
    }

    {
        int sequence = 123;
        NSString *content = @"content";
        NSString *device = @"device";

        RLTReport *report = [RLTReport reportWithSequence:sequence content:content device:device];
        NSArray <RLTReport *> *reports = @[report];

        NSString *deviceContent;
        NSInteger maxSequence = 0;
        NSArray<NSString *> *result = [RLTFormats getUploadReports:reports deviceContent:&deviceContent maxSequence:&maxSequence];

        XCTAssertEqual(maxSequence, sequence);
        XCTAssertEqualObjects(deviceContent, device);
        XCTAssertEqual(result.count, 1);
        XCTAssertEqualObjects(result.firstObject, content);
    }

    {
        int sequence1 = 123;
        NSString *content1 = @"content1";
        int sequence2 = 124;
        NSString *content2 = @"content2";

        NSArray <RLTReport *> *reports = @[
                [RLTReport reportWithSequence:sequence1 content:content1 device:nil],
                [RLTReport reportWithSequence:sequence2 content:content2 device:nil]
        ];

        NSString *deviceContent;
        NSInteger maxSequence = 0;
        NSArray<NSString *> *result = [RLTFormats getUploadReports:reports deviceContent:&deviceContent maxSequence:&maxSequence];

        XCTAssertEqual(maxSequence, sequence2);
        XCTAssertNil(deviceContent);
        XCTAssertEqual(result.count, 2);
        XCTAssertEqualObjects(result[0], content1);
        XCTAssertEqualObjects(result[1], content2);
    }

    {
        int sequence1 = 123;
        NSString *content1 = @"content1";
        int sequence2 = 124;
        NSString *content2 = @"content2";
        NSString *device = @"device";

        NSArray <RLTReport *> *reports = @[
                [RLTReport reportWithSequence:sequence1 content:content1 device:device],
                [RLTReport reportWithSequence:sequence2 content:content2 device:device]
        ];

        NSString *deviceContent;
        NSInteger maxSequence = 0;
        NSArray<NSString *> *result = [RLTFormats getUploadReports:reports deviceContent:&deviceContent maxSequence:&maxSequence];

        XCTAssertEqual(maxSequence, sequence2);
        XCTAssertEqualObjects(deviceContent, device);
        XCTAssertEqual(result.count, 2);
        XCTAssertEqualObjects(result[0], content1);
        XCTAssertEqualObjects(result[1], content2);
    }

    {
        int sequence1 = 123;
        NSString *content1 = @"content1";
        NSString *device1 = @"device1";
        int sequence2 = 124;
        NSString *content2 = @"content2";
        NSString *device2 = @"device2";

        NSArray <RLTReport *> *reports = @[
                [RLTReport reportWithSequence:sequence1 content:content1 device:device1],
                [RLTReport reportWithSequence:sequence2 content:content2 device:device2]
        ];

        NSString *deviceContent;
        NSInteger maxSequence = 0;
        NSArray<NSString *> *result = [RLTFormats getUploadReports:reports deviceContent:&deviceContent maxSequence:&maxSequence];

        XCTAssertEqual(maxSequence, sequence1);
        XCTAssertEqualObjects(deviceContent, device1);
        XCTAssertEqual(result.count, 1);
        XCTAssertEqualObjects(result[0], content1);
    }

    {
        int sequence1 = 123;
        NSString *content1 = @"content1";
        NSString *device1 = @"device1";
        int sequence2 = 124;
        NSString *content2 = @"content2";
        NSString *device2 = nil;

        NSArray <RLTReport *> *reports = @[
                [RLTReport reportWithSequence:sequence1 content:content1 device:device1],
                [RLTReport reportWithSequence:sequence2 content:content2 device:device2]
        ];

        NSString *deviceContent;
        NSInteger maxSequence = 0;
        NSArray<NSString *> *result = [RLTFormats getUploadReports:reports deviceContent:&deviceContent maxSequence:&maxSequence];

        XCTAssertEqual(maxSequence, sequence1);
        XCTAssertEqualObjects(deviceContent, device1);
        XCTAssertEqual(result.count, 1);
        XCTAssertEqualObjects(result[0], content1);
    }

    {
        int sequence1 = 123;
        NSString *content1 = @"content1";
        NSString *device1 = nil;
        int sequence2 = 124;
        NSString *content2 = @"content2";
        NSString *device2 = @"device2";

        NSArray <RLTReport *> *reports = @[
                [RLTReport reportWithSequence:sequence1 content:content1 device:device1],
                [RLTReport reportWithSequence:sequence2 content:content2 device:device2]
        ];

        NSString *deviceContent;
        NSInteger maxSequence = 0;
        NSArray<NSString *> *result = [RLTFormats getUploadReports:reports deviceContent:&deviceContent maxSequence:&maxSequence];

        XCTAssertEqual(maxSequence, sequence1);
        XCTAssertNil(deviceContent);
        XCTAssertEqual(result.count, 1);
        XCTAssertEqualObjects(result[0], content1);
    }

    {
        int sequence1 = 123;
        NSString *content1 = @"content1";
        NSString *device = @"device";
        int sequence2 = 124;
        NSString *content2 = @"content2";
        int sequence3 = 125;
        NSString *content3 = @"content3";

        NSArray <RLTReport *> *reports = @[
                [RLTReport reportWithSequence:sequence1 content:content1 device:device],
                [RLTReport reportWithSequence:sequence2 content:content2 device:device],
                [RLTReport reportWithSequence:sequence3 content:content3 device:device]
        ];

        NSString *deviceContent;
        NSInteger maxSequence = 0;
        NSArray<NSString *> *result = [RLTFormats getUploadReports:reports deviceContent:&deviceContent maxSequence:&maxSequence];

        XCTAssertEqual(maxSequence, sequence3);
        XCTAssertEqualObjects(deviceContent, device);
        XCTAssertEqual(result.count, 3);
        XCTAssertEqualObjects(result[0], content1);
        XCTAssertEqualObjects(result[1], content2);
        XCTAssertEqualObjects(result[2], content3);
    }

    {
        int sequence1 = 123;
        NSString *content1 = @"content1";
        NSString *device = @"device";
        int sequence2 = 124;
        NSString *content2 = @"content2";
        int sequence3 = 125;
        NSString *content3 = @"content3";
        NSString *device3 = @"device3";

        NSArray <RLTReport *> *reports = @[
                [RLTReport reportWithSequence:sequence1 content:content1 device:device],
                [RLTReport reportWithSequence:sequence2 content:content2 device:device],
                [RLTReport reportWithSequence:sequence3 content:content3 device:device3]
        ];

        NSString *deviceContent;
        NSInteger maxSequence = 0;
        NSArray<NSString *> *result = [RLTFormats getUploadReports:reports deviceContent:&deviceContent maxSequence:&maxSequence];

        XCTAssertEqual(maxSequence, sequence2);
        XCTAssertEqualObjects(deviceContent, device);
        XCTAssertEqual(result.count, 2);
        XCTAssertEqualObjects(result[0], content1);
        XCTAssertEqualObjects(result[1], content2);
    }
}
@end
