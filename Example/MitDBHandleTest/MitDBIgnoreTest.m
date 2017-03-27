//
//  MitDBIgnoreTest.m
//  MitDB
//
//  Created by MENGCHEN on 2017/3/25.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MITDBTestModel.h"
#import "MITDBTestModelTwo.h"

@interface MitDBIgnoreTest : XCTestCase

@end

@implementation MitDBIgnoreTest

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
//    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testSaveIgnore{
    [self measureBlock:^{
        for (int i = 0; i<5; i++) {
            MITDBTestModel * mol = [MITDBTestModel new];
            mol.name = [NSString stringWithFormat:@"%d",i];
            mol.age = i;
            mol.email = @"444@qq.com";
            mol.psd = @"123456";
            [mol save];
        }
    }];
}

- (void)testSearchData{
    [self measureBlock:^{
       [MITDBTestModel selectAllCompletion:^(NSArray *arr) {
           NSLog(@"%@",arr);
       }];
    }];
}

- (void)testUpdateData{
    __block MITDBTestModel * mol = nil;
    [MITDBTestModel selectAllCompletion:^(NSArray *arr) {
        mol = arr.firstObject;
    }];
    mol.email = @"111@qq.com";
    [mol update];
}

- (void)testRemove{
    __block MITDBTestModel * mol = nil;
    [MITDBTestModel selectAllCompletion:^(NSArray *arr) {
        mol = arr.firstObject;
    }];
    mol.email = @"111@qq.com";
    [mol remove];
}




- (void)testWithoutIgnore{
//    [self measureBlock:^{
//        for (int i = 0; i<9; i++) {
//            MITDBTestModelTwo * mol = [MITDBTestModelTwo new];
//            mol.uuid = @"asdf";
//            mol.pp = [NSString stringWithFormat:@"%d",i];
//            mol.sexy = @"sex";
//            [mol save];
//        }
//    }];
}


- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
