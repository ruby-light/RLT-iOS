#import <XCTest/XCTest.h>
#import "RLT.h"
#import "RLTClientWrapper.h"
#import "RLTIdentifyStorage.h"
#import "RLTConfiguration.h"
#import "RLTClientImpl+Tests.h"
#import "RLTReportsStorage.h"

NSString *const API_KEY = @"app";

@interface rlt_tests : XCTestCase
@property(nonatomic) RLT *rlt;
@property(nonatomic) RLTClientWrapper *rltInstance;
@end

@implementation rlt_tests

- (void)setUp {
    [self clearIdentifyStorage];
}

- (void)tearDown {
    [self clearIdentifyStorage];
    self.rltInstance = nil;
    self.rlt = nil;
    [NSThread sleepForTimeInterval:0.2f];
}

- (void)testDefaultClientInitialization {
    [self initializeClient];
    RLTClientImpl *client = (RLTClientImpl *) self.rltInstance.client;
    XCTAssertNotNil(client.deviceId, @"DeviceId must not be nil");
    XCTAssertTrue(client.deviceId.length > 0, @"DeviceId must not be empty string");
    XCTAssertNil(client.userId, @"UserId must nil by default");
}

- (void)testNotInitializedClient {
    RLT *rlt = [[RLT alloc] init];
    RLTClientWrapper *clientWrapper = [rlt getClient];
    XCTAssertNotNil(clientWrapper);
    RLTClientImpl *client = (RLTClientImpl *) self.rltInstance.client;
    XCTAssertNil(client);
}

- (void)testInitializeTwice {
    [self initializeClient];
    XCTAssertNotNil(self.rltInstance);
    XCTAssertEqual(self.rltInstance, [self.rlt initializeWithApiKey:@"myApiKey2"]);
}

- (void)testDeviceId {
    //initial setup
    [self initializeClient];
    RLTClientImpl *client = (RLTClientImpl *) self.rltInstance.client;
    XCTAssertNotNil(client.deviceId, @"DeviceId must not be nil");
    XCTAssertEqualObjects(client.deviceId, client.identifyStorage.deviceId);
    XCTAssertTrue(client.deviceId.length > 0, @"DeviceId must not be empty string");
    XCTAssertNil(client.userId, @"UserId must nil by default");
    XCTAssertNil(client.identifyStorage.userId, @"UserId must nil by default");

    [client.identifyStorage removeAllData];

    //first start
    self.rlt = [[RLT alloc] init];
    RLTInitConfig *initConfig = [[RLTInitConfig alloc] init];
    initConfig.initialDeviceId = @"myInitialDeviceId";
    initConfig.initialUserId = @"myInitialUserId";
    self.rltInstance = [self.rlt initializeWithApiKey:API_KEY initConfig:initConfig];
    client = (RLTClientImpl *) self.rltInstance.client;
    [client waitUntilAllOperationsAreFinished];
    XCTAssertEqualObjects(initConfig.initialDeviceId, client.deviceId, @"DeviceId must be equal to passed initial id");
    XCTAssertEqualObjects(initConfig.initialDeviceId, client.identifyStorage.deviceId, @"DeviceId must be equal to passed initial id");
    XCTAssertEqualObjects(initConfig.initialUserId, client.userId, @"UserId must be equal to passed initial id");
    XCTAssertEqualObjects(initConfig.initialUserId, client.identifyStorage.userId, @"UserId must be equal to passed initial id");

    //second start
    self.rlt = [[RLT alloc] init];
    self.rltInstance = [self.rlt initializeWithApiKey:API_KEY initConfig:initConfig];
    client = (RLTClientImpl *) self.rltInstance.client;
    [client waitUntilAllOperationsAreFinished];
    XCTAssertEqualObjects(initConfig.initialDeviceId, client.deviceId, @"After restart: DeviceId must be equal to previously stored id");
    XCTAssertEqualObjects(initConfig.initialDeviceId, client.identifyStorage.deviceId, @"After restart: DeviceId must be equal to previously stored id");
    XCTAssertEqualObjects(initConfig.initialUserId, client.userId, @"After restart: UserId must be equal to previously stored id");
    XCTAssertEqualObjects(initConfig.initialUserId, client.identifyStorage.userId, @"After restart: UserId must be equal to previously stored id");
    [client resetUserId:NO];
    [client waitUntilAllOperationsAreFinished];
    XCTAssertEqualObjects(initConfig.initialDeviceId, client.deviceId, @"DeviceId must be equal to previously stored id after only UserId is reset");
    XCTAssertEqualObjects(initConfig.initialDeviceId, client.identifyStorage.deviceId, @"DeviceId must be equal to previously stored id after only UserId is reset");
    XCTAssertNil(client.userId, @"UserId must be nil after 'resetUserId'");
    XCTAssertNil(client.identifyStorage.userId, @"UserId must be nil after 'resetUserId'");
    [client resetUserId:YES];
    [client waitUntilAllOperationsAreFinished];
    XCTAssertNotEqualObjects(initConfig.initialDeviceId, client.deviceId, @"DeviceId must NOT be equal to previously stored id after UserId is reset with DeviceId");
    XCTAssertNotEqualObjects(initConfig.initialDeviceId, client.identifyStorage.deviceId, @"DeviceId must NOT be equal to previously stored id after UserId is reset with DeviceId");
    XCTAssertTrue(client.deviceId.length > 0, @"DeviceId must not be empty string");
    XCTAssertTrue(client.identifyStorage.deviceId.length > 0, @"DeviceId must not be empty string");
    XCTAssertNil(client.userId, @"UserId must be nil after 'resetUserId'");
    XCTAssertNil(client.identifyStorage.userId, @"UserId must be nil after 'resetUserId'");

    [client setUserId:@"user1"];
    [client waitUntilAllOperationsAreFinished];
    XCTAssertEqualObjects(client.userId, @"user1");
    XCTAssertEqualObjects(client.identifyStorage.userId, @"user1");

    [client setUserId:@"user2"];
    [client waitUntilAllOperationsAreFinished];
    XCTAssertEqualObjects(client.userId, @"user2");
    XCTAssertEqualObjects(client.identifyStorage.userId, @"user2");
}

#pragma mark Internal

- (void)initializeClient {
    self.rlt = [[RLT alloc] init];
    self.rltInstance = [self.rlt initializeWithApiKey:API_KEY];
}

- (void)clearIdentifyStorage {
    RLTConfiguration *configuration = [[RLTConfiguration alloc] initWithApiKey:API_KEY initConfig:[[RLTInitConfig alloc] init]];
    RLTIdentifyStorage *identifyStorage = [[RLTIdentifyStorage alloc] initWithConfiguration:configuration];
    [identifyStorage removeAllData];
}

- (void)clearReportsStorage {
    RLTConfiguration *configuration = [[RLTConfiguration alloc] initWithApiKey:API_KEY initConfig:[[RLTInitConfig alloc] init]];
    RLTReportsStorage *identifyStorage = [[RLTReportsStorage alloc] initWithConfiguration:configuration];
    XCTAssertTrue([identifyStorage deleteDatabase]);
}

@end
