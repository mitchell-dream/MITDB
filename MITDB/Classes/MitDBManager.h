//
//  MitDBManager.h
//  MITDB
//
//  Created by MENGCHEN on 2019/5/2.
//

#import <Foundation/Foundation.h>

#define MITRegisterTable(table) \
__attribute__((constructor)) \
static void preRegister##table(void) {\
    [MitDBManager preRegisterTable:[table class]];\
}

@interface MitDBManager : NSObject
/**
 sharedManager
 */
+ (instancetype)sharedManager;

/**
 start
 */
+ (void)start;

/**
 preregister table
 */
+ (void)preRegisterTable:(Class )table;

/**
 register table
 */
+ (void)registerTable:(NSString *)table;
@end
