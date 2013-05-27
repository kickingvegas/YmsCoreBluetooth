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


@property (nonatomic, readonly) DEAAccelerometerService *accelerometer;
@property (nonatomic, readonly) DEABarometerService *barometer;
@property (nonatomic, readonly) DEADeviceInfoService *devinfo;
@property (nonatomic, readonly) DEAGyroscopeService *gyroscope;
@property (nonatomic, readonly) DEAHumidityService *humidity;
@property (nonatomic, readonly) DEAMagnetometerService *magnetometer;
@property (nonatomic, readonly) DEASimpleKeysService *simplekeys;
@property (nonatomic, readonly) DEATemperatureService *temperature;

@end
