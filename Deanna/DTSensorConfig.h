//
//  DTSensorConfig.h
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#include "YMSCBUtils.h"
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DTSensorConfig : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSString *config;

@property (nonatomic, strong) CBPeripheral *peripheral;

//@property (nonatomic, strong) NSString *period;
//@property (nonatomic, strong) NSString *calibration;


//- (NSString *)genCBUUIDString:(int)offsetConstant withBase:(yms_u128_t *)base;

- (CBUUID *)genCBUUID:(NSString *)key;

- (NSArray *)genCharacteristics;

- (id)initWithBase:(yms_u128_t *)base;

- (BOOL)isMatchToService:(CBService *)svc;

- (BOOL)isMatchToCharacteristic:(CBCharacteristic *)ct withKey:(NSString *)key;

- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;


@end
