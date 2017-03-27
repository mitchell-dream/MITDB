//
//  MitDBHandleTest.m
//  MitDBHandleTest
//
//  Created by MENGCHEN on 2017/3/24.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MITDBTestModel.h"

@interface MitDBHandleTest : XCTestCase

@end

@implementation MitDBHandleTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
    }];
}

- (void)testSaveModelWithTransaction{
//    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
//    [self measureBlock:^{
//        for (int i = 0; i<999; i++) {
//            MITDBTestModel * mol = [MITDBTestModel new];
//            mol.name = [NSString stringWithFormat:@"%d",i];
//            mol.age = i;
//            [arr addObject:mol];
//        }
//        [MITDBTestModel save:arr param:nil inTransaction:true];
//    }];
    
    
}
- (void)testSaveModelWithOutTransaction{
//    [self measureBlock:^{
//        for (int i = 0; i<999; i++) {
//            MITDBTestModel * mol = [MITDBTestModel new];
//            mol.name = [NSString stringWithFormat:@"%d",i];
//            mol.age = i;
//            [mol save];
//        }
//    }];
    
}


- (void)testDefaultSearch{
    MitDBParam * pa =[MitDBParam new];
//    pa.where(@"name").equal(@"a").OR().propertyName(@"email").equal(@"123@qq.com");
    pa.where(@"name").equal(@"a").AND().propertyName(@"email").equal(@"123@qq.com");
    [MITDBTestModel selectWithParam:pa completion:^(NSArray *arr) {
       
        
    }];

//    pa.where().propertyNames(@[@"name",@"email"]).values(@[@"123",@"aaa"]);
    NSLog(@"aaaaaaa = %@",pa.conditionSql);
}

@end
