# MITDB
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

