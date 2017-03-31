//
//  MITDBTestModel.h
//  MitDB
//
//  Created by MENGCHEN on 2017/3/24.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MITDB/MitDBProtocal.h>

@interface MITDBTestModel : NSObject<MitDBProtocal>
/**  <#Description#>*/
@property(nonatomic, strong)NSString * name;
/**  <#Description#>*/
@property(nonatomic, assign)NSInteger age;
/**  <#Description#>*/
@property(nonatomic, strong)NSString * email;
/**  <#Description#>*/
@property(nonatomic, strong)NSString * psd;
@property(nonatomic, strong)NSString * uid;

@end
