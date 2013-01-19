//
//  DTBTLEService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//
#include "TISensorTag.h"
#import "DEABluetoothService.h"
#import "DEASensorTag.h"

NSString * const DTBTLEServicePowerOffNotification = @"com.yummymelon.btleservice.power.off";

static DEABluetoothService *sharedBluetoothService;

@implementation DEABluetoothService

+ (DEABluetoothService *)sharedService {
    if (sharedBluetoothService == nil) {
        sharedBluetoothService = [[super allocWithZone:NULL] init];
    }
    return sharedBluetoothService;
}


- (id)init {
    self = [super init];
    
    if (self) {
        _ymsPeripherals = [[NSMutableArray alloc] init];
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}


- (BOOL)isSensorTagPeripheral:(CBPeripheral *)peripheral {
    BOOL result = NO;
    
    result = [peripheral.name isEqualToString:@"TI BLE Sensor Tag"];
    
    return result;
}


- (void)persistPeripherals {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    
    for (CBPeripheral *p in self.ymsPeripherals) {
        CFStringRef uuidString = NULL;
        
        uuidString = CFUUIDCreateString(NULL, p.UUID);
        if (uuidString) {
            [devices addObject:(NSString *)CFBridgingRelease(uuidString)];
        }
    }

    [userDefaults setObject:devices forKey:@"storedPeripherals"];
    [userDefaults synchronize];
}


- (void)loadPeripherals {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [userDefaults arrayForKey:@"storedPeripherals"];
    NSMutableArray *peripheralUUIDList = [[NSMutableArray alloc] init];
    
    if (![devices isKindOfClass:[NSArray class]]) {
        // TODO - need right error handler
        NSLog(@"No stored array to load");
    }
    
    for (id uuidString in devices) {
        if (![uuidString isKindOfClass:[NSString class]]) {
            continue;
        }
        
        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)uuidString);
        
        if (!uuid)
            continue;
        
        [peripheralUUIDList addObject:(id)CFBridgingRelease(uuid)];
    }
    
    if ([peripheralUUIDList count] > 0) {
        [self.manager retrievePeripherals:peripheralUUIDList];
    }
    else {
        [self startScan];
    }
}


- (void)startScan {
    [self.manager scanForPeripheralsWithServices:nil options:nil];
    self.isScanning = YES;
    
    if (self.delegate != nil) {
        [self.delegate hasStartedScanning:self];
    }
}


- (void)stopScan {
    [self.manager stopScan];
    self.isScanning = NO;
    
    if (self.delegate != nil) {
        [self.delegate hasStoppedScanning:self];
    }

}


#pragma mark CBCentralManagerDelegate Protocol Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    static CBCentralManagerState oldManagerState = -1;
    
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"cbcm powered on");
            //[self.manager scanForPeripheralsWithServices:nil options:nil];
            [self loadPeripherals];
            
            break;
            
        case CBCentralManagerStateUnknown:
            NSLog(@"cbcm unknown");
            break;
            
        case CBCentralManagerStatePoweredOff:
            NSLog(@"cbcm powered off");

            if (oldManagerState != -1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DTBTLEServicePowerOffNotification
                                                                    object:self];
                
            }
            break;
            
        case CBCentralManagerStateResetting:
            NSLog(@"cbcm resetting");
            break;
            
        case CBCentralManagerStateUnauthorized:
            NSLog(@"cbcm unauthorized");
            break;
            
        case CBCentralManagerStateUnsupported: {
            NSLog(@"cbcm unsupported");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            
            [alert show];
            break;
        }
    }
    
    oldManagerState = central.state;
}



- (DEASensorTag *)findYmsPeripheral:(CBPeripheral *)peripheral {
    
    DEASensorTag *result;
    
    if ([self.ymsPeripherals count] == 0) {
        result = nil;
    }
    
    else {
        for (DEASensorTag *sensorTag in self.ymsPeripherals) {
            if (sensorTag.cbPeriperheral == peripheral) {
                result = sensorTag;
                break;
            }
        }
    }

    return result;
}



- (void)handleFoundPeripheral:(CBPeripheral *)peripheral withCentral:(CBCentralManager *)central {
    
    DEASensorTag *sensorTag;
    
    sensorTag = [self findYmsPeripheral:peripheral];
    
    if (sensorTag == nil) {
        sensorTag = [[DEASensorTag alloc] initWithPeripheral:peripheral];
        
        [self.ymsPeripherals addObject:sensorTag];
        
        if (peripheral.isConnected == NO) {
            [central connectPeripheral:peripheral options:nil];
        }
    }
}



- (void)connectPeripheral:(NSUInteger)index {
    if ([self.ymsPeripherals count] > 0) {
        DEASensorTag *sensorTag = self.ymsPeripherals[index];
        [self.manager connectPeripheral:sensorTag.cbPeriperheral options:nil];
    }

}

- (void)disconnectPeripheral:(NSUInteger)index {
    if ([self.ymsPeripherals count] > 0) {
        DEASensorTag *sensorTag = self.ymsPeripherals[index];
        [self.manager cancelPeripheralConnection:sensorTag.cbPeriperheral];
    }
}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    NSLog(@"%@", peripheral);
    
    [self handleFoundPeripheral:peripheral withCentral:central];
    

}

- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"centralManager didRetrievePeripherals");
    

    for (CBPeripheral *peripheral in peripherals) {
        [self handleFoundPeripheral:peripheral withCentral:central];
    }

    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 6

    if ([self isSensorTagPeripheral:peripheral]) {
        DEASensorTag *sensorTag = [self findYmsPeripheral:peripheral];
        
        if (sensorTag != nil) {
            [peripheral discoverServices:[sensorTag services]];
        }
        
    }
    
    self.isConnected = YES;
    
    if (self.delegate != nil) {
        [self.delegate didConnectPeripheral:self];
    }

}



- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"centralManager didDisconnectePeripheral");
    
    if (self.delegate != nil) {
        [self.delegate didDisconnectPeripheral:self];
    }
    
    DEASensorTag *sensorTag = [self findYmsPeripheral:peripheral];
    [self.ymsPeripherals removeObject:sensorTag];
    
    self.isConnected = NO;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"centralManager didFailToConnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"centralManager didRetrieveConnectedPeripheral");
    
}


@end
