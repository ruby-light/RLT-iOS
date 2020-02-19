//
// Created by Alexey Chirkov on 17/01/2020.
// Copyright (c) 2020 Rubylight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

@interface RLTSQLiteUtils : NSObject

+ (NSError *)NSErrorFromSQLiteResult:(int)result source:(NSString*)source;

+ (int)openDatabase:(sqlite3 *_Nonnull *_Nonnull)database dbFilePath:(NSString *)dbFilePath;

+ (BOOL)createTableWithName:(NSString *)tableName db:(sqlite3 *)db command:(NSString *)command;

+ (BOOL)executeStatementWith:(sqlite3 *)db sqlCommand:(NSString *)sqlCommand;

+ (BOOL)dropTable:(sqlite3 *)db tableName:(NSString *)tableName sqlCommand:(NSString *)sqlCommand;

+ (int)getIntFrom:(sqlite3_stmt *)statement column:(int)column tableName:(NSString *)tableName;

+ (NSString *_Nullable)getTextFrom:(sqlite3_stmt *)statement column:(int)column tableName:(NSString *)tableName checkForNull:(BOOL)checkForNull checkForEmptyString:(BOOL)checkForEmptyString success:(BOOL *)success;
@end

NS_ASSUME_NONNULL_END
