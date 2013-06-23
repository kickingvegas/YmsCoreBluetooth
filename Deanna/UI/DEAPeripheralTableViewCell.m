//
//  DEAPeripheralTableViewCell.m
//  Deanna
//
//  Created by Charles Choi on 4/18/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "DEAPeripheralTableViewCell.h"
#import "YMSCBPeripheral.h"
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
    
    if (self.yperipheral.isConnected) {
        [self.connectButton setTitle:@"CANCELLING…" forState:UIControlStateNormal];
        [self.yperipheral disconnect];
    } else {
        [self.connectButton setTitle:@"PAIRING…" forState:UIControlStateNormal];
        [self.yperipheral connect];

    }
}


- (void)configureWithPeripheral:(YMSCBPeripheral *)yp {
    
    self.yperipheral = yp;
    
    [self updateDisplay];
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

- (void)updateDisplay {
    NSString *buttonLabel;
    
    if (self.yperipheral.cbPeripheral.name) {
        self.nameLabel.text = self.yperipheral.cbPeripheral.name;
    } else {
        self.nameLabel.text = @"Undisclosed Name";
    }

    
    if ([self.yperipheral isKindOfClass:[DEASensorTag class]]) {
        if (self.yperipheral.isConnected) {
            buttonLabel = @"DISCONNECT";
            self.peripheralStatusLabel.text = @"CONNECTED";
            self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            [self.connectButton setTitle:buttonLabel forState:UIControlStateNormal];
            self.connectButton.titleLabel.text = buttonLabel;
            
        } else {
            buttonLabel = @"CONNECT";
            self.peripheralStatusLabel.text = @"UNCONNECTED";
            self.accessoryType = UITableViewCellAccessoryNone;
            [self.connectButton setTitle:buttonLabel forState:UIControlStateNormal];
            
            //self.rssiLabel.text = @"—";
            
        }

    } else {
        self.connectButton.hidden = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
        

}


@end
