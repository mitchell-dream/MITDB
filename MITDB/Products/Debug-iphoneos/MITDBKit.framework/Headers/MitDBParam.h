//
//  MitDBParam.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/7.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, Mit_SortType) {
    Mit_SortTypeAEC,
    Mit_SortTypeDESC,
};

typedef NS_ENUM(NSUInteger, Mit_CalculateType) {
    Mit_CalculateType_Min,
    Mit_CalculateType_Max,
    Mit_CalculateType_AVG,
};


typedef NS_ENUM(NSUInteger, Mit_OperateType) {
    Mit_OperateTypeEqual,
    Mit_OperateTypeLessThan,
    Mit_OperateTypeLessEqualThan,
    Mit_OperateTypeMoreThan,
    Mit_OperateTypeMoreEqualThan,
    Mit_OperateTypeUnequal,
};

typedef NS_ENUM(NSUInteger, Mit_FilterType) {
    Mit_FilterTypeAll,
    Mit_FilterTypePrefix,
    Mit_FilterTypeSuffix,
};

@interface MitDBParam : NSObject
/** sql */
@property(nonatomic, strong)NSString * conditionSql;
/** 属性字符串 */
@property(nonatomic, strong)NSString * propNameString;
/** 属性数组 */
@property(nonatomic, strong)NSArray * propArr;
/** 值字符串 */
@property(nonatomic, strong)NSString * valueString;
/** 值数组 */
@property(nonatomic, strong)NSArray * valueArr;

/* Operate */

//传递待比较参数
- (MitDBParam *(^)(NSString *)) propertyName;
//传递多个待比较参数
- (MitDBParam *(^)(NSArray *)) propertyNames;
//传递值
- (MitDBParam *(^)(id)) value;
//传递多个值
- (MitDBParam *(^)(NSArray *)) values;






//WHERE
- (MitDBParam *(^)( NSString *  )) where;
//HAVING
- (MitDBParam *(^)( )) having;
//相等
- (MitDBParam *(^)(id)) equal;
//不等
- (MitDBParam *(^)(id)) unequal;
//小于
- (MitDBParam *(^)(id)) lessThan;
//小于等于
- (MitDBParam *(^)(id)) lessEqualThan;
//大于
- (MitDBParam *(^)(id)) moreThan;
//大于等于
- (MitDBParam *(^)(id)) moreEqualThan;
//并
- (MitDBParam *(^)())AND;
//或
- (MitDBParam *(^)())OR;


/* Filter */
//向后匹配
- (MitDBParam *(^)(NSString *)) prefix;
//向前匹配
- (MitDBParam *(^)(NSString *)) suffix;
//全匹配
- (MitDBParam *(^)(NSString *)) contain;

/* Sort */
//分组
- (MitDBParam *(^)(NSString *)) groupBy;
//顺序
- (MitDBParam *(^)(NSString *)) aec;
//倒叙
- (MitDBParam *(^)(NSString *)) desc;
//限制
- (MitDBParam *(^)(id))limit;
//偏移
- (MitDBParam *(^)(id))offset;


/* Calculate */
//最大
- (MitDBParam *(^)(NSString *))max;
//最小
- (MitDBParam *(^)(NSString *))min;
//平均
- (MitDBParam *(^)(NSString *))avg;
//总和
- (MitDBParam *(^)(NSString *))sum;
//数量
- (MitDBParam  *(^)(NSString * ))count;



/* Other */
//别名
- (MitDBParam *(^)( NSString * ))AS;
@end
