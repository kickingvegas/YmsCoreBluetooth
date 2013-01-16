//
//  DTHomeViewController.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEAHomeViewController.h"
#import "DEABluetoothService.h"
#import "DEASensorTag.h"
#import "DTTemperatureBTService.h"
#import "DTAccelerometerBTService.h"

@interface DEAHomeViewController ()

- (void)btleOffHandler:(NSNotification *)notification;
    

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
    // Do any additional setup after loading the view from its nib.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btleOffHandler:) name:DTBTLEServicePowerOffNotification object:nil];
    

    DEABluetoothService *btleService = [DEABluetoothService sharedService];
    
    [btleService addObserver:self
                  forKeyPath:@"sensorTagEnabled"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
    
    
    
    
}


- (void)btleOffHandler:(NSNotification *)notification {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BTLE is off"
                                                    message:@"yo turn it on!"
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    DEABluetoothService *btleService = [DEABluetoothService sharedService];
    DEASensorTag *sensorTag = btleService.sensorTag;
    
    DTTemperatureBTService *ts = sensorTag.sensorServices[@"temperature"];
    DTAccelerometerBTService *as = sensorTag.sensorServices[@"accelerometer"];

    if (object == btleService) {
        if ([keyPath isEqualToString:@"sensorTagEnabled"]) {
            if (btleService.sensorTagEnabled) {
                [ts addObserver:self
                     forKeyPath:@"ambientTemp"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
                
                [ts addObserver:self
                     forKeyPath:@"objectTemp"
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
                

                [ts addObserver:self
                     forKeyPath:@"isEnabled"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
                
                [as addObserver:self
                     forKeyPath:@"isEnabled"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
                

                

            }
        }
    }
    
    
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
            [self.accelSwitch setOn:ts.isEnabled animated:YES];
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
    
    DEABluetoothService *btleService = [DEABluetoothService sharedService];
    DEASensorTag *sensorTag = btleService.sensorTag;
    
    if (sensorTag != nil) {
    
        NSString *sensorName;

        UISwitch *enableSwitch = (UISwitch *)sender;
        
        if (sender == self.accelSwitch) {
            sensorName = @"accelerometer";
        }
        else {
            sensorName= @"temperature";
        }
        
        DEABaseCBService *btService = sensorTag.sensorServices[sensorName];

        
        if (enableSwitch.isOn)
            [btService turnOn];
        else
            [btService turnOff];

    }

    
}
@end
