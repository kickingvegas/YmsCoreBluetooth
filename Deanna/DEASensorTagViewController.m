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
#import "DEAGyroscopeViewCell.h"

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
                            , @"gyroscope"
                            , @"humidity"
                            , @"barometer"
                            ];
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
    
    for (NSString *prefix in self.cbServiceCells) {
        NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
        [self setValue:nil forKey:key];
    }
    /*
    [self setTemperatureViewCell:nil];
    [self setAccelerometerViewCell:nil];
    [self setHumidityViewCell:nil];
    [self setSimplekeysViewCell:nil];
    [self setBarometerViewCell:nil];
    [self setGyroscopeViewCell:nil];
     */
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    cbAppService.delegate = self;
    
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
    
    return result;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = 44.0;
    
    NSString *prefix = (NSString *)[self.cbServiceCells objectAtIndex:indexPath.section];
    NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
    UITableViewCell *cell = (UITableViewCell *)[self valueForKey:key];
    result = cell.bounds.size.height;
    
    return result;
}

- (void)didConnectPeripheral:(id)delegate {
}


- (void)didDisconnectPeripheral:(id)delegate {
}





@end
