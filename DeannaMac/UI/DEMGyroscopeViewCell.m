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

#import "DEMGyroscopeViewCell.h"
#import "DEASensorTag.h"
#import "DEAGyroscopeService.h"

@implementation DEMGyroscopeViewCell

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"gyroscope"];
    
    for (NSString *key in @[@"gyroscopeValues", @"isOn", @"isEnabled"]) {
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
    for (NSString *key in @[@"gyroscopeValues", @"isOn", @"isEnabled"]) {
        [self.service removeObserver:self forKeyPath:key];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object != self.service) {
        return;
    }
    
    DEAGyroscopeService *gs = (DEAGyroscopeService *)object;
    
    if ([keyPath isEqualToString:@"gyroscopeValues"]) {
        NSDictionary *values = gs.gyroscopeValues;

        double roll = [values[@"roll"] doubleValue];
        self.rollLabel.stringValue = [NSString stringWithFormat:@"%0.2f", roll];
        
        double pitch = [values[@"pitch"] doubleValue];
        self.pitchLabel.stringValue = [NSString stringWithFormat:@"%0.2f", pitch];
        
        double yaw = [values[@"yaw"] doubleValue];
        self.yawLabel.stringValue = [NSString stringWithFormat:@"%0.2f", yaw];

    } else if ([keyPath isEqualToString:@"isOn"]) {
        if (gs.isOn) {
            [self.notifySwitch setState:NSOnState];
        } else {
            [self.notifySwitch setState:NSOffState];
        }
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:gs.isEnabled];
    }
    
    
}



- (IBAction)calibrateButtonAction:(id)sender {
    DEAGyroscopeService *gs = (DEAGyroscopeService *)self.service;
    [gs calibrate];
}

@end
