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

#import "DEMPeripheralViewCell.h"

@implementation DEMPeripheralViewCell


- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    if (self) {
        
        // Name Label
        _nameLabel = [[NSTextField alloc] initWithFrame:CGRectMake(20, 60, 153, 21)];
        [self configureTextField:_nameLabel];
    
        // Connect Button
        _connectButton = [[NSButton alloc] initWithFrame:CGRectMake(20, 9, 153, 49)];
        _connectButton.title = @"Connect";
        [_connectButton setEnabled:NO];
        [_connectButton setTarget:self];
        [_connectButton setAction:@selector(connectButtonAction:)];
        
        // RSSI Label
        _rssiLabel = [[NSTextField alloc] initWithFrame:CGRectMake(181, 25, 81, 23)];
        [_rssiLabel setFont:[NSFont systemFontOfSize:22.0]];
        [self configureTextField:_rssiLabel];
        
        _dbLabel = [[NSTextField alloc] initWithFrame:CGRectMake(230, 25, 81, 12)];
        [_dbLabel setFont:[NSFont systemFontOfSize:10.0]];
        _dbLabel.stringValue = @"db";
        [self configureTextField:_dbLabel];
        
        // Detail Button
        _detailButton = [[NSButton alloc] initWithFrame:CGRectMake(300, 0, 50, 50)];
        [_detailButton setBezelStyle:NSRoundedDisclosureBezelStyle];
        [_detailButton setTitle:@""];
        [_detailButton setTarget:self];
        [_detailButton setAction:@selector(detailButtonAction:)];
        [_detailButton setHidden:YES];
        
        [self addSubview:_nameLabel];
        [self addSubview:_connectButton];
        [self addSubview:_rssiLabel];
        [self addSubview:_detailButton];
        [self addSubview:_dbLabel];

        
    }
    return self;
}

- (void)configureTextField:(NSTextField *)label {
    [label setEditable:NO];
    [label setDrawsBackground:NO];
    [label setBezeled:NO];
    [label setFocusRingType:NSFocusRingTypeNone];
    [label setBordered:NO];

}


- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.sensorTag = sensorTag;
}

- (void)updateDisplay:(CBPeripheral *)peripheral {
    
}


- (void)connectButtonAction:(id)sender {
    NSLog(@"hit connect button");
    
    if (self.sensorTag.cbPeripheral.isConnected) {
        [self.sensorTag disconnect];
        [self.connectButton setTitle:@"Disconnecting..."];
    } else {
        NSApplication *app = [NSApplication sharedApplication];
        self.sensorTag.delegate = (id)app;
        self.sensorTag.watchdogTimerInterval = 30.0;
        [self.sensorTag connect];
        [self.connectButton setTitle:@"Pairing"];
    }
}


- (void)detailButtonAction:(id)sender {
    NSLog(@"hit detail button");
    
    if ([self.delegate respondsToSelector:@selector(openPeripheralWindow:)]) {
        [self.delegate openPeripheralWindow:self.sensorTag];
    }

}


@end
