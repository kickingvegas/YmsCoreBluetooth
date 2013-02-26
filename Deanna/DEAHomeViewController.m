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

@interface DEAHomeViewController ()

- (void)btleOffHandler:(NSNotification *)notification;
//- (void)scanButtonAction:(id)sender;
//- (void)connectButtonAction:(id)sender;
    

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btleOffHandler:) name:YMSCBPowerOffNotification object:nil];

}


- (void)viewWillAppear:(BOOL)animated {

    DEACBAppService *btleService = [DEACBAppService sharedService];
    btleService.delegate = self;

    
    DEATemperatureService *ts = self.sensorTag.sensorServices[@"temperature"];
    DEAAccelerometerService *as = self.sensorTag.sensorServices[@"accelerometer"];
    
    for (NSString *key in @[@"ambientTemp", @"objectTemp", @"isOn", @"isEnabled"]) {
        [ts addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled"]) {
        [as addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }

    
//    [ts addObserver:self
//         forKeyPath:@"ambientTemp"
//            options:NSKeyValueObservingOptionNew
//            context:NULL];
//    
//    [ts addObserver:self
//         forKeyPath:@"objectTemp"
//            options:NSKeyValueObservingOptionNew
//            context:NULL];
//    
//    [ts addObserver:self
//         forKeyPath:@"isOn"
//            options:NSKeyValueObservingOptionNew
//            context:NULL];
    
    
//    [as addObserver:self
//         forKeyPath:@"x"
//            options:NSKeyValueObservingOptionNew
//            context:NULL];
//    [as addObserver:self
//         forKeyPath:@"y"
//            options:NSKeyValueObservingOptionNew
//            context:NULL];
//    
//    [as addObserver:self
//         forKeyPath:@"z"
//            options:NSKeyValueObservingOptionNew
//            context:NULL];
//    
//    [as addObserver:self
//         forKeyPath:@"isOn"
//            options:NSKeyValueObservingOptionNew
//            context:NULL];
    
    [self.temperatureSwitch setOn:ts.isOn animated:YES];
    [self.temperatureSwitch setEnabled:ts.isEnabled];
    
    [self.accelSwitch setOn:as.isOn animated:YES];
    [self.accelSwitch setEnabled:as.isEnabled];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    DEATemperatureService *ts = self.sensorTag.sensorServices[@"temperature"];
    DEAAccelerometerService *as = self.sensorTag.sensorServices[@"accelerometer"];
    
    //self.connectButton.title = @"Connect";
    
    for (NSString *key in @[@"ambientTemp", @"objectTemp", @"isOn", @"isEnabled"]) {
        [ts removeObserver:self forKeyPath:key];
    }
    
    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled"]) {
        [as removeObserver:self forKeyPath:key];
    }

//    
//    [ts removeObserver:self forKeyPath:@"ambientTemp"];
//    [ts removeObserver:self forKeyPath:@"objectTemp"];
//    [ts removeObserver:self forKeyPath:@"isOn"];
//    
//    [as removeObserver:self forKeyPath:@"x"];
//    [as removeObserver:self forKeyPath:@"y"];
//    [as removeObserver:self forKeyPath:@"z"];
//    [as removeObserver:self forKeyPath:@"isOn"];
//
}

- (void)btleOffHandler:(NSNotification *)notification {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BTLE is off"
                                                    message:@"yo turn it on!"
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    
    [alert show];
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
    
    //YMSBluetoothService *btleService = [YMSBluetoothService sharedService];
    //DEASensorTag *sensorTag = btleService.ymsPeripherals[0];
    
    DEATemperatureService *ts = self.sensorTag.sensorServices[@"temperature"];
    DEAAccelerometerService *as = self.sensorTag.sensorServices[@"accelerometer"];

    
    if (object == ts) {
        

        if ([keyPath isEqualToString:@"ambientTemp"]) {
            double temperatureC = [ts.ambientTemp doubleValue];
            float temperatureF = (float)temperatureC * 9.0/5.0 + 32.0;
            temperatureF = roundf(100 * temperatureF)/100.0;
            self.ambientTemperatureLabel.text = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];
            
        }
        else if ([keyPath isEqualToString:@"objectTemp"]) {
            double temperatureC = [ts.objectTemp doubleValue];
            float temperatureF = (float)temperatureC * 9.0/5.0 + 32.0;
            temperatureF = roundf(100 * temperatureF)/100.0;
            self.objectTemperatureLabel.text = [NSString stringWithFormat:@"%0.2f ℉", temperatureF];

        }
        else if ([keyPath isEqualToString:@"isOn"]) {
            [self.temperatureSwitch setOn:ts.isOn animated:YES];
        }
        else if ([keyPath isEqualToString:@"isEnabled"]) {
            [self.temperatureSwitch setEnabled:ts.isEnabled];
        }


    }
    
    else if (object == as) {
        if ([keyPath isEqualToString:@"x"]) {
            self.accelXLabel.text = [NSString stringWithFormat:@"%0.2f", [as.x floatValue]];
            
        }
        else if ([keyPath isEqualToString:@"y"]) {
            self.accelYLabel.text = [NSString stringWithFormat:@"%0.2f", [as.y floatValue]];
            
        }
        
        else if ([keyPath isEqualToString:@"z"]) {
            self.accelZLabel.text = [NSString stringWithFormat:@"%0.2f", [as.z floatValue]];
            
        }
        else if ([keyPath isEqualToString:@"isOn"]) {
            [self.accelSwitch setOn:as.isOn animated:YES];
        }
        else if ([keyPath isEqualToString:@"isEnabled"]) {
            [self.accelSwitch setEnabled:as.isEnabled];
        }


    }
    

}


- (IBAction)enableAction:(id)sender {
    
    //YMSBluetoothService *btleService = [YMSBluetoothService sharedService];
    //DEASensorTag *sensorTag = btleService.ymsPeripherals[0];
    
    if (self.sensorTag != nil) {
    
        NSString *sensorName;

        UISwitch *enableSwitch = (UISwitch *)sender;
        
        if (sender == self.accelSwitch) {
            sensorName = @"accelerometer";
        }
        else {
            sensorName= @"temperature";
        }
        
        YMSCBService *btService = self.sensorTag.sensorServices[sensorName];

        
        if (enableSwitch.isOn)
            [btService turnOn];
        else
            [btService turnOff];

    }

    
}
@end
