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

#import "DEMBaseViewCell.h"
#import "DEMAccelerometerViewCell.h"
#import "DEASensorTag.h"
#import "DEAAccelerometerService.h"


@implementation DEMAccelerometerViewCell

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"accelerometer"];
    
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled", @"period"]) {
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
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled", @"period"]) {
        [self.service removeObserver:self forKeyPath:key];
    }
}


- (IBAction)periodSliderAction:(id)sender {
    
    uint8_t value;
    
    value = (uint8_t)[self.periodSlider integerValue];
    
    //NSLog(@"Value: %x", value);
    
    DEAAccelerometerService *as = (DEAAccelerometerService *)self.service;
    [as configPeriod:value];
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
        if (as.isEnabled) {
            self.periodSlider.enabled = as.isEnabled;
            [as readPeriod];
        }
    
    } else if ([keyPath isEqualToString:@"period"]) {
        
        int pvalue = (int)([as.period floatValue] * 10.0);

        self.periodLabel.stringValue = [NSString stringWithFormat:@"%d ms", pvalue];
        if (!self.hasReadPeriod) {
            [self.periodSlider setFloatValue:[as.period floatValue]];
            self.hasReadPeriod = YES;
        }
        
    }
}



@end
