//
// Created by Alexey Chirkov on 06/02/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTReportsStorage.h"

@interface RLTReportsStorage (Test)

@property(nonatomic, readonly) dispatch_queue_t databaseOperationQueue;

- (void) waitUntilAllOperationsAreFinished;

@end