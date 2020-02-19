//
//  rlt_configuration.m
//  rlt-analytics-tests
//
//  Created by Alexey Chirkov on 05/02/2020.
//  Copyright © 2020 Rubylight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLTInitConfig.h"
#import "RLTConfiguration.h"
#import "RLTFormats.h"
#import "RLTBaseProperties.h"

@interface rlt_configuration : XCTestCase

@end

@implementation rlt_configuration

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testInitConfig {
    RLTInitConfig *initConfig = [[RLTInitConfig alloc] init];

    XCTAssertNil(initConfig.serverUrl);
    XCTAssertNil(initConfig.devicePropertyConfig);
    XCTAssertNil(initConfig.initialDeviceId);
    XCTAssertNil(initConfig.initialUserId);
    XCTAssertFalse(initConfig.enableStartAppEvent);
    XCTAssertFalse(initConfig.enableSessionTracking);

    initConfig.serverUrl = @"abc";
    initConfig.devicePropertyConfig = [[[RLTDevicePropertyConfig alloc] init] trackBrand];
    initConfig.initialDeviceId = @"d";
    initConfig.initialUserId = @"u";
    initConfig.enableStartAppEvent = YES;
    initConfig.enableSessionTracking = YES;

    XCTAssertEqualObjects(initConfig.serverUrl, @"abc");
    XCTAssertEqualObjects(initConfig.devicePropertyConfig, [[[RLTDevicePropertyConfig alloc] init] trackBrand]);
    XCTAssertEqualObjects(initConfig.initialDeviceId, @"d");
    XCTAssertEqualObjects(initConfig.initialUserId, @"u");
    XCTAssertTrue(initConfig.enableStartAppEvent);
    XCTAssertTrue(initConfig.enableSessionTracking);
}

- (void)testDefault {
    NSString *apiKey = @"APIKEY";
    RLTInitConfig *initConfig = [[RLTInitConfig alloc] init];

    RLTConfiguration *configuration = [[RLTConfiguration alloc] initWithApiKey:apiKey initConfig:initConfig];
    XCTAssertEqualObjects(configuration.apiKey, apiKey);
    XCTAssertEqualObjects(configuration.serverUrl, RLT__SERVER_URL);
    XCTAssertNil(configuration.deviceProperties);
}

- (void)testCustom {
    NSString *apiKey = @"APIKEY";
    NSString *serverUrl = @"http://localhost";
    RLTInitConfig *initConfig = [[RLTInitConfig alloc] init];
    initConfig.serverUrl = serverUrl;
    initConfig.devicePropertyConfig = [[[RLTDevicePropertyConfig alloc] init] trackBrand];

    RLTConfiguration *configuration = [[RLTConfiguration alloc] initWithApiKey:apiKey initConfig:initConfig];
    XCTAssertEqualObjects(configuration.apiKey, apiKey);
    XCTAssertEqualObjects(configuration.serverUrl, serverUrl);
    XCTAssertEqual(configuration.deviceProperties.properties.count, 1);
    XCTAssertTrue([configuration.deviceProperties.properties[@"brand"] conformsToProtocol:@protocol(RLTDevicePropertySupplierProtocol)]);
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) configuration.deviceProperties.properties[@"brand"]) getValue], @"Apple");
}

@end
