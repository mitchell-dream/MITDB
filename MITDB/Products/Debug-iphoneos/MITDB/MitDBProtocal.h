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
+ (NSString *)primaryKey;
+ (NSArray *)ignoreKeys;

@end
