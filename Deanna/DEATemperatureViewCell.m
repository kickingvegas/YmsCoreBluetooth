//
//  DEATemperatureViewCell.m
//  Deanna
//
//  Created by Charles Choi on 2/27/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEATemperatureViewCell.h"
#import "DEASensorTag.h"
#import "DEATemperatureService.h"

@implementation DEATemperatureViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.ambientTemperatureLabel.text = @"--";
        self.objectTemperatureLabel.text = @"--";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)notifySwitchAction:(id)sender {
    NSLog(@"notifySwitch");
    if (self.notifySwitch.isOn) {
        [self.service turnOn];
    } else {
        [self.service turnOff];
    }
}


- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"temperature"];
    
    for (NSString *key in @[@"ambientTemp", @"objectTemp", @"isOn", @"isEnabled"]) {
        [self.service addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self.notifySwitch setOn:self.service.isOn animated:YES];
    [self.notifySwitch setEnabled:self.service.isEnabled];
}

- (void)deconfigure {
    for (NSString *key in @[@"ambientTemp", @"objectTemp", @"isOn", @"isEnabled"]) {
        [self.service removeObserver:self forKeyPath:key];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object != self.service) {
        return;
    }
    
    DEATemperatureService *ts = (DEATemperatureService *)object;
    
    if ([keyPath isEqualToString:@"ambientTemp"]) {
        double temperatureC = [ts.ambientTemp doubleValue];
        float temperatureF = (float)temperatureC * 9.0/5.0 + 32.0;
        temperatureF = roundf(100 * temperatureF)/100.0;
        self.ambientTemperatureLabel.text = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];
        
    } else if ([keyPath isEqualToString:@"objectTemp"]) {
        double temperatureC = [ts.objectTemp doubleValue];
        float temperatureF = (float)temperatureC * 9.0/5.0 + 32.0;
        temperatureF = roundf(100 * temperatureF)/100.0;
        self.objectTemperatureLabel.text = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];
        
    } else if ([keyPath isEqualToString:@"isOn"]) {
        [self.notifySwitch setOn:ts.isOn animated:YES];
        
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.notifySwitch setEnabled:ts.isEnabled];
    }

    
}

@end
