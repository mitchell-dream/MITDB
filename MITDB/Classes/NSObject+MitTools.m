//
//  NSObject+MitTools.m
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/8.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "NSObject+MitTools.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "MitDBProtocol.h"
@implementation NSObject (MitTools)

NSString * MIT_IVARNAME = @"property_name";
NSString * MIT_IVARTYPE = @"property_type";
NSString * MIT_SQLTYPE = @"sql_type";



#pragma mark action 获取所有属性
+ (NSArray *)getAllPropertysFromClass{
    NSMutableArray * arr = [NSMutableArray array];
    NSString * ivar_name = nil;
    NSString * ivar_type = nil;
    NSString * sql_type = nil;
    Class clz = [self class];
    if ([clz conformsToProtocol:@protocol(MitDBProtocol)]) {
        u_int count;
        Ivar * ivars = class_copyIvarList(clz, &count);
        for (int i = 0; i<count; i++) {
            Ivar ivar = ivars[i];
            const char * ivarName = ivar_getName(ivar);
            ivar_name = [NSString stringWithUTF8String:ivarName];
            const char * ivarType = ivar_getTypeEncoding(ivar);
            ivar_type = [NSString stringWithUTF8String:ivarType];
            ivar_type = [ivar_type stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
            ivar_type = [ivar_type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            [ivar_type stringByReplacingOccurrencesOfString:@"\"@\"" withString:@""];
            [ivar_type stringByReplacingOccurrencesOfString:@"\\""" withString:@""];
            sql_type = [self changeToSqlType:ivar_type];
            if([ivar_name length] > 0 && [ivar_type length] > 0){
                ivar_name = [ivar_name stringByReplacingOccurrencesOfString:@"_" withString:@""];
                
                if ([self isIgnoreKey:ivar_name]) {
                    continue;
                }
                [arr addObject:@{MIT_IVARNAME:ivar_name,MIT_IVARTYPE:ivar_type,MIT_SQLTYPE:sql_type}];
//                [arr addObject:@{MIT_IVARNAME:[ivar_name stringByReplacingOccurrencesOfString:@"_" withString:@""],MIT_IVARTYPE:ivar_type,MIT_SQLTYPE:sql_type}];
            }
        }
        free(ivars);
    }
    return arr;
}

#pragma mark action 转换成 SQL 的类型
+ (NSString *)changeToSqlType:( NSString * )str{
    NSString * typeEncoding = nil;
    /*
     @"c":char
     @"C":unsigned char
     @"f":float
     @"i":int
     @"I":unsigned int
     @"d":double
     @"l":long
     @"s":short
     @"S":unsigned short
     @"q":long long
     @"I":unsigned int,
     @"Q":unsigned long long,
     @"B":C++ bool or a C99 _Bool,
     */
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
        typeEncoding = @"TEXT";
    }else if ([str isEqualToString:@"NSDictionary"]){
        typeEncoding = @"TEXT";
    }else{
        typeEncoding = @"TEXT";
    }
    return typeEncoding;
}

#pragma mark action 转换成 Json 串
+ (id)changeToJsonWithType:( NSString *)ivarType value:(id)value{
    Class cls = NSClassFromString(ivarType);
    if (value&&([cls isSubclassOfClass:[NSArray class]]||[cls isSubclassOfClass:[UIImage class]]||[cls conformsToProtocol:@protocol(MitDBProtocol)])) {
        NSError * err = nil;
        NSData * data = [value dataUsingEncoding:NSUTF8StringEncoding];
        id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        return obj;
    }else{
        return value;
    }
    return value;
}

#pragma mark action 检查是否需要转换成 json 字符串
- (id )checkToEncodeJsonString:(NSString *)ivarType{
    Class cls = NSClassFromString(ivarType);
    if (self&&([cls isSubclassOfClass:[NSArray class]]||[cls isSubclassOfClass:[UIImage class]]||[cls isSubclassOfClass:[NSDictionary class]]||[cls conformsToProtocol:@protocol(MitDBProtocol)])) {
        return [self encodedJsonString];
    } else {
        return self;
    }
}
- (id )checkToEncodeJsonString{
    Class cls = [self class];
    if (self&&([cls isSubclassOfClass:[NSArray class]]||[cls isSubclassOfClass:[UIImage class]]||[cls isSubclassOfClass:[NSDictionary class]]||[cls conformsToProtocol:@protocol(MitDBProtocol)])) {
        return [self encodedJsonString];
    } else {
        return self;
    }
}



#pragma mark action data -> jsonString
- (NSString *)encodedJsonString {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}


#pragma mark action 获取列表名称
+ (NSString *)tableName{
    NSString * tb_name = nil;
    //查看是否实现了协议中默认名称方法
    tb_name = [self defaultTableName];
    if (!tb_name||tb_name.length == 0 ) {
        //如果没有实现，查看是否实现了表数组方法
        NSArray * arr = [self tableNames];
        if (arr&&arr.count>0) {
            tb_name = [arr firstObject];
        }
    }
    if (!tb_name||tb_name.length == 0) {
        tb_name = [self mit_defaultTableName];
    }
    return tb_name;
}

#pragma mark action 设置默认表名
+ (NSString *)mit_defaultTableName{
    NSString * tb_name = NSStringFromClass([self class]);
    tb_name = [NSString stringWithFormat:@"mitdb_%@",tb_name];
    return tb_name;
}


#pragma mark ------------------ 协议方法 ------------------
+ (NSString *)defaultTableName{
    return nil;
}

+ (NSArray *)tableNames{
    return nil;
}

@end
