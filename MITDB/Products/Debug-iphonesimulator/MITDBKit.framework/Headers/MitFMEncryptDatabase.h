//
//  MitFMEncryptDatabase.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/7.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <FMDB/FMDB.h>


@interface MitFMEncryptDatabase : FMDatabase

/** 设置秘钥 */
+ (void)setEncryptKey:(NSString *)encryptKey;


@end
