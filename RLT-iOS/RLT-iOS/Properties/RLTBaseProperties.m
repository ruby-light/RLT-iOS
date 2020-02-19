//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTBaseProperties.h"

@interface RLTBaseProperties ()
@property(nonatomic, readwrite) NSMutableDictionary <NSString *, NSObject *> *properties;
@end

@implementation RLTBaseProperties

- (instancetype)init {
    self = [super init];
    if (self) {
        self.properties = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end