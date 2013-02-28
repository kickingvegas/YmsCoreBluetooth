//
//  DEAAccelerometerViewCell.m
//  Deanna
//
//  Created by Charles Choi on 2/27/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEAAccelerometerViewCell.h"
#import "DEAAccelerometerService.h"
#import "DEASensorTag.h"

@implementation DEAAccelerometerViewCell

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


- (IBAction)notifySwitchAction:(id)sender {
    NSLog(@"notifySwitch");
    if (self.notifySwitch.isOn) {
        [self.service turnOn];
    } else {
        [self.service turnOff];
    }
}

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"accelerometer"];
    
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled"]) {
        [self.service addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self.notifySwitch setOn:self.service.isOn animated:YES];
    [self.notifySwitch setEnabled:self.service.isEnabled];
}

- (void)deconfigure {
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled"]) {
        [self.service removeObserver:self forKeyPath:key];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object != self.service) {
        return;
    }
    
    DEAAccelerometerService *as = (DEAAccelerometerService *)object;
    
    if ([keyPath isEqualToString:@"x"]) {
        self.accelXLabel.text = [NSString stringWithFormat:@"%0.2f", [as.x floatValue]];
    } else if ([keyPath isEqualToString:@"y"]) {
        self.accelYLabel.text = [NSString stringWithFormat:@"%0.2f", [as.y floatValue]];
    } else if ([keyPath isEqualToString:@"z"]) {
        self.accelZLabel.text = [NSString stringWithFormat:@"%0.2f", [as.z floatValue]];
    } else if ([keyPath isEqualToString:@"isOn"]) {
        [self.notifySwitch setOn:as.isOn animated:YES];
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:as.isEnabled];
    }

}



@end
