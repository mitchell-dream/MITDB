//
//  MitDBParam.m
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/7.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitDBParam.h"
#import "NSObject+MitTools.h"
@interface MitDBParam ()

@end

@implementation MitDBParam

-(instancetype)init{
    if (self = [super init]) {
        self.conditionSql = @"";
        self.propNameString  = @"";
        self.valueString = @"";
    }
    return self;
}
#pragma mark action 设置待比较属性
-(MitDBParam *(^)(NSString *))propertyName{
    return ^MitDBParam *(NSString * params){
        [self.propNameString  stringByAppendingString:params];
        return self;
    };
}
#pragma mark action 设置多个待比较属性
-(MitDBParam *(^)(NSArray*))propertyNames{
    
    return ^MitDBParam *(NSArray*arr){
        self.propArr = [arr copy];
        self.propNameString  = [arr componentsJoinedByString:@","];
        return self;
    };
}

#pragma mark action 设置单个值
-(MitDBParam *(^)(id))value{
    return ^MitDBParam *(id value){
        self.valueString = [self.valueString stringByAppendingString:[NSString stringWithFormat:@"'%@'",[value checkToEncodeJsonString]]];
        return self;
    };
}


#pragma mark action 设置多个值
-(MitDBParam *(^)(NSArray *))values{
    
    return ^MitDBParam *(NSArray * arr){
        self.valueArr = [arr copy];
        NSMutableArray * mutableArr = [NSMutableArray array];
        for (NSInteger i =0; i<arr.count; i++) {
            [mutableArr addObject: [NSString stringWithFormat:@"'%@'",[arr[i] checkToEncodeJsonString]]];
        }
        self.valueString = [mutableArr componentsJoinedByString:@","];
        return self;
    };
}


#pragma mark action WHERE 比较语句
/*
 *  行级过滤
 */
-(MitDBParam *(^)())where {
    return ^MitDBParam *(){
        
        [self appendString:@" WHERE "];
        return self;
    };
}
#pragma mark action HAVING 比较分组
/*
 组级过滤
 通常可以使用 having 来替换 where
 唯一的差别是，WHERE 过滤行，而 HAVING 过滤分组
 */
-(MitDBParam *(^)())having{
    return ^MitDBParam *(){
        [self appendString:@" HAVING "];
        return self;
    };
    
    
}

#pragma mark ------------------ Operate ------------------
#pragma mark action 等于
- (MitDBParam *(^)(id))equal{
    return ^MitDBParam *(id value){
        [self appendString:[NSString stringWithFormat:@" = '%@'",value]];
        return self;
    };
}
#pragma mark action 不等于
- (MitDBParam *(^)(id))unequal{
    return ^MitDBParam *(id value){
        [self appendString:[NSString stringWithFormat:@" <> '%@'",value]];
        return self;
    };
}

#pragma mark action 小于
- (MitDBParam *(^)(id))lessThan{
    return ^MitDBParam *(id value){
        [self appendString:[NSString stringWithFormat:@" < '%@'",value]];

        return self;
    };
}

#pragma mark action 小于等于
- (MitDBParam *(^)(id))lessEqualThan{
    return ^MitDBParam *(id value){
        [self appendString:[NSString stringWithFormat:@" <= '%@'",value]];
        return self;
    };
}

#pragma mark action 大于
- (MitDBParam *(^)(id))moreThan{
    return ^MitDBParam *(id value){
        [self appendString:[NSString stringWithFormat:@" > '%@'",value]];
        return self;
    };
}
#pragma mark action 大于等于
- (MitDBParam *(^)(id))moreEqualThan{
    return ^MitDBParam *(id value){
        [self appendString:[NSString stringWithFormat:@" >= '%@'",value]];
        return self;
    };
}

#pragma mark action AND
- (MitDBParam *(^)())AND{
    return ^MitDBParam*(){
        [self appendString:@" AND "];
        return self;
    };
}

#pragma mark action OR
- (MitDBParam *(^)())OR{
    return ^MitDBParam*(){
        [self appendString:@" OR "];
        return self;
    };
}


#pragma mark ------------------ Filter ------------------
#pragma mark action 向后匹配
- (MitDBParam *(^)(NSString *))prefix{
    return ^MitDBParam*(NSString * str){
        [self appendString:[NSString stringWithFormat:@" LIKE '%@%%%%'",str]];
        return self;
    };
}

#pragma mark action 向前匹配
- (MitDBParam *(^)(NSString *))suffix{
    return ^MitDBParam*(NSString * str){
        [self appendString:[NSString stringWithFormat:@" LIKE '%%%%%@'",str]];
        return self;
    };
}
#pragma mark action 全匹配
- (MitDBParam *(^)(NSString *))contain{
    return ^MitDBParam*(NSString * str){
        [self appendString:[NSString stringWithFormat:@" LIKE '%%%%%@%%%%'",str]];
        return self;
    };
}


#pragma mark ------------------ Sort ------------------
#pragma mark action 升序
- (MitDBParam *(^)(NSString *))aec{
    return ^MitDBParam*(NSString * str){
        [self appendString:[NSString stringWithFormat:@" ORDER BY %@ AEC",str]];
        return self;
    };
}


#pragma mark action desc 降序
- (MitDBParam *(^)(NSString *))desc{
    return ^MitDBParam*(NSString * str){
        [self appendString:[NSString stringWithFormat:@" ORDER BY %@ DESC ",str]];
        return self;
    };
}

#pragma mark action 分组
/*
 * GROUP BY子句必须出现在WHERE子句之后，ORDER BY子句之前。
 */
- (MitDBParam *(^)(NSString *))groupBy{
    return ^MitDBParam*(NSString *str){
        [self appendString:[NSString stringWithFormat:@" GROUP BY %@",str]];
        return self;
    };
}

#pragma mark action 限制
- (MitDBParam *(^)(id))limit{
    return ^MitDBParam *(id value){
        [self appendString:[NSString stringWithFormat:@" LIMIT %@ ",value]];
        return self;
    };
}
#pragma mark action 偏移
- (MitDBParam *(^)(id))offset{
    return ^MitDBParam *(id value){
        [self appendString:[NSString stringWithFormat:@" OFFSET %@ ",value]];
        return self;
    };
}

#pragma mark ------------------ Calculate ------------------
#pragma mark action 最大值
-(MitDBParam *(^)(NSString *))max{
    return ^MitDBParam* (NSString *str){
      
        [self appendString:[NSString stringWithFormat:@" MAX(%@) ",str]];
        return self;
    };
}
#pragma mark action 最小值
-(MitDBParam *(^)(NSString *))min{
    return ^MitDBParam* (NSString *str){
        [self appendString:[NSString stringWithFormat:@" MIN(%@) ",str]];
        return self;
    };
}
#pragma mark action 平均值
-(MitDBParam *(^)(NSString *))avg{
    return ^MitDBParam* (NSString *str){
        [self appendString:[NSString stringWithFormat:@" AVG(%@) ",str]];
        return self;
    };
}

#pragma mark action 总和
-(MitDBParam *(^)(NSString *))sum{
    return ^MitDBParam* (NSString *str){
        [self appendString:[NSString stringWithFormat:@" SUM(%@) ",str]];
        return self;
    };
}
#pragma mark action 数量
-(MitDBParam *(^)(NSString *))count{
    return ^MitDBParam* (NSString *str){
        if (!str) {
            [self appendString:@" COUNT(*) "];
        }else{
            [self appendString:[NSString stringWithFormat:@" COUNT(%@) ",str]];
        }
        return self;
    };
}


#pragma mark ------------------ Other ------------------
#pragma mark action 别名
-(MitDBParam *(^)(NSString *))AS{
    return ^MitDBParam* (NSString *str){
        [self appendString:[NSString stringWithFormat:@" AS %@ AEC",str]];
        return self;
    };
}


#pragma mark action 拼接
- (void)appendString:(NSString *)string{
    self.conditionSql = [self.conditionSql stringByAppendingString:string];
}

@end
