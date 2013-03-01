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

///

/// Holds (key, value pairs of (NSString, YMSCBCharacteristic) instances
@property (nonatomic, strong) NSMutableDictionary *characteristicDict;

/**
 Initialize class instance.
 @param oName name of service
 @return YMSCBCharacteristic
 */
- (id)initWithName:(NSString *)oName;

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


- (void)setNotifyValue:(BOOL)notifyValue forCharacteristic:(CBCharacteristic *)characteristic;

- (void)setNotifyValue:(BOOL)notifyValue forCharacteristicName:(NSString *)cname;


- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;

- (void)writeValue:(NSData *)data forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type;

- (void)writeByte:(int8_t)val forCharacteristicName:(NSString *)cname type:(CBCharacteristicWriteType)type;

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;
- (void)readValueForCharacteristicName:(NSString *)cname;

- (void)requestConfig;
- (NSData *)responseConfig;


- (void)turnOn;
- (void)turnOff;

- (void)updateCharacteristic:(YMSCBCharacteristic *)yc;

@end
