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

#import "YMSCBCentralManager.h"
#import "YMSCBPeripheral.h"
#import "YMSCBService.h"
#import "YMSCBCharacteristic.h"
#import "YMSCBStoredPeripherals.h"

NSString *const YMSCBVersion = @"" kYMSCBVersion;

@implementation YMSCBCentralManager

- (NSString *)version {
    return YMSCBVersion;
}

#pragma mark - Constructors

- (instancetype)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue {
    self = [super init];
    
    if (self) {
        _ymsPeripherals = [NSMutableArray new];
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
        _knownPeripheralNames = nameList;
        _discoveredCallback = nil;
        _retrievedCallback = nil;
        _useStoredPeripherals = NO;
    }
    
    return self;
}

- (instancetype)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue useStoredPeripherals:(BOOL)useStore {

    self = [super init];
    
    if (self) {
        _ymsPeripherals = [NSMutableArray new];
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
        _knownPeripheralNames = nameList;
        _discoveredCallback = nil;
        _retrievedCallback = nil;
        _useStoredPeripherals = useStore;
    }
    
    if (useStore) {
        [YMSCBStoredPeripherals initializeStorage];
    }
    
    return self;
}

#pragma mark - Peripheral Management

- (NSUInteger)count {
    return  [self.ymsPeripherals count];
}


- (YMSCBPeripheral *)peripheralAtIndex:(NSUInteger)index {
    YMSCBPeripheral *result;
    result = (YMSCBPeripheral *)[self.ymsPeripherals objectAtIndex:index];
    return result;
}


- (void)addPeripheral:(YMSCBPeripheral *)yperipheral {
    [self.ymsPeripherals addObject:yperipheral];
}

- (void)removePeripheral:(YMSCBPeripheral *)yperipheral {
    if (self.useStoredPeripherals) {
        if (yperipheral.cbPeripheral.UUID != nil) {
            [YMSCBStoredPeripherals deleteUUID:yperipheral.cbPeripheral.UUID];
        }
    }
    [self.ymsPeripherals removeObject:yperipheral];
}

- (void)removePeripheralAtIndex:(NSUInteger)index {
    
    YMSCBPeripheral *yperipheral = [self.ymsPeripherals objectAtIndex:index];
    
    [self removePeripheral:yperipheral];
}

- (BOOL)isKnownPeripheral:(CBPeripheral *)peripheral {
    BOOL result = NO;
    
    for (NSString *key in self.knownPeripheralNames) {
        result = result || [peripheral.name isEqualToString:key];
        if (result) {
            break;
        }
    }
    
    return result;
}

#pragma mark - Scan Methods

- (void)startScan {
    /*
     * THIS METHOD IS TO BE OVERRIDDEN
     */
    
    NSAssert(NO, @"[YMSCBCentralManager startScan] must be be overridden and include call to [self scanForPeripherals:options:]");
    
    //[self scanForPeripheralsWithServices:nil options:nil];
}


- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options {
    [self.manager scanForPeripheralsWithServices:serviceUUIDs options:options];
    self.isScanning = YES;
}


- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options withBlock:(void (^)(CBPeripheral *, NSDictionary *, NSNumber *, NSError *))discoverCallback {
    self.discoveredCallback = discoverCallback;
    
    [self scanForPeripheralsWithServices:serviceUUIDs options:options];
}


- (void)stopScan {
    [self.manager stopScan];
    self.isScanning = NO;
}


- (YMSCBPeripheral *)findPeripheral:(CBPeripheral *)peripheral {
    
    YMSCBPeripheral *result = nil;
    
    for (YMSCBPeripheral *yPeripheral in self.ymsPeripherals) {
        if (yPeripheral.cbPeripheral == peripheral) {
            result = yPeripheral;
            break;
        }
    }
    
    return result;
}



- (void)handleFoundPeripheral:(CBPeripheral *)peripheral {
    /*
     * THIS METHOD IS TO BE OVERRIDDEN
     */
    
    NSAssert(NO, @"[YMSCBCentralManager handleFoundPeripheral:] must be be overridden.");

}


#pragma mark - Retrieve Methods

- (void)retrieveConnectedPeripherals {
    [self.manager retrieveConnectedPeripherals];
}

- (void)retrieveConnectedPeripheralswithBlock:(void (^)(CBPeripheral *))retrieveCallback {
    self.retrievedCallback = retrieveCallback;
    [self retrieveConnectedPeripherals];
}

- (void)retrievePeripherals:(NSArray *)peripheralUUIDs {
    [self.manager retrievePeripherals:peripheralUUIDs];
}

- (void)retrievePeripherals:(NSArray *)peripheralUUIDs withBlock:(void (^)(CBPeripheral *))retrieveCallback {
    self.retrievedCallback = retrieveCallback;
    [self retrievePeripherals:peripheralUUIDs];
}


#pragma mark - CBCentralManger state handler methods.

- (void)managerPoweredOnHandler {
    // THIS METHOD IS TO BE OVERRIDDEN
}

- (void)managerUnknownHandler {
    // THIS METHOD IS TO BE OVERRIDDEN
}

- (void)managerPoweredOffHandler {
    // THIS METHOD IS TO BE OVERRIDDEN
}

- (void)managerResettingHandler {
    // THIS METHOD IS TO BE OVERRIDDEN
}

- (void)managerUnauthorizedHandler {
    // THIS METHOD IS TO BE OVERRIDDEN
}

- (void)managerUnsupportedHandler {
    // THIS METHOD IS TO BE OVERRIDDEN
}

#pragma mark - CBCentralManagerDelegate Protocol Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self managerPoweredOnHandler];
            break;
            
        case CBCentralManagerStateUnknown:
            [self managerUnknownHandler];
            break;
            
        case CBCentralManagerStatePoweredOff:
            [self managerPoweredOffHandler];
            break;
            
        case CBCentralManagerStateResetting:
            [self managerResettingHandler];
            break;
            
        case CBCentralManagerStateUnauthorized:
            [self managerUnauthorizedHandler];
            break;
            
        case CBCentralManagerStateUnsupported: {
            [self managerUnsupportedHandler];
            break;
        }
    }

    if ([self.delegate respondsToSelector:@selector(centralManagerDidUpdateState:)]) {
        [self.delegate centralManagerDidUpdateState:central];
    }

}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    if (self.useStoredPeripherals) {
        [YMSCBStoredPeripherals saveUUID:peripheral.UUID];
    }
    
    if (self.discoveredCallback) {
        self.discoveredCallback(peripheral, advertisementData, RSSI, nil);
    } else {
        [self handleFoundPeripheral:peripheral];
    }


    if ([self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
        [self.delegate centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    }

}



- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    
    if (self.retrievedCallback) {
        for (CBPeripheral *peripheral in peripherals) {
            self.retrievedCallback(peripheral);
        }
    } else {
        for (CBPeripheral *peripheral in peripherals) {
            [self handleFoundPeripheral:peripheral];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(centralManager:didRetrievePeripherals:)]) {
        [self.delegate centralManager:central didRetrievePeripherals:peripherals];
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    
    for (CBPeripheral *peripheral in peripherals) {
        [self handleFoundPeripheral:peripheral];
    }

    if ([self.delegate respondsToSelector:@selector(centralManager:didRetrieveConnectedPeripherals:)]) {
        [self.delegate centralManager:central didRetrieveConnectedPeripherals:peripherals];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    YMSCBPeripheral *yp = [self findPeripheral:peripheral];
    
    [yp handleConnectionResponse:nil];
    
    if ([self.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
        [self.delegate centralManager:central didConnectPeripheral:peripheral];
    }
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    YMSCBPeripheral *yp = [self findPeripheral:peripheral];
    
    for (id key in yp.serviceDict) {
        YMSCBService *service = yp.serviceDict[key];
        service.cbService = nil;
        service.isOn = NO;
        service.isEnabled = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(centralManager:didDisconnectPeripheral:error:)]) {
        [self.delegate centralManager:central didDisconnectPeripheral:peripheral error:error];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    YMSCBPeripheral *yp = [self findPeripheral:peripheral];
    
    [yp handleConnectionResponse:error];
    
    if ([self.delegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
        [self.delegate centralManager:central didFailToConnectPeripheral:peripheral error:error];
    }
    
}



@end
