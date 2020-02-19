//
// Created by Alexey Chirkov on 06/02/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "NSString+Test.h"

@implementation NSString (Test)

+ (NSString *)stringWithLength:(int)length {
    return [@"_" stringByPaddingToLength:(NSUInteger) length withString:@"_" startingAtIndex:0];
}

@end