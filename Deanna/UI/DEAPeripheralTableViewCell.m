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
#import "DEACBAppService.h"

@implementation DEAPeripheralTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)connectButtonAction:(id)sender {
    
    if (self.sensorTag.isConnected) {
        [self.connectButton setTitle:@"Cancelling…" forState:UIControlStateNormal];
        [self.sensorTag disconnect];
    } else {
        [self.connectButton setTitle:@"Pairing…" forState:UIControlStateNormal];
        [self.sensorTag connect];

    }
}


- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    
    self.sensorTag = sensorTag;
    
    [self updateDisplay:self.sensorTag.cbPeripheral];
}


- (void)updateDisplay:(CBPeripheral *)peripheral {
    
    NSString *buttonLabel;
    
    if (self.sensorTag.cbPeripheral == peripheral) {
        if (peripheral.isConnected) {
            
            buttonLabel = @"Disconnect";
            
            self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            self.dbLabel.hidden = NO;
            [self.connectButton setTitle:buttonLabel forState:UIControlStateNormal];
            self.connectButton.titleLabel.text = buttonLabel;
            
        } else {
            
            buttonLabel = @"Connect";
            
            self.accessoryType = UITableViewCellAccessoryNone;
            self.dbLabel.hidden = YES;
            [self.connectButton setTitle:buttonLabel forState:UIControlStateNormal];

            self.rssiLabel.text = @"";

        }
    }
    
}


@end
