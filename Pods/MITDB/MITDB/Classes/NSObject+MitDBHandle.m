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
#import "MitDBProtocal.h"
#import "MitFMEncryptDatabaseQueue.h"
#import "NSObject+MitDBParam.h"
#import "MitDBMigrationHandle.h"

NSString * MIT_ENCRYPTKEY = @"0";
@implementation NSObject (MitDBHandle)
#pragma mark action 读取所有的表
+ (void)load{
    //获取所有的类
    Class * classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0 )
    {
        //建表
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            if ([class_getSuperclass(classes[i]) isSubclassOfClass:[NSObject class]]) {
                if ([classes[i] conformsToProtocol:@protocol(MitDBProtocal)]) {
                    //创建表
                    [classes[i] createTable];
                }
            }
        }
        //迁移
        free(classes);
    }
}
#pragma mark action 创建数据队列
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

#pragma mark action 更新加密 key
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
#pragma mark action 获取数据库路径
+(NSString *)dbPath{
    NSArray *Paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[Paths objectAtIndex:0];
    NSString * dbPath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",kSQLITE_NAME]];
    return dbPath;
}


#pragma mark ------------------ 主键 ------------------
static NSString * const kPrimaryKey = @"kprimaryKey";
#pragma mark action 主键值 setter
-(void)setPrimaryValue:(NSString *)primaryValue{
    objc_setAssociatedObject(self, &kPrimaryKey, primaryValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark action 主键值 getter
-(NSString *)primaryValue{
    if ([[self class] hasPrimaryKey]) {
        NSString * key = [[self class] primaryKey];
        id value = [self valueForKey:key];
        return value;
    }else{
        return objc_getAssociatedObject(self, &kPrimaryKey);
    }
}
#pragma mark action 主键 Key
+ (NSString *)primaryKey{
    if ([self instancesRespondToSelector:@selector(primaryKey)]) {
        return [self primaryKey];
    }
    return @"mit_db_primary";
}

#pragma mark action 是否设置了主键
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


#pragma mark ------------------ 表操作 ------------------
#pragma mark action 建表
+ (void)createTable{
    NSString * sql = [self createTabSQL];
    NSLog(@"sql = ---%@",sql);
    [NSObject executeSQL:sql];
}

#pragma mark action 增加
- (void)save{
    [self saveWithParam:nil];
}

- (void)saveWithParam:(MitDBParam *)param{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self saveSqlWithParam:param];
        NSLog(@"sql = ---%@",sql);
        NSError * err = nil;
        
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            if (![[self class]hasPrimaryKey]) {
                NSLog(@"主键值 = %lld",[db lastInsertRowId]);
                [self setPrimaryValue:[NSString stringWithFormat:@"%lld",[db lastInsertRowId]]];
            }
            NSLog(@"保存成功");
        }else{
            NSLog(@"失败 %@",err);
        }
    }];
}
+(void)save:(NSArray<id<MitDBProtocal>> *)arr param:(MitDBParam *)param inTransaction:(BOOL)transaction{
    if (!transaction) {
        [self save:arr param:param];
    }else{
        
    }
}
+ (void)save:(NSArray<id<MitDBProtocal>> *)arr param:(MitDBParam *)param{
    for (NSObject * obj in arr) {
        [obj saveWithParam:param];
    }
}
+ (void)saveinTransaction:(NSArray<id<MitDBProtocal>> *)arr param:(MitDBParam *)param{
    NSMutableArray * ar = [NSMutableArray arrayWithCapacity:0];
    for (NSObject * obj in arr) {
        [ar addObject:[obj saveSqlWithParam:param]];
    }
    [self executeSQLs:[ar copy] withTransaction:true];
}



#pragma mark action 删除
- (void)remove{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql =  [self removeSqlWithParam:nil];
        NSError * err = nil;
        NSLog(@"sql = ---%@",sql);
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"失败 %@",err);
        }
    }];
}

+ (void)remove:(NSArray<id<MitDBProtocal>> *)arr{
    for (NSObject * obj in arr) {
        [obj remove];
    }
}

#pragma mark action 清空表内容
+ (void)clear{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql =  [self removeAllSql:[self tableName]];
        NSError * err = nil;
        NSLog(@"sql = ---%@",sql);
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            NSLog(@"删除成功");
        }else{
            NSLog(@"失败 %@",err);
        }
    }];
    
}
#pragma mark action 修改
- (void)update{
    [self updateWithParam:nil];
}
-(void)updateWithParam:(MitDBParam *)param{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self updateSqlWithParam:param];
        NSLog(@"sql = ---%@",sql);
        NSError * err = nil;
        if ([db executeUpdate:sql withErrorAndBindings:&err]) {
            NSLog(@"修改成功");
        }else{
            NSLog(@"修改失败 %@",err);
        }
    }];
}
+ (void)update:(NSArray <id<MitDBProtocal>> *)arr param:(MitDBParam *)param{
    for (NSObject * obj in arr) {
        [obj updateWithParam:param];
    }
    
    
}


#pragma mark action 查询
+ (void)selectAllCompletion:(void(^)(NSArray *arr))completion{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self selectSqlWithParam:nil];
        NSLog(@"sql = ---%@",sql);
        FMResultSet * set = [db executeQuery:sql];
        NSMutableArray * result = [NSMutableArray array];
        while ( [set next]) {
            id value = [self changeToObj:set :db];
            [result addObject:value];
        }
        completion([result copy]);
    }];
}

+ (void)selectWithParam:(MitDBParam *)param completion:(void (^)(NSArray *))completion{
    [DBQueue() inDatabase:^(FMDatabase *db) {
        NSString * sql = [self selectSqlWithParam:param];
        FMResultSet * set = [db executeQuery:sql];
        NSMutableArray * result = [NSMutableArray array];
        while ( [set next]) {
            id value = [self changeToObj:set :db];
            [result addObject:value];
        }
        completion([result copy]);
    }];
}

#pragma mark action 转换成对象
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
                //其他情况
                [object setValue:[set objectForColumnName:key] forKey:key];
            }
        }
    }];
    if (![[self class] hasPrimaryKey]) {
        NSString * key = [[self  class]primaryKey];
        [object setPrimaryValue:[NSString stringWithFormat:@"%@",@([set intForColumn:key])]];
    }
    return object;
}

#pragma mark action 执行任务
+(BOOL)executeSQL:(NSString *)sql{
    __block BOOL result = false;
    if (sql) {
        [DBQueue() inDatabase:^(FMDatabase *db) {
            result = [db executeUpdate:sql];
            if(result)
            {
                NSLog(@"执行成功");
            }else{
                NSLog(@"执行失败");
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
                    NSLog(@"执行出现问题，自动回滚");
                }
            }
        }];
    }
    return result;
}
@end
