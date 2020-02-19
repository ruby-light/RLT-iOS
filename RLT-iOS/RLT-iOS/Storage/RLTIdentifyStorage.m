//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTIdentifyStorage.h"
#import "RLTLogger.h"
#import "RLTConfiguration.h"
#import "RLTIO.h"

NSString *const RLTIdentifyStorage_Entity = @"identify";

NSString *const RLTIdentifyStorage_DeviceId = @"deviceId";
NSString *const RLTIdentifyStorage_UserId = @"userId";

@interface RLTIdentifyStorage ()
@property(nonatomic, weak) RLTConfiguration *configuration;
@end

@implementation RLTIdentifyStorage

- (instancetype)initWithConfiguration:(RLTConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.configuration = configuration;
    }
    return self;
}

- (NSString *)deviceId {
    return [self dataFromStorage][RLTIdentifyStorage_DeviceId];
}

- (void)setDeviceId:(NSString *)deviceId {
    [self storeValue:deviceId forKey:RLTIdentifyStorage_DeviceId];
}

- (NSString *)userId {
    return [self dataFromStorage][RLTIdentifyStorage_UserId];
}

- (void)setUserId:(NSString *)userId {
    [self storeValue:userId forKey:RLTIdentifyStorage_UserId];
}

- (void)removeAllData {
    NSString *path = [self filePath];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        BOOL success = [fileManager removeItemAtPath:path error:&error];
        if (!success || error) {
            RLTLoggerError(error, @"Removing all data failed.");
        }
    }
}

- (NSString *)filePath {
    NSString *fileName = [NSString stringWithFormat:@"com_rubylight_statistics_%@_%@.dictionary", self.configuration.apiKey, RLTIdentifyStorage_Entity];
    return [RLTIO.rootDirPath stringByAppendingPathComponent:fileName];
}

- (void)storeValue:(NSObject *)value forKey:(NSString *)key {
    NSMutableDictionary *dictionary = [[self dataFromStorage] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    dictionary[key] = value;

    NSString *path = [self filePath];
    BOOL success = NO;
    if (@available(iOS 11.0, *)) {
        NSError *archiveError;
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:dictionary requiringSecureCoding:YES error:&archiveError];
        if (!archivedData || archiveError) {
            RLTLoggerError(archiveError, @"Archive failed. Data length is %li bytes.", (long) archivedData.length);
            return;
        }
        NSError *writeError;
        success = [archivedData writeToFile:path options:NSDataWritingAtomic error:&writeError];
        if (!success || writeError) {
            RLTLoggerError(writeError, @"Write archived data failed.");
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        success = [NSKeyedArchiver archiveRootObject:dictionary toFile:path];
#pragma clang diagnostic pop
    }
    if (!success) {
        RLTLoggerError(nil, @"Archive failed to file '%@'. Failed object %@.", path, dictionary);
    }
}

- (NSDictionary *)dataFromStorage {
    NSString *path = [self filePath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return nil;
    }
    NSError *error;
    NSDictionary *result;
    @try {
        if (@available(iOS 11.0, *)) {
            result = [NSKeyedUnarchiver unarchivedObjectOfClass:NSDictionary.class fromData:data error:&error];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:&error];
#pragma clang diagnostic pop
        }
        if (!error && [result isKindOfClass:[NSDictionary class]]) {
            return result;
        } else {
            RLTLoggerError(error, @"Unarchive failed. Got object with class %@.", NSStringFromClass(result.class));
        }
    }
    @catch (NSException *exception) {
        RLTLoggerException(exception, @"Unarchive failed. Initial data length: %li bytes.", (long) data.length);
    }
}

@end