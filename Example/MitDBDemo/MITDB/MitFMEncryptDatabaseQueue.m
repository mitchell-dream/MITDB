//
//  MitFMEncryptDatabaseQueue.m
//  AudioDemo
//
//  Created by MENGCHEN on 2017/2/9.
//  Copyright © 2017年 MENGCHEN. All rights reserved.
//

#import "MitFMEncryptDatabaseQueue.h"
#import "MitFMEncryptDatabase.h"
@implementation MitFMEncryptDatabaseQueue

+(Class)databaseClass{
    return [MitFMEncryptDatabase class];
}

@end

