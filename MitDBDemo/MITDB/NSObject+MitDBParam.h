//
//  NSObject+MitDBParam.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/7.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MitDBParam.h"

@interface NSObject (MitDBParam)
//建表
+ (NSString *)createTabSQL;
//保存
- (NSString *)saveSqlWithParam:(MitDBParam *)param;
//修改
- (NSString *)updateSqlWithParam:(MitDBParam *)param;
//删除
- (NSString *)removeSqlWithParam:(MitDBParam *)param;
//查询
- (NSString *)selectSqlWithParam:(MitDBParam *)param;

@end
