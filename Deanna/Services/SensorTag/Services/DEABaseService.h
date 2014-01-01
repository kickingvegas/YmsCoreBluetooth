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

#import "YMSCBService.h"
#include "TISensorTag.h"
/**
 Base class for defining a CoreBluetooth service for a TI SensorTag. 
 */
@interface DEABaseService : YMSCBService


/**
 Dictionary containing the values measured by the sensor.
 
 This is an abstract propery.
 */
@property (nonatomic, readonly) NSDictionary *sensorValues;

/**
 Turn on CoreBluetooth peripheral service.
 
 This method turns on the service by:
 
 *  writing to *config* characteristic to enable service.
 *  writing to *data* characteristic to enable notification.
 
 */
- (void)turnOn;


/**
 Turn off CoreBluetooth peripheral service.
 
 This method turns off the service by:
 
 *  writing to *config* characteristic to disable service.
 *  writing to *data* characteristic to disable notification.
 
 */
- (void)turnOff;


@end
