//
// Created by Alexey Chirkov on 29/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTClientImpl+Tests.h"
#import "RLTIdentifyStorage.h"
#import "RLTReportsStorage.h"
#import "RLTConfiguration.h"


@implementation RLTClientImpl (Tests)

@dynamic deviceId;
@dynamic userId;
@dynamic configuration;
@dynamic identifyStorage;
@dynamic reportsStorage;
@dynamic operationQueue;

- (void) waitUntilAllOperationsAreFinished {
    [self.operationQueue waitUntilAllOperationsAreFinished];
}

@end
