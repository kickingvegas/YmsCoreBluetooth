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

#import <Cocoa/Cocoa.h>

@class DEASensorTag;
@class DEMAccelerometerViewCell;
@class DEMBarometerViewCell;
@class DEMDeviceInfoViewCell;
@class DEMSimpleKeysViewCell;
@class DEMTemperatureViewCell;

@interface DEASensorTagWindow : NSWindowController<NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property (strong, nonatomic) DEASensorTag *sensorTag;

/// Array of names of service cells.
@property (strong, nonatomic) NSArray *cbServiceCells;

@property (strong) IBOutlet NSTableView *servicesTableView;
@property (strong) IBOutlet DEMAccelerometerViewCell *accelerometerViewCell;
@property (strong) IBOutlet DEMBarometerViewCell *barometerViewCell;
@property (strong) IBOutlet DEMDeviceInfoViewCell *devinfoViewCell;
@property (strong) IBOutlet DEMSimpleKeysViewCell *simplekeysViewCell;
@property (strong) IBOutlet DEMTemperatureViewCell *temperatureViewCell;

@end
