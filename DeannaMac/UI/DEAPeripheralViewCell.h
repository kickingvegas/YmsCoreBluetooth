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
#import "DEASensorTag.h"

@class YMSCBPeripheral;

@protocol DEAPeripheralViewCellDelegate <NSObject>

- (void)openPeripheralWindow:(YMSCBPeripheral *)yp;

@end


@interface DEAPeripheralViewCell : NSControl


@property (weak) id<DEAPeripheralViewCellDelegate> delegate;

@property (weak, nonatomic) DEASensorTag *sensorTag;
@property (assign, nonatomic) BOOL hasConnected;

@property (strong, nonatomic) NSTextField *nameLabel;
@property (strong, nonatomic) NSTextField *rssiLabel;
@property (strong, nonatomic) NSButton *connectButton;
@property (strong, nonatomic) NSTextField *dbLabel;
@property (strong, nonatomic) NSButton *detailButton;



- (void)connectButtonAction:(id)sender;

- (void)detailButtonAction:(id)sender;

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag;

- (void)updateDisplay:(CBPeripheral *)peripheral;

- (void)configureTextField:(NSTextField *)label;

@end
