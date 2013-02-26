//
//  DTAccelerometerBTService.h
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "YMSCBService.h"

/**
 TI SensorTag CoreBluetooth service definition for accelerometer.
 */
@interface DEAAccelerometerService : YMSCBService

@property (nonatomic, strong) NSNumber *x;
@property (nonatomic, strong) NSNumber *y;
@property (nonatomic, strong) NSNumber *z;

@end
