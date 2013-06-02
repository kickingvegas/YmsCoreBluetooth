//
//  DEAPeripheralViewCell.m
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEAPeripheralViewCell.h"

@implementation DEAPeripheralViewCell


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
        _rssiLabel = [[NSTextField alloc] initWithFrame:CGRectMake(181, 0, 81, 50)];
        [_rssiLabel setFont:[NSFont systemFontOfSize:22.0]];
        [self configureTextField:_rssiLabel];
        
        
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
