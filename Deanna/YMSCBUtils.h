//
//  YMSCBUtils.h
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include "TISensorTag.h"

@interface YMSCBUtils : NSObject

+ (NSString *)genCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset;

+ (NSString *)genCBUUID:(yms_u128_t *)base withIntOffset:(int)addrOffset;

+ (CBUUID *)createCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset;

+ (CBUUID *)createCBUUID:(yms_u128_t *)base withIntOffset:(int)addrOffset;

@end
