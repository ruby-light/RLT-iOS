//
//  rlt_reportsStorage.m
//  rlt-analytics-tests
//
//  Created by Alexey Chirkov on 06/02/2020.
//  Copyright © 2020 Rubylight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RLTConfiguration.h"
#import "RLTInitConfig.h"
#import "RLTReportsStorage.h"
#import "RLTLogger.h"
#import "RLTReport.h"

@interface rlt_reportsStorage : XCTestCase
@property(nonatomic) RLTReportsStorage *reportsStorage;
@end

@implementation rlt_reportsStorage

- (void)setUp {
    NSString *apiKey = @"APIKEY";
    RLTInitConfig *initConfig = [[RLTInitConfig alloc] init];
    RLTConfiguration *configuration = [[RLTConfiguration alloc] initWithApiKey:apiKey initConfig:initConfig];
    [RLTLogger setLogger:initConfig.logger];
    self.reportsStorage = [[RLTReportsStorage alloc] initWithConfiguration:configuration];
    [self.reportsStorage dropAllTables:YES];
}

- (void)tearDown {
    self.reportsStorage = nil;
}

- (void)testPutEvent {
    XCTAssertEqual([self.reportsStorage getReportsCount], 0);
    XCTAssertEqual([self.reportsStorage getMaxSequence], 0);
    XCTAssertNil([self.reportsStorage getReports:1]);

    int sequence1 = 1;
    NSString *content1 = @"{\"content\":1}";
    [self.reportsStorage putReport:sequence1 reportContent:content1 device:nil];

    XCTAssertEqual([self.reportsStorage getReportsCount], 1);
    XCTAssertEqual([self.reportsStorage getMaxSequence], sequence1);

    NSArray <RLTReport *> *reports = [self.reportsStorage getReports:1];
    XCTAssertEqual(reports.count, 1);
    XCTAssertEqual(reports.firstObject.sequence, sequence1);
    XCTAssertEqualObjects(reports.firstObject.content, content1);
    XCTAssertNil(reports.firstObject.device);

    int sequence3 = 3;
    NSString *content3 = @"{\"content\":3}";
    NSString *device3 = @"{\"device\":3}";
    [self.reportsStorage putReport:sequence3 reportContent:content3 device:device3];

    XCTAssertEqual([self.reportsStorage getReportsCount], 2);
    XCTAssertEqual([self.reportsStorage getMaxSequence], sequence3);


    NSArray<RLTReport *> *reports21 = [self.reportsStorage getReports:1];
    XCTAssertEqual(reports21.count, 1);
    XCTAssertEqual(reports21.firstObject.sequence, sequence1);
    XCTAssertEqualObjects(reports21.firstObject.content, content1);
    XCTAssertNil(reports21.firstObject.device);

    NSArray<RLTReport *> *reports22 = [self.reportsStorage getReports:2];
    XCTAssertEqual(reports22.count, 2);
    XCTAssertEqual(reports22.firstObject.sequence, sequence1);
    XCTAssertEqualObjects(reports22.firstObject.content, content1);
    XCTAssertNil(reports22.firstObject.device);
    XCTAssertEqual(reports22[1].sequence, sequence3);
    XCTAssertEqualObjects(reports22[1].content, content3);
    XCTAssertEqualObjects(reports22[1].device, device3);

    NSArray<RLTReport *> *reports23 = [self.reportsStorage getReports:3];
    XCTAssertEqual(reports23.count, 2);
    XCTAssertEqual(reports23.firstObject.sequence, sequence1);
    XCTAssertEqualObjects(reports23.firstObject.content, content1);
    XCTAssertNil(reports23.firstObject.device);
    XCTAssertEqual(reports23[1].sequence, sequence3);
    XCTAssertEqualObjects(reports23[1].content, content3);
    XCTAssertEqualObjects(reports23[1].device, device3);

    BOOL removeSuccess = [self.reportsStorage removeEarlyReports:sequence1];
    XCTAssertTrue(removeSuccess);
    XCTAssertEqual([self.reportsStorage getReportsCount], 1);
    XCTAssertEqual([self.reportsStorage getMaxSequence], sequence3);

    NSArray<RLTReport *> *reports33 = [self.reportsStorage getReports:3];
    XCTAssertEqual(reports33.count, 1);
    XCTAssertEqual(reports33.firstObject.sequence, sequence3);
    XCTAssertEqualObjects(reports33.firstObject.content, content3);
    XCTAssertEqualObjects(reports33.firstObject.device, device3);

    removeSuccess = [self.reportsStorage removeEarlyReports:sequence3];
    XCTAssertTrue(removeSuccess);
    XCTAssertEqual([self.reportsStorage getReportsCount], 0);
    XCTAssertEqual([self.reportsStorage getMaxSequence], 0);
    XCTAssertNil([self.reportsStorage getReports:1]);
}

- (void)testDuplicateEvent {
    XCTAssertEqual([self.reportsStorage getReportsCount], 0);
    XCTAssertEqual([self.reportsStorage getMaxSequence], 0);
    XCTAssertNil([self.reportsStorage getReports:1]);

    int sequence1 = 1;
    NSString *content1 = @"{\"content\":1}";
    [self.reportsStorage putReport:sequence1 reportContent:content1 device:nil];

    XCTAssertEqual([self.reportsStorage getReportsCount], 1);
    XCTAssertEqual([self.reportsStorage getMaxSequence], sequence1);

    NSArray <RLTReport *> *reports = [self.reportsStorage getReports:1];
    XCTAssertEqual(reports.count, 1);
    XCTAssertEqual(reports.firstObject.sequence, sequence1);
    XCTAssertEqualObjects(reports.firstObject.content, content1);
    XCTAssertNil(reports.firstObject.device);

    [self.reportsStorage putReport:sequence1 reportContent:content1 device:nil];

    XCTAssertEqual([self.reportsStorage getMaxSequence], sequence1);

    NSArray <RLTReport *> *reports2 = [self.reportsStorage getReports:1];
    XCTAssertEqual(reports2.count, 1);
    XCTAssertEqual(reports2.firstObject.sequence, sequence1);
    XCTAssertEqualObjects(reports2.firstObject.content, content1);
    XCTAssertNil(reports2.firstObject.device);
}

- (void)testPutEventPerformance {
    int sequence1 = 1;
    NSString *content1 = @"{\"content\":1}";

    [self measureBlock:^{
        [self.reportsStorage putReport:sequence1 reportContent:content1 device:nil];
    }];
}

- (void)testGetReportsCountPerformance {
    int sequence1 = 1;
    NSString *content1 = @"{\"content\":1}";
    [self.reportsStorage putReport:sequence1 reportContent:content1 device:nil];
    [self measureBlock:^{
        XCTAssertEqual([self.reportsStorage getReportsCount], 1);
    }];
}

- (void)testGetReportsPerformance {
    int sequence1 = 1;
    NSString *content1 = @"{\"content\":1}";
    [self.reportsStorage putReport:sequence1 reportContent:content1 device:nil];
    [self measureBlock:^{
        __unused NSArray <RLTReport *> *reports = [self.reportsStorage getReports:1];
    }];
}

- (void)testRemoveEarlyReportsPerformance {
    int sequence1 = 1;
    NSString *content1 = @"{\"content\":1}";
    [self.reportsStorage putReport:sequence1 reportContent:content1 device:nil];
    [self measureBlock:^{
        [self.reportsStorage removeEarlyReports:sequence1];
    }];
}

@end
