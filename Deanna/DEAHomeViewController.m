//
//  DTHomeViewController.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEAHomeViewController.h"
#import "YMSBluetoothService.h"
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

    YMSBluetoothService *btleService = [YMSBluetoothService sharedService];
    btleService.delegate = self;

    
    DEATemperatureService *ts = self.sensorTag.sensorServices[@"temperature"];
    DEAAccelerometerService *as = self.sensorTag.sensorServices[@"accelerometer"];
    
    [ts addObserver:self
         forKeyPath:@"ambientTemp"
            options:NSKeyValueObservingOptionNew
            context:NULL];
    
    [ts addObserver:self
         forKeyPath:@"objectTemp"
            options:NSKeyValueObservingOptionNew
            context:NULL];
    
    [ts addObserver:self
         forKeyPath:@"isEnabled"
            options:NSKeyValueObservingOptionNew
            context:NULL];
    
    
    [as addObserver:self
         forKeyPath:@"x"
            options:NSKeyValueObservingOptionNew
            context:NULL];
    [as addObserver:self
         forKeyPath:@"y"
            options:NSKeyValueObservingOptionNew
            context:NULL];
    
    [as addObserver:self
         forKeyPath:@"z"
            options:NSKeyValueObservingOptionNew
            context:NULL];
    
    [as addObserver:self
         forKeyPath:@"isEnabled"
            options:NSKeyValueObservingOptionNew
            context:NULL];
    
    if (ts.isEnabled) {
        self.temperatureSwitch.on = YES;
    }
    else {
        self.temperatureSwitch.on = NO;
    }
    
    if (as.isEnabled) {
        self.accelSwitch.on = YES;
    }
    else {
        self.accelSwitch.on = NO;
    }
        

    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    DEATemperatureService *ts = self.sensorTag.sensorServices[@"temperature"];
    DEAAccelerometerService *as = self.sensorTag.sensorServices[@"accelerometer"];
    
    //self.connectButton.title = @"Connect";
    
    [ts removeObserver:self forKeyPath:@"ambientTemp"];
    [ts removeObserver:self forKeyPath:@"objectTemp"];
    [ts removeObserver:self forKeyPath:@"isEnabled"];
    
    [as removeObserver:self forKeyPath:@"x"];
    [as removeObserver:self forKeyPath:@"y"];
    [as removeObserver:self forKeyPath:@"z"];
    [as removeObserver:self forKeyPath:@"isEnabled"];

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
        else if ([keyPath isEqualToString:@"isEnabled"]) {
            [self.temperatureSwitch setOn:ts.isEnabled animated:YES];
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
        else if ([keyPath isEqualToString:@"isEnabled"]) {
            [self.accelSwitch setOn:as.isEnabled animated:YES];
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
