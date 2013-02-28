//
//  DEASensorTagViewController.m
//  Deanna
//
//  Created by Charles Choi on 2/27/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEASensorTagViewController.h"
#import "DEACBAppService.h"
#import "DEATemperatureViewCell.h"

@interface DEASensorTagViewController ()

@end

@implementation DEASensorTagViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _cbServiceCells = @[@"temperature", @"accelerometer"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Deanna";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSensorTableView:nil];
    [self setTemperatureViewCell:nil];
    [self setAccelerometerViewCell:nil];
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    cbAppService.delegate = self;

    [self.temperatureViewCell configureWithSensorTag:self.sensorTag];

    
//    DEATemperatureService *ts = self.sensorTag.serviceDict[@"temperature"];
//    DEAAccelerometerService *as = self.sensorTag.serviceDict[@"accelerometer"];
//    DEAHumidityService *hs = self.sensorTag.serviceDict[@"humidity"];
//    
//    for (NSString *key in @[@"ambientTemp", @"objectTemp", @"isOn", @"isEnabled"]) {
//        [ts addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
//    }
//    
//    for (NSString *key in @[@"x", @"y", @"z", @"isOn", @"isEnabled"]) {
//        [as addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
//    }
//    
//    for (NSString *key in @[@"ambientTemp", @"relativeHumidity", @"isOn", @"isEnabled"]) {
//        [hs addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
//    }
//    
//    
//    
//    [self.temperatureSwitch setOn:ts.isOn animated:YES];
//    [self.temperatureSwitch setEnabled:ts.isEnabled];
//    
//    [self.accelSwitch setOn:as.isOn animated:YES];
//    [self.accelSwitch setEnabled:as.isEnabled];
//    
//    [self.humiditySwitch setOn:hs.isOn animated:YES];
//    [self.humiditySwitch setEnabled:hs.isEnabled];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [self.temperatureViewCell deconfigure];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = self.temperatureViewCell;
        
    } else if (indexPath.section == 1) {
        cell = self.accelerometerViewCell;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *result;
    
    result = [self.cbServiceCells objectAtIndex:section];
    
    return result;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = 44.0;
    
    if (indexPath.section == 0) {
        result = self.temperatureViewCell.bounds.size.height;
    }
    else if (indexPath.section == 1) {
        result = self.accelerometerViewCell.bounds.size.height;
    }
    
    return result;
}

- (void)didConnectPeripheral:(id)delegate {
}


- (void)didDisconnectPeripheral:(id)delegate {
}





@end
