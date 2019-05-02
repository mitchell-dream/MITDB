//
//  NSObject+MitDBHandle.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/8.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MitDBParam;
@protocol MitDBProtocol;

@interface NSObject (MitDBHandle)
/**
 primary key
 @abstract why there are two keys?
            The primaryvalue for instance is for select the data from
 
 */
@property(nonatomic, strong)NSString * primaryValue;

/**
 ignore map
 */
@property(nonatomic, strong)NSMutableDictionary * ignoreMap;

/**
 get primary key
 */
+ (NSString *)primaryKey;

/**
 whether have primary key
 */
+ (BOOL)hasPrimaryKey;

/**
 ignore key map
 */
+ (NSArray *)ignoreKey;

/**
 is ignored key

 @param key key
 */
+ (BOOL)isIgnoreKey:(NSString *)key;

/**
 db path

 */
+ (NSString *)dbPath;

/**
 get sqlcipher key

 @param encrypt need encrypt
 */
+ (void)updateSQLCipherKey:(BOOL)encrypt;

#pragma mark save
/**
 save
 */
- (void)save;

/**
 save

 @param param param
 */
- (void)saveWithParam:(MitDBParam *)param;

/**
 save

 @param arr data's arr
 @param param param
 */
+ (void)save:(NSArray <id<MitDBProtocol>> *)arr
       param:(MitDBParam *)param;

/**
 save

 @param arr data's arr
 @param param param
 @param transaction whether in transaction
 */
+ (void)save:(NSArray <id<MitDBProtocol>> *)arr
        param:(MitDBParam *)param
        inTransaction:(BOOL)transaction;

/**
 save

 @param tabName table's name
 */
- (void)saveWithTabName:(NSString *)tabName;

/**
 save

 @param param param
 @param tabName table's name
 */
- (void)saveWithParam:(MitDBParam *)param
              tabName:(NSString *)tabName;

/**
 save

 @param arr data's arr
 @param param param
 @param tabName table's name
 */
+ (void)save:(NSArray <id<MitDBProtocol>> *)arr
       param:(MitDBParam *)param
     tabName:(NSString *)tabName;

/**
 save

 @param arr data's arr
 @param param param
 @param transaction whether in transaction
 @param tabName table's name
 */
+ (void)save:(NSArray <id<MitDBProtocol>> *)arr
       param:(MitDBParam *)param
inTransaction:(BOOL)transaction
     tabName:(NSString *)tabName;

#pragma mark update
/**
 update
 */
- (void)update;

/**
 update

 @param tabName table's name
 */
- (void)updateWithTabName:(NSString *)tabName;

/**
 update

 @param param param
 */
- (void)updateWithParam:(MitDBParam*)param;

/**
 update

 @param param param
 @param tabName table's name
 */
- (void)updateWithParam:(MitDBParam*)param
                tabName:(NSString *)tabName;

/**
 update

 @param arr data's arr
 @param param param
 */
+ (void)update:(NSArray <id<MitDBProtocol>> *)arr
         param:(MitDBParam *)param;

/**
 update

 @param arr data's arr
 @param param param
 @param tabName table's name
 */
+ (void)update:(NSArray <id<MitDBProtocol>> *)arr
         param:(MitDBParam *)param
       tabName:(NSString *)tabName;

/**
 update

 @param arr data's arr
 @param param param
 @param transaction whether use transaction
 */
+ (void)update:(NSArray <id<MitDBProtocol>> *)arr
        param:(MitDBParam *)param
        inTransaction:(BOOL)transaction;

/**
 update

 @param arr data's arr
 @param param param
 @param transaction whether use transaction
 @param tabName table's name
 */
+ (void)update:(NSArray <id<MitDBProtocol>> *)arr
         param:(MitDBParam *)param
 inTransaction:(BOOL)transaction
       tabName:(NSString *)tabName;

#pragma mark remove
/**
 remove
 */
- (void)remove;

/**
 remove

 @param tabName table's name
 */
- (void)removeWithTabName:(NSString *)tabName;

/**
 remove

 @param arr array of data
 @param param param
 */
+ (void)remove:(NSArray<id<MitDBProtocol>>*)arr
         param:(MitDBParam *)param;

/**
 remove

 @param arr array of data
 @param param param
 @param tabName table's name
 */
+ (void)remove:(NSArray<id<MitDBProtocol>>*)arr
         param:(MitDBParam *)param
       tabName:(NSString *)tabName;

/**
 remove

 @param arr array of data
 @param param param
 @param transaction whether in transaction
 */
+ (void)remove:(NSArray<id<MitDBProtocol>>*)arr
         param:(MitDBParam *)param
 inTransaction:(BOOL)transaction;

/**
 remove

 @param arr array of data
 @param param param
 @param transaction whether in transaction
 @param tabName table's name
 */
+ (void)remove:(NSArray<id<MitDBProtocol>>*)arr
         param:(MitDBParam *)param
 inTransaction:(BOOL)transaction
       tabName:(NSString *)tabName;

/**
 clear all data's for the table
 */
+ (void)clear;

/**
 clear selected table

 @param tabName table's name
 */
+ (void)clearWithTabName:(NSString *)tabName;

#pragma mark select
/**
 select

 @param result result
 */
+ (void)selectAllResult:(void(^)(NSArray *arr))result;

/**
 select

 @param tabName table's name
 @param result result
 */
+ (void)selectAllWithTabName:(NSString *)tabName
                      result:(void(^)(NSArray *arr))result;

/**
 select

 @param param param
 @param result result
 */
+ (void)selectWithParam:(MitDBParam *)param
                 result:(void(^)(NSArray * arr))result;

/**
 select

 @param param params
 @param tabName table's name
 @param result result
 */
+ (void)selectWithParam:(MitDBParam *)param
                tabName:(NSString *)tabName
                 result:(void(^)(NSArray * arr))result;

#pragma mark excute sql directly
/**
 excute sql

 @param sql sql
 */
+ (BOOL)executeSQL:(NSString *)sql;

/**
 excute sqls

 @param sqls sqls
 @param isTransaction whether use transaction
 */
+ (BOOL)executeSQLs:(NSArray *)sqls withTransaction:(BOOL)isTransaction;

@end
