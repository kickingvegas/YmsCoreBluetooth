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

#import "YMSCBUtils.h"

@class YMSCBPeripheral;

/**
 Base class for defining a Bluetooth LE descriptor.
 
 YMSCBDescriptor holds an instance of CBDescriptor (cbDescriptor).
 
 The implementation of this class is TBD.
 */
@interface YMSCBDescriptor : NSObject

/// Pointer to actual CBDescriptor
@property (atomic, strong) CBDescriptor *cbDescriptor;

/// Descriptor UUID
@property (atomic, readonly) CBUUID *UUID;

/// Pointer to parent peripheral.
@property (atomic, weak) YMSCBPeripheral *parent;

/**
 FIFO queue for reads.
 
 Each element is a block of type YMSCBReadCallbackBlockType.
 */
@property (atomic, strong) NSMutableArray *readCallbacks;

/**
 FIFO queue for writes.
 
 Each element is a block of type YMSCBWriteCallbackBlockType.
 */
@property (atomic, strong) NSMutableArray *writeCallbacks;


/** @name Issuing a Write Request */
/**
 
 Issue write with value data and execute callback block writeCallback upon response.
 
 The callback block writeCallback has one argument: `error`:
 
 * `error` is populated with the returned `error` object from the delegate method
 peripheral:didWriteValueForCharacteristic:error: implemented in YMSCBPeripheral.
 
 @param data The value to be written
 @param writeCallback Callback block to execute upon response.
 
 */
- (void)writeValue:(NSData *)data withBlock:(void (^)(NSError *error))writeCallback;

/**
 Issue write with byte val and execute callback block writeCallback upon response.
 
 The callback block writeCallback has one argument: `error`:
 
 * `error` is populated with the returned `error` object from the delegate method
 peripheral:didWriteValueForCharacteristic:error: implemented in YMSCBPeripheral.
 
 @param val Byte value to be written
 @param writeCallback Callback block to execute upon response.
 
 */
- (void)writeByte:(int8_t)val withBlock:(void (^)(NSError *error))writeCallback;


/** @name Issuing a Read Request */
/**
 Issue read and execute callback block readCallback upon response.
 
 The callback block readCallback has two arguments: `data` and `error`:
 
 * `data` is populated with the `value` property of [YMSCBCharacteristic cbCharacteristic].
 * `error` is populated with the returned `error` object from the delegate method peripheral:didUpdateValueForCharacteristic:error: implemented in YMSCBPeripheral.
 
 
 @param readCallback Callback block to execute upon response.
 */
- (void)readValueWithBlock:(void (^)(NSData *data, NSError *error))readCallback;

/** @name Callback Handler Methods */
/**
 Handler method to process first callback in readCallbacks.
 
 @param data Value returned from read request.
 @param error Error object, if failed.
 */
- (void)executeReadCallback:(NSData *)data error:(NSError *)error;

/**
 Handler method to process first callback in writeCallbacks.
 
 @param error Error object, if failed.
 */
- (void)executeWriteCallback:(NSError *)error;



@end
