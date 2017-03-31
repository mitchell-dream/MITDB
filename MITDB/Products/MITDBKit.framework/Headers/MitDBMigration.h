//
//  MitDBMigration.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/10.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBMigrationManager.h"
@interface MitDBMigration : NSObject<FMDBMigrating>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) uint64_t version;

- (instancetype)initWithName:(NSString *)name andVersion:(uint64_t)version andExecuteUpdateArray:(NSArray *)updateArray;//自定义方法
- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;

@end
