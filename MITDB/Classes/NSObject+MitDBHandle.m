//
//  NSObject+MitDBHandle.m
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/8.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSObject+MitDBHandle.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "MitDBProtocol.h"
#import "MitFMEncryptDatabaseQueue.h"
#import "NSObject+MitDBParam.h"
#import "MitDBMigrationHandle.h"

NSString * MIT_ENCRYPTKEY = @"0";

@implementation NSObject (MitDBHandle)

-(NSMutableDictionary *)ignoreMap{
    return objc_getAssociatedObject(self, @selector(ignoreMap));
}

-(void)setignoreMap:(NSMutableDictionary *)ignoreMap{
    objc_setAssociatedObject(self, @selector(ignoreMap), ignoreMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark action create the queue of db
static NSString * kSQLITE_NAME = @"Record.sqlite";
static NSString * kSQLCipherKey = @"kSQLCipherKey";
static dispatch_once_t onceToken;
static FMDatabaseQueue * dataQueue;
FMDatabaseQueue * DBQueue(){
    dispatch_once(&onceToken, ^{
        NSArray *Paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path=[Paths objectAtIndex:0];
        NSString * dbPath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",kSQLITE_NAME]];
        NSLog(@"%@",dbPath);
        NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
        [user integerForKey:kSQLCipherKey];
        if (![user integerForKey:kSQLCipherKey]) {
            if ([MIT_ENCRYPTKEY integerValue]==1) {
                dataQueue = [MitFMEncryptDatabaseQueue databaseQueueWithPath:dbPath];
                [NSObject updateSQLCipherKey:true];
            } else {
                dataQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
            }
        }else{
            if ([user integerForKey:kSQLCipherKey]==1) {
                dataQueue = [MitFMEncryptDatabaseQueue databaseQueueWithPath:dbPath];
            }else{
                dataQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
            }
        }
    });
    return dataQueue;
}

#pragma mark action sqlcipher key
+ (void)updateSQLCipherKey:(BOOL)encrypt{
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    if(encrypt){
        [user setInteger:1 forKey:kSQLCipherKey];
        [user synchronize];
    }else{
        [user setInteger:0 forKey:kSQLCipherKey];
        [user synchronize];
    }
    //重新创建数据库队列
    onceToken = 0;
    dataQueue = nil;
}
#pragma mark action dbPath
+(NSString *)dbPath{
    NSArray *Paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[Paths objectAtIndex:0];
    NSString * dbPath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",kSQLITE_NAME]];
    return dbPath;
}


#pragma mark primary key
static NSString * const kPrimaryKey = @"kprimaryKey";
#pragma mark action setter of the primaryValue
- (void)setPrimaryValue:(NSString *)primaryValue{
    objc_setAssociatedObject(self, &kPrimaryKey, primaryValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark action getter of the primaryValue
- (NSString *)primaryValue{
    if ([[self class] hasPrimaryKey]) {
        NSString * key = [[self class] primaryKey];
        id value = [self valueForKey:key];
        return value;
    } else {
        return objc_getAssociatedObject(self, &kPrimaryKey);
    }
}


#pragma mark action whether is the ignored key
+ (BOOL)isIgnoreKey:(NSString *)key{
    NSArray * arr = [self ignoreKeys];
    if (!arr||arr.count==0) {
        return false;
    }else{
        for (NSString * k in arr) {
            if ([k isEqualToString:key]) {
                return true;
            }
        }
    }
    return false;
}



#pragma mark action whether had the primary key
+ (BOOL)hasPrimaryKey{
    __block BOOL isHas = false;
    NSArray * arr = [self getAllPropertysFromClass];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary * dict = obj;
        if ([dict[MIT_IVARNAME]isEqualToString:[self primaryKey]]) {
            isHas = true;
        }
    }];
    return isHas;
}


#pragma mark action create table
+ (void)createTable{
    NSArray * arr = [self tableNames];
    if (arr&&arr.count>0) {
        NSMutableArray * sqlArr = [NSMutableArray array];
        for (NSString * tabName in arr) {
            //判断表是否存在，不存在创建，存在查看是否需要迁移，需要则迁移
            if (![self isTableExist:tabName]) {
                NSString * sql = [self createTabSQLWithTabName:tabName];
                [sqlArr addObject:sql];
            } else {
#warning 判断是否需要迁移 注释 ：by mc
            }
        }
        if (sqlArr.count >0) {
            BOOL result = [NSObject executeSQLs:sqlArr withTransaction:true];
            if (result) {
                NSLog(@"创建成功");
            } else {
                NSLog(@"创建失败");
            }
        } else {
            NSLog(@"没有表需要创建");
        }
    } else {
        NSString * sql = [self createTabSQL];
        NSLog(@"sql = ---%@",sql);
        if (![self isTableExist:[self tableName]]) {
            BOOL result = [NSObject executeSQL:sql];
            if (result) {
                NSLog(@"创建成功");
            } else {
                NSLog(@"创建失败");
            }
        } else {
            NSLog(@"没有表需要创建");
        }
    }
}

- (BOOL)isTableExist:(NSString *)tableName
{
    __block BOOL result = NO;
    NSArray *Paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[Paths objectAtIndex:0];
    NSString * dbPath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",kSQLITE_NAME]];
    FMDatabase * db = [FMDatabase databaseWithPath:dbPath];
    NSString *name =nil;
    if ([db open]) {
        NSString * sql = [[NSString alloc]initWithFormat:@"select name from sqlite_master where type = 'table' and name = '%@'",tableName];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            name = [rs stringForColumn:@"name"];
            if ([name isEqualToString:tableName])
            {
                result =1;
            }
        }
        [db close];
    }
    return result;
}


#pragma mark tables' name
+ (NSArray *)tableNames{
    return nil;
}


#pragma mark action save
- (void)save{
    [self saveWithParam:nil];
}

- (void)saveWithTabName:(NSString *)tabName{
    [self saveWithParam:nil tabName:tabName];
    
}

- (void)saveWithParam:(MitDBParam *)param{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self saveSqlWithParam:param tabName:nil];
        NSError * err = nil;
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            if (![[self class]hasPrimaryKey]) {
                NSLog(@"the primary key is %lld",[db lastInsertRowId]);
                [self setPrimaryValue:[NSString stringWithFormat:@"%lld",[db lastInsertRowId]]];
            }
            NSLog(@"save succeed");
        }else{
            NSLog(@"save failed %@",err);
        }
    }];
}

- (void)saveWithParam:(MitDBParam *)param tabName:(NSString *)tabName{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self saveSqlWithParam:param tabName:tabName];
        NSError * err = nil;
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            if (![[self class]hasPrimaryKey]) {
                NSLog(@"the primary key is %lld",[db lastInsertRowId]);
                [self setPrimaryValue:[NSString stringWithFormat:@"%lld",[db lastInsertRowId]]];
            }
            NSLog(@"save succeed");
        }else{
            NSLog(@"save failed %@",err);
        }
    }];
}

+ (void)save:(NSArray<id<MitDBProtocol>> *)arr param:(MitDBParam *)param inTransaction:(BOOL)transaction{
    if (!transaction) {
        [self save:arr param:param];
    }else{
        NSMutableArray * ar = [NSMutableArray arrayWithCapacity:0];
        for (NSObject * obj in arr) {
            [ar addObject:[obj saveSqlWithParam:param tabName:nil]];
        }
        [self executeSQLs:ar withTransaction:true];
    }
}

+ (void)save:(NSArray<id<MitDBProtocol>> *)arr param:(MitDBParam *)param inTransaction:(BOOL)transaction tabName:(NSString *)tabName {
    if (!transaction) {
        [self save:arr param:param tabName:tabName];
    }else{
        NSMutableArray * ar = [NSMutableArray arrayWithCapacity:0];
        for (NSObject * obj in arr) {
            [ar addObject:[obj saveSqlWithParam:param tabName:tabName]];
        }
        [self executeSQLs:ar withTransaction:true];
    }
}

+ (void)save:(NSArray<id<MitDBProtocol>> *)arr param:(MitDBParam *)param{
    for (NSObject * obj in arr) {
        [obj saveWithParam:param];
    }
}

+ (void)save:(NSArray<id<MitDBProtocol>> *)arr param:(MitDBParam *)param tabName:(NSString *)tabName{
    if (tabName&&tabName.length>0) {
        for (NSObject * obj in arr) {
            [obj saveWithParam:param tabName:tabName];
        }
    } else{
        [self save:arr param:param];
    }
}

#pragma mark action remove
- (void)remove{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql =  [self removeSqlWithParam:nil tabName:nil];
        NSError * err = nil;
        NSLog(@"sql = ---%@",sql);
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            NSLog(@"remove succeed");
        }else{
            NSLog(@"remove failed %@",err);
        }
    }];
}

- (void)removeWithTabName:(NSString *)tabName{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql =  [self removeSqlWithParam:nil tabName:tabName];
        NSError * err = nil;
        NSLog(@"sql = ---%@",sql);
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            NSLog(@"remove succeed");
        } else {
            NSLog(@"remove failed %@",err);
        }
    }];
}


+ (void)remove:(NSArray<id<MitDBProtocol>> *)arr param:(MitDBParam *)param{
    if (!param) {
        for (NSObject * obj in arr) {
            [obj remove];
        }
    }else{
        [self remove:arr param:param inTransaction:true];
    }
}

+ (void)remove:(NSArray<id<MitDBProtocol>> *)arr param:(MitDBParam *)param tabName:(NSString *)tabName {
    if (!param) {
        for (NSObject * obj in arr) {
            [obj removeWithTabName:tabName];
        }
    }else{
        [self remove:arr param:param inTransaction:true tabName:tabName];
    }
}

+ (void)remove:(NSArray<id<MitDBProtocol>> *)arr param:(MitDBParam *)param inTransaction:(BOOL)transaction{
    if (!transaction) {
        [self remove:arr param:param];
    }else{
        NSMutableArray * ar = [NSMutableArray arrayWithCapacity:0];
        for (NSObject * obj in arr) {
            [ar addObject:[obj removeSqlWithParam:param tabName:nil]];
        }
        [self executeSQLs:[ar copy] withTransaction:true];
    }
}

+ (void)remove:(NSArray<id<MitDBProtocol>> *)arr param:(MitDBParam *)param inTransaction:(BOOL)transaction tabName:(NSString *)tabName {
    if (!transaction) {
        [self remove:arr param:param tabName:tabName];
    }else{
        NSMutableArray * ar = [NSMutableArray arrayWithCapacity:0];
        for (NSObject * obj in arr) {
            [ar addObject:[obj removeSqlWithParam:param tabName:tabName]];
        }
        [self executeSQLs:[ar copy] withTransaction:true];
    }
    
    
}


#pragma mark action clear
+ (void)clear{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql =  [self removeAllSql:[self tableName]];
        NSError * err = nil;
        NSLog(@"sql = ---%@",sql);
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            NSLog(@"clear succeed");
        }else{
            NSLog(@"clear failed %@",err);
        }
    }];
}

+ (void)clearWithTabName:(NSString *)tabName{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql =  [self removeAllSql:tabName];
        NSError * err = nil;
        NSLog(@"sql = ---%@",sql);
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            NSLog(@"clear succeed");
        }else{
            NSLog(@"clear failed %@",err);
        }
    }];
}



#pragma mark action update
- (void)update{
    [self updateWithParam:nil];
}

- (void)updateWithTabName:(NSString *)tabName {
    [self updateWithParam:nil tabName:tabName];
}

- (void)updateWithParam:(MitDBParam *)param {
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self updateSqlWithParam:param tabName:nil];
        NSLog(@"sql = ---%@",sql);
        NSError * err = nil;
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            NSLog(@"update succeed");
        }else{
            NSLog(@"update failed %@",err);
        }
    }];
}
- (void)updateWithParam:(MitDBParam *)param tabName:(NSString *)tabName {
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self updateSqlWithParam:param tabName:tabName];
        NSLog(@"sql = ---%@",sql);
        NSError * err = nil;
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            NSLog(@"update succeed");
        }else{
            NSLog(@"update failed %@",err);
        }
    }];
}

+ (void)update:(NSArray <id<MitDBProtocol>> *)arr
         param:(MitDBParam *)param{
    for (NSObject * obj in arr) {
        [obj updateWithParam:param];
    }
}

+ (void)update:(NSArray<id<MitDBProtocol>> *)arr
         param:(MitDBParam *)param tabName:(NSString *)tabName{
    for (NSObject * obj in arr) {
        [obj updateWithParam:param tabName:tabName];
    }
}

+ (void)update:(NSArray<id<MitDBProtocol>> *)arr
         param:(MitDBParam *)param
 inTransaction:(BOOL)transaction{
    if (!transaction) {
        [self update:arr param:param];
    }else{
        NSMutableArray * ar = [NSMutableArray arrayWithCapacity:0];
        for (NSObject * obj in arr) {
            [ar addObject:[obj updateSqlWithParam:param tabName:nil]];
        }
        [self executeSQLs:ar withTransaction:true];
    }
}

+ (void)update:(NSArray<id<MitDBProtocol>> *)arr
         param:(MitDBParam *)param
 inTransaction:(BOOL)transaction
       tabName:(NSString *)tabName {
    if (!transaction) {
        [self update:arr param:param tabName:tabName];
    }else{
        NSMutableArray * ar = [NSMutableArray arrayWithCapacity:0];
        for (NSObject * obj in arr) {
            [ar addObject:[obj updateSqlWithParam:param tabName:tabName]];
        }
        [self executeSQLs:ar withTransaction:true];
    }
}


#pragma mark action select
+ (void)selectAllResult:(void (^)(NSArray *))result{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self selectSqlWithParam:nil tabName:nil];
        NSLog(@"sql = ---%@",sql);
        FMResultSet * set = [db executeQuery:sql];
        NSMutableArray * re = [NSMutableArray array];
        while ( [set next]) {
            id value = [self changeToObj:set :db];
            [re addObject:value];
        }
        result([re copy]);
    }];
}

+(void)selectAllWithTabName:(NSString *)tabName
                 result:(void (^)(NSArray *))result{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self selectSqlWithParam:nil tabName:tabName];
        NSLog(@"sql = ---%@",sql);
        FMResultSet * set = [db executeQuery:sql];
        NSMutableArray * re = [NSMutableArray array];
        while ( [set next]) {
            id value = [self changeToObj:set :db];
            [re addObject:value];
        }
        result([re copy]);
    }];
}


+ (void)selectWithParam:(MitDBParam *)param
             result:(void (^)(NSArray *))completion{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self selectSqlWithParam:param tabName:nil];
        FMResultSet * set = [db executeQuery:sql];
        NSMutableArray * result = [NSMutableArray array];
        while ( [set next]) {
            id value = [self changeToObj:set :db];
            [result addObject:value];
        }
        completion([result copy]);
    }];
}

+ (void)selectWithParam:(MitDBParam *)param
                tabName:(NSString *)tabName
                 result:(void (^)(NSArray *))completion {
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self selectSqlWithParam:param tabName:tabName];
        FMResultSet * set = [db executeQuery:sql];
        NSMutableArray * result = [NSMutableArray array];
        while ( [set next]) {
            id value = [self changeToObj:set :db];
            [result addObject:value];
        }
        completion([result copy]);
    }];
}

#pragma mark action change to object
- (id)changeToObj:(FMResultSet*)set :(FMDatabase *)db{
    NSArray * arr = [[self class] getAllPropertysFromClass];
    __block NSDictionary * dict = nil;
    __block NSString * type = nil;
    __block NSString * key = nil;
    Class cls = [self class];
    id object = [[cls alloc]init];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dict = obj;
        key = [dict objectForKey:MIT_IVARNAME];
        /*
         if ([str isEqualToString:@"c"]) {
         typeEncoding = @"text";
         }else if([str isEqualToString:@"i"]||[str isEqualToString:@"I"]){
         typeEncoding = @"integer";
         }else if([str isEqualToString:@"s"]||[str isEqualToString:@"S"]){
         typeEncoding = @"double";
         }else if([str isEqualToString:@"f"]){
         typeEncoding = @"double";
         }else if([str isEqualToString:@"d"]){
         typeEncoding = @"double";
         }else if([str isEqualToString:@"l"]||[str isEqualToString:@"L"]){
         typeEncoding = @"double";
         }else if([str isEqualToString:@"q"]||[str isEqualToString:@"Q"]){
         typeEncoding = @"double";
         }else if([str isEqualToString:@"B"]){
         typeEncoding = @"BOOLEAN";
         }else if([str isEqualToString:@"NSString"]){
         typeEncoding = @"text";
         }else if([str isEqualToString:@"NSNumber"]){
         typeEncoding = @"double";
         }else if ([str isEqualToString:@"NSData"]){
         typeEncoding = @"blob";
         }else if ([str isEqualToString:@"NSArray"]){
         typeEncoding = @"text";
         }else if ([str isEqualToString:@"NSDictionary"]){
         typeEncoding = @"text";
         }else{
         typeEncoding = @"text";
         }
         */
        if([db columnExists:key inTableWithName:[[self class] tableName]]){
            type = [dict objectForKey:MIT_SQLTYPE];
            if ([type isEqualToString:@"text"]) {
                NSString * str = [set stringForColumn:key];
                if (str) {
                    [object setValue:str forKey:key];
                }
            }else if ([type isEqualToString:@"i"]){
                [object setValue:@([set intForColumn:key]) forKey:key];
            }else if ([type isEqualToString:@"s"]||[type isEqualToString:@"S"]||[type isEqualToString:@"f"]||[type isEqualToString:@"d"]||[type isEqualToString:@"l"]||[type isEqualToString:@"L"]||[type isEqualToString:@"q"]||[type isEqualToString:@"Q"]){
                [object setValue:@([set doubleForColumn:key]) forKey:key];
            }else if ([type isEqualToString:@"blob"]){
                NSData * data = [set dataForColumn:key];
                if (data) {
                    [object setValue:data forKey:key];
                }
            }else{
                [object setValue:[set objectForColumn:key] forKey:key];
            }
        }
    }];
    if (![[self class] hasPrimaryKey]) {
        NSString * key = [[self  class]primaryKey];
        [object setPrimaryValue:[NSString stringWithFormat:@"%@",@([set intForColumn:key])]];
    }
    return object;
}

#pragma mark action excute sql
+(BOOL)executeSQL:(NSString *)sql{
    __block BOOL result = false;
    if (sql) {
        [DBQueue() inDatabase:^(FMDatabase *db) {
            result = [db executeUpdate:sql];
            if(result)
            {
                NSLog(@"succeed");
            }else{
                NSLog(@"failed");
            }
        }];
    }
    return result;
}

+ (BOOL)executeSQLs:(NSArray *)sqls withTransaction:(BOOL)isTransaction{
    __block BOOL result = false;
    if (sqls.count>0) {
        [DBQueue() inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (NSString * str in sqls) {
                result = [db executeUpdate:str];
                if (!result) {
                    NSLog(@"failed，roll back automatically");
                }else{
                    NSLog(@"do succeed");
                }
            }
        }];
    }
    return result;
}

#pragma mark ------------------ Class Method ------------------
#pragma mark action get the primary key
+ (NSString *)primaryKey{
    return [self mit_primaryKey];
}
#pragma mark default primary key
+ (NSString *)mit_primaryKey{
    return @"mit_db_primary";
}

#pragma mark action black keys
+ (NSArray *)ignoreKeys{
    return nil;
}
#pragma mark action get primary key map of the table
+ (NSDictionary *)tablePrimaryKeyMap{
    return nil;
}

@end
