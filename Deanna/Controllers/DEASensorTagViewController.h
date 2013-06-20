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


#import "DEABaseViewController.h"
@class DEASensorTag;
@class DEATemperatureViewCell;
@class DEAAccelerometerViewCell;
@class DEAHumidityViewCell;
@class DEASimpleKeysViewCell;
@class DEABarometerViewCell;
@class DEAGyroscopeViewCell;
@class DEAMagnetometerViewCell;
@class DEADeviceInfoViewCell;

/**
 ViewController for TI SensorTag peripheral.
 */
@interface DEASensorTagViewController : DEABaseViewController <UITableViewDelegate, UITableViewDataSource, CBPeripheralDelegate>

/** @name Properties */
/// Array of names of service cells.
@property (strong, nonatomic) NSArray *cbServiceCells;

/// Instance of DEASensorTag.
@property (strong, nonatomic) DEASensorTag *sensorTag;

/// BarButtonItem to display RSSI
@property (strong, nonatomic) UIBarButtonItem *rssiButton;

/// TableView holding UI controls for all SensorTag services.
@property (strong, nonatomic) IBOutlet UITableView *sensorTableView;

/// UI for temperature service.
@property (strong, nonatomic) IBOutlet DEATemperatureViewCell *temperatureViewCell;
/// UI for accelerometer service.
@property (strong, nonatomic) IBOutlet DEAAccelerometerViewCell *accelerometerViewCell;
/// UI for humidity service.
@property (strong, nonatomic) IBOutlet DEAHumidityViewCell *humidityViewCell;
/// UI for simple keys service.
@property (strong, nonatomic) IBOutlet DEASimpleKeysViewCell *simplekeysViewCell;
/// UI for barometer  service.
@property (strong, nonatomic) IBOutlet DEABarometerViewCell *barometerViewCell;
/// UI for gyroscope service.
@property (strong, nonatomic) IBOutlet DEAGyroscopeViewCell *gyroscopeViewCell;
/// UI for magnetometer service.
@property (strong, nonatomic) IBOutlet DEAMagnetometerViewCell *magnetometerViewCell;
/// UI for device info service.
@property (strong, nonatomic) IBOutlet DEADeviceInfoViewCell *devinfoViewCell;

@end
