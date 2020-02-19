//
// Created by Alexey Chirkov on 28/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RLTReportsStorage.h"
#import "RLTIO.h"
#import "RLTConfiguration.h"
#import "RLTSQLiteUtils.h"
#import "RLTReport.h"
#import "RLTLogger.h"
#import "RLTUtils.h"

static NSString *const kDatabaseOperationQueueName = @"com_rubylight_statistics_db_rwq";

static NSString *const kTableName_Events = @"events";
static NSString *const kTableKeyEvent_Id = @"id";
static NSString *const kTableKeyEvent_Text = @"text";
static NSString *const kTableKeyEvent_Device = @"device";
static NSString *const kCreateTableCommand_Events = @"create TABLE IF NOT EXISTS %@ ("
                                                    "%@ INTEGER, "
                                                    "%@ TEXT, "
                                                    "%@ TEXT NULL"
                                                    ");";

static NSString *const kDropTableCommand = @"drop TABLE IF EXISTS %@";

static NSString *const kInsertIntoTableCommand = @"INSERT INTO %@ (%@, %@, %@) VALUES (?, ?, ?);";

static NSString *const kCountFromTableCommand = @"SELECT COUNT(*) FROM %@;";

static NSString *const kSelectOrderByWithLimitFromTableCommand = @"SELECT %@, %@, %@ FROM %@ ORDER BY %@ ASC LIMIT %i;";

static NSString *const kSelectMaxValueFromTableCommand = @"SELECT MAX(%@) FROM %@;";

static NSString *const kDeleteUpToSequenceNumberFromTableCommand = @"DELETE FROM %@ WHERE %@ <= %i;";

/**
 * @return YES if db closed
 */
typedef BOOL (^RLTReportsStorageWithDatabaseCallback)(sqlite3 *database);

typedef void (^RLTReportsStorageWithDatabaseStatementCallback)(sqlite3_stmt *statement);

@interface RLTReportsStorage ()
@property(nonatomic, weak) RLTConfiguration *configuration;

@property(nonatomic) NSString *dbFilePath;

@property(nonatomic) sqlite3 *database;
/**
 * Serial queue for database read/write operations.
 */
@property(nonatomic) dispatch_queue_t databaseOperationQueue;

@end

@implementation RLTReportsStorage

- (void)dealloc {
    if (self.database) {
        sqlite3_close(self.database);
    }
}

- (instancetype)initWithConfiguration:(RLTConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.configuration = configuration;
        self.dbFilePath = [self generateDBFilePath];
        self.databaseOperationQueue = dispatch_queue_create(kDatabaseOperationQueueName.UTF8String, DISPATCH_QUEUE_SERIAL);
        [self openDatabase];
    }
    return self;
}

- (int)getMaxSequence {
    return [self __getMaxValueFromTable:kTableName_Events columnName:kTableKeyEvent_Id];
}

- (int)getReportsCount {
    return [self __getRowCountFromTable:kTableName_Events];
}

- (void)putReport:(int)reportSequence reportContent:(NSString *)reportContent device:(NSString *_Nullable)device {
    NSString *insertSQLCommand = [NSString stringWithFormat:kInsertIntoTableCommand,
                                                            kTableName_Events,
                                                            kTableKeyEvent_Id,
                                                            kTableKeyEvent_Text,
                                                            kTableKeyEvent_Device];

    [self insertText:reportContent device:device identifier:reportSequence intoTableWithName:kTableName_Events insertSQLCommand:insertSQLCommand];
}

- (BOOL)removeEarlyReports:(int)sequenceNumber {
    __block BOOL success = YES;

    NSString *tableName = kTableName_Events;
    NSString *sqlCommand = [NSString stringWithFormat:kDeleteUpToSequenceNumberFromTableCommand, tableName, kTableKeyEvent_Id, sequenceNumber];

    success &= [self runDBCommandWithBlock:^BOOL(sqlite3 *database) {
        success &= [RLTSQLiteUtils executeStatementWith:database sqlCommand:sqlCommand];
        return NO;
    }];

    if (!success) {
        [self dropAllTables:NO];
    }

    return success;
}

- (NSArray <RLTReport *> *_Nullable)getReports:(int)limit {
    NSString *tableName = kTableName_Events;
    NSString *sqlCommand = [NSString stringWithFormat:kSelectOrderByWithLimitFromTableCommand, kTableKeyEvent_Id, kTableKeyEvent_Text, kTableKeyEvent_Device, tableName, kTableKeyEvent_Id, limit];

    NSArray<RLTReport *> *reports = [self eventsWithSelectSqlCommand:sqlCommand tableName:tableName];

#ifdef DEBUG
    NSMutableArray <NSNumber *> *reportSequenceNumbers = [[NSMutableArray alloc] init];
    [reports enumerateObjectsUsingBlock:^(RLTReport *report, NSUInteger idx, BOOL *stop) {
        [reportSequenceNumbers addObject:@(report.sequence)];
    }];

    RLTLoggerLog(@"Reports from DB to upload: [%@] : [%@]", [[reportSequenceNumbers sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [[obj1 stringValue] compare:[obj2 stringValue] options:NSNumericSearch];
    }] componentsJoinedByString:@","], [reports componentsJoinedByString:@","]);
#endif

    return reports.count == 0 ? nil : reports;
}

- (BOOL)dropAllTables:(BOOL)deleteDatabase {
    __block BOOL success = YES;

    if (deleteDatabase) {
        success &= [self deleteDatabase];
    } else {
        success &= [self runDBCommandWithBlock:^BOOL(sqlite3 *database) {
            NSString *sqlCommand = [NSString stringWithFormat:kDropTableCommand, kTableName_Events];
            success &= [RLTSQLiteUtils executeStatementWith:database sqlCommand:sqlCommand];
            return NO;
        }];
    }

    success &= [self createTables];

    if (success) {
        RLTLoggerWarn(@"All tables dropped and recreated!");
    }

    return success;
}

- (BOOL)deleteDatabase {
    BOOL success = YES;
    if ([RLTIO fileExistsAtPath:self.dbFilePath]) {
        NSError *error;
        success = [RLTIO removeFileAtPath:self.dbFilePath error:&error];
        if (!success) {
            RLTLoggerError(error, @"Removing db failed.");
        }
    }
    return success;
}

#pragma mark SQLite operations

- (void)openDatabase {
    NSString *pathForDBFile = self.dbFilePath;
    if (![RLTIO fileExistsAtPath:pathForDBFile]) {
        [self createTables];
    }
}

- (BOOL)runDBCommandWithStatement:(NSString *)sqlCommand callback:(RLTReportsStorageWithDatabaseStatementCallback)callback {
    __block BOOL success = YES;

    [self runDBCommandWithBlock:^BOOL(sqlite3 *database) {
        sqlite3_stmt *statement;
        int prepareResult = sqlite3_prepare_v2(database, [sqlCommand UTF8String], -1, &statement, NULL);
        if (prepareResult != SQLITE_OK) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
            NSError *error = [RLTSQLiteUtils NSErrorFromSQLiteResult:prepareResult source:[NSString stringWithFormat:@"Failed to prepare statement for sql command %@", sqlCommand]];
#pragma clang diagnostic pop
            RLTLoggerError(error, @"");
            sqlite3_finalize(statement);
            sqlite3_close(database);
            success = NO;
            return YES;
        }
        callback(statement);
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return YES;
    }];
    return success;
}

- (BOOL)runDBCommandWithBlock:(RLTReportsStorageWithDatabaseCallback)callback {
    NSString *queueName = [NSString stringWithUTF8String:dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];
    if ([kDatabaseOperationQueueName isEqual:queueName]) {
        //deadlock
        RLTLoggerError(nil, @"Deadlock in databaseOperationQueue: %@", [NSThread callStackSymbols]);
        return NO;
    }
    __block BOOL success = YES;

    dispatch_sync(self.databaseOperationQueue, ^{
        BOOL dbExists = [RLTIO fileExistsAtPath:self.dbFilePath];
        sqlite3 *db = nil;
        int result = [RLTSQLiteUtils openDatabase:&db dbFilePath:self.dbFilePath];
        if (result == SQLITE_OK) {
            self->_database = db;
            if (!dbExists) {
                RLTLoggerLog(@"DB file created '%@'", self.dbFilePath);
            }
        } else {
            sqlite3_close(self.database);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
            NSError *error = [RLTSQLiteUtils NSErrorFromSQLiteResult:result source:[NSString stringWithFormat:@"Could not %@ RLT database at path %@", dbExists ? @"open" : @"create", self.dbFilePath]];
#pragma clang diagnostic pop
            RLTLoggerError(error, @"");
            success = NO;
            self.database = nil;
            return;
        }
        BOOL dbClosed = callback(self.database);
        if (!dbClosed) {
            int closeResult = sqlite3_close(self.database);
            if (closeResult != SQLITE_OK) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
                NSError *error = [RLTSQLiteUtils NSErrorFromSQLiteResult:closeResult source:@"Error closing DB"];
#pragma clang diagnostic pop
                RLTLoggerError(error, @"");
            }
        }
        self.database = nil;
    });

    return success;
}

- (BOOL)insertText:(NSString *)text device:(NSString *)device identifier:(int)identifier intoTableWithName:(NSString *)tableName insertSQLCommand:(NSString *)insertSQLCommand {
    __block BOOL success = YES;
    success &= [self runDBCommandWithStatement:insertSQLCommand callback:^(sqlite3_stmt *statement) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
        int bindIdResult = sqlite3_bind_int(statement, 1, identifier);
        if (bindIdResult != SQLITE_OK) {
            NSError *error = [RLTSQLiteUtils NSErrorFromSQLiteResult:bindIdResult source:[NSString stringWithFormat:@"Failed to bind int value while inserting statement into table '%@'", tableName]];
            RLTLoggerError(error, @"");
            success = NO;
            return;
        }

        int bindTextResult = sqlite3_bind_text(statement, 2, [text UTF8String], -1, SQLITE_STATIC);
        if (bindTextResult != SQLITE_OK) {
            NSError *error = [RLTSQLiteUtils NSErrorFromSQLiteResult:bindTextResult source:[NSString stringWithFormat:@"Failed to bind text value while inserting statement into table '%@'", tableName]];
            RLTLoggerError(error, @"");
            success = NO;
            return;
        }
        int bindDeviceResult = sqlite3_bind_text(statement, 3, [device UTF8String], -1, SQLITE_STATIC);
        if (bindDeviceResult != SQLITE_OK) {
            NSError *error = [RLTSQLiteUtils NSErrorFromSQLiteResult:bindDeviceResult source:[NSString stringWithFormat:@"Failed to bind device value while inserting statement into table '%@'", tableName]];
            RLTLoggerError(error, @"");
            success = NO;
            return;
        }
        int statementResult = sqlite3_step(statement);
        if (statementResult != SQLITE_DONE) {
            NSError *error = [RLTSQLiteUtils NSErrorFromSQLiteResult:statementResult source:[NSString stringWithFormat:@"Failed to evaluate sql while inserting value statement into table '%@'", tableName]];
            RLTLoggerError(error, @"");
            success = NO;
            return;
        }
#pragma clang diagnostic pop
    }];

    if (!success) {
        [self dropAllTables:NO];
    }

    return success;
}

- (BOOL)createTables {
    __block BOOL success = YES;
    [self runDBCommandWithBlock:^BOOL(sqlite3 *database) {
        success &= [RLTSQLiteUtils createTableWithName:kTableName_Events db:database command:[NSString stringWithFormat:kCreateTableCommand_Events, kTableName_Events, kTableKeyEvent_Id, kTableKeyEvent_Text, kTableKeyEvent_Device]];
        return NO;
    }];
    return success;
}

- (BOOL)dropTableWithName:(NSString *)tableName {
    NSString *sqlCommand = [NSString stringWithFormat:kDropTableCommand, tableName];
    return [RLTSQLiteUtils dropTable:self.database tableName:tableName sqlCommand:sqlCommand];
}

- (int)__getRowCountFromTable:(NSString *)tableName {
    __block int count = 0;
    NSString *sqlCommand = [NSString stringWithFormat:kCountFromTableCommand, tableName];
    [self runDBCommandWithStatement:sqlCommand callback:^(sqlite3_stmt *statement) {
        int result = sqlite3_step(statement);
        if (result == SQLITE_ROW) {
            count = [RLTSQLiteUtils getIntFrom:statement column:0 tableName:tableName];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
            NSError *error = [RLTSQLiteUtils NSErrorFromSQLiteResult:result source:[NSString stringWithFormat:@"Failed to get row count from table '%@'", tableName]];
#pragma clang diagnostic pop
            RLTLoggerError(error, @"");
        }
    }];
    return count;
}

- (int)__getMaxValueFromTable:(NSString *)tableName columnName:(NSString *)columnName {
    __block int max = 0;
    NSString *sqlCommand = [NSString stringWithFormat:kSelectMaxValueFromTableCommand, columnName, tableName];
    [self runDBCommandWithStatement:sqlCommand callback:^(sqlite3_stmt *statement) {
        int result = sqlite3_step(statement);
        if (result == SQLITE_ROW) {
            max = [RLTSQLiteUtils getIntFrom:statement column:0 tableName:kTableName_Events];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
            NSError *error = [RLTSQLiteUtils NSErrorFromSQLiteResult:result source:[NSString stringWithFormat:@"Failed to get MAX(%@) from table '%@'", columnName, tableName]];
#pragma clang diagnostic pop
            RLTLoggerError(error, @"");
        }
    }];
    return max;
}

- (NSArray<RLTReport *> *)eventsWithSelectSqlCommand:(NSString *)sqlCommand tableName:(NSString *)tableName {
    __block NSMutableArray<RLTReport *> *result = [[NSMutableArray alloc] init];

    [self runDBCommandWithStatement:sqlCommand callback:^(sqlite3_stmt *statement) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int sequenceNumber = [RLTSQLiteUtils getIntFrom:statement column:0 tableName:tableName];

            BOOL textSuccess = NO;
            NSString *text = [RLTSQLiteUtils getTextFrom:statement column:1 tableName:tableName checkForNull:YES checkForEmptyString:YES success:&textSuccess];
            if (!textSuccess) {
                continue;
            }
            NSDictionary *textAsDictionary;
            BOOL deserializeSuccess = [RLTUtils deserializeJSONObjectFrom:[text dataUsingEncoding:NSUTF8StringEncoding] result:&textAsDictionary resultClass:NSDictionary.class];
            if (!deserializeSuccess) {
                RLTLoggerError(nil, @"Table '%@': 'text' column cannot be deserialized into NSDictionary!", tableName);
                continue;
            }
            NSString *device = [RLTSQLiteUtils getTextFrom:statement column:2 tableName:tableName checkForNull:NO checkForEmptyString:NO success:&textSuccess];
            RLTReport *report = [RLTReport reportWithSequence:sequenceNumber content:text device:device];
            [result addObject:report];
        }
    }];
    return result;
}

#pragma mark Internal

- (NSString *)generateDBFilePath {
    NSString *fileName = [NSString stringWithFormat:@"com_rubylight_statistics_%@_storage.sqlite", self.configuration.apiKey];
    return [RLTIO.rootDirPath stringByAppendingPathComponent:fileName];
}


@end
