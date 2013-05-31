//
// Copyright 2013 Yummy Melon Software LLC
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

#include "YMSCBUtils.h"
#include "TISensorTag.h"

/**
 Utility class for DEASensorTag.
 */


@interface DEASensorTagUtils : NSObject

/**
 Generate CBUUID string given base of type yms_u128_t and offset of type int
 
 This method is used in place of [YMSCBUtils genCBUUID:withIntOffset:] due to
 the peculiar way (IMHO) the TI SensorTag 128-bit address map is setup:
 Offset values are put into the 96th bit position of a 128-bit address.
 
 @param base base address
 @param addrOffset offset value
 @return CBUUID string
 */
+ (NSString *)genCBUUID:(yms_u128_t *)base withIntOffset:(int)addrOffset;

/**
 Generate CBUUID given base of type yms_u128_t and offset of type int
 
 This method is used in place of [YMSCBUtils genCBUUID:withIntOffset:] due to
 the peculiar way (IMHO) the TI SensorTag 128-bit address map is setup:
 Offset values are put into the 96th bit position of a 128-bit address.
 
 @param base base address
 @param addrOffset offset value
 @return CBUUID generated from base and addOffset
 */
+ (CBUUID *)createCBUUID:(yms_u128_t *)base withIntOffset:(int)addrOffset;
@end
