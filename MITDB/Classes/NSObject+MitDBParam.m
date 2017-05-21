//
//  NSObject+MitDBParam.m
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/7.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSObject+MitDBParam.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "NSObject+MitDBHandle.h"
#import "NSObject+MitTools.h"
#import "MitDBProtocal.h"


@implementation NSObject (MitDBParam)
#pragma mark action 创建建表的 sql 语句
+ (NSString *)createSQLWithParamArr:(NSArray *)arr{
    __block NSString * sqlString = @"(";
    __block NSString * key;
    __block NSString * type;
    NSString * primary = [self primaryKey];
    //如果设置了主键
    if ([self hasPrimaryKey]) {
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary * dict = obj;
            //属性名称
            key = [dict objectForKey:MIT_IVARNAME];
            //sql 类型
            type = [dict objectForKey:MIT_SQLTYPE];
            if ([key isEqualToString:primary]) {
                sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"%@ %@ primary key,",key,type]];
            }else{
                sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"%@ %@,",key,type]];
            }
        }];
        sqlString = [sqlString stringByReplacingCharactersInRange:NSMakeRange(sqlString.length-1, 1) withString:@""];
    } else {
        //没有主键,则设置主键
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary * dict = obj;
            //属性名称
            key = [dict objectForKey:MIT_IVARNAME];
            //sql 类型
            type = [dict objectForKey:MIT_SQLTYPE];
            sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"%@ %@,",key,type]];
        }];
        sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"%@ integer primary key autoincrement",primary]];
    }
    sqlString = [sqlString stringByAppendingString:@");"];
    return sqlString;
}

#pragma mark action 建表
+ (NSString *)createTabSQL{
    NSArray * arr = [self getAllPropertysFromClass];
    NSString * sql = [NSString stringWithFormat:@"create table if not exists %@ %@",[self tableName],[self createSQLWithParamArr:arr]];
    return sql;
}

+ (NSString *)createTabSQLWithTabName:(NSString *)tabName{
    if (!tabName||tabName.length==0) {
        return nil;
    }
    NSArray * arr = [self getAllPropertysFromClass];
    NSString * sql = [NSString stringWithFormat:@"create table if not exists %@ %@",tabName,[self createSQLWithParamArr:arr]];
    return sql;
}

#pragma mark action 存储语句
- (NSString *)saveSqlWithParam:(MitDBParam *)param tabName:(NSString *)tabName{
    NSArray * arr = [[self class] getAllPropertysFromClass];
    if (!(arr.count>0)) {
        return nil;
    }
    NSString * sql = nil;
    if (tabName &&tabName.length>0) {
       sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@",tabName];
    } else {
        sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@",[[self class] tableName]];
    }
    NSMutableArray * keys  = [NSMutableArray array];
    NSMutableArray * values = [NSMutableArray array];
    NSString * key = nil;
    NSDictionary * dict = nil;
    id value = nil;
    if (!param) {
        //如果没有条件参数，那么默认存
        for (NSInteger i = 0; i<arr.count; i++) {
            dict = arr[i];
            key = [dict objectForKey:MIT_IVARNAME];
            value = [self valueForKey:key];
            if (value!=nil) {
                [keys addObject:key];
                value = [value checkToEncodeJsonString:key];
                [values addObject:value];
            }else{
                continue;
            }
        }
        NSString * keyStr = [keys componentsJoinedByString:@","];
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"(%@)",keyStr]];
        NSString * v = nil;
        for (int j = 0; j<values.count; j++) {
            v = [NSString stringWithFormat:@"'%@'",values[j]];
            [values replaceObjectAtIndex:j withObject:v];
        }
        NSString * valueStr = [values componentsJoinedByString:@","];
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"VALUES(%@);",valueStr]];
    }else{
        //有条件参数，拼条件
        NSArray * tempKeysArr = [param.propNameString  componentsSeparatedByString:@","];
        //如果有 key 值
        if (tempKeysArr.count>0) {
            for (NSInteger i = 0; i<tempKeysArr.count; i++) {
                key = tempKeysArr[i];
                value = [self valueForKey:key];
                if (value!=nil) {
                    [keys addObject:key];
                    value = [value checkToEncodeJsonString:key];
                    [values addObject:value];
                }else{
                    continue;
                }
            }
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"(%@)",param.propNameString ]];
        }
        if (param.valueString.length>0) {
            //如果有值字符串
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"VALUES(%@);",param.valueString]];
        }else{
            //如果没有值字符串,直接从自己的值中取值
            NSString * v = nil;
            for (int j = 0; j<values.count; j++) {
                v = [NSString stringWithFormat:@"'%@'",values[j]];
                [values replaceObjectAtIndex:j withObject:v];
            }
            NSString * valueStr = [values componentsJoinedByString:@","];
            sql = [sql stringByAppendingString:valueStr];
            sql = [sql stringByAppendingString:@");"];
        }
    }
    return sql;
}


#pragma mark action 删除语句
-(NSString *)removeSqlWithParam:(MitDBParam *)param tabName:(NSString *)tabName{
    NSArray * arr = [[self class] getAllPropertysFromClass];
    if (!(arr.count>0)) {
        return nil;
    }
    NSString * sql = nil;
    if (tabName&&tabName.length>0) {
        sql = [NSString stringWithFormat:@"DELETE FROM %@ ",tabName];
    } else {
        sql = [NSString stringWithFormat:@"DELETE FROM %@ ",[[self class] tableName]];

    }
    if (!param) {
        //没有条件，拼接主键
        //是否有自己设置的主键
        NSString * primaryKey = [[self class] primaryKey];
        id value = [self primaryValue];
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"WHERE %@ = '%@';",primaryKey,value]];
    } else {
        if (param.conditionSql.length>0) {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@;",param.conditionSql]];
        }else{
            NSString * primaryKey = [[self class] primaryKey];
            id value = [self primaryValue];
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"WHERE %@ = '%@';",primaryKey,value]];
        }
    }
    return sql;
}

#pragma mark action 清空语句
- (NSString *)removeAllSql:(NSString *)tableName{
    NSString * str = [NSString stringWithFormat:@"truncate table %@",tableName];
    return str;
}


#pragma mark action 更新
- (NSString *)updateSqlWithParam:(MitDBParam *)param tabName:(NSString *)tabName{
    NSArray * arr = [[self class] getAllPropertysFromClass];
    if (!(arr.count>0)) {
        return nil;
    }
    NSString * sql = nil;
    if (tabName&&tabName.length>0) {
        sql = [NSString stringWithFormat:@"UPDATE %@ SET ",tabName];
    } else {
        sql = [NSString stringWithFormat:@"UPDATE %@ SET ",[[self class] tableName]];
    }
    if (!param) {
        //无参数
        __block NSMutableArray * keys  = [NSMutableArray array];
        __block NSMutableArray * values = [NSMutableArray array];
        __block NSString * key = nil;
        __block NSDictionary * dict = nil;
        __block id value = nil;
        //没设主键
        if (![[self class] hasPrimaryKey]) {
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dict = obj;
                key = [dict objectForKey:MIT_IVARNAME];
                value = [self valueForKey:key];
                if (value!=nil) {
                    [keys addObject:key];
                    [values addObject:value];
                }
            }];
            for (int i = 0; i<keys.count; i++) {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = '%@',",keys[i],values[i]]];
            }
            sql = [sql stringByReplacingCharactersInRange:NSMakeRange(sql.length-1, 1) withString:@""];
            NSString * primaryValue = [self primaryValue];
            NSString * primaryKey = [[self class] primaryKey];
            sql  = [sql stringByAppendingString:[NSString stringWithFormat:@"WHERE %@ = '%@' ",primaryKey,primaryValue]];
            sql  = [sql stringByAppendingString:@";"];
        } else {
            //有自定义主键
            NSString * primaryKey = [[self class] primaryKey];
            NSString * primaryValue = [self primaryValue];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dict = obj;
                key = [dict objectForKey:MIT_IVARNAME];
                value = [self valueForKey:key];
                if (value!=nil&&![key isEqualToString:primaryKey]) {
                    [keys addObject:key];
                    [values addObject:value];
                }
            }];
            for (int i = 0; i<keys.count; i++) {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = '%@',",keys[i],values[i]]];
            }
            sql = [sql stringByReplacingCharactersInRange:NSMakeRange(sql.length-1, 1) withString:@""];
            sql  = [sql stringByAppendingString:[NSString stringWithFormat:@"WHERE %@ = '%@'",primaryKey,primaryValue]];
            sql  = [sql stringByAppendingString:@";"];
        }
    } else {
        //拼接修改参数
        if (param.propArr.count>0) {
            for (NSInteger i = 0; i<param.propArr.count; i++) {
              sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = '%@',",param.propArr[i],param.valueArr[i]]];
            }
        }
        //将，替换成‘ ’
        sql = [sql stringByReplacingCharactersInRange:NSMakeRange(sql.length-1, 1) withString:@" "];

        //拼接条件参数
        if (param.conditionSql.length>0) {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@",param.conditionSql]];
        }else{
            //拼接主键
            NSString * primaryValue = [self primaryValue];
            NSString * primaryKey = [[self class] primaryKey];
            sql  = [sql stringByAppendingString:[NSString stringWithFormat:@"WHERE %@ = '%@' ",primaryKey,primaryValue]];
        }
        sql = [sql stringByAppendingString:@";"];
    }
    return sql;
}



#pragma mark action 查询语句
- (NSString *)selectSqlWithParam:(MitDBParam *)param tabName:(NSString *)tabName{
    NSArray * arr = [[self class] getAllPropertysFromClass];
    if (!(arr.count>0)) {
        return nil;
    }
    NSString * sql = @"SELECT";
    NSString * tableName = (tabName&&tabName.length>0)?tabName:([[self class]tableName]);
    if (!param) {
        //没参数 全查
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"* FROM %@;",tableName]];
    } else {
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@FROM %@",param.propertyNames,tableName]];
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@;",param.conditionSql]];
    }
    return sql;
}





@end
