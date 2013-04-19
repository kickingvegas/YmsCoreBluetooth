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

#import "DEAPeripheralsViewController.h"
#import "DEASensorTag.h"
#import "DEASensorTagViewController.h"
#import "DEAPeripheralTableViewCell.h"

@interface DEAPeripheralsViewController ()
- (void)configureCell:(DEAPeripheralTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation DEAPeripheralsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Peripherals";
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    

    [self.navigationController setToolbarHidden:NO];


    self.scanButton = [[UIBarButtonItem alloc] initWithTitle:@"Start Scanning" style:UIBarButtonItemStyleBordered target:self action:@selector(scanButtonAction:)];
    
    self.toolbarItems = @[self.scanButton];
    
    [self.peripheralsTableView reloadData];
    
    [cbAppService addObserver:self
                  forKeyPath:@"isScanning"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
    


}

- (void)viewWillAppear:(BOOL)animated {
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    cbAppService.delegate = self;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    
    if (object == cbAppService) {
        if ([keyPath isEqualToString:@"isScanning"]) {
            if (cbAppService.isScanning) {
                self.scanButton.title = @"Scanning";
            } else {
                self.scanButton.title = @"Scan";
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)scanButtonAction:(id)sender {
    NSLog(@"scanButtonAction");
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    
    if (cbAppService.isScanning == NO) {
        [cbAppService startScan];
    }
    else {
        [cbAppService stopScan];
    }
}



#pragma mark - CBCentralManagerDelegate Methods


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self.peripheralsTableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self.peripheralsTableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [self.peripheralsTableView reloadData];
}


- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    [self.peripheralsTableView reloadData];

}


- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    [self.peripheralsTableView reloadData];
}



#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 107.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    DEAPeripheralTableViewCell *cell = (DEAPeripheralTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DEAPeripheralTableViewCell" owner:self options:nil];
        cell = self.tvCell;
        self.tvCell = nil;
        
    }

    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;

}


- (void)configureCell:(DEAPeripheralTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    DEASensorTag *sensorTag = (DEASensorTag *)[cbAppService.ymsPeripherals objectAtIndex:indexPath.row];
    

    [cell configureWithSensorTag:sensorTag];
    
    cell.nameLabel.text = sensorTag.cbPeripheral.name;

    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    NSInteger result;
    result = [cbAppService.ymsPeripherals count];
    return result;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    
    DEASensorTag *sensorTag = (DEASensorTag *)[cbAppService.ymsPeripherals objectAtIndex:indexPath.row];
    
    DEASensorTagViewController *stvc = [[DEASensorTagViewController alloc] initWithNibName:@"DEASensorTagViewController" bundle:nil];
    stvc.sensorTag = sensorTag;

    
    [self.navigationController pushViewController:stvc animated:YES];
    
    
}


- (void)viewDidUnload {
    [self setTvCell:nil];
    [self setTvCell:nil];
    [super viewDidUnload];
}
@end
