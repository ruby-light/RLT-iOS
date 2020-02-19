//
// Created by Alexey Chirkov on 03/02/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTLogger.h"

@implementation RLTLogger

static id <RLTLoggerProtocol> internalLogger;

+ (id <RLTLoggerProtocol>)logger {
    return internalLogger;
}

+ (void)setLogger:(id)logger {
    internalLogger = logger;
}

+ (id <RLTLoggerProtocol>)defaultLogger {
    return [[RLTLogger alloc] init];
}

- (void)accept:(NSString *)message, ... {
#ifdef DEBUG
    va_list args;
    va_start(args, message);
    NSLog(@"%@", [[NSString alloc] initWithFormat:message arguments:args]);
    va_end(args);
#endif
}

- (void)acceptError:(NSError *)error message:(NSString *)message, ... {
#ifdef DEBUG
    va_list args;
    va_start(args, message);
    NSLog(@"%@ : error %@", [[NSString alloc] initWithFormat:message arguments:args], error);
    va_end(args);
#endif
}

- (void)acceptException:(NSException *)exception message:(NSString *)message, ... {
#ifdef DEBUG
    va_list args;
    va_start(args, message);
    NSLog(@"%@ : exception %@", [[NSString alloc] initWithFormat:message arguments:args], exception);
    va_end(args);
#endif
}

@end