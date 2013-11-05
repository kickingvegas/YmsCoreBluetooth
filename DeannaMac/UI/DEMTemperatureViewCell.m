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

#import "DEMTemperatureViewCell.h"
#import "DEASensorTag.h"
#import "DEATemperatureService.h"

@implementation DEMTemperatureViewCell


- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"temperature"];
    
    for (NSString *key in @[@"temperatureValues", @"isOn", @"isEnabled"]) {
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
    for (NSString *key in @[@"temperatureValues", @"isOn", @"isEnabled"]) {
        [self.service removeObserver:self forKeyPath:key];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object != self.service) {
        return;
    }
    
    DEATemperatureService *ts = (DEATemperatureService *)object;
    
    if ([keyPath isEqualToString:@"temperatureValues"]) {
        NSDictionary *values = ts.temperatureValues;

        double temperatureC = [values[@"ambientTemp"] doubleValue];
        float temperatureF = (float)temperatureC * 9.0/5.0 + 32.0;
        temperatureF = roundf(100 * temperatureF)/100.0;
        self.ambientTemperatureLabel.stringValue = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];

        temperatureC = [values[@"objectTemp"] doubleValue];
        temperatureF = (float)temperatureC * 9.0/5.0 + 32.0;
        temperatureF = roundf(100 * temperatureF)/100.0;
        self.objectTemperatureLabel.stringValue = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];
        
    } else if ([keyPath isEqualToString:@"isOn"]) {
        if (ts.isOn) {
            [self.notifySwitch setState:NSOnState];
        } else {
            [self.notifySwitch setState:NSOffState];
        }
        
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:ts.isEnabled];
    }
    
}

@end
