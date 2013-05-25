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
#import <CoreBluetooth/CoreBluetooth.h>

@class YMSCBPeripheral;

typedef void (^YMSCBReadCallbackBlockType)(NSData *, NSError *);
typedef void (^YMSCBWriteCallbackBlockType)(NSError *);

/**
 Base class for defining a Bluetooth LE characteristic.
 
 YMSCBCharacteristic holds an instance of CBCharacteristic (cbCharacteristic).
 
 This class is typically instantiated by a subclass of YMSCBService. The property
 cbCharacteristic is set in [YMSCBService syncCharacteristics:]
 
 
 */
@interface YMSCBCharacteristic : NSObject

/** @name Properties */
/// Human-friendly name for this BLE characteristic.
@property (nonatomic, strong) NSString *name;

/// Characterisic CBUUID.
@property (nonatomic, strong) CBUUID *uuid;

/// Pointer to actual CBCharacterisic.
@property (nonatomic, strong) CBCharacteristic *cbCharacteristic;

/// Pointer to parent peripheral.
@property (nonatomic, weak) YMSCBPeripheral *parent;

/// Offset address value, if applicable.
@property (nonatomic, strong) NSNumber *offset;

/// Notification state callback
@property (nonatomic, strong) YMSCBWriteCallbackBlockType notificationStateCallback;

/// FIFO queue for reads
@property (nonatomic, strong) NSMutableArray *readCallbacks;

/// FIFO queue for reads
@property (nonatomic, strong) NSMutableArray *writeCallbacks;



- (void)executeNotificationStateCallback:(NSError *)error;
- (void)executeReadCallback:(NSData *)data error:(NSError *)error;
- (void)executeWriteCallback:(NSError *)error;

/** @name Initializing a YMSCBCharacteristic */
/**
 Constructor.

 @param oName characteristic name
 @param oUUID characteristic CBUUID
 @param addrOffset characteristic address offset
 */
- (id)initWithName:(NSString *)oName parent:(YMSCBPeripheral *)pObj uuid:(CBUUID *)oUUID offset:(int)addrOffset;



/** @name BLE Notification Methods */
/**
 Set notification value with respect to characteristic.
 
 @param notifyValue Set notification enable.
 
 */
- (void)setNotifyValue:(BOOL)notifyValue withBlock:(void (^)(NSError *error))writeCallback;


/** @name Write Request BLE Service Methods */
/**
 Request write value given characteristic name and execute callback block upon response.
 
 The callback block readCallback has one argument: `error`:
 
 * `error` is populated with the returned `error` object from the delegate method peripheral:didUpdateValueForCharacteristic:error:
 or peripheral:didWriteValueForCharacteristic:error: implemented in YMSCBPeripheral.
 
 @param data The value to be written
 @param writeCallback Callback block to execute upon response.
 
 */
- (void)writeValue:(NSData *)data withBlock:(void (^)(NSError *error))writeCallback;

/**
 Request write byte given characteristic name and execute callback block upon response.
 
 The callback block readCallback has one argument: `error`:
 
 * `error` is populated with the returned `error` object from the delegate method peripheral:didUpdateValueForCharacteristic:error:
 or peripheral:didWriteValueForCharacteristic:error: implemented in YMSCBPeripheral.
 
 @param val Byte value to be written
 @param writeCallback Callback block to execute upon response.
 
 */
- (void)writeByte:(int8_t)val withBlock:(void (^)(NSError *error))writeCallback;


/** @name Read Request BLE Service Methods */
/**
 Request read value given characteristic name and execute callback block upon response.
 
 The callback block readCallback has two arguments: `data` and `error`:
 
 * `data` is populated with the `value` property of [YMSCBCharacteristic cbCharacteristic].
 * `error` is populated with the returned `error` object from the delegate method peripheral:didUpdateValueForCharacteristic:error: implemented in YMSCBPeripheral.
 
 
 @param readCallback Callback block to execute upon response.
 */
- (void)readValueWithBlock:(void (^)(NSData *data, NSError *error))readCallback;



@end
