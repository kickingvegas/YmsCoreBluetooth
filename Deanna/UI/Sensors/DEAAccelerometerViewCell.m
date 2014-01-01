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
    if (self.notifySwitch.isOn) {
        [self.service turnOn];
    } else {
        [self.service turnOff];
    }
}

- (IBAction)periodSliderAction:(id)sender {
    
    uint8_t value;
    
    value = (uint8_t)nearbyintf(self.periodSlider.value);
    
    //NSLog(@"Value: %x", value);
    [self.service configPeriod:value];
}

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"accelerometer"];
    
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled", @"period"]) {
        [self.service addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self.notifySwitch setOn:self.service.isOn animated:YES];
    [self.notifySwitch setEnabled:self.service.isEnabled];
    self.periodSlider.enabled = self.service.isEnabled;
    
    DEAAccelerometerService *as = (DEAAccelerometerService *)self.service;
    if (as.isEnabled) {
        [as requestReadPeriod];
    }
    
    
}

- (void)deconfigure {
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled", @"period"]) {
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
        if (as.isEnabled) {
            self.periodSlider.enabled = as.isEnabled;
            [as requestReadPeriod];
        }
        
    } else if ([keyPath isEqualToString:@"period"]) {
        
        int pvalue = (int)([as.period floatValue] * 10.0);
        
        self.periodLabel.text = [NSString stringWithFormat:@"%d ms", pvalue];
        if (!self.hasReadPeriod) {
            [self.periodSlider setValue:[as.period floatValue] animated:YES];
            self.hasReadPeriod = YES;
        }

    }

}



@end
