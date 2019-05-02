//
//  MitFMEncryptHelper.m
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/9.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitFMEncryptHelper.h"
#import "FMDatabase.h"
#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif
#import "MitFMEncryptDatabase.h"
#import "NSObject+MitDBHandle.h"

@implementation MitFMEncryptHelper

#pragma mark action 加密文件
+(BOOL)encryptDatabase:(NSString *)path :(NSString *)str{
    NSString *sourcePath = path;
    NSString *targetPath = [NSString stringWithFormat:@"%@.tmp.db", path];
    
    if([self encryptDatabase:sourcePath targetPath:targetPath encryptKey:str]) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        [fm removeItemAtPath:sourcePath error:nil];
        [fm moveItemAtPath:targetPath toPath:sourcePath error:nil];
        //修改 加密 kEY
        [NSObject updateSQLCipherKey:true];
        return true;
    } else {
        return false;
    }
    
}

#pragma mark action 解密文件
+(BOOL)decodeDatabase:(NSString *)path :(NSString *)str{
    NSString *sourcePath = path;
    NSString *targetPath = [NSString stringWithFormat:@"%@.tmp.db", path];
    if([self unEncryptDatabase:sourcePath targetPath:targetPath encryptKey:str]) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        [fm removeItemAtPath:sourcePath error:nil];
        [fm moveItemAtPath:targetPath toPath:sourcePath error:nil];
        [NSObject updateSQLCipherKey:false];

        return YES;
    } else {
        return NO;
    }
}

#pragma mark action 对数据库加密
+ (BOOL)encryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath encryptKey:(NSString *)encryptKey
{
    const char* sqlQ = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", targetPath, encryptKey] UTF8String];
    
    sqlite3 *unencrypted_DB;
    if (sqlite3_open([sourcePath UTF8String], &unencrypted_DB) == SQLITE_OK) {
        char *errmsg;
        // Attach empty encrypted database to unencrypted database
        sqlite3_exec(unencrypted_DB, sqlQ, NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"%@", [NSString stringWithUTF8String:errmsg]);
            sqlite3_close(unencrypted_DB);
            return NO;
        }
        
        // export database
        sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"%@", [NSString stringWithUTF8String:errmsg]);
            sqlite3_close(unencrypted_DB);
            return NO;
        }
        
        // Detach encrypted database
        sqlite3_exec(unencrypted_DB, "DETACH DATABASE encrypted;", NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"%@", [NSString stringWithUTF8String:errmsg]);
            sqlite3_close(unencrypted_DB);
            return NO;
        }
        
        sqlite3_close(unencrypted_DB);
        
        return YES;
    }
    else {
        sqlite3_close(unencrypted_DB);
        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
        
        return NO;
    }
}

#pragma mark action 对数据库解密
+ (BOOL)unEncryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath encryptKey:(NSString *)encryptKey
{
    const char* sqlQ = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS plaintext KEY '';", targetPath] UTF8String];
    
    sqlite3 *encrypted_DB;
    if (sqlite3_open([sourcePath UTF8String], &encrypted_DB) == SQLITE_OK) {
        
        
        char* errmsg;
        
        sqlite3_exec(encrypted_DB, [[NSString stringWithFormat:@"PRAGMA key = '%@';", encryptKey] UTF8String], NULL, NULL, &errmsg);
        
        // Attach empty unencrypted database to encrypted database
        sqlite3_exec(encrypted_DB, sqlQ, NULL, NULL, &errmsg);
        
        if (errmsg) {
            NSLog(@"%@", [NSString stringWithUTF8String:errmsg]);
            sqlite3_close(encrypted_DB);
            return NO;
        }
        
        // export database
        sqlite3_exec(encrypted_DB, "SELECT sqlcipher_export('plaintext');", NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"%@", [NSString stringWithUTF8String:errmsg]);
            sqlite3_close(encrypted_DB);
            return NO;
        }
        
        // Detach unencrypted database
        sqlite3_exec(encrypted_DB, "DETACH DATABASE plaintext;", NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"%@", [NSString stringWithUTF8String:errmsg]);
            sqlite3_close(encrypted_DB);
            return NO;
        }
        
        sqlite3_close(encrypted_DB);
        
        return YES;
    }
    else {
        sqlite3_close(encrypted_DB);
        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(encrypted_DB));
        
        return NO;
    }
}

#pragma mark action 修改秘钥，必须在加密状态下调用，否则无效
+ (BOOL)changeKey:(NSString *)dbPath originKey:(NSString *)originKey newKey:(NSString *)newKey
{
    sqlite3 * encrypted_DB;
    if (sqlite3_open([dbPath UTF8String], &encrypted_DB) == SQLITE_OK) {
        
        sqlite3_exec(encrypted_DB, [[NSString stringWithFormat:@"PRAGMA key = '%@';", originKey] UTF8String], NULL, NULL, NULL);
        
        sqlite3_exec(encrypted_DB, [[NSString stringWithFormat:@"PRAGMA rekey = '%@';", newKey] UTF8String], NULL, NULL, NULL);
        
        sqlite3_close(encrypted_DB);
        return YES;
    }
    else {
        sqlite3_close(encrypted_DB);
        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(encrypted_DB));
        
        return NO;
    }
}
#pragma mark action 设置秘钥
+ (void)setEncryptKey:(NSString *)encryptKey{
//    [MitFMEncryptDatabase setEncryptKey:encryptKey];
//    [FMDatabase setEncryptKey:encryptKey];
}
@end
