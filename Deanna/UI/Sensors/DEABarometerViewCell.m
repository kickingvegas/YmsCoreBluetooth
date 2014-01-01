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


#import "DEABarometerViewCell.h"
#import "DEASensorTag.h"
#import "DEABarometerService.h"


@implementation DEABarometerViewCell

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

- (IBAction)calibrateButtonAction:(id)sender {
    [self.service requestCalibration];
}


- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"barometer"];
    
    for (NSString *key in @[@"ambientTemp", @"pressure", @"isOn", @"isEnabled", @"isCalibrating"]) {
        [self.service addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self.notifySwitch setOn:self.service.isOn animated:YES];
    [self.notifySwitch setEnabled:self.service.isEnabled];
}

- (void)deconfigure {
    for (NSString *key in @[@"ambientTemp", @"pressure", @"isOn", @"isEnabled", @"isCalibrating"]) {
        [self.service removeObserver:self forKeyPath:key];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object != self.service) {
        return;
    }
    
    DEABarometerService *bs = (DEABarometerService *)object;
    
    if ([keyPath isEqualToString:@"ambientTemp"]) {
        double temperatureC = [bs.ambientTemp doubleValue];
        float temperatureF = (float)temperatureC * 9.0/5.0 + 32.0;
        temperatureF = roundf(100 * temperatureF)/100.0;
        self.ambientTemperatureLabel.text = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];

    } else if ([keyPath isEqualToString:@"pressure"]) {
        double pressure = [bs.pressure doubleValue];
        double pressureRound = pressure/1.01325E5;
        
        self.pressureLabel.text = [NSString stringWithFormat:@"%0.4f atm", pressureRound];
        
    } else if ([keyPath isEqualToString:@"isOn"]) {
        [self.notifySwitch setOn:bs.isOn animated:YES];
        
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:bs.isEnabled];
        
    } else if ([keyPath isEqualToString:@"isCalibrating"]) {
        [self.calibrateButton setEnabled:!bs.isCalibrating];
    }
    
    
}




@end
