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
#import "DEAPeripheralViewCell.h"

@class DEASensorTagWindow;

@interface DEMAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, DEAPeripheralViewCellDelegate>
@property (nonatomic, assign) int oldCount;
@property (nonatomic, strong) NSMutableArray *peripheralWindows;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *scanButton;
@property (weak) IBOutlet NSTableView *peripheralTableView;



- (IBAction)scanAction:(id)sender;



@end
