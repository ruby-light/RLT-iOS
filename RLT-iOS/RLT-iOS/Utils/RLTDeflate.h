//
// Created by Alexey Chirkov on 10/02/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLTDeflate : NSObject

+ (NSData *) rlt_compress:(NSData *)data;

+ (NSData *) rlt_decompress:(NSData *)data;

@end