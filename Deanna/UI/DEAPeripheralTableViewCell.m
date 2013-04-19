//
//  DEAPeripheralTableViewCell.m
//  Deanna
//
//  Created by Charles Choi on 4/18/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

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
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];

    BOOL isConnected = self.sensorTag.cbPeripheral.isConnected;
    
    if (isConnected) {
        [cbAppService.manager cancelPeripheralConnection:self.sensorTag.cbPeripheral];
    } else {
        [cbAppService.manager connectPeripheral:self.sensorTag.cbPeripheral options:nil];
    }

}

- (void)dealloc {
    [self.sensorTag.cbPeripheral removeObserver:self forKeyPath:@"RSSI"];

}


- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    
    self.sensorTag = sensorTag;
    
    [sensorTag.cbPeripheral addObserver:self
                               forKeyPath:@"RSSI"
                                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                  context:NULL];


    if (sensorTag.cbPeripheral.isConnected) {
        self.connectButton.titleLabel.textAlignment = UITextAlignmentCenter;
        self.connectButton.titleLabel.text = @"Disconnect";
        
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        [self.connectButton setNeedsDisplay];
        self.dbLabel.hidden = NO;
        
        
    } else {
        self.connectButton.titleLabel.textAlignment = UITextAlignmentCenter;
        self.connectButton.titleLabel.text = @"Connect";
        self.accessoryType = UITableViewCellAccessoryNone;
        self.rssiLabel.text = @"";
        self.dbLabel.hidden = YES;
    }
    

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"RSSI"]) {
        self.rssiLabel.text = [NSString stringWithFormat:@"%@", change[@"new"]];
        
    }

}


@end
