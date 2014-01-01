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
 TI SensorTag CoreBluetooth service definition for device information.
 */
@interface DEADeviceInfoService : YMSCBService

/** @name Properties */
/// System ID
@property (nonatomic, strong) NSString *system_id;
/// Model Number
@property (nonatomic, strong) NSString *model_number;
/// Serial Number
@property (nonatomic, strong) NSString *serial_number;
/// Firmware Revision
@property (nonatomic, strong) NSString *firmware_rev;
/// Hardware Revision
@property (nonatomic, strong) NSString *hardware_rev;
/// Software Revision
@property (nonatomic, strong) NSString *software_rev;
/// Manufacturer Name
@property (nonatomic, strong) NSString *manufacturer_name;
/// IEEE 11073 Certification Data
@property (nonatomic, strong) NSString *ieee11073_cert_data;

/** @name Read Device Information */
/**
 Issue set of read requests to obtain device information which is store in the class properties.
 */
- (void)readDeviceInfo;

@end
