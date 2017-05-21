//
//  CPDViewController.m
//  PROJECT
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright (c) TODAYS_YEAR PROJECT_OWNER. All rights reserved.
//

#import "CPDViewController.h"
#import "MITDBTestModelTwo.h"
#import "MITDBTestModel.h"
@interface CPDViewController ()

@end

@implementation CPDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    MITDBTestModelTwo * mo = [[MITDBTestModelTwo alloc]init];
    mo.uuid = @"111";
    mo.pp = @"22";
    mo.sexy = @"yes";
    [mo save];
    
    MITDBTestModel * mol = [MITDBTestModel new];
    mol.name = @"asfdljh";
    mol.age = 233;
    mol.psd = @"12asdfasdf";
    mol.uid = @"asdfsafd";
    mol.email = @"444444@aaaa.com";
    [mol save];
    [mol saveWithTabName:@"tableTwo"];
    
}
@end
