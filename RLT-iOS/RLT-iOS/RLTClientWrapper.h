//
// Created by Alexey Chirkov on 27/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLTClient.h"

@interface RLTClientWrapper : NSObject <RLTClient>

@property(nonatomic) id <RLTClient> client;

@end