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

#import <UIKit/UIKit.h>

#import "YMSCBAppService.h"
#import "DEABaseViewController.h"

@class DEASensorTag;

/**
 View Controller for TI Sensor Tag instance.
 */

@interface DEAHomeViewController : DEABaseViewController <YMSCBAppServiceDelegate>

@property (strong, nonatomic) IBOutlet UILabel *ambientTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *objectTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelXLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelYLabel;
@property (strong, nonatomic) IBOutlet UILabel *accelZLabel;
@property (strong, nonatomic) IBOutlet UISwitch *temperatureSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *accelSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *humiditySwitch;
@property (strong, nonatomic) IBOutlet UILabel *humidityLabel;
@property (strong, nonatomic) IBOutlet UILabel *humidityTemperature;


@property (strong, nonatomic) DEASensorTag *sensorTag;

- (IBAction)enableAction:(id)sender;

@end
