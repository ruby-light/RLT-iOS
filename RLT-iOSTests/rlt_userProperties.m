//
//  rlt_userProperties.m
//  rlt-analytics-tests
//
//  Created by Alexey Chirkov on 06/02/2020.
//  Copyright © 2020 Rubylight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLTUserProperties.h"
#import "RLTFormats.h"
#import "RLTUserPropertyValue.h"
#import "NSString+Test.h"

@interface rlt_userProperties : XCTestCase

@end

@implementation rlt_userProperties

- (void)setUp {
}

- (void)tearDown {
}

- (void)testExample {
    RLTUserProperties *userProperties = [RLTUserProperties instance];
    XCTAssertEqual(userProperties.properties.count, 0);

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

    [userProperties unset:property1];
    XCTAssertEqual(userProperties.properties.count, 1);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property1]).operation, RLT__PROPERTY_OPERATION__UNSET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property1]).value, [NSNull null]);

    [userProperties unset:property2];
    XCTAssertEqual(userProperties.properties.count, 2);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property2]).operation, RLT__PROPERTY_OPERATION__UNSET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property2]).value, [NSNull null]);

    [userProperties unset:property3];
    XCTAssertEqual(userProperties.properties.count, 3);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property3]).operation, RLT__PROPERTY_OPERATION__UNSET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property3]).value, [NSNull null]);

    [userProperties unset:property4];
    XCTAssertEqual(userProperties.properties.count, 4);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property4]).operation, RLT__PROPERTY_OPERATION__UNSET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property4]).value, [NSNull null]);

    [userProperties unset:property5];
    XCTAssertEqual(userProperties.properties.count, 5);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property5]).operation, RLT__PROPERTY_OPERATION__UNSET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property5]).value, [NSNull null]);

    [userProperties set:value1 forKey:property1];
    [userProperties set:value2 forKey:property2];
    [userProperties set:value3 forKey:property3];
    [userProperties set:value4 forKey:property4];
    [userProperties set:value5 forKey:property5];
    [userProperties set:value6 forKey:property6];
    XCTAssertEqual(userProperties.properties.count, 5);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property1]).operation, RLT__PROPERTY_OPERATION__SET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property1]).value, value1);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property2]).operation, RLT__PROPERTY_OPERATION__SET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property2]).value, value2);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property3]).operation, RLT__PROPERTY_OPERATION__SET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property3]).value, value3);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property4]).operation, RLT__PROPERTY_OPERATION__SET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property4]).value, value4);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property5]).operation, RLT__PROPERTY_OPERATION__SET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property5]).value, value5);

    [userProperties set:value12 forKey:property1];
    XCTAssertEqual(userProperties.properties.count, 5);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property1]).operation, RLT__PROPERTY_OPERATION__SET);
    XCTAssertEqualObjects(((RLTUserPropertyValue *) userProperties.properties[property1]).value, value12);

}


@end
