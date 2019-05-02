//
//  MitDBManager.m
//  MITDB
//
//  Created by MENGCHEN on 2019/5/2.
//

#import "MitDBManager.h"
#import <objc/runtime.h>
#import "MitDBProtocol.h"
#import "NSObject+MitDBHandle.h"
@interface MitDBManager()
/**
 pre register table
 */
@property(nonatomic, strong)NSMutableDictionary * preRegisterTable;
/**
 table
 */
@property(nonatomic, strong)NSMutableDictionary * registeredMap;
@end

@implementation MitDBManager

static MitDBManager * _manager = nil;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[MitDBManager alloc]init];
    });
    return _manager;
}

+ (void)preRegisterTable:(Class )table {
    [[MitDBManager sharedManager].preRegisterTable setObject:NSStringFromClass(table) forKey:NSStringFromClass(table)];
}

+ (void)start {
    [self registerTable];
    [self createTable];
}

+ (void)registerTable {
    for (NSString *str in [MitDBManager sharedManager].preRegisterTable) {
        [[MitDBManager sharedManager].registeredMap setObject:str forKey:str];
    }
}

+ (void)createTable {
    for (NSString * clsString in [MitDBManager sharedManager].registeredMap) {
        Class cls = NSClassFromString(clsString);
        if ([cls conformsToProtocol:@protocol(MitDBProtocol)]) {
            //创建表
            [cls createTable];
        }
    }
}

- (NSMutableDictionary *)preRegisterTable {
    if (!_preRegisterTable) {
        _preRegisterTable = [NSMutableDictionary dictionary];
    }
    return _preRegisterTable;
}

- (NSMutableDictionary *)registeredMap {
    if (!_registeredMap) {
        _registeredMap = [NSMutableDictionary dictionary];
    }
    return _registeredMap;
}
@end
