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


#import "DEAGyroscopeViewCell.h"
#import "DEASensorTag.h"
#import "DEAGyroscopeService.h"

@implementation DEAGyroscopeViewCell

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

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"gyroscope"];
    
    for (NSString *key in @[@"roll", @"pitch", @"yaw", @"isOn", @"isEnabled"]) {
        [self.service addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self.notifySwitch setOn:self.service.isOn animated:YES];
    [self.notifySwitch setEnabled:self.service.isEnabled];
}

- (void)deconfigure {
    for (NSString *key in @[@"roll", @"pitch", @"yaw", @"isOn", @"isEnabled"]) {
        [self.service removeObserver:self forKeyPath:key];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object != self.service) {
        return;
    }
    
    DEAGyroscopeService *gs = (DEAGyroscopeService *)object;
    
    if ([keyPath isEqualToString:@"roll"]) {
        double roll = [gs.roll doubleValue];
        self.rollLabel.text = [NSString stringWithFormat:@"%0.2f", roll];

    } else if ([keyPath isEqualToString:@"pitch"]) {
        double pitch = [gs.pitch doubleValue];
        self.pitchLabel.text = [NSString stringWithFormat:@"%0.2f", pitch];

    } else if ([keyPath isEqualToString:@"yaw"]) {
        double yaw = [gs.yaw doubleValue];
        self.yawLabel.text = [NSString stringWithFormat:@"%0.2f", yaw];

    } else if ([keyPath isEqualToString:@"isOn"]) {
        [self.notifySwitch setOn:gs.isOn animated:YES];
        
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:gs.isEnabled];
    }
    
    
}



- (IBAction)calibrateButtonAction:(id)sender {
    [self.service calibrate];

}

@end
