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
#import <IOBluetooth/IOBluetooth.h>
#import "DEMPeripheralViewCell.h"

/**
 DeannaMac application delegate.
 
 This application scans for BLE peripherals and if the peripheral is a TI SensorTag, 
 will allow connection to it from an OS X system.
 */
@class DEASensorTagWindow;

@interface DEMAppDelegate : NSObject <NSApplicationDelegate,
 NSTableViewDataSource,
 NSTableViewDelegate,
 CBCentralManagerDelegate,
 CBPeripheralDelegate,
 DEAPeripheralViewCellDelegate>

/**
 Counter used to determine if there is a change in the number of peripherals discovered.
 */
@property (nonatomic, assign) int oldCount;

/**
 Array containing peripheral window instances.
 */
@property (nonatomic, strong) NSMutableArray *peripheralWindows;

/**
 Main window.
 */
@property (assign) IBOutlet NSWindow *window;

/**
 Scan button.
 */
@property (weak) IBOutlet NSButton *scanButton;

/**
 Table containing discovered peripherals.
 */
@property (weak) IBOutlet NSTableView *peripheralTableView;

/**
 Action method for scanButton.
 */
- (IBAction)scanAction:(id)sender;



@end
