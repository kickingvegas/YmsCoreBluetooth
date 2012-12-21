//
//  DTHomeViewController.m
//  Deanna
//
//  Created by Charles Choi on 12/17/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DTHomeViewController.h"
#import "DTBTLEService.h"
#import "DTSensorTag.h"
#import "DTTemperatureBTService.h"
#import "DTAccelerometerBTService.h"

@interface DTHomeViewController ()

- (void)btleOffHandler:(NSNotification *)notification;
    

@end

@implementation DTHomeViewController

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
    

    DTBTLEService *btleService = [DTBTLEService sharedService];
    
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
    
    DTBTLEService *btleService = [DTBTLEService sharedService];
    DTSensorTag *sensorTag = btleService.sensorTag;
    
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

                

            }
        }
    }
    
    
    if (object == ts) {
        

        if ([keyPath isEqualToString:@"ambientTemp"]) {
            self.ambientTemperatureLabel.text = [NSString stringWithFormat:@"%d", [ts.ambientTemp intValue]];
            
        }
        else if ([keyPath isEqualToString:@"objectTemp"]) {
            self.objectTemperatureLabel.text = [NSString stringWithFormat:@"%d", [ts.objectTemp intValue]];

        }
    }
    
    else if (object == as) {
        if ([keyPath isEqualToString:@"x"]) {
            self.accelXLabel.text = [NSString stringWithFormat:@"%d", [as.x intValue]];
            
        }
        else if ([keyPath isEqualToString:@"y"]) {
            self.accelYLabel.text = [NSString stringWithFormat:@"%d", [as.y intValue]];
            
        }
        
        else if ([keyPath isEqualToString:@"z"]) {
            self.accelZLabel.text = [NSString stringWithFormat:@"%d", [as.z intValue]];
            
        }


    }
    

}


@end
