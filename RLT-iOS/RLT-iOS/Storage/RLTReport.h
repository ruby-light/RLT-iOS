//
// Created by Alexey Chirkov on 04/02/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RLTReport : NSObject
@property(nonatomic, readonly) int sequence;
@property(nonatomic, readonly) NSString *content;
@property(nonatomic, readonly) NSString *_Nullable device;

+ (instancetype)reportWithSequence:(int)sequence content:(NSString *)content device:(NSString *_Nullable)device;

@end

NS_ASSUME_NONNULL_END