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

#import "DEMAppDelegate.h"
#import "DEACentralManager.h"
#import "YMSCBPeripheral.h"
#import "DEASensorTag.h"
#import "DEMPeripheralViewCell.h"
#import "DEASimpleKeysService.h"
#import "DEASensorTagWindow.h"

@implementation DEMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    centralManager.delegate = self;
    [self.peripheralTableView reloadData];
    
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {
    
}

- (IBAction)scanAction:(id)sender {
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    
    if (centralManager.isScanning) {
        [centralManager stopScan];
        self.scanButton.title = @"Start Scanning";
        
        [self.peripheralTableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
            
            DEMPeripheralViewCell *pvc = [rowView viewAtColumn:0];
            
            if (pvc.sensorTag) {
                NSLog(@"%@", rowView);
                [pvc.connectButton setEnabled:YES];
            }
            
        }];
        
        
        
    } else {
        [centralManager startScan];
        self.scanButton.title = @"Stop Scanning";
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:@"keyValue"]) {
        DEASimpleKeysService *sks = (DEASimpleKeysService *)object;
        NSLog(@"Button %d pressed", [sks.keyValue intValue]);
    } else if ([keyPath isEqualToString:@"RSSI"]) {
        
        DEACentralManager *centralManager = [DEACentralManager sharedService];
        __weak DEASensorTag *sensorTag = (DEASensorTag *)[centralManager findPeripheral:object];
        
        [self.peripheralTableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
            
            DEMPeripheralViewCell *pvc = [rowView viewAtColumn:0];
            
            if (pvc.sensorTag == sensorTag) {
                pvc.rssiLabel.stringValue = [NSString stringWithFormat:@"%d", [sensorTag.cbPeripheral.RSSI intValue]];
                
            }
            
        }];
        
        
    }
    
}


- (void)openPeripheralWindow:(YMSCBPeripheral *)yp {
    NSLog(@"yp open: %@", yp);
    
    if (self.peripheralWindows == nil) {
        self.peripheralWindows = [NSMutableArray new];
    }
    
    BOOL foundWindow = NO;
    for (DEASensorTagWindow *stWindow in self.peripheralWindows) {
        if (stWindow.sensorTag == yp) {
            foundWindow = YES;
            [stWindow showWindow:self];
            break;
        }
    }
    
    if (foundWindow == NO) {
        DEASensorTagWindow *stWindow = [[DEASensorTagWindow alloc] init];
        
        DEASensorTag *sensorTag = (DEASensorTag *)yp;
        stWindow.sensorTag = sensorTag;
        
        [self.peripheralWindows addObject:stWindow];
        [stWindow showWindow:self];
        
    }
    
    
}




#pragma mark - NSTableViewDelegate & NSTableViewDataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger result;
    
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    
    result = centralManager.count;
    
    return result;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    DEMPeripheralViewCell *result = [tableView makeViewWithIdentifier:@"myView" owner:self];
    
    if (result == nil) {
        CGRect frame = CGRectMake(0, 0, self.peripheralTableView.bounds.size.width, 0);
        result = [[DEMPeripheralViewCell alloc] initWithFrame:frame];
        result.identifier = @"myView";
        
    }
    
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    YMSCBPeripheral *yp = centralManager.ymsPeripherals[row];
    if (yp) {
        if ([yp isKindOfClass:[DEASensorTag class]]) {
            [result configureWithSensorTag:(DEASensorTag *)yp];
        } else {
            [result.connectButton setHidden:YES];
            [result.dbLabel setHidden:YES];
            [result.rssiLabel setHidden:YES];
            [result.detailButton setHidden:YES];
        }
        
        if (yp.cbPeripheral.name != nil) {
            result.nameLabel.stringValue = yp.cbPeripheral.name;
        } else {
            result.nameLabel.stringValue = @"Unknown";
        }
    }
    
    result.delegate = self;
    
    return result;
    
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 107.0;
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView {
    return NO;
}


#pragma mark - CBCentralManager Delegate Methods

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
    yp.delegate = self;
    
    if (self.oldCount == 0) {
        self.oldCount = centralManager.count;
        [self.peripheralTableView reloadData];
    } else {
        if (centralManager.count != self.oldCount) {
            [self.peripheralTableView reloadData];
            self.oldCount = centralManager.count;
        }
    }
    
    //[self.peripheralTableView reloadData];
    
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self.peripheralTableView reloadData];
            break;
        case CBCentralManagerStatePoweredOff:
            break;
            
        case CBCentralManagerStateUnsupported: {
            NSLog(@"Can't do that.");
            break;
        }
            
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    DEASensorTag *sensorTag = (DEASensorTag *)[centralManager findPeripheral:peripheral];
    
    // TODO: Need to trigger RSSI update cycle. This may be a Cirago bug.
    [sensorTag updateRSSI];
    DEASimpleKeysService *sks = sensorTag.simplekeys;
    
    [sks addObserver:self
          forKeyPath:@"keyValue"
             options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
             context:NULL];
    
    [peripheral addObserver:self
                 forKeyPath:@"RSSI"
                    options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                    context:NULL];
    
    
    [self.peripheralTableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        DEMPeripheralViewCell *pvc = [rowView viewAtColumn:0];
        
        if (pvc.sensorTag == sensorTag) {
            
            NSLog(@"%@", rowView);
            pvc.connectButton.title = @"Disconnect";
            [pvc.detailButton setHidden:NO];
        }
        
    }];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    DEACentralManager *centralManager = [DEACentralManager sharedService];
    DEASensorTag *sensorTag = (DEASensorTag *)[centralManager findPeripheral:peripheral];
    
    DEASimpleKeysService *sks = sensorTag.simplekeys;
    
    
    [sks removeObserver:self forKeyPath:@"keyValue"];
    
    
    @try {
        [peripheral removeObserver:self forKeyPath:@"RSSI"];
    }
    @catch (NSException *exception) {
    }
    
    
    
    [self.peripheralTableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        
        
        DEMPeripheralViewCell *pvc = [rowView viewAtColumn:0];
        
        if (pvc.sensorTag == sensorTag) {
            
            NSLog(@"%@", rowView);
            pvc.connectButton.title = @"Connect";
            [pvc.detailButton setHidden:YES];
        }
        
    }];
    
    
}

#pragma mark - CBPeripheralDelegate Methods

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"RSSI: %@", peripheral.RSSI);
}

@end
