//
// Copyright 2013 Yummy Melon Software LLC
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
 TI SensorTag CoreBluetooth service definition for barometer.
 */
@interface DEABarometerService : DEABaseService

@property (nonatomic, assign) BOOL isCalibrating;

@property (nonatomic, assign) BOOL isCalibrated;

/// Calibration point
@property (nonatomic, assign) uint16_t c1;
/// Calibration point
@property (nonatomic, assign) uint16_t c2;
/// Calibration point
@property (nonatomic, assign) uint16_t c3;
/// Calibration point
@property (nonatomic, assign) uint16_t c4;
/// Calibration point
@property (nonatomic, assign) int16_t c5;
/// Calibration point
@property (nonatomic, assign) int16_t c6;
/// Calibration point
@property (nonatomic, assign) int16_t c7;
/// Calibration point
@property (nonatomic, assign) int16_t c8;

/// Pressure measurement
@property (nonatomic, strong) NSNumber *pressure;

/// Ambient temperature measurement
@property (nonatomic, strong) NSNumber *ambientTemp;

/**
 Request calibration of barometer.
 */
- (void)requestCalibration;



@end
