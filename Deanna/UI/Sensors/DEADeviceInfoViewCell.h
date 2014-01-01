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

#import "DEAPeripheralTableViewCell.h"
@class DEADeviceInfoService;
@class DEASensorTag;


/**
 View and control logic for the SensorTag device information service.
 */
@interface DEADeviceInfoViewCell : UITableViewCell
@property (strong, nonatomic) DEADeviceInfoService *service;

/** @name Properties */
/// List of keys
@property (nonatomic, strong) NSArray *keyList;

/// System ID
@property (strong, nonatomic) IBOutlet UILabel *system_idLabel;
/// Model Number
@property (strong, nonatomic) IBOutlet UILabel *model_numberLabel;
/// Serial Number
@property (strong, nonatomic) IBOutlet UILabel *serial_numberLabel;
/// Firmware Revision
@property (strong, nonatomic) IBOutlet UILabel *firmware_revLabel;
/// Hardware Revision
@property (strong, nonatomic) IBOutlet UILabel *hardware_revLabel;
/// Software Revision
@property (strong, nonatomic) IBOutlet UILabel *software_revLabel;
/// Manufacturer Name
@property (strong, nonatomic) IBOutlet UILabel *manufacturer_nameLabel;
/// IEEE 11073-20601 Regulatory Certification Data List
@property (strong, nonatomic) IBOutlet UILabel *ieee11073_cert_dataLabel;

/**
 Bind UI components to service of interest in sensorTag.
 
 @param sensorTag Peripheral instance of SensorTag.
 */
- (void)configureWithSensorTag:(DEASensorTag *)sensorTag;

/**
 Unbind UI components to service.
 */
- (void)deconfigure;

@end
