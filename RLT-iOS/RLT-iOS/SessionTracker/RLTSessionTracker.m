//
// Created by Alexey Chirkov on 30/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLTSessionTracker.h"
#import "RLTSessionTrackerState.h"
#import "RLTSessionTrackerBackgroundState.h"
#import "RLTLogger.h"

NSString *const kRLTSessionTrackerSessionExpiredNotification = @"kRLTSessionTrackerSessionExpiredNotification";
static NSTimeInterval UIApplicationBackgroundTaskDelay = 2;

@interface RLTSessionTracker ()
@property(nonatomic) NSObject *lock;
@property(nonatomic) BOOL enabled;
@property(nonatomic) NSTimeInterval timeout;
@property(nonatomic) NSTimer *timer;
@property(nonatomic) RLTSessionTrackerListener *listener;
@property(nonatomic) id <RLTSessionTrackerState> state;
@property(nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
@end

@implementation RLTSessionTracker

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [[NSObject alloc] init];
        self.state = [[RLTSessionTrackerBackgroundState alloc] initWithTracker:self coldStart:YES];
    }
    return self;
}

- (void)enableSessionTracking:(NSTimeInterval)timeout listener:(RLTSessionTrackerListener *)listener {
    @synchronized (self.lock) {
        if (self.enabled) {
            return;
        }
        self.enabled = YES;
    }
    self.timeout = timeout;
    self.listener = listener;

    __weak __typeof(self) weakSelf = self;
    [self runOnMainQueue:^{
        __strong __typeof(self) self = weakSelf;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(onUIApplicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
        [center addObserver:self selector:@selector(onUIApplicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
        [center addObserver:self selector:@selector(onUIApplicationDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [center addObserver:self selector:@selector(onRLTSessionTrackerSessionExpiredNotification:) name:kRLTSessionTrackerSessionExpiredNotification object:nil];
        UIApplication *sharedApplication = [self getSharedApplication];
        if (sharedApplication) {
            if (sharedApplication.applicationState != UIApplicationStateBackground) {
                [self onUIApplicationDidBecomeActiveNotification];
            }
        }
    }];
}

+ (instancetype)enableSessionTracking:(NSTimeInterval)timeout listener:(RLTSessionTrackerListener *)listener {
    RLTSessionTracker *tracker = [[RLTSessionTracker alloc] init];
    [tracker enableSessionTracking:timeout listener:listener];
    return tracker;
}

- (void)runOnMainQueue:(void (^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#pragma mark Internal

- (void)onUIApplicationWillResignActiveNotification {
    [self endBackgroundTask];
}

- (void)onUIApplicationDidBecomeActiveNotification {
    NSAssert([NSThread isMainThread], @"Must be called from the main thread!");
    UIApplication *sharedApplication = [self getSharedApplication];
    if (sharedApplication == nil) {
        //app extension case
        return;
    }
    [self endBackgroundTask];
    self.state = [self.state toForeground:self.listener timer:self.timer];
}

- (void)onUIApplicationDidEnterBackgroundNotification {
    NSAssert([NSThread isMainThread], @"Must be called from the main thread!");
    UIApplication *sharedApplication = [self getSharedApplication];
    if (sharedApplication == nil) {
        //app extension case
        return;
    }
    [self endBackgroundTask];
    __weak __typeof(self) weakSelf = self;
    self.backgroundTaskId = [sharedApplication beginBackgroundTaskWithName:@"RLTSessionTrackerBgTask" expirationHandler:^{
        __strong __typeof(self) self = weakSelf;
        [self endBackgroundTask];
    }];
    self.state = [self.state toBackground:self.listener timer:self.timer];
}

- (void)onRLTSessionTrackerSessionExpiredNotification:(NSNotification *)notification {
    self.state = [self.state sessionExpirationEventOn:notification.object listener:self.listener];
    //to be sure that the request will reach the server
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (UIApplicationBackgroundTaskDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endBackgroundTask];
    });
}

- (void)endBackgroundTask {
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication *sharedApplication = [self getSharedApplication];
        if (!sharedApplication) {
            return;
        }
        [sharedApplication endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
}

- (UIApplication *)getSharedApplication {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if (UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return [UIApplication performSelector:@selector(sharedApplication)];
    }
    return nil;
}

@end

