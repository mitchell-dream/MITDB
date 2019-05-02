//
//  MITDBTestModel.m
//  MitDB
//
//  Created by MENGCHEN on 2017/3/24.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MITDBTestModel.h"

@class MITDBTestModel;

@interface MITDBTestModel()<MitDBProtocol>
@end

MITRegisterTable(MITDBTestModel);

@implementation MITDBTestModel
+(NSArray *)ignoreKeys{
    return @[@"name",@"age"];
}
//+ (NSString *)primaryKey{
//    return @"uid";
//}

//+(NSString *)defaultTableName{
//    return @"aaaa";
//}

+ (NSArray *)tableNames{
    return @[@"tableOne",@"tableTwo"];
}

+ (NSDictionary *)tablePrimaryKeyMap{
    return @{@"tableOne":@"uid"};
}

@end
