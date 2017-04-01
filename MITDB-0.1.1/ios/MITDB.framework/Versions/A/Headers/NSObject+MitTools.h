//
//  NSObject+MitTools.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/8.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MitTools)

FOUNDATION_EXTERN NSString * MIT_IVARNAME;
FOUNDATION_EXTERN NSString * MIT_IVARTYPE;
FOUNDATION_EXTERN NSString * MIT_SQLTYPE;
//获取类的所有属性数组
/*
 数组中的元素由字典组成：
 MIT_IVARNAME:变量名称
 MIT_IVARTYPE:变量类型
 MIT_SQLTYPE:变量所对应的 sql 类型
 */
+ (NSArray *)getAllPropertysFromClass;
//表名
+ (NSString *)tableName;

//根据属性名，转换属性
+ (id)changeToJsonWithType:(NSString *)ivarType value:(id)value;

// 检查是否需要序列化成 Json 字符串
- (id )checkToEncodeJsonString:(NSString *)ivarType;
- (id )checkToEncodeJsonString;
//data -> json 字符串
- (NSString *)encodedJsonString;
@end
