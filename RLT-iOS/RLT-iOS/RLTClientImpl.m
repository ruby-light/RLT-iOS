//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTClientImpl.h"
#import "RLTInitConfig.h"
#import "RLTConfiguration.h"
#import "RLTIdentifyStorage.h"
#import "RLTReportsStorage.h"
#import "RLTUploader.h"
#import "RLTLogger.h"
#import "RLTUtils.h"
#import "RLTFormats.h"
#import "RLTSessionTracker.h"
#import "RLTSessionTrackerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RLTClientImpl ()
@property(nonatomic) RLTConfiguration *configuration;
@property(nonatomic) RLTIdentifyStorage *identifyStorage;
@property(nonatomic) RLTReportsStorage *reportsStorage;
@property(nonatomic) RLTUploader *uploader;

@property(nonatomic) NSTimer *_Nullable scheduleUploadTimer;
@property(nonatomic) BOOL scheduleUpload;
@property(nonatomic) BOOL uploading;

@property(nonatomic) NSOperationQueue *operationQueue;

@property(nonatomic, setter=setUserIdInternal:) NSString *_Nullable userId;
@property(nonatomic) NSString *deviceId;
@property(nonatomic) int sequence;

@property(nonatomic) RLTSessionTracker *sessionTracker;
@property(nonatomic, weak) id<RLTSessionTrackerDelegate>_Nullable sessionTrackerDelegate;
@end

@implementation RLTClientImpl

- (id <RLTClient>)initWithApiKey:(NSString *)apiKey initConfig:(RLTInitConfig *)initConfig {
    self = [super init];
    if (self) {
        self.configuration = [[RLTConfiguration alloc] initWithApiKey:apiKey initConfig:initConfig];
        self.identifyStorage = [[RLTIdentifyStorage alloc] initWithConfiguration:self.configuration];
        self.reportsStorage = [[RLTReportsStorage alloc] initWithConfiguration:self.configuration];
        self.uploader = [[RLTUploader alloc] initWithConfiguration:self.configuration];

        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;

        self.deviceId = [self initializeDeviceId:initConfig.initialDeviceId];
        self.userId = [self initializeUserId:initConfig.initialUserId];
        self.sequence = [self.reportsStorage getMaxSequence];

        RLTLoggerLog(@"RLT initialized: deviceId '%@', userId '%@', sequence %i, configuration: %@", self.deviceId, self.userId, self.sequence, self.configuration);

        self.sessionTrackerDelegate = initConfig.sessionTrackerDelegate;
        if (initConfig.enableStartAppEvent) {
            [self logEvent:RLT__DEFAULT_EVENTS__START_APP];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.sessionTrackerDelegate onStartAppEvent];
            }];
        }
        if (initConfig.enableSessionTracking) {
            __weak __typeof(self) weakSelf = self;
            self.sessionTracker = [RLTSessionTracker enableSessionTracking:initConfig.sessionTimeout listener:[RLTSessionTrackerListener listenerWithSessionStartedCallback:^(BOOL firstSession) {
                __strong __typeof(self) self = weakSelf;
                [self logEvent:RLT__DEFAULT_EVENTS__START_SESSION];
                [self flush];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.sessionTrackerDelegate onStartSessionEvent];
                }];
            }                                                                                                                                          sessionEndedCallback:^(NSTimeInterval duration) {
                __strong __typeof(self) self = weakSelf;
                [self flush];
            }]];
        } else {
            [self flush];
        }
    }
    return self;
}

- (void)setUserIdInternal:(NSString *_Nullable)userId {
    _userId = userId;
}

#pragma mark RLT StatisticsClient interface

- (id <RLTClient>)setUserId:(NSString *)userId {
    if (userId.length == 0) {
        RLTLoggerWarn(@"Warning: Ignore setUserId, value is blank");
        return self;
    }
    __weak __typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        __strong __typeof(self) self = weakSelf;
        [self.identifyStorage setUserId:userId];
        self.userId = userId;

        RLTLoggerLog(@"Set new userId '%@'", userId);
    }];
    return self;
}

- (id <RLTClient>)resetUserId:(BOOL)regenerateDeviceId {
    __weak __typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        __strong __typeof(self) self = weakSelf;
        self->_userId = nil;
        [self.identifyStorage setUserId:nil];
        if (regenerateDeviceId) {
            self.deviceId = [[NSUUID UUID] UUIDString];
            [self.identifyStorage setDeviceId:self.deviceId];
        }
    }];
    return self;
}

- (id <RLTClient>)logUserProperties:(RLTUserProperties *)userProperties {
    int64_t time = [RLTUtils currentTimeMillis];
    __weak __typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        __strong __typeof(self) self = weakSelf;
        NSDictionary *userContent = [RLTFormats buildPropertiesContent:userProperties];
        [self logReport:time eventContent:nil userContent:userContent];
    }];
    return self;
}

- (id <RLTClient>)logEvent:(NSString *)eventName {
    int64_t time = [RLTUtils currentTimeMillis];
    __weak __typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        __strong __typeof(self) self = weakSelf;
        NSDictionary *eventContent = [RLTFormats buildEventContent:eventName eventProperties:nil];
        if (eventContent) {
            [self logReport:time eventContent:eventContent userContent:nil];
        }
    }];
    return self;
}

- (id <RLTClient>)logEvent:(NSString *)eventName eventProperties:(RLTEventProperties *_Nullable)eventProperties {
    int64_t time = [RLTUtils currentTimeMillis];
    __weak __typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        __strong __typeof(self) self = weakSelf;
        NSDictionary *eventContent = [RLTFormats buildEventContent:eventName eventProperties:eventProperties];
        if (eventContent) {
            [self logReport:time eventContent:eventContent userContent:nil];
        }
    }];
    return self;
}

- (void)flush {
    __weak __typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        __strong __typeof(self) self = weakSelf;
        [self uploadReports];
    }];
}

#pragma mark Internal

- (void)logReport:(int64_t)time eventContent:(NSDictionary *_Nullable)eventContent userContent:(NSDictionary *_Nullable)userContent {
    int reportSequence = ++self.sequence;

    // save
    NSDictionary *report = [RLTFormats buildReport:self.deviceId userId:self.userId time:time sequence:reportSequence userContent:userContent eventContent:eventContent];
    NSString *reportContent =  [RLTUtils toJson:report];
    NSString *reportDeviceContent = nil;
    if (self.configuration.deviceProperties) {
        reportDeviceContent = [RLTUtils toJson:[RLTFormats buildPropertiesContent:self.configuration.deviceProperties]];
    }

    if (self.configuration.dryRunEnabled) {
        if (eventContent) {
            RLTLoggerLog(@"Event skipped (dryRun ON): %@ : %@", reportContent, reportDeviceContent);
        }
        if (userContent) {
            RLTLoggerLog(@"User Property skipped (dryRun ON): %@ : %@", reportContent, reportDeviceContent);
        }
        return;
    }

    [self.reportsStorage putReport:reportSequence reportContent:reportContent device:reportDeviceContent];

    RLTLoggerLog(@"Saved report[%i]: reportContent = '%@', reportDeviceContent = '%@'", reportSequence, reportContent, reportDeviceContent);

    // remove oldest if full
    int reportsCount = [self.reportsStorage getReportsCount];
    if (reportsCount > self.configuration.maxReportsCountInStorage) {
        int removeCount = reportsCount * self.configuration.removeReportsPercentWhenFull / 100;
        int sequenceForRemove = reportSequence - MAX(1, reportsCount - removeCount);
        BOOL removeSuccess = [self.reportsStorage removeEarlyReports:sequenceForRemove];
        if (removeSuccess) {
            RLTLoggerWarn(@"Number of reports removed: %li. Actual reports: %li", removeCount, [self.reportsStorage getReportsCount]);
        } else {
            RLTLoggerError(nil, @"Failed to remove %li reports. Existing reports: %li", removeCount, [self.reportsStorage getReportsCount]);
        }
    }

    // upload signal
    if ((reportsCount % self.configuration.uploadReportsCount) == 0) {
        [self uploadReports];
    } else {
        [self scheduleUploadReports];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wshadow"

- (void)uploadReports {
    if (self.uploading) {
        return;
    } else {
        self.uploading = YES;
    }

    @try {
        int limit = self.configuration.uploadReportsCount;
        NSArray<RLTReport *> *reports = [self.reportsStorage getReports:limit];
        if (reports.count > 0) {
            NSInteger maxSequence = 0;
            NSString *reportsContent = [RLTFormats buildUploadReportsContent:reports maxSequence:&maxSequence];
            __weak __typeof(self) weakSelf = self;
            [self.uploader uploadReports:reportsContent callback:^(BOOL success) {
                __strong __typeof(self) self = weakSelf;
                [self.operationQueue addOperationWithBlock:^{
                    [self handleUploadReportsResult:maxSequence success:success];
                }];
            }];
        } else {
            self.uploading = NO;
        }
    }
    @catch (NSException *exception) {
        RLTLoggerException(exception, @"Error while prepare upload reports task.");
    }
}

#pragma clang diagnostic pop

- (void)handleUploadReportsResult:(NSInteger)maxSequence success:(BOOL)success {
    if (success) {
        [self.reportsStorage removeEarlyReports:(int) maxSequence];
    }

    self.uploading = NO;

    if (success) {
        [self uploadReports];
    }
}

- (void)uploadReportsDelayed {
    __weak __typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        __strong __typeof(self) self = weakSelf;
        self.scheduleUpload = NO;
        [self uploadReports];
    }];
}

- (void)scheduleUploadReports {
    if (self.scheduleUpload) {
        return;
    } else {
        self.scheduleUpload = YES;
    }
    NSTimeInterval delay = self.configuration.uploadReportsPeriod;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scheduleUploadTimer invalidate];
        self.scheduleUploadTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(uploadReportsDelayed) userInfo:nil repeats:NO];
    });
}

- (NSString *)initializeDeviceId:(NSString *)initialDeviceId {
    NSString *deviceId = self.identifyStorage.deviceId;
    if (!deviceId) {
        if ([RLTUtils isStringEmpty:initialDeviceId]) {
            initialDeviceId = [[NSUUID UUID] UUIDString];
        }
        deviceId = initialDeviceId;
        [self.identifyStorage setDeviceId:deviceId];
    }
    return deviceId;
}

- (NSString *_Nullable)initializeUserId:(NSString *)initialUserId {
    NSString *userId = self.identifyStorage.userId;
    if (!userId) {
        if (![RLTUtils isStringEmpty:initialUserId]) {
            userId = initialUserId;
            [self.identifyStorage setUserId:userId];
        }
    }
    return userId;
}

@end

NS_ASSUME_NONNULL_END
