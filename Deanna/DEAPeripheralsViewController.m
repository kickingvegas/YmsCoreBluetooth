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
    
    DEACBAppService *btleService = [DEACBAppService sharedService];
    btleService.delegate = self;
    
    
    [self.navigationController setToolbarHidden:NO];
    
    
    self.scanButton = [[UIBarButtonItem alloc] initWithTitle:@"Start Scanning" style:UIBarButtonItemStyleBordered target:self action:@selector(scanButtonAction:)];
    
    self.connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStyleBordered target:self action:@selector(connectButtonAction:)];
    
    self.toolbarItems = @[self.scanButton, self.connectButton];
    
    
    [self.peripheralsTableView reloadData];
    
    
    

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)scanButtonAction:(id)sender {
    NSLog(@"scanButtonAction");
    
    DEACBAppService *btleService = [DEACBAppService sharedService];
    
    if (btleService.isScanning == NO) {
        [btleService startScan];
    }
    else {
        [btleService stopScan];
    }
}


- (void)connectButtonAction:(id)sender {
    NSLog(@"connectButtonAction");
    
    DEACBAppService *btleService = [DEACBAppService sharedService];
    
    
    // TODO: handle N case
    
    if (btleService.isConnected == YES) {
        [btleService disconnectPeripheral:0];
    }
    else {
        [btleService loadPeripherals];
    }
    
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
    self.scanButton.title = @"Stop Scanning";
}

- (void)hasStoppedScanning:(id)delegate {
    self.scanButton.title = @"Start Scanning";
}

- (void)didConnectPeripheral:(id)delegate {
    NSLog(@"didConnectPeripheral:");
    
    [self.peripheralsTableView reloadData];

    
}

- (void)didDisconnectPeripheral:(id)delegate {
    NSLog(@"didDisconnectPeripheral:");
    
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
    
    DEACBAppService *btleService = [DEACBAppService sharedService];
    
    DEASensorTag *sensorTag = (DEASensorTag *)[btleService.ymsPeripherals objectAtIndex:indexPath.row];
    
    if (sensorTag.cbPeriperheral.isConnected) {
        cell.detailTextLabel.text = @"Connected";
    }
    else {
        cell.detailTextLabel.text = @"Unconnected";
    }
    
    cell.textLabel.text = sensorTag.cbPeriperheral.name;
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    DEACBAppService *btleService = [DEACBAppService sharedService];
    
    NSInteger result;
    
    result = [btleService.ymsPeripherals count];
    
    return result;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected");

    
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    DEACBAppService *btleService = [DEACBAppService sharedService];
    
    DEASensorTag *sensorTag = (DEASensorTag *)[btleService.ymsPeripherals objectAtIndex:indexPath.row];
    
    
    DEAHomeViewController *hvc = [[DEAHomeViewController alloc] initWithNibName:@"DEAHomeViewController" bundle:nil];
    
    hvc.sensorTag = sensorTag;
    
    [self.navigationController pushViewController:hvc animated:YES];
    
    
}


@end
