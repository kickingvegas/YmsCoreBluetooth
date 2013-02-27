//
//  DTHomeViewController.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEAHomeViewController.h"
#import "DEACBAppService.h"
#import "DEASensorTag.h"
#import "DEATemperatureService.h"
#import "DEAAccelerometerService.h"
#import "DEAHumidityService.h"

@interface DEAHomeViewController ()

- (void)connectButtonAction:(id)sender;

@end

@implementation DEAHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Deanna";
}



- (void)viewWillAppear:(BOOL)animated {

    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    cbAppService.delegate = self;

    
    DEATemperatureService *ts = self.sensorTag.serviceDict[@"temperature"];
    DEAAccelerometerService *as = self.sensorTag.serviceDict[@"accelerometer"];
    DEAHumidityService *hs = self.sensorTag.serviceDict[@"humidity"];
    
    for (NSString *key in @[@"ambientTemp", @"objectTemp", @"isOn", @"isEnabled"]) {
        [ts addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled"]) {
        [as addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    for (NSString *key in @[@"ambientTemp", @"relativeHumidity", @"isOn", @"isEnabled"]) {
        [hs addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    
    
    [self.temperatureSwitch setOn:ts.isOn animated:YES];
    [self.temperatureSwitch setEnabled:ts.isEnabled];
    
    [self.accelSwitch setOn:as.isOn animated:YES];
    [self.accelSwitch setEnabled:as.isEnabled];
    
    [self.humiditySwitch setOn:hs.isOn animated:YES];
    [self.humiditySwitch setEnabled:hs.isEnabled];
    
}

- (void)connectButtonAction:(id)sender {
    
    NSLog(@"connectButtonAction:");
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    
    
    if (self.sensorTag.cbPeriperheral.isConnected) {
        [cbAppService.manager cancelPeripheralConnection:self.sensorTag.cbPeriperheral];
    }
    else {
        [cbAppService.manager connectPeripheral:self.sensorTag.cbPeriperheral options:nil];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    DEATemperatureService *ts = self.sensorTag.serviceDict[@"temperature"];
    DEAAccelerometerService *as = self.sensorTag.serviceDict[@"accelerometer"];
    DEAHumidityService *hs = self.sensorTag.serviceDict[@"humidity"];
    
    for (NSString *key in @[@"ambientTemp", @"objectTemp", @"isOn", @"isEnabled"]) {
        [ts removeObserver:self forKeyPath:key];
    }
    
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled"]) {
        [as removeObserver:self forKeyPath:key];
    }
    
    for (NSString *key in @[@"ambientTemp", @"relativeHumidity", @"isOn", @"isEnabled"]) {
        [hs removeObserver:self forKeyPath:key];
    }

}


- (void)hasStartedScanning:(id)delegate {
//    self.scanButton.title = @"Stop Scanning";
}

- (void)hasStoppedScanning:(id)delegate {
//    self.scanButton.title = @"Start Scanning";
}


- (void)didConnectPeripheral:(id)delegate {
}


- (void)didDisconnectPeripheral:(id)delegate {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //YMSBluetoothService *cbAppService = [YMSBluetoothService sharedService];
    //DEASensorTag *sensorTag = cbAppService.ymsPeripherals[0];
    
    DEATemperatureService *ts = self.sensorTag.serviceDict[@"temperature"];
    DEAAccelerometerService *as = self.sensorTag.serviceDict[@"accelerometer"];
    DEAHumidityService *hs = self.sensorTag.serviceDict[@"humidity"];
    
    if (object == ts) {
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
            [self.temperatureSwitch setOn:ts.isOn animated:YES];

        } else if ([keyPath isEqualToString:@"isEnabled"]) {
            [self.temperatureSwitch setEnabled:ts.isEnabled];
        }


    } else if (object == as) {
        if ([keyPath isEqualToString:@"x"]) {
            self.accelXLabel.text = [NSString stringWithFormat:@"%0.2f", [as.x floatValue]];
        } else if ([keyPath isEqualToString:@"y"]) {
            self.accelYLabel.text = [NSString stringWithFormat:@"%0.2f", [as.y floatValue]];
        } else if ([keyPath isEqualToString:@"z"]) {
            self.accelZLabel.text = [NSString stringWithFormat:@"%0.2f", [as.z floatValue]];
        } else if ([keyPath isEqualToString:@"isOn"]) {
            [self.accelSwitch setOn:as.isOn animated:YES];
        } else if ([keyPath isEqualToString:@"isEnabled"]) {
            [self.accelSwitch setEnabled:as.isEnabled];
        }
        
        
    } else if (object == hs) {
        if ([keyPath isEqualToString:@"ambientTemp"]) {
            double temperatureC = [hs.ambientTemp doubleValue];
            float temperatureF = (float)temperatureC * 9.0/5.0 + 32.0;
            temperatureF = roundf(100 * temperatureF)/100.0;
            self.humidityTemperature.text = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];
            
        } else if ([keyPath isEqualToString:@"relativeHumidity"]) {
            double relativeHumidity = [hs.relativeHumidity doubleValue];
            self.humidityLabel.text = [NSString stringWithFormat:@"%0.2f", relativeHumidity];
            
        } else if ([keyPath isEqualToString:@"isOn"]) {
            [self.humiditySwitch setOn:hs.isOn animated:YES];
            
        } else if ([keyPath isEqualToString:@"isEnabled"]) {
            [self.humiditySwitch setEnabled:hs.isEnabled];
        }

    }

    
    
}


- (IBAction)enableAction:(id)sender {
    
    if (self.sensorTag != nil) {
    
        NSString *sensorName;

        UISwitch *enableSwitch = (UISwitch *)sender;
        
        if (sender == self.accelSwitch) {
            sensorName = @"accelerometer";
        } else if (sender == self.temperatureSwitch) {
            sensorName= @"temperature";
        } else if (sender == self.humiditySwitch) {
            sensorName= @"humidity";
        }
        
        YMSCBService *yService = self.sensorTag.serviceDict[sensorName];

        if (enableSwitch.isOn)
            [yService turnOn];
        else
            [yService turnOff];

    }

    
}
- (void)viewDidUnload {
    [self setHumiditySwitch:nil];
    [self setHumidityLabel:nil];
    [self setHumidityTemperature:nil];
    [super viewDidUnload];
}
@end
