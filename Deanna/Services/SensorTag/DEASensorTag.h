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

#import "YMSCBPeripheral.h"

@class DEAAccelerometerService;
@class DEABarometerService;
@class DEADeviceInfoService;
@class DEAGyroscopeService;
@class DEAHumidityService;
@class DEAMagnetometerService;
@class DEASimpleKeysService;
@class DEATemperatureService;

/**
 TI SensorTag Peripheral Class.
 
 This class maps to an instance of a CBPeripheral associated with a found TI SensorTag.
 */
@interface DEASensorTag : YMSCBPeripheral

/// Convenience pointer to accelerometer service.
@property (nonatomic, readonly) DEAAccelerometerService *accelerometer;
/// Convenience pointer to barometer service.
@property (nonatomic, readonly) DEABarometerService *barometer;
/// Convenience pointer to device information service.
@property (nonatomic, readonly) DEADeviceInfoService *devinfo;
/// Convenience pointer to gyroscope service.
@property (nonatomic, readonly) DEAGyroscopeService *gyroscope;
/// Convenience pointer to humidity service.
@property (nonatomic, readonly) DEAHumidityService *humidity;
/// Convenience pointer to magnetometer service.
@property (nonatomic, readonly) DEAMagnetometerService *magnetometer;
/// Convenience pointer to simple keys service.
@property (nonatomic, readonly) DEASimpleKeysService *simplekeys;
/// Convenience pointer to temperature service.
@property (nonatomic, readonly) DEATemperatureService *temperature;

@end
