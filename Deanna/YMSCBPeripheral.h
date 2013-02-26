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
 Container class for CBPeripheral. 
 */
@interface YMSCBPeripheral : NSObject <CBPeripheralDelegate>

/// 128 bit address base
@property (nonatomic, assign) yms_u128_t base;

/// Hold (key, value) pairs of (NSString, YMSCBService) instances
@property (nonatomic, strong) NSDictionary *sensorServices;

/// Pointer to CBPeripheral instance of a sensor tag.
@property (nonatomic, strong) CBPeripheral *cbPeriperheral;

/// If ON, enable updates of RSSI.
@property (nonatomic, assign) BOOL shouldPingRSSI;

/**
 Constructor 
 
 @param peripheral class
 */
- (id)initWithPeripheral:(CBPeripheral *)peripheral;

/**
 Generate array of CBUUID for all SensorTag CoreBluetooth services.
 
 The output of this method is to be passed to [CBPeripheral discoverServices:]
 
 @return array of CBUUID services
 */
- (NSArray *)services;

/**
 Find YMSCBService given its corresponding CBService.
 
 @param service this thing
 @return YMSCBService
 */
- (YMSCBService *)findService:(CBService *)service;

/**
 Request RSSI update from CBPeripheral.
 */
- (void)updateRSSI;

@end

