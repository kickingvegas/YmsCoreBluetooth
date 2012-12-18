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


@class DTSensorConfig;


@interface DTSensorTag : NSObject <CBPeripheralDelegate>


@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) NSDictionary *sensorConfigs;
@property (nonatomic, assign) yms_u128_t base;

- (NSArray *)services;

- (DTSensorConfig *)getConfigFromService:(CBService *)service;

- (void)addPeripheralsObject:(id)object;

- (void)removeObjectFromPeripheralsAtIndex:(NSUInteger)index;


@end

