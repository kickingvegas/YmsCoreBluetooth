//
//  DTSensorTag.h
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include "YMSCBUtils.h"

@class YMSCBService;


/**
 TI SensorTag object.
 */
@interface YMSCBPeripheral : NSObject <CBPeripheralDelegate>

/// 128 bit address base
@property (nonatomic, assign) yms_u128_t base;

/// Hold (key, value) pairs of (NSString, YMSCBService) instances
@property (nonatomic, strong) NSDictionary *sensorServices;

/// Pointer to CBPeripheral instance of a sensor tag.
@property (nonatomic, strong) CBPeripheral *cbPeriperheral;

@property (nonatomic, assign) BOOL shouldPingRSSI;

- (id)initWithPeripheral:(CBPeripheral *)peripheral;

/**
 Generate array of CBUUID for all SensorTag CoreBluetooth services.
 @return array of CBUUID services
 */
- (NSArray *)services;
- (YMSCBService *)findService:(CBService *)service;
- (void)updateRSSI;

@end

