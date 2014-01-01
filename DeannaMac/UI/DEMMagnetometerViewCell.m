// 
// Copyright 2013-2014 Yummy Melon Software LLC
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

#import "DEMMagnetometerViewCell.h"
#import "DEAMagnetometerService.h"
#import "DEASensorTag.h"

@implementation DEMMagnetometerViewCell


- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"magnetometer"];
    
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
    
    DEAMagnetometerService *ms = (DEAMagnetometerService *)object;
    
    if ([keyPath isEqualToString:@"x"]) {
        float x = [ms.x floatValue];
        self.xLabel.stringValue = [NSString stringWithFormat:@"%0.2f", x];

    } else if ([keyPath isEqualToString:@"y"]) {
        float y = [ms.y floatValue];
        self.yLabel.stringValue = [NSString stringWithFormat:@"%0.2f", y];

    } else if ([keyPath isEqualToString:@"z"]) {
        float z = [ms.z floatValue];
        self.zLabel.stringValue = [NSString stringWithFormat:@"%0.2f", z];
        
    } else if ([keyPath isEqualToString:@"isOn"]) {
        if (ms.isOn) {
            [self.notifySwitch setState:NSOnState];
        } else {
            [self.notifySwitch setState:NSOffState];
        }
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:ms.isEnabled];
    }
    
    
}

- (IBAction)calibrateButtonAction:(id)sender {
    DEAMagnetometerService *ms = (DEAMagnetometerService *)self.service;
    [ms calibrate];
}

@end
