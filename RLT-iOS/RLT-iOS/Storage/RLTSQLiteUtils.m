//
// Created by Alexey Chirkov on 17/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import "RLTLogger.h"
#import "RLTSQLiteUtils.h"

@interface RLTSQLiteUtils ()
@end

@implementation RLTSQLiteUtils

+ (NSError *)NSErrorFromSQLiteResult:(int)result source:(NSString*)source {
    //sqlite3 result code to string
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    const char *errorStr = sqlite3_errstr(result);
#pragma clang diagnostic pop
    NSString *errorReason = [NSString stringWithFormat:@"%s", errorStr];
    NSString *errorDescription = [NSString stringWithFormat:@"%@", source];
    return [NSError errorWithDomain:@"RLTSQLiteError" code:result userInfo:@{
            NSLocalizedDescriptionKey: errorDescription,
            NSLocalizedFailureReasonErrorKey: errorReason
    }];
}

#pragma mark SQLite management

+ (int)openDatabase:(sqlite3 **)database dbFilePath:(NSString *)dbFilePath {
    int result = sqlite3_open_v2([dbFilePath UTF8String],
            database,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FILEPROTECTION_NONE,
            NULL);
    return result;
}

+ (BOOL)createTableWithName:(NSString *)tableName db:(sqlite3 *)db command:(NSString *)command {
    BOOL success = [RLTSQLiteUtils executeStatementWith:db sqlCommand:command];
    return success;
}

+ (BOOL)executeStatementWith:(sqlite3 *)db sqlCommand:(NSString *)sqlCommand {
    char *error;
    BOOL failure = sqlite3_exec(db, [sqlCommand UTF8String], NULL, NULL, &error) != SQLITE_OK;
    if (failure) {
        RLTLoggerError(nil, @"Failed to execute SQL command '%@': %s", sqlCommand, error);
        return NO;
    }
    return YES;
}

+ (BOOL)dropTable:(sqlite3 *)db tableName:(NSString *)tableName sqlCommand:(NSString *)sqlCommand {
    char *error;
    BOOL failure = sqlite3_exec(db, [sqlCommand UTF8String], NULL, NULL, &error) != SQLITE_OK;
    if (failure) {
        RLTLoggerError(nil, @"Failed to drop table %@ : %s", tableName, error);
        return NO;
    }
    RLTLoggerWarn(@"Table '%@' dropped!", tableName);
    return YES;
}

+ (int)getIntFrom:(sqlite3_stmt *)statement column:(int)column tableName:(NSString *)tableName {
    return sqlite3_column_int(statement, column);
}

+ (NSString *_Nullable)getTextFrom:(sqlite3_stmt *)statement column:(int)column tableName:(NSString *)tableName checkForNull:(BOOL)checkForNull checkForEmptyString:(BOOL)checkForEmptyString success:(BOOL *)success {
    const char *value = (const char *) sqlite3_column_text(statement, column);
    if (checkForNull && value == NULL) {
        RLTLoggerError(nil, @"TEXT column[%i] is NULL in table '%@'", column, tableName);
        *success = NO;
        return nil;
    }
    NSString *text = value != NULL ? [NSString stringWithUTF8String:value] : nil;
    if (checkForEmptyString && text.length == 0) {
        RLTLoggerError(nil, @"TEXT column[%i] is empty in table '%@'", column, tableName);
        *success = NO;
        return nil;
    }
    *success = YES;
    return text;
}

@end
