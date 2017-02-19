//
//  MitDBMigrationHandle.m
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/10.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitDBMigrationHandle.h"
#import "MitDBMigration.h"
#import "NSObject+MitDBHandle.h"

@interface MitDBMigrationHandle()

/** 迁移数组 */
@property(nonatomic, strong)NSMutableArray * mitgrationArr;

@end

@implementation MitDBMigrationHandle

#pragma mark action 创建单例
static dispatch_once_t onceToken;
static MitDBMigrationHandle * manager = nil;
+ (instancetype)sharedManager{
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

#pragma mark action 添加迁移版本
- (void)addMigration:(MitDBMigration *)migration{
    [self.mitgrationArr addObject:migration];
}

#pragma mark create 迁移数组
- (NSMutableArray *)mitgrationArr{
    if (!_mitgrationArr) {
        NSMutableArray * arr = [NSMutableArray array];
        _mitgrationArr = arr;
    }
    return _mitgrationArr;
}
#pragma mark action 释放
- (void)free{
    onceToken = 0;
    manager = nil;
}


#pragma mark action 开始
- (void)startMigrationCompletion:(void (^)(BOOL))completion{
    FMDBMigrationManager * manager=[FMDBMigrationManager managerWithDatabaseAtPath:[NSObject dbPath] migrationsBundle:[NSBundle mainBundle]];
    for (int i = 0; i<self.mitgrationArr.count; i++) {
        MitDBMigration * migration = self.mitgrationArr[i];
        [manager addMigration:migration];
    }
    BOOL resultState=NO;
    NSError * error=nil;
    if (!manager.hasMigrationsTable) {
        resultState=[manager createMigrationsTable:&error];
    }
    
    resultState=[manager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];
    completion(resultState);
    if (resultState) {
        onceToken = 0;
        manager = nil;
    }
}

@end
