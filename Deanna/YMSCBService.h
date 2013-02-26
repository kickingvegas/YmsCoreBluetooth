//
//  YMSCBService.h
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
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
@property (nonatomic, strong) NSMutableDictionary *characteristicMap;

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
 Return array of YMSCBCharacteristic instances.
 */
- (NSArray *)characteristics;

/**
 Synchronize found CBCharacteristics with corresponding YMSCBCharacteristic containers.
 
 @param foundCharacteristics array of CBCharacteristics
 */
- (void)syncCharacteristics:(NSArray *)foundCharacteristics;

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

- (void)update;

@end
