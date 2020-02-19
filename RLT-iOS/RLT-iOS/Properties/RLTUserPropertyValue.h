//
// Created by Alexey Chirkov on 29/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RLTUserPropertyValue : NSObject
@property(nonatomic, readonly) NSString *operation;
@property(nonatomic, readonly) NSObject *_Nullable value;

- (instancetype)initWithOperation:(NSString *)operation value:(NSObject *_Nullable)value;

@end

NS_ASSUME_NONNULL_END