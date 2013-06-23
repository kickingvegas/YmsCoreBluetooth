//
//  DEAPeripheralTableViewCell.m
//  Deanna
//
//  Created by Charles Choi on 4/18/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "DEAPeripheralTableViewCell.h"
#import "DEASensorTag.h"
#import "DEACentralManager.h"
#import "DEAStyleSheet.h"
#import "DEABaseButton.h"

@implementation DEAPeripheralTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)connectButtonAction:(id)sender {
    
    if (self.sensorTag.isConnected) {
        [self.connectButton setTitle:@"CANCELLING…" forState:UIControlStateNormal];
        [self.sensorTag disconnect];
    } else {
        [self.connectButton setTitle:@"PAIRING…" forState:UIControlStateNormal];
        [self.sensorTag connect];

    }
}


- (void)configureWithPeripheral:(DEASensorTag *)sensorTag {
    
    self.sensorTag = sensorTag;
    
    [self updateDisplay:self.sensorTag.cbPeripheral];
}

- (void)applyStyle {
    self.contentView.superview.backgroundColor = kDEA_STYLE_BACKGROUNDCOLOR;
    self.dbLabel.textColor = kDEA_STYLE_WHITECOLOR;
    self.rssiLabel.textColor = kDEA_STYLE_RSSI_TEXTCOLOR;
    self.nameLabel.textColor = kDEA_STYLE_WHITECOLOR;
    self.signalLabel.textColor = kDEA_STYLE_BASIC_TEXTCOLOR;
    self.peripheralStatusLabel.textColor = kDEA_STYLE_BASIC_TEXTCOLOR;
    
    [self.connectButton applyStyle];
}

- (void)updateDisplay:(CBPeripheral *)peripheral {
    NSString *buttonLabel;
    
    if (peripheral == nil) {
        self.connectButton.hidden = YES;
        self.peripheralStatusLabel.text = @"DISCOVERED";
        self.accessoryType = UITableViewCellAccessoryNone;
        
    } else if (self.sensorTag.cbPeripheral == peripheral) {
        if (peripheral.isConnected) {
            
            buttonLabel = @"DISCONNECT";
            self.peripheralStatusLabel.text = @"CONNECTED";
            
            self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            //self.dbLabel.hidden = NO;
            [self.connectButton setTitle:buttonLabel forState:UIControlStateNormal];
            self.connectButton.titleLabel.text = buttonLabel;
            
        } else {
            
            buttonLabel = @"CONNECT";
            self.peripheralStatusLabel.text = @"UNCONNECTED";
            
            self.accessoryType = UITableViewCellAccessoryNone;
            //self.dbLabel.hidden = YES;
            [self.connectButton setTitle:buttonLabel forState:UIControlStateNormal];

            self.rssiLabel.text = @"—";

        }
    }
    
}


@end
