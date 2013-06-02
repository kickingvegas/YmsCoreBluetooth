//
//  DEMBarometerViewCell.m
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEMBarometerViewCell.h"
#import "DEASensorTag.h"
#import "DEABarometerService.h"


@implementation DEMBarometerViewCell

- (IBAction)calibrateButtonAction:(id)sender {
    DEABarometerService *bs = (DEABarometerService *)self.service;
    [bs requestCalibration];
}

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.barometer;
    
    for (NSString *key in @[@"ambientTemp", @"pressure", @"isOn", @"isEnabled", @"isCalibrating"]) {
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
        self.ambientTemperatureLabel.stringValue = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];
        
    } else if ([keyPath isEqualToString:@"pressure"]) {
        double pressure = [bs.pressure doubleValue];
        double pressureRound = pressure/1.01325E5;
        
        self.pressureLabel.stringValue = [NSString stringWithFormat:@"%0.4f atm", pressureRound];
        
    } else if ([keyPath isEqualToString:@"isOn"]) {
        if (bs.isOn) {
            [self.notifySwitch setState:NSOnState];
        } else {
            [self.notifySwitch setState:NSOffState];
        }

    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:bs.isEnabled];
        
    } else if ([keyPath isEqualToString:@"isCalibrating"]) {
        [self.calibrateButton setEnabled:!bs.isCalibrating];
    }
    
    
}




@end
