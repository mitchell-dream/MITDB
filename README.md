# MITDB

[![CI Status](http://img.shields.io/travis/mcmengchen/MITDB.svg?style=flat)](https://travis-ci.org/mcmengchen/MITDB)
[![Version](https://img.shields.io/cocoapods/v/MITDB.svg?style=flat)](http://cocoapods.org/pods/MITDB)
[![License](https://img.shields.io/cocoapods/l/MITDB.svg?style=flat)](http://cocoapods.org/pods/MITDB)
[![Platform](https://img.shields.io/cocoapods/p/MITDB.svg?style=flat)](http://cocoapods.org/pods/MITDB)

# Introduce 
+ MITDB is again of FMDB encapsulation which add ORM,database migration and database encryption function.
+ MITDB is for object-oriented model of database operations
+ MITDB use protocol named MitDBProtocal to add function into model without infestation.
+ MITDB increase the chain programming to create data updating and query function.
+ MITDB use MitDBMigrationHandle and MitDBMigration to perform the function of database migration.
+ MITDB use MitFMEncryptDatabase and MitFMEncryptDatabaseQueue to add database encryption function.
+ MITDB use NSObject+MitDBHandle to perfrom IDUS operations.
# Integration MITDB to your project
+ Recommended：
```
pod 'MITDB'
```

# How to use MITDB
+ Use 
```
//Your model
#import <Foundation/Foundation.h>
#import <MITDB/MitDBProtocal.h>
@interface MITDBTestModel : NSObject<MitDBProtocal>
@property(nonatomic, strong)NSString * name;
@property(nonatomic, assign)NSInteger age;
@property(nonatomic, strong)NSString * email;
@property(nonatomic, strong)NSString * psd;
@property(nonatomic, strong)NSString * uid;
@end
#import "MITDBTestModel.h"
@implementation MITDBTestModel
@end
//Insert
MITDBTestModel * mol = [MITDBTestModel new];
mol.name = @"save";
[mol save];
//Update
mol.name = @"update";
[mol update];
//Delete
[mol remove];
//Select
[MITDBTestModel selectAllCompletion:^(NSArray *arr) {
    NSLog(@"%@",arr);
}];
```
+ Define your primary key：
```
+ (NSString *)primaryKey{
    return @"uid";
}
```
+ Define your keys which need to be ignored
```
+ (NSArray *)ignoreKeys{
    return @[@"name",@"age"];
}
```
+ Use MitDBParam to joining together the query string.
```
MitDBParam * pa =[MitDBParam new];
pa.where(@"name").equal(@"a").AND().propertyName(@"email").equal(@"123@qq.com");
[MITDBTestModel selectWithParam:pa completion:^(NSArray *arr) {
    //result
}];
```

---

# 介绍 
+ MITDB 是对 FMDB 的二次封装，添加了 ORM 功能，数据库迁移功能和数据库加密功能。
+ MITDB 针对的是面向对象模型的数据库操作。
+ MITDB 通过 MitDBProtocal 轻量级的协议引用方式到模型中，无侵染性。
+ MITDB 通过 MitDBParam 增加了链式编程创建数据的更新与查询语句。
+ MITDB 通过 MitDBMigrationHandle 与 MitDBMigration 类来添加数据库迁移功能。
+ MITDB 通过 MitFMEncryptDatabase 与 MitFMEncryptDatabaseQueue 来添加数据库加密功能。
+ MITDB 通过 NSObject+MitDBHandle 类来进行增删改查的操作。

# 集成 MITDB
+ 推荐：
```
pod 'MITDB'
```

# 使用 MITDB
+ 简单使用
```
//自定义模型
#import <Foundation/Foundation.h>
#import <MITDB/MitDBProtocal.h>
@interface MITDBTestModel : NSObject<MitDBProtocal>
@property(nonatomic, strong)NSString * name;
@property(nonatomic, assign)NSInteger age;
@property(nonatomic, strong)NSString * email;
@property(nonatomic, strong)NSString * psd;
@property(nonatomic, strong)NSString * uid;
@end
#import "MITDBTestModel.h"
@implementation MITDBTestModel
@end
//增加
MITDBTestModel * mol = [MITDBTestModel new];
mol.name = @"save";
[mol save];
//更新
mol.name = @"update";
[mol update];
//删除
[mol remove];
//查询
[MITDBTestModel selectAllCompletion:^(NSArray *arr) {
    NSLog(@"%@",arr);
}];
```
+ 自定义主键：
```
+ (NSString *)primaryKey{
    return @"uid";
}
```
+ 自定义忽略属性
```
+ (NSArray *)ignoreKeys{
    return @[@"name",@"age"];
}
```
+ 借助 MitDBParam 拼接自定义查询语句
```
MitDBParam * pa =[MitDBParam new];
pa.where(@"name").equal(@"a").AND().propertyName(@"email").equal(@"123@qq.com");
[MITDBTestModel selectWithParam:pa completion:^(NSArray *arr) {
    //查询结果
}];
```

