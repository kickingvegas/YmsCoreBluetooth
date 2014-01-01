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


#import "DEAHumidityViewCell.h"
#import "DEASensorTag.h"
#import "DEAHumidityService.h"

@implementation DEAHumidityViewCell

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
    self.service = sensorTag.serviceDict[@"humidity"];
    
    for (NSString *key in @[@"ambientTemp", @"relativeHumidity", @"isOn", @"isEnabled"]) {
        [self.service addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self.notifySwitch setOn:self.service.isOn animated:YES];
    [self.notifySwitch setEnabled:self.service.isEnabled];
}

- (void)deconfigure {
    for (NSString *key in @[@"ambientTemp", @"relativeHumidity", @"isOn", @"isEnabled"]) {
        [self.service removeObserver:self forKeyPath:key];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object != self.service) {
        return;
    }
    
    DEAHumidityService *hs = (DEAHumidityService *)object;
    
    if ([keyPath isEqualToString:@"ambientTemp"]) {
        double temperatureC = [hs.ambientTemp doubleValue];
        float temperatureF = (float)temperatureC * 9.0/5.0 + 32.0;
        temperatureF = roundf(100 * temperatureF)/100.0;
        self.ambientTemperatureLabel.text = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];
        
    } else if ([keyPath isEqualToString:@"relativeHumidity"]) {
        double relativeHumidity = [hs.relativeHumidity doubleValue];
        self.relativeHumidityLabel.text = [NSString stringWithFormat:@"%0.2f", relativeHumidity];
        
    } else if ([keyPath isEqualToString:@"isOn"]) {
        [self.notifySwitch setOn:hs.isOn animated:YES];
        
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:hs.isEnabled];
    }
    
    
}



@end
