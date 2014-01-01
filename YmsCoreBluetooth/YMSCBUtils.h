// 
// Copyright 2013-2014 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif

#include "YMS128.h"


#ifndef _YMS_PERFORM_ON_MAIN_THREAD
#define _YMS_PERFORM_ON_MAIN_THREAD(block) dispatch_async(dispatch_get_main_queue(), block);
#endif

/**
 Utility class for YMS CoreBluetooth Framework
 */
@interface YMSCBUtils : NSObject

/**
 Generate CBUUID string given base and offset of type yms_u128_t

 @param base base address
 @param offset offset value
 @return CBUUID string
 */
+ (NSString *)genCBUUID:(yms_u128_t *)base withOffset:(yms_u128_t *)offset;

/**
 Generate CBUUID string given base of type yms_u128_t and offset of type int
 
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
 @return CBUUID generated from base and addOffset
 */
+ (CBUUID *)createCBUUID:(yms_u128_t *)base withIntOffset:(int)addrOffset;

/**
 Generate CBUUID string given base of type yms_u128_t and BLE offset of type int
 
 This is written to comply with the Bluetooth Specification Version 4.0 [Vol. 3] Section 3.2.1 where:
 
     128-Bit UUID = 16-bit Attribute UUID * pow(2,96) + Bluetooth_Base_UUID

 
 @param base base address
 @param addrOffset offset value
 @return CBUUID string
 */
+ (NSString *)genCBUUID:(yms_u128_t *)base withIntBLEOffset:(int)addrOffset;


/**
 Generate CBUUID given base and BLE offset of type yms_u128_t
 
 This is written to comply with the Bluetooth Specification Version 4.0 [Vol. 3] Section 3.2.1 where:
 
    128-Bit UUID = 16-bit Attribute UUID * pow(2,96) + Bluetooth_Base_UUID

 
 @param base base address
 @param offset offset value
 @return CBUUID
 */
+ (CBUUID *)createCBUUID:(yms_u128_t *)base withIntBLEOffset:(int)addrOffset;


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
