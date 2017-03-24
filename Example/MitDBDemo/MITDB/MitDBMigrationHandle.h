//
//  MitDBMigrationHandle.h
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/10.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MitDBMigration;


#define MitDBMigrationManager [MitDBMigrationHandle sharedManager]

@interface MitDBMigrationHandle : NSObject
+(instancetype)sharedManager;
/** 添加迁移版本 */
- (void)addMigration:(MitDBMigration*)migration;
/** 开始迁移 */
- (void)startMigrationCompletion:(void(^)(BOOL succeed))completion;

@end
