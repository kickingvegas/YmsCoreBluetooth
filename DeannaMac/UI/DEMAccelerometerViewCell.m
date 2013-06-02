//
//  DEMAccelerometerViewCell.m
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEMBaseViewCell.h"
#import "DEMAccelerometerViewCell.h"
#import "DEASensorTag.h"
#import "DEAAccelerometerService.h"


@implementation DEMAccelerometerViewCell

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"accelerometer"];
    
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled"]) {
        [self.service addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    if (self.service.isOn) {
        [self.notifySwitch setState:NSOnState];
    } else {
        [self.notifySwitch setState:NSOffState];
    }
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
        self.accelXLabel.stringValue = [NSString stringWithFormat:@"%0.2f", [as.x floatValue]];
    } else if ([keyPath isEqualToString:@"y"]) {
        self.accelYLabel.stringValue = [NSString stringWithFormat:@"%0.2f", [as.y floatValue]];
    } else if ([keyPath isEqualToString:@"z"]) {
        self.accelZLabel.stringValue = [NSString stringWithFormat:@"%0.2f", [as.z floatValue]];
    } else if ([keyPath isEqualToString:@"isOn"]) {
        if (as.isOn) {
            [self.notifySwitch setState:NSOnState];
        } else {
            [self.notifySwitch setState:NSOffState];
        }
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:as.isEnabled];
    }
    
}


@end
