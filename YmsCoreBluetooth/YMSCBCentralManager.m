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

@interface YMSCBCentralManager ()


// Helper methods to perform delegate method on main thread.

- (void)performCentralManagerDidConnectPeripheralWithObject:(NSArray *)args;
- (void)performCentralManagerDidDisconnectPeripheralWithObject:(NSArray *)args;
- (void)performCentralManagerDidFailToConnectPeripheralWithObject:(NSArray *)args;

- (void)performCentralManagerDidDiscoverPeripheralWithObject:(NSArray *)args;
- (void)performCentralManagerDidRetrieveConnectedPeripheralsWithObject:(NSArray *)arg;
- (void)performCentralManagerDidRetrievePeripheralsWithObject:(NSArray *)args;

- (void)performCentralManagerDidUpdateStateWithObject:(NSArray *)args;

@end

@implementation YMSCBCentralManager

- (NSString *)version {
    return YMSCBVersion;
}

#pragma mark - Constructors

- (instancetype)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue delegate:(id<CBCentralManagerDelegate>) delegate; {
    self = [super init];
    
    if (self) {
        _ymsPeripherals = [NSMutableArray new];
        _delegate = delegate;
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
        _knownPeripheralNames = nameList;
        _discoveredCallback = nil;
        _retrievedCallback = nil;
        _useStoredPeripherals = NO;
    }
    
    return self;
}

- (instancetype)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue useStoredPeripherals:(BOOL)useStore delegate:(id<CBCentralManagerDelegate>)delegate {

    self = [super init];
    
    if (self) {
        _ymsPeripherals = [NSMutableArray new];
        _delegate = delegate;
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
- (void)performCentralManagerDidUpdateStateWithObject:(NSArray *)args {
    CBCentralManager *central = args[0];
    [self.delegate centralManagerDidUpdateState:central];
}

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
        NSArray *args = @[central];
        [self performSelectorOnMainThread:@selector(performCentralManagerDidUpdateStateWithObject:) withObject:args waitUntilDone:NO];
    }

}


- (void)performCentralManagerDidDiscoverPeripheralWithObject:(NSArray *)args {
    CBCentralManager *central = args[0];
    CBPeripheral *peripheral = args[1];
    NSDictionary *advertisementData = args[2];
    NSNumber *RSSI = args[3];
    [self.delegate centralManager:central
            didDiscoverPeripheral:peripheral
                advertisementData:advertisementData
                             RSSI:RSSI];
    
     
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
        NSArray *args = @[central, peripheral, advertisementData, RSSI];
        [self performSelectorOnMainThread:@selector(performCentralManagerDidDiscoverPeripheralWithObject:) withObject:args waitUntilDone:NO];
    }

}


- (void)performCentralManagerDidRetrievePeripheralsWithObject:(NSArray *)args {
    CBCentralManager *central = args[0];
    NSArray *peripherals = args[1];
    [self.delegate centralManager:central didRetrievePeripherals:peripherals];
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
        //[self.delegate centralManager:central didRetrievePeripherals:peripherals];
        NSArray *args = @[central, peripherals];
        [self performSelectorOnMainThread:@selector(performCentralManagerDidRetrievePeripheralsWithObject:) withObject:args waitUntilDone:NO];
    }
}

- (void)performCentralManagerDidRetrieveConnectedPeripheralsWithObject:(NSArray *)args {
    CBCentralManager *central = args[0];
    NSArray *peripherals = args[1];
    [self.delegate centralManager:central didRetrieveConnectedPeripherals:peripherals];
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    
    for (CBPeripheral *peripheral in peripherals) {
        [self handleFoundPeripheral:peripheral];
    }

    if ([self.delegate respondsToSelector:@selector(centralManager:didRetrieveConnectedPeripherals:)]) {
        NSArray *args = @[central, peripherals];
        [self performSelectorOnMainThread:@selector(performCentralManagerDidRetrieveConnectedPeripheralsWithObject:) withObject:args waitUntilDone:NO];
    }
    
}


- (void)performCentralManagerDidConnectPeripheralWithObject:(NSArray *)args {
    CBCentralManager *central = args[0];
    CBPeripheral *peripheral = args[1];
    [self.delegate centralManager:central didConnectPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    YMSCBPeripheral *yp = [self findPeripheral:peripheral];
    
    [yp handleConnectionResponse:nil];
    
    if ([self.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
        NSArray *args = @[central, peripheral];
        [self performSelectorOnMainThread:@selector(performCentralManagerDidConnectPeripheralWithObject:) withObject:args waitUntilDone:NO];
    }
}


- (void)performCentralManagerDidDisconnectPeripheralWithObject:(NSArray *)args {
    CBCentralManager *central = args[0];
    CBPeripheral *peripheral = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }

    [self.delegate centralManager:central didDisconnectPeripheral:peripheral error:error];
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
        NSArray *args;
        
        if (error) {
            args = @[central, peripheral, error];
        } else {
            args = @[central, peripheral, [NSNull null]];
        }

        [self performSelectorOnMainThread:@selector(performCentralManagerDidDisconnectPeripheralWithObject:) withObject:args waitUntilDone:NO];
    }
    
}

- (void)performCentralManagerDidFailToConnectPeripheralWithObject:(NSArray *)args {
    CBCentralManager *central = args[0];
    CBPeripheral *peripheral = args[1];
    NSError *error = args[2];
    if ((id)error == [NSNull null]) {
        error = nil;
    }

    [self.delegate centralManager:central didFailToConnectPeripheral:peripheral error:error];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    YMSCBPeripheral *yp = [self findPeripheral:peripheral];
    
    [yp handleConnectionResponse:error];
    
    if ([self.delegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
        NSArray *args;
        
        if (error) {
            args = @[central, peripheral, error];
        } else {
            args = @[central, peripheral, [NSNull null]];
        }

        [self performSelectorOnMainThread:@selector(performCentralManagerDidFailToConnectPeripheralWithObject:) withObject:args waitUntilDone:NO];
    }
    
}



@end
