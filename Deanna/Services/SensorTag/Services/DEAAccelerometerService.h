// 
// Copyright 2013-2014 Yummy Melon Software LLC
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


#import "DEABaseService.h"

/**
 TI SensorTag CoreBluetooth service definition for accelerometer.
 */
@interface DEAAccelerometerService : DEABaseService

/**
 Inherited property of DEABaseService.
 Keys: @"x", @"y" and @"z".
 */
@property (nonatomic, readonly) NSDictionary *sensorValues;

/// x value
@property (nonatomic, strong, readonly) NSNumber *x;
/// y value
@property (nonatomic, strong, readonly) NSNumber *y;
/// z value
@property (nonatomic, strong, readonly) NSNumber *z;

/// Period
@property (nonatomic, strong, readonly) NSNumber *period;

/**
 Configure accelerometer period.
 
 @param value unsigned byte value to set period
 */
- (void)configPeriod:(uint8_t)value;

/**
 Read accelerometer period.
 */
- (void)requestReadPeriod;

@end
