//
//  YMSBluetoothService.m
//  Deanna
//
//  Created by Charles Choi on 12/18/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//
#include "TISensorTag.h"
#import "YMSCBAppService.h"
#import "YMSCBPeripheral.h"
#import "YMSCBService.h"
#import "YMSCBCharacteristic.h"

NSString * const YMSCBPowerOffNotification = @"com.yummymelon.btleservice.power.off";

@implementation YMSCBAppService

- (id)init {
    self = [super init];
    
    if (self) {
        _ymsPeripherals = [[NSMutableArray alloc] init];
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}



- (void)persistPeripherals {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    
    for (YMSCBPeripheral *sensorTag in self.ymsPeripherals) {
        CBPeripheral *p = sensorTag.cbPeriperheral;
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


- (BOOL)isAppServicePeripheral:(CBPeripheral *)peripheral {
    BOOL result = NO;
    
    for (NSString *key in self.peripheralSearchNames) {
        result = result || [peripheral.name isEqualToString:key];
        if (result) {
            break;
        }
    }
    
    return result;
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
                [[NSNotificationCenter defaultCenter] postNotificationName:YMSCBPowerOffNotification
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



- (YMSCBPeripheral *)findYmsPeripheral:(CBPeripheral *)peripheral {
    
    YMSCBPeripheral *result;
    
    if ([self.ymsPeripherals count] == 0) {
        result = nil;
    }
    
    else {
        for (YMSCBPeripheral *sensorTag in self.ymsPeripherals) {
            if (sensorTag.cbPeriperheral == peripheral) {
                result = sensorTag;
                break;
            }
        }
    }

    return result;
}



- (void)handleFoundPeripheral:(CBPeripheral *)peripheral withCentral:(CBCentralManager *)central {
    
    YMSCBPeripheral *sensorTag;
    
    [self stopScan];
    
    sensorTag = [self findYmsPeripheral:peripheral];
    
    if (sensorTag == nil) {
        sensorTag = [[YMSCBPeripheral alloc] initWithPeripheral:peripheral];
        
        [self.ymsPeripherals addObject:sensorTag];
        
        if (peripheral.isConnected == NO) {
            [central connectPeripheral:peripheral options:nil];
        }
    }
}



- (void)connectPeripheral:(NSUInteger)index {
    if ([self.ymsPeripherals count] > 0) {
        YMSCBPeripheral *sensorTag = self.ymsPeripherals[index];
        [self.manager connectPeripheral:sensorTag.cbPeriperheral options:nil];
    }

}

- (void)disconnectPeripheral:(NSUInteger)index {
    if ([self.ymsPeripherals count] > 0) {
        YMSCBPeripheral *sensorTag = self.ymsPeripherals[index];
        [self.manager cancelPeripheralConnection:sensorTag.cbPeriperheral];
    }
}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    NSLog(@"%@, %@, %@", peripheral, peripheral.name, RSSI);

    
    if (peripheral.name != nil) {
        if ([self isAppServicePeripheral:peripheral]) {
            [self handleFoundPeripheral:peripheral withCentral:central];
        }
    }
    

}

- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"centralManager didRetrievePeripherals");
    

    for (CBPeripheral *peripheral in peripherals) {
        if ([self isAppServicePeripheral:peripheral]) {
            [self handleFoundPeripheral:peripheral withCentral:central];
        }
    }

    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 6
    if ([self isAppServicePeripheral:peripheral]) {
        YMSCBPeripheral *sensorTag = [self findYmsPeripheral:peripheral];
        
        if (sensorTag != nil) {
            NSArray *services = [sensorTag services];
            [peripheral discoverServices:services];
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
    
    YMSCBPeripheral *sensorTag = [self findYmsPeripheral:peripheral];
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
