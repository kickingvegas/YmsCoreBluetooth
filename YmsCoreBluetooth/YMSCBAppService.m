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

#include "TISensorTag.h"
#import "YMSCBAppService.h"
#import "YMSCBPeripheral.h"
#import "YMSCBService.h"
#import "YMSCBCharacteristic.h"

NSString * const YMSCBUnknownNotification = @"com.yummymelon.ymscb.unknown";
NSString * const YMSCBResettingNotification = @"com.yummymelon.ymscb.resetting";
NSString * const YMSCBUnsupportedNotification = @"com.yummymelon.ymscb.unsupported";
NSString * const YMSCBUnauthorizedNotification = @"com.yummymelon.ymscb.unauthorized";
NSString * const YMSCBPoweredOffNotification = @"com.yummymelon.ymscb.poweredoff";
NSString * const YMSCBPoweredOnNotification = @"com.yummymelon.ymscb.poweredon";


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
}


- (void)stopScan {
    [self.manager stopScan];
    self.isScanning = NO;
}


#pragma mark CBCentralManagerDelegate Protocol Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    static CBCentralManagerState oldManagerState = -1;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self loadPeripherals];
            [defaultCenter postNotificationName:YMSCBPoweredOnNotification object:self];
            break;
            
        case CBCentralManagerStateUnknown:
            [defaultCenter postNotificationName:YMSCBUnknownNotification object:self];
            break;
            
        case CBCentralManagerStatePoweredOff:
            if (oldManagerState != -1) {
                [defaultCenter postNotificationName:YMSCBPoweredOffNotification object:self];
            }
            break;
            
        case CBCentralManagerStateResetting:
            [defaultCenter postNotificationName:YMSCBResettingNotification object:self];
            break;
            
        case CBCentralManagerStateUnauthorized:
            [defaultCenter postNotificationName:YMSCBUnauthorizedNotification object:self];
            break;
            
        case CBCentralManagerStateUnsupported: {
            [defaultCenter postNotificationName:YMSCBUnsupportedNotification object:self];
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
    // THIS METHOD IS TO BE OVERRIDDEN
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

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"centralManager didRetrievePeripherals");

    for (CBPeripheral *peripheral in peripherals) {
        if ([self isAppServicePeripheral:peripheral]) {
            [self handleFoundPeripheral:peripheral withCentral:central];
        }
    }

    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if ([self isAppServicePeripheral:peripheral]) {
        YMSCBPeripheral *yp = [self findYmsPeripheral:peripheral];
        
        if (yp != nil) {
            NSArray *services = [yp services];
            [peripheral discoverServices:services];
        }
        
    }
    
    
    if (self.delegate != nil) {
        [self.delegate didConnectPeripheral:self];
    }

}



- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"centralManager didDisconnectePeripheral");
    
    
    YMSCBPeripheral *sensorTag = [self findYmsPeripheral:peripheral];
    [self.ymsPeripherals removeObject:sensorTag];
    
    if (self.delegate != nil) {
        [self.delegate didDisconnectPeripheral:self];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"centralManager didFailToConnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"centralManager didRetrieveConnectedPeripheral");
    
}


@end
