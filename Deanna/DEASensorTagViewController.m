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


#import "DEASensorTagViewController.h"
#import "DEACBAppService.h"
#import "DEATemperatureViewCell.h"
#import "DEAAccelerometerViewCell.h"
#import "DEAHumidityViewCell.h"
#import "DEASimpleKeysViewCell.h"

@interface DEASensorTagViewController ()

@end

@implementation DEASensorTagViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _cbServiceCells = @[@"temperature", @"accelerometer", @"humidity", @"simplekeys"];
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
    [self setHumidityViewCell:nil];
    [self setSimplekeysViewCell:nil];
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    cbAppService.delegate = self;

    [self.temperatureViewCell configureWithSensorTag:self.sensorTag];
    [self.accelerometerViewCell configureWithSensorTag:self.sensorTag];
    [self.humidityViewCell configureWithSensorTag:self.sensorTag];
    [self.simplekeysViewCell configureWithSensorTag:self.sensorTag];
}


- (void)viewWillDisappear:(BOOL)animated {
    [self.temperatureViewCell deconfigure];
    [self.accelerometerViewCell deconfigure];
    [self.humidityViewCell deconfigure];
    [self.simplekeysViewCell deconfigure];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = self.temperatureViewCell;
        
    } else if (indexPath.section == 1) {
        cell = self.accelerometerViewCell;
    
    } else if (indexPath.section == 2) {
        cell = self.humidityViewCell;

    } else if (indexPath.section == 3) {
        cell = self.simplekeysViewCell;
    }



    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cbServiceCells count];
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
    else if (indexPath.section == 2) {
        result = self.humidityViewCell.bounds.size.height;
    }
    else if (indexPath.section == 3) {
        result = self.simplekeysViewCell.bounds.size.height;
    }

    
    return result;
}

- (void)didConnectPeripheral:(id)delegate {
}


- (void)didDisconnectPeripheral:(id)delegate {
}





@end
