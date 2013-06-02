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
@class DEABaseService;

@interface DEMBaseViewCell : NSView

@property (strong, nonatomic) DEABaseService *service;

@property (strong) IBOutlet NSButton *notifySwitch;

/**
 Configure this class to use sensorTag.
 
 @param sensorTag Peripheral containing service to be used by this UI component.
 */
- (void)configureWithSensorTag:(DEASensorTag *)sensorTag;

/**
 Deconfigure this class to not use sensorTag.
 */
- (void)deconfigure;

/**
 Action method to handle notifySwitch toggle.
 
 @param sender notifySwitch UI component.
 */
- (IBAction)notifySwitchAction:(id)sender;


@end
