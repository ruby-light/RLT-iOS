//
//  rlt_devicePropertyConfig.m
//  rlt-analytics-tests
//
//  Created by Alexey Chirkov on 05/02/2020.
//  Copyright © 2020 Rubylight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLTDevicePropertyConfig.h"
#import "RLTDevicePropertyFactory.h"

@interface rlt_devicePropertyConfig : XCTestCase

@end

@implementation rlt_devicePropertyConfig

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAllProperties {
    RLTDevicePropertyConfig *devicePropertyConfig = [[[[[[[[[[[[RLTDevicePropertyConfig alloc] init]
            trackPlatform]
            trackModel]
            trackBrand]
            trackManufacturer]
            trackOsVersion]
            trackAppVersion]
            trackCountry]
            trackLanguage]
            trackCarrier]
            trackCacheProperty:@"my" callback:^NSString * {
                return @"prop";
            }];

    XCTAssertEqual(devicePropertyConfig.properties.count, 10);
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"platform"]) getValue], @"ios");
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"model"]) getValue], [RLTDevicePropertyFactory getHWMachine]);
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"brand"]) getValue], @"Apple");
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"manufacturer"]) getValue], @"Apple");
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"osVersion"]) getValue], [[UIDevice currentDevice] systemVersion]);
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"appVersion"]) getValue], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]);
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"country"]) getValue], [RLTDevicePropertyFactory countryISOCode]);
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"language"]) getValue], [RLTDevicePropertyFactory language]);
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"carrier"]) getValue], [RLTDevicePropertyFactory carrier]);
    XCTAssertEqualObjects([((id<RLTDevicePropertySupplierProtocol>) devicePropertyConfig.properties[@"my"]) getValue], @"prop");

}

@end
