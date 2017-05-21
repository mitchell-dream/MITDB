//
//  NSObject+MitDBHandle.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/8.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MitDBParam;
@protocol MitDBProtocal;



@interface NSObject (MitDBHandle)
/**  主键值 */
@property(nonatomic, strong)NSString * primaryValue;

//获取主键
+ (NSString *)primaryKey;
//是否有主键
+ (BOOL)hasPrimaryKey;
//忽略属性列表
+ (NSArray *)ignoreKey;
//是否是忽略属性
+ (BOOL)isIgnoreKey:(NSString *)key;
//数据库路径
+ (NSString *)dbPath;
//更新加密键
+ (void)updateSQLCipherKey:(BOOL)encrypt;

/**
 存
 @param arr 数组
 @param param 条件参数
 @param transaction 事务
 @param tabName 表名
 */
- (void)save;
- (void)saveWithParam:(MitDBParam *)param;
+ (void)save:(NSArray <id<MitDBProtocal>> *)arr param:(MitDBParam *)param;
+ (void)save:(NSArray <id<MitDBProtocal>> *)arr
        param:(MitDBParam *)param
        inTransaction:(BOOL)transaction;
- (void)saveWithTabName:(NSString *)tabName;
- (void)saveWithParam:(MitDBParam *)param
              tabName:(NSString *)tabName;
+ (void)save:(NSArray <id<MitDBProtocal>> *)arr
       param:(MitDBParam *)param
     tabName:(NSString *)tabName;
+ (void)save:(NSArray <id<MitDBProtocal>> *)arr
       param:(MitDBParam *)param
inTransaction:(BOOL)transaction
     tabName:(NSString *)tabName;

/**
 改
 @param arr 数组
 @param param 条件参数
 @param transaction 事务
 @param tabName 表名
 */
- (void)update;
- (void)updateWithTabName:(NSString *)tabName;
- (void)updateWithParam:(MitDBParam*)param;
- (void)updateWithParam:(MitDBParam*)param
                tabName:(NSString *)tabName;
+ (void)update:(NSArray <id<MitDBProtocal>> *)arr
         param:(MitDBParam *)param;
+ (void)update:(NSArray <id<MitDBProtocal>> *)arr
         param:(MitDBParam *)param
       tabName:(NSString *)tabName;
+ (void)update:(NSArray <id<MitDBProtocal>> *)arr
        param:(MitDBParam *)param
        inTransaction:(BOOL)transaction;
+ (void)update:(NSArray <id<MitDBProtocal>> *)arr
         param:(MitDBParam *)param
 inTransaction:(BOOL)transaction
       tabName:(NSString *)tabName;

/**
 删
 @param arr 数组
 @param param 条件参数
 @param transaction 事务
 @param tabName 表名
 */
- (void)remove;
- (void)removeWithTabName:(NSString *)tabName;
+ (void)remove:(NSArray<id<MitDBProtocal>>*)arr param:(MitDBParam *)param;
+ (void)remove:(NSArray<id<MitDBProtocal>>*)arr
         param:(MitDBParam *)param
       tabName:(NSString *)tabName;
+ (void)remove:(NSArray<id<MitDBProtocal>>*)arr
         param:(MitDBParam *)param
 inTransaction:(BOOL)transaction;
+ (void)remove:(NSArray<id<MitDBProtocal>>*)arr
         param:(MitDBParam *)param
 inTransaction:(BOOL)transaction
       tabName:(NSString *)tabName;
+ (void)clear;
+ (void)clearWithTabName:(NSString *)tabName;


/**
 查
 @param arr 数组
 @param param 条件参数
 @param transaction 事务
 @param tabName 表名
 @param completion 完成回调
 */
+ (void)selectAllCompletion:(void(^)(NSArray *arr))completion;
+ (void)selectAllWithTabName:(NSString *)tabName
                  completion:(void(^)(NSArray *arr))completion;
+ (void)selectWithParam:(MitDBParam *)param
             completion:(void(^)(NSArray * arr))completion;
+ (void)selectWithParam:(MitDBParam *)param
                tabName:(NSString *)tabName
             completion:(void(^)(NSArray * arr))completion;

//执行自建 sql 语句
+ (BOOL) executeSQL:(NSString *)sql;
+ (BOOL) executeSQLs:(NSArray *)sqls withTransaction:(BOOL)isTransaction;

@end
