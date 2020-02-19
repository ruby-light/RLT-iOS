//
// Created by Alexey Chirkov on 15/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTIO.h"

@implementation RLTIO

+ (NSString *)rootDirPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)removeFileAtPath:(NSString *)path error:(NSError **)error {
    BOOL exists = [RLTIO fileExistsAtPath:path];
    if (exists) {
        return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
    }
    return YES;
}

@end