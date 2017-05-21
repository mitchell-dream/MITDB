//
//  MitDBProtocal.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/7.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MitDBParam.h"
#import "NSObject+MitTools.h"
#import "NSObject+MitDBHandle.h"
#import "NSObject+MitEncrypt.h"
#import "MitDBMigration.h"
#import "MitDBMigrationHandle.h"
//默认加密秘钥
FOUNDATION_EXTERN NSString * MIT_DEFAULT_ENCRYPTKEY;
/*
 *  加密开关
 *  0 关闭，1，开启
 */
FOUNDATION_EXTERN NSString * MIT_ENCRYPTKEY;

@protocol MitDBProtocal <NSObject>

@optional

/**
 主键
 */
+ (NSString *)primaryKey;

/**
 忽略键值
 */
+ (NSArray *)ignoreKeys;

/**
 表名数组
 */
+ (NSArray *)tableNames;

/**
 默认表名
 */
+ (NSString *)defaultTableName;

/**
 表主键映射（未完成）
 */
+ (NSDictionary *)tablePrimaryKeyMap;

@end
