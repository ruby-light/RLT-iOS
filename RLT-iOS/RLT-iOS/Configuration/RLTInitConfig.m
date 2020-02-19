//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTInitConfig.h"
#import "RLTLogger.h"

@implementation RLTInitConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionTimeout = 30.0f;
        self.uploadTimeout = 60.0f;
        self.uploadReportsCount = 30;
        self.uploadReportsPeriod = 30.0f;
    }
    return self;
}

- (id)logger {
    return _logger ?: [RLTLogger defaultLogger];
}

@end