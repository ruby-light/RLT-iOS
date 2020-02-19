//
//  rlt_eventProperties.m
//  rlt-analytics-tests
//
//  Created by Alexey Chirkov on 06/02/2020.
//  Copyright © 2020 Rubylight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLTEventProperties.h"
#import "RLTFormats.h"
#import "NSString+Test.h"

@interface rlt_eventProperties : XCTestCase

@end

@implementation rlt_eventProperties

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    RLTEventProperties *eventProperties = [RLTEventProperties instance];
    XCTAssertEqual(eventProperties.properties.count, 0);

    NSString *property1 = @"property1";
    NSString *value1 = @"value2";
    NSString *value12 = @"value23";

    NSString *property2 = @" property2";
    NSString *value2 = @" value2 ";

    NSString *property3 = [NSString stringWithLength:PROPERTY_NAME_MAX_LENGTH + 1];
    NSString *value3 = @"value2";

    NSString *property4 = @"";
    NSString *value4 = nil;

    NSString *property5 = @"   ";
    NSString *value5 = [NSString stringWithLength:PROPERTY_VALUE_MAX_LENGTH + 1];

    NSString *property6 = nil;
    NSString *value6 = nil;

    NSString *property7 = @"property7";
    NSNumber *value7 = @1;

    [eventProperties set:value1 forKey:property1];
    [eventProperties set:value2 forKey:property2];
    [eventProperties set:value3 forKey:property3];
    [eventProperties set:value4 forKey:property4];
    [eventProperties set:value5 forKey:property5];
    [eventProperties set:value6 forKey:property6];
    [eventProperties set:value7 forKey:property7];

    XCTAssertEqual(eventProperties.properties.count, 6);
    XCTAssertEqualObjects(eventProperties.properties[property1], value1);
    XCTAssertEqualObjects(eventProperties.properties[property2], value2);
    XCTAssertEqualObjects(eventProperties.properties[property3], value3);
    XCTAssertEqual(eventProperties.properties[property4], [NSNull null]);
    XCTAssertEqualObjects(eventProperties.properties[property5], value5);

    [eventProperties set:value12 forKey:property1];
    XCTAssertEqual(eventProperties.properties.count, 6);
    XCTAssertEqualObjects(eventProperties.properties[property1], value12);
}


@end
