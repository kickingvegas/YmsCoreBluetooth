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


#import <UIKit/UIKit.h>
@class DEASensorTag;
@class DEAMagnetometerService;

/**
 View and control logic for the SensorTag magenetometer service.
 */
@interface DEAMagnetometerViewCell : UITableViewCell

@property (strong, nonatomic) DEAMagnetometerService *service;

/// Enable notification
@property (strong, nonatomic) IBOutlet UISwitch *notifySwitch;

/// X label
@property (strong, nonatomic) IBOutlet UILabel *xLabel;
/// Y label
@property (strong, nonatomic) IBOutlet UILabel *yLabel;
/// Z label
@property (strong, nonatomic) IBOutlet UILabel *zLabel;
/// Calibration button
@property (strong, nonatomic) IBOutlet UIButton *calibrateButton;

/**
 Action method to handle notifySwitch toggle.
 
 @param sender notifySwitch UI component.
 */
- (IBAction)notifySwitchAction:(id)sender;

/**
 Action method to handle calibrateButton
 
 @param sender calibrateButton
 */
- (IBAction)calibrateButtonAction:(id)sender;

/**
 Configure this class to use sensorTag.
 
 @param sensorTag Peripheral containing service to be used by this UI component.
 */
- (void)configureWithSensorTag:(DEASensorTag *)sensorTag;

/**
 Deconfigure this class to not use sensorTag.
 */
- (void)deconfigure;


@end
