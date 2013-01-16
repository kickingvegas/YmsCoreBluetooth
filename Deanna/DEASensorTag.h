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

@class DEABaseCBService;

@interface DEASensorTag : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) NSDictionary *sensorServices;
@property (nonatomic, assign) yms_u128_t base;

- (NSArray *)services;

- (DEABaseCBService *)findService:(CBService *)service;

@end

