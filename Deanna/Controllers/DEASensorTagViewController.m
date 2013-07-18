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
#import "DEACentralManager.h"
#import "DEATemperatureViewCell.h"
#import "DEAAccelerometerViewCell.h"
#import "DEAHumidityViewCell.h"
#import "DEASimpleKeysViewCell.h"
#import "DEAGyroscopeViewCell.h"
#import "DEASensorTag.h"
#import "YMSCBService.h"
#import "YMSCBCharacteristic.h"
#import "DEATemperatureService.h"
#import "DEATheme.h"

@interface DEASensorTagViewController ()

@end

@implementation DEASensorTagViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _cbServiceCells = @[@"simplekeys"
                            , @"temperature"
                            , @"accelerometer"
                            , @"magnetometer"
                            , @"gyroscope"
                            , @"humidity"
                            , @"barometer"
                            , @"devinfo"
                            ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.sensorTag.cbPeripheral.name;
    
    self.rssiButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.toolbarItems = @[flexSpace, self.rssiButton];
    
    [DEATheme customizeTableView:self.sensorTableView forType:DEAPeripheralDetailTableViewStyle];
    
    for (NSString *prefix in self.cbServiceCells) {
        NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
        [DEATheme customizeSensorTableViewCell:[self valueForKey:key]];
    }


}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSensorTableView:nil];
    [self setRssiButton:nil];
    
    for (NSString *prefix in self.cbServiceCells) {
        NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
        [self setValue:nil forKey:key];
    }

    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    centralManager.delegate = self;
    
    self.sensorTag.delegate = self;
    
    for (NSString *prefix in self.cbServiceCells) {
        NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
        UITableViewCell *cell = (UITableViewCell *)[self valueForKey:key];
        
        if ([cell respondsToSelector:@selector(configureWithSensorTag:)]) {
            [cell performSelector:@selector(configureWithSensorTag:) withObject:self.sensorTag];
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated {

    for (NSString *prefix in self.cbServiceCells) {
        NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
        UITableViewCell *cell = (UITableViewCell *)[self valueForKey:key];
        if ([cell respondsToSelector:@selector(deconfigure)]) {
            [cell performSelector:@selector(deconfigure)];
        }
    }
}


#pragma mark - UITableViewDelegate & UITableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSString *prefix = (NSString *)[self.cbServiceCells objectAtIndex:indexPath.section];
    NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
    cell = (UITableViewCell *)[self valueForKey:key];
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
    return [result uppercaseString];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = 44.0;
    
    NSString *prefix = (NSString *)[self.cbServiceCells objectAtIndex:indexPath.section];
    NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
    UITableViewCell *cell = (UITableViewCell *)[self valueForKey:key];
    result = cell.bounds.size.height;
    
    return result;
}


#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected"
                                                    message:@"This peripheral has been disconnected."
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    
    [alert show];
    
    
    // Quick and dirty hack! But good enough to let the previous view controller that the disconnection happened.
    
    [self.navigationController.viewControllers[0] centralManager:central didDisconnectPeripheral:peripheral error:error];
    
}


#pragma mark - CBPeripheralDelegate Methods

- (void)performUpdateRSSI:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    
    [peripheral readRSSI];
    
}



- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    //NSLog(@"HEY got here");
    
    if (error) {
        NSLog(@"ERROR: readRSSI failed, retrying. %@", error.description);
        
        if (peripheral.state == CBPeripheralStateConnected) {
            NSArray *args = @[peripheral];
            [self performSelector:@selector(performUpdateRSSI:) withObject:args afterDelay:2.0];
        }
        
        return;
    }
    
    self.rssiButton.title = [NSString stringWithFormat:@"%@ db", peripheral.RSSI];
    
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
    
    NSArray *args = @[peripheral];
    [self performSelector:@selector(performUpdateRSSI:) withObject:args afterDelay:yp.rssiPingPeriod];

}

/*
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //NSLog(@"HEY updating characteristic");
    

    if (characteristic.isNotifying) {
        YMSCBService *btService = [self.sensorTag findService:characteristic.service];
        YMSCBCharacteristic *ct = [btService findCharacteristic:characteristic];
        
        if ([btService isKindOfClass:[DEATemperatureService class]]) {
            [self.temperatureViewCell updateDisplayForCharacteristicName:ct.name];
        }
        
    }
}
*/


@end
