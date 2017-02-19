//
//  MitFMEncryptDatabase.m
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/7.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitFMEncryptDatabase.h"
#import <sqlite3.h>
#import <UIKit/UIKit.h>

@implementation MitFMEncryptDatabase
static NSString * kEncryptKey;

NSString * MIT_DEFAULT_ENCRYPTKEY = @"12345";


+(void)initialize{
    [super initialize];
    kEncryptKey = MIT_DEFAULT_ENCRYPTKEY;
}


#pragma mark ------------------ 重写方法 ------------------
- (BOOL)open {
    if (_db) {
        return YES;
    }
    
    int err = sqlite3_open([self sqlitePath], (sqlite3**)&_db );
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    }else{
        [self setKey:kEncryptKey];
    }
    if (_maxBusyRetryTimeInterval > 0.0) {
        // set the handler
        [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
    }
    
    
    return YES;
}
- (const char*)sqlitePath {
    
    if (!_databasePath) {
        return ":memory:";
    }
    
    if ([_databasePath length] == 0) {
        return ""; // this creates a temporary database (it's an sqlite thing).
    }
    
    return [_databasePath fileSystemRepresentation];
    
}

- (BOOL)openWithFlags:(int)flags {
    return [self openWithFlags:flags vfs:nil];
}
- (BOOL)openWithFlags:(int)flags vfs:(NSString *)vfsName {
#if SQLITE_VERSION_NUMBER >= 3005000
    if (_db) {
        return YES;
    }
    
    int err = sqlite3_open_v2([self sqlitePath], (sqlite3**)&_db, flags, [vfsName UTF8String]);
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    }else{
            [self setKey:kEncryptKey];
    }
    if (_maxBusyRetryTimeInterval > 0.0) {
        // set the handler
        [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
    }
    
    return YES;
#else
    NSLog(@"openWithFlags requires SQLite 3.5");
    return NO;
#endif
}

#pragma mark - 配置方法
+ (void)setEncryptKey:(NSString *)encryptKey
{
    kEncryptKey = encryptKey;
}









@end
