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

@interface DEASensorTag : NSObject <CBPeripheralDelegate>

@property (nonatomic, assign) yms_u128_t base;
@property (nonatomic, strong) NSDictionary *sensorServices;
@property (nonatomic, strong) CBPeripheral *cbPeriperheral;

- (id)initWithPeripheral:(CBPeripheral *)peripheral;
- (NSArray *)services;
- (YMSCBService *)findService:(CBService *)service;

@end

