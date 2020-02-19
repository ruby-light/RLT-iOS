//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLTInitConfig;
@class RLTBaseProperties;

NS_ASSUME_NONNULL_BEGIN

@interface RLTConfiguration : NSObject

@property(nonatomic, readonly) NSString *apiKey;

@property(nonatomic, readonly) NSString *serverUrl;
@property(nonatomic, readonly) NSTimeInterval uploadTimeout;
@property(nonatomic, readonly) NSURLSession *URLSession;

@property(nonatomic, readonly) int maxReportsCountInStorage;
@property(nonatomic, readonly) int removeReportsPercentWhenFull;
@property(nonatomic, readonly) int uploadReportsCount;
@property(nonatomic, readonly) NSTimeInterval uploadReportsPeriod;

@property(nonatomic, readonly) RLTBaseProperties *deviceProperties;

@property(nonatomic, readonly) BOOL dryRunEnabled;

- (instancetype)initWithApiKey:(NSString *)apiKey initConfig:(RLTInitConfig *)initConfig;

@end

NS_ASSUME_NONNULL_END