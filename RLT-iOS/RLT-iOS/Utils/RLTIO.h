//
// Created by Alexey Chirkov on 15/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLTIO : NSObject
@property(nonatomic, readonly, class) NSString *rootDirPath;

+ (BOOL)fileExistsAtPath:(NSString *)path;

+ (BOOL)removeFileAtPath:(NSString *)path error:(NSError **)error;

@end