//
//  MitFMEncryptHelper.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/9.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MitFMEncryptHelper : NSObject
//数据库加密
+ (BOOL)encryptDatabase:(NSString *)path :(NSString *)str;
//数据库解密
+ (BOOL)decodeDatabase:(NSString *)path :(NSString *)str;

/** 对数据库加密 */
+ (BOOL)encryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath;

/** 对数据库解密 */
+ (BOOL)unEncryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath;

/** 修改数据库秘钥 一定要在加密状态下调用，否则无效 */
+ (BOOL)changeKey:(NSString *)dbPath originKey:(NSString *)originKey newKey:(NSString *)newKey;


/** 自定义秘钥
    加密之后的数据库文件，在别的数据库管理软件是不一定能打开的，即使你知道密码.
    因为sqlcihper和当前使用的数据库管理软件并不一定是用的是一套加解密机制。
 */
+ (void)setEncryptKey:(NSString *)encryptKey;
@end
