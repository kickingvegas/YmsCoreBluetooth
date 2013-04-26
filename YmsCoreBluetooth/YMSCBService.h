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
#import "YMSCBUtils.h"
@class YMSCBCharacteristic;

/**
 Base class for TI SensorTag CoreBluetooth service definition.
 */

@interface YMSCBService : NSObject

/// name of service
@property (nonatomic, strong) NSString *name;

/// pointer to CBService
@property (nonatomic, strong) CBService *cbService;

/// 128 bit base address struct
@property (nonatomic, assign) yms_u128_t base;

/** CoreBluetooth service is on */
@property (nonatomic, assign) BOOL isOn;

/** CoreBluetooth characteristics are synchronized */
@property (nonatomic, assign) BOOL isEnabled;

/// Holds (key, value pairs of (NSString, YMSCBCharacteristic) instances
@property (nonatomic, strong) NSMutableDictionary *characteristicDict;

/**
 Initialize class instance.
 @param oName name of service
 @param hi top 64 bits of 128-bit base address value
 @param lo bottom 64 bits of 128-bit base address value
 @return YMSCBCharacteristic
 */
- (id)initWithName:(NSString *)oName
            baseHi:(int64_t)hi
            baseLo:(int64_t)lo;

/**
 Add YMSCBCharacteristic instance given address offset.
 @param cname characteristic name
 @param addrOffset offset value
 */
- (void)addCharacteristic:(NSString *)cname withOffset:(int)addrOffset;

/**
 Add YMSCBCharacteristic instance given address offset.
 @param cname characteristic name
 @param addr offset value
 */
- (void)addCharacteristic:(NSString *)cname withAddress:(int)addr;

/**
 Return array of CBUUIDs for all YMSCBCharacteristic instances in characteristicDict.
 */
- (NSArray *)characteristics;

/**
 Synchronize found CBCharacteristics with corresponding YMSCBCharacteristic containers.
 
 @param foundCharacteristics array of CBCharacteristics
 */
- (void)syncCharacteristics:(NSArray *)foundCharacteristics;


/**
 Find characteristic container for CBCharacteristic.
 
 @param ct CBCharacteristic 
 @return container of ct
 */
- (YMSCBCharacteristic *)findCharacteristic:(CBCharacteristic *)ct;


/**
 Set notification value with respect to characteristic.
 
 @param notifyValue Set notification enable.
 @param characteristic CBCharacteristic to be notified of.
 
 */
- (void)setNotifyValue:(BOOL)notifyValue forCharacteristic:(CBCharacteristic *)characteristic;

/**
 Set notification value with respect to characteristic name.
 
 @param notifyValue Set notification enable.
 @param cname Name of CBCharacteristic to be notified of.
 */
- (void)setNotifyValue:(BOOL)notifyValue forCharacteristicName:(NSString *)cname;

/**
 Write value with respect to characteristic.
 
 @param data Data to be written.
 @param characteristic CBCharacteristic to be notified of.
 @param type The type of write to be executed.
 */
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;

/**
 Write value with respect to characteristic name.
 
 @param data Data to be written.
 @param cname Name of CBCharacteristic to be notified of.
 @param type The type of write to be executed.
 */
- (void)writeValue:(NSData *)data forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type;

/**
 Write byte with respect to characteristic name.
 
 @param val Byte value to be written.
 @param cname Name of CBCharacteristic to be notified of.
 @param type The type of write to be executed.
 */
- (void)writeByte:(int8_t)val forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type;

/**
 Read value with respect to characteristic.
 
 @param characteristic CBCharacteristic to be notified of.
 */
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;

/**
 Read value with respect to characteristic name.
 
 @param cname Name of CBCharacteristic to be notified of.
 */
- (void)readValueForCharacteristicName:(NSString *)cname;

/**
 Request a read of the *config* characteristic.
 */
- (void)requestConfig;

/**
 Return value of the *config* characteristic.

 @returns data of *config* characteristic.
 */
- (NSData *)responseConfig;

/**
 Turn on CoreBluetooth peripheral service.
 
 This method turns on the service by:
 
 *  writing to *config* characteristic to enable service.
 *  writing to *data* characteristic to enable notification.
 
 */
- (void)turnOn;


/**
 Turn off CoreBluetooth peripheral service.
 
 This method turns off the service by:
 
 *  writing to *config* characteristic to disable service.
 *  writing to *data* characteristic to disable notification.
 
 */
- (void)turnOff;

/**
 Method to handle response update for a prior read or write request to a characteristic.  
 This method is invoked by [YMSCBPeripheral peripheral:didUpdateValueForCharacteristic:error:]
 **This method must be overridden**.

 @param yc Characteristic receiving update.
 
 */
- (void)updateCharacteristic:(YMSCBCharacteristic *)yc;

@end
