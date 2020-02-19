//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLTConfiguration;
@class RLTReport;

NS_ASSUME_NONNULL_BEGIN

@interface RLTReportsStorage : NSObject

- (instancetype)initWithConfiguration:(RLTConfiguration *)configuration;

- (int)getMaxSequence;

- (int)getReportsCount;

- (void)putReport:(int)reportSequence reportContent:(NSString *)reportContent device:(NSString *_Nullable)device;

- (BOOL)removeEarlyReports:(int)sequenceNumber;

- (NSArray <RLTReport *> *_Nullable)getReports:(int)limit;

- (BOOL)dropAllTables:(BOOL)deleteDatabase;

- (BOOL)deleteDatabase;

@end

NS_ASSUME_NONNULL_END