//
// Created by Alexey Chirkov on 29/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTUserPropertyValue.h"
#import "RLTLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface RLTUserPropertyValue ()
@property(nonatomic, readwrite) NSString *operation;
@property(nonatomic, readwrite) NSObject *_Nullable value;
@end

@implementation RLTUserPropertyValue

- (instancetype)initWithOperation:(NSString *)operation value:(NSObject *_Nullable)value {
    self = [super init];
    if (self) {
        self.operation = operation;
        self.value = value;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END