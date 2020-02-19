//
//  rlt_identifyStorage.m
//  rlt-analytics-tests
//
//  Created by Alexey Chirkov on 06/02/2020.
//  Copyright © 2020 Rubylight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLTConfiguration.h"
#import "RLTIdentifyStorage.h"
#import "RLTInitConfig.h"

@interface rlt_identifyStorage : XCTestCase
@property(nonatomic) RLTConfiguration *configuration;
@property(nonatomic) RLTIdentifyStorage *identifyStorage;
@end

@implementation rlt_identifyStorage

- (void)setUp {
    NSString *apiKey = @"APIKEY";
    self.configuration = [[RLTConfiguration alloc] initWithApiKey:apiKey initConfig:[[RLTInitConfig alloc] init]];
    self.identifyStorage = [[RLTIdentifyStorage alloc] initWithConfiguration:self.configuration];
    [self.identifyStorage removeAllData];
}

- (void)tearDown {
    self.identifyStorage = nil;
}

- (void)testDeviceId {
    NSString *deviceId = @"abc";
    XCTAssertNil(self.identifyStorage.deviceId);

    [self.identifyStorage setDeviceId:deviceId];
    XCTAssertEqualObjects(self.identifyStorage.deviceId, deviceId);
}

- (void)testUserId {
    NSString *userId = @"abc";
    XCTAssertNil(self.identifyStorage.userId);

    [self.identifyStorage setUserId:userId];
    XCTAssertEqualObjects(self.identifyStorage.userId, userId);
}

- (void)testSetPerformance {
    NSString *userId = @"abc";

    [self measureBlock:^{
        [self.identifyStorage setUserId:userId];
    }];
}

@end
