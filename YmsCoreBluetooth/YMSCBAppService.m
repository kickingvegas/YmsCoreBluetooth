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
#import "YMSCBStoredPeripherals.h"

NSString *const YMSCBVersion = @"" kYMSCBVersion;

@implementation YMSCBAppService

- (id)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue {
    self = [super init];
    
    if (self) {
        _ymsPeripherals = [NSMutableArray new];
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
        _knownPeripheralNames = nameList;
        _connectionCallbackDict = [NSMutableDictionary new];
        _discoveredCallback = nil;
        _retrievedCallback = nil;
        _useStoredPeripherals = NO;
    }
    
    return self;
}

- (id)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue useStoredPeripherals:(BOOL)useStore {

    self = [super init];
    
    if (self) {
        _ymsPeripherals = [NSMutableArray new];
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
        _knownPeripheralNames = nameList;
        _connectionCallbackDict = [NSMutableDictionary new];
        _discoveredCallback = nil;
        _retrievedCallback = nil;
        _useStoredPeripherals = useStore;
    }
    
    if (useStore) {
        [YMSCBStoredPeripherals initializeStorage];
    }
    
    return self;
}


- (void)persistPeripherals {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    
    for (YMSCBPeripheral *sensorTag in self.ymsPeripherals) {
        CBPeripheral *p = sensorTag.cbPeripheral;
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
}

- (YMSCBPeripheral *)peripheralAtIndex:(NSUInteger)index {
    YMSCBPeripheral *result;
    result = (YMSCBPeripheral *)[self.ymsPeripherals objectAtIndex:index];
    return result;
}

- (NSUInteger)count {
    return  [self.ymsPeripherals count];
}

- (NSString *)version {
    return YMSCBVersion;
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


- (void)startScan {
    /*
     * THIS METHOD IS TO BE OVERRIDDEN
     */
    
    NSAssert(NO, @"[YMSCBAppService startScan] must be be overridden and include call to [self scanForPeripherals:options:]");
    
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
    
    NSAssert(NO, @"[YMSCBAppService handleFoundPeripheral:] must be be overridden.");

}

- (void)handleConnectedPeripheral:(CBPeripheral *)peripheral {
    /*
     * THIS METHOD IS TO BE OVERRIDDEN
     */

    NSAssert(NO, @"[YMSCBAppService handleConnectedPeripheral:] must be be overridden.");
}


- (void)connectPeripheralAtIndex:(NSUInteger)index options:(NSDictionary *)options {
    if ([self.ymsPeripherals count] > 0) {
        YMSCBPeripheral *yPeripheral = self.ymsPeripherals[index];
        [self connectPeripheral:yPeripheral options:options];
    }
}

- (void)connectPeripheralAtIndex:(NSUInteger)index options:(NSDictionary *)options withBlock:(void (^)(YMSCBPeripheral *, NSError *))connectCallback {
    
    if ([self.ymsPeripherals count] > 0) {
        YMSCBPeripheral *yPeripheral = self.ymsPeripherals[index];
        NSString *uuidString = UUID2STRING(yPeripheral.cbPeripheral.UUID);
        self.connectionCallbackDict[uuidString] = connectCallback;
        [self connectPeripheral:yPeripheral options:options];
    }
}

- (void)disconnectPeripheralAtIndex:(NSUInteger)index {
    if ([self.ymsPeripherals count] > 0) {
        YMSCBPeripheral *yPeripheral = self.ymsPeripherals[index];
        [self.manager cancelPeripheralConnection:yPeripheral.cbPeripheral];
    }
}

- (void)connect:(YMSCBPeripheral *)peripheral {
    NSAssert(NO, @"[YMSCBAppService connect:] must be be overridden.");
}


- (void)connectPeripheral:(YMSCBPeripheral *)peripheral options:(NSDictionary *)options {
    [self.manager connectPeripheral:peripheral.cbPeripheral options:options];
}

- (void)connectPeripheral:(YMSCBPeripheral *)peripheral options:(NSDictionary *)options withBlock:(void (^)(YMSCBPeripheral *, NSError *))connectCallback {
    
    NSString *uuidString = UUID2STRING(peripheral.cbPeripheral.UUID);
    
    self.connectionCallbackDict[uuidString] = connectCallback;
    [self connectPeripheral:peripheral options:options];
}

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

- (void)cancelPeripheralConnection:(YMSCBPeripheral *)peripheral {
    [self.manager cancelPeripheralConnection:peripheral.cbPeripheral];
}

#pragma mark CBCentralManger state handler methods.

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

#pragma mark CBCentralManagerDelegate Protocol Methods

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
    
    NSString *uuidString = UUID2STRING(peripheral.UUID);
    
    if ([self isKnownPeripheral:peripheral]) {
        YMSCBConnectCallbackBlockType cb = self.connectionCallbackDict[uuidString];
        if (cb) {
            YMSCBPeripheral *yp = [self findPeripheral:peripheral];
            if (yp) {
                cb(yp, nil);
                [self.connectionCallbackDict removeObjectForKey:uuidString];
            }
        } else {
            [self handleConnectedPeripheral:peripheral];
        }
        
    }
    

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
    
    NSString *uuidString = UUID2STRING(peripheral.UUID);
    
    YMSCBConnectCallbackBlockType cb = self.connectionCallbackDict[uuidString];
    
    if (cb) {
        YMSCBPeripheral *yp = [self findPeripheral:peripheral];
        cb(yp, error);
        [self.connectionCallbackDict removeObjectForKey:uuidString];
    }
    
    if ([self.delegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
        [self.delegate centralManager:central didFailToConnectPeripheral:peripheral error:error];
    }
    
}



@end
