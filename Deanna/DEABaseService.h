//
//  DTSensorBTService.h
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "YMSCBUtils.h"

@class DEACharacteristic;

@interface DEABaseService : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) CBService *service;
@property (nonatomic, assign) yms_u128_t base;
@property (nonatomic, assign) BOOL isEnabled;

// Contains DTCharacteristic values
@property (nonatomic, strong) NSMutableDictionary *characteristicMap;

- (id)initWithName:(NSString *)oName;

- (void)addCharacteristic:(NSString *)cname withOffset:(int)addrOffset;

- (void)addCharacteristic:(NSString *)cname withAddress:(int)addr;

- (NSArray *)characteristics;

- (void)syncCharacteristics:(NSArray *)foundCharacteristics;

- (DEACharacteristic *)findCharacteristic:(CBCharacteristic *)ct;


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




@end
