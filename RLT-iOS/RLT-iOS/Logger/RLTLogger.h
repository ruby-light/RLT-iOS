//
// Created by Alexey Chirkov on 03/02/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef RLT_TRACKER_DEBUG
#define RLTLoggerLog(format, ...) [RLTLogger.logger accept:(@"RLT DEBUG " format), ##__VA_ARGS__]
#else
#define RLTLoggerLog(format, ...)
#endif

#ifdef RLT_TRACKER_WARN
#define RLTLoggerWarn(format, ...) [RLTLogger.logger accept:(@"RLT WARN " format), ##__VA_ARGS__]
#else
#define RLTLoggerWarn(format, ...)
#endif

#ifdef RLT_TRACKER_ERROR
#define RLTLoggerError(error, format, ...) [RLTLogger.logger acceptError:error message:(@"RLT ERROR " format), ##__VA_ARGS__]
#define RLTLoggerException(exception, format, ...) [RLTLogger.logger acceptException:exception message:(@"RLT EXCEPTION " format), ##__VA_ARGS__]
#else
#define RLTLoggerError(format, ...)
#define RLTLoggerException(format, ...)
#endif

@protocol RLTLoggerProtocol <NSObject>

- (void)accept:(NSString *)message, ...;

- (void)acceptError:(NSError *)error message:(NSString *)message, ...;

- (void)acceptException:(NSException *)exception message:(NSString *)message, ...;

@end

@interface RLTLogger : NSObject <RLTLoggerProtocol>

@property(nonatomic, class) id <RLTLoggerProtocol> logger;

+ (id <RLTLoggerProtocol>)defaultLogger;

@end