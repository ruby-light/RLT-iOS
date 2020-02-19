//
// Created by Alexey Chirkov on 29/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTClientImpl.h"

@class RLTIdentifyStorage;
@class RLTReportsStorage;
@class RLTConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface RLTClientImpl (Tests)

@property(nonatomic, readonly) NSString *_Nullable userId;
@property(nonatomic, readonly) NSString *deviceId;

@property(nonatomic, readonly) RLTConfiguration *configuration;


@property(nonatomic, readonly) RLTIdentifyStorage *identifyStorage;
@property(nonatomic, readonly) RLTReportsStorage *reportsStorage;

@property(nonatomic, readonly) NSOperationQueue *operationQueue;

- (void) waitUntilAllOperationsAreFinished;

@end

NS_ASSUME_NONNULL_END