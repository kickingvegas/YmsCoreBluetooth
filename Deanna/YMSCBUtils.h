//
//  YMSCBUtils.h
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include "TISensorTag.h"

/**
 Utility class for YMS CoreBluetooth Framework
 */
@interface YMSCBUtils : NSObject

/**
 Generate CBUUID given base and offset of type yms_u128_t

 @param base base address
 @param offset offset value
 @return CBUUID string
 */
+ (NSString *)genCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset;

/**
 Generate CBUUID given base of type yms_u128_t and offset of type int
 
 @param base base address
 @param addrOffset offset value
 @return CBUUID string
 */
+ (NSString *)genCBUUID:(yms_u128_t *)base withIntOffset:(int)addrOffset;

/**
 Generate CBUUID given base and offset of type yms_u128_t
 
 @param base base address
 @param offset offset value
 @return CBUUID
 */
+ (CBUUID *)createCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset;

/**
 Generate CBUUID given base of type yms_u128_t and offset of type int

 @param base base address
 @param addrOffset offset value
 @return CBUUID string
 */
+ (CBUUID *)createCBUUID:(yms_u128_t *)base withIntOffset:(int)addrOffset;

/**
 Convert data to byte
 @param data data to convert
 @return 8-bit integer
 */
+ (int8_t)dataToByte:(NSData *)data;

/**
 Convert data to 16-bit integer
 @param data data to convert
 @return 16-bit integer

 */
+ (int16_t)dataToInt16:(NSData *)data;

/**
 Convert data to 32-bit integer
 @param data data to convert
 @return 32-bit integer
 */
+ (int32_t)dataToInt32:(NSData *)data;

@end
