//
//  DEAPeripheralsViewController.m
//  Deanna
//
//  Created by Charles Choi on 1/19/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEAPeripheralsViewController.h"
#import "DEASensorTag.h"
#import "DEAHomeViewController.h"

@interface DEAPeripheralsViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

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
    cbAppService.delegate = self;
    
    
    [self.navigationController setToolbarHidden:NO];
    
    
    self.scanButton = [[UIBarButtonItem alloc] initWithTitle:@"Start Scanning" style:UIBarButtonItemStyleBordered target:self action:@selector(scanButtonAction:)];
    self.connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStyleBordered target:self action:@selector(connectButtonAction:)];
    
    self.toolbarItems = @[self.scanButton, self.connectButton];
    
    
    [self.peripheralsTableView reloadData];
    
    
    [cbAppService addObserver:self
                  forKeyPath:@"isScanning"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
    
    [self.connectButton setEnabled:NO];


}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    
    if (object == cbAppService) {
        if ([keyPath isEqualToString:@"isScanning"]) {
            if (cbAppService.isScanning) {
                self.scanButton.title = @"Scanning";
            }
            else {
                self.scanButton.title = @"Scan";
            }
        } else if ([keyPath isEqualToString:@"isConnected"]) {
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


- (void)connectButtonAction:(id)sender {
    NSLog(@"connectButtonAction");
    
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    
    NSIndexPath *indexPath = [self.peripheralsTableView indexPathForSelectedRow];
    DEASensorTag *sensorTag = (DEASensorTag *)[cbAppService.ymsPeripherals objectAtIndex:indexPath.row];
    
    [self.connectButton setEnabled:YES];
    
    if (sensorTag.cbPeriperheral.isConnected) {
        [cbAppService disconnectPeripheral:indexPath.row];
    } else {
        [cbAppService loadPeripherals];
    }
}




- (void)didConnectPeripheral:(id)delegate {
    NSLog(@"didConnectPeripheral:");
    
    [self.peripheralsTableView reloadData];

    
}

- (void)didDisconnectPeripheral:(id)delegate {
    NSLog(@"didDisconnectPeripheral:");
    
    self.connectButton.title = @"Connect";
    [self.connectButton setEnabled:NO];
    
    
    [self.peripheralsTableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;

}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    DEASensorTag *sensorTag = (DEASensorTag *)[cbAppService.ymsPeripherals objectAtIndex:indexPath.row];
    
    if (sensorTag.cbPeriperheral.isConnected) {
        cell.detailTextLabel.text = @"Connected";
    }
    else {
        cell.detailTextLabel.text = @"Unconnected";
    }
    
    cell.textLabel.text = sensorTag.cbPeriperheral.name;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    NSInteger result;
    result = [cbAppService.ymsPeripherals count];
    return result;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected");
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    DEASensorTag *sensorTag = (DEASensorTag *)[cbAppService.ymsPeripherals objectAtIndex:indexPath.row];
    
    [self.connectButton setEnabled:YES];
    
    if (sensorTag.cbPeriperheral.isConnected) {
        self.connectButton.title = @"Disconnect";
        
    } else {
        self.connectButton.title = @"Connect";
    }

}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    
    DEASensorTag *sensorTag = (DEASensorTag *)[cbAppService.ymsPeripherals objectAtIndex:indexPath.row];
    
    
    DEAHomeViewController *hvc = [[DEAHomeViewController alloc] initWithNibName:@"DEAHomeViewController" bundle:nil];
    
    hvc.sensorTag = sensorTag;
    
    [self.navigationController pushViewController:hvc animated:YES];
    
    
}


@end
