// 
// Copyright 2013-2014 Yummy Melon Software LLC
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
{
    NSMutableArray *_ymsPeripherals;
}

@property (atomic, strong) NSMutableArray *ymsPeripherals;

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
    return  [self countOfYmsPeripherals];
}

- (YMSCBPeripheral *)peripheralAtIndex:(NSUInteger)index {
    return [self objectInYmsPeripheralsAtIndex:index];
}


- (void)addPeripheral:(YMSCBPeripheral *)yperipheral {
    [self insertObject:yperipheral inYmsPeripheralsAtIndex:self.countOfYmsPeripherals];
}

- (void)removePeripheral:(YMSCBPeripheral *)yperipheral {
    [self removeObjectFromYmsPeripheralsAtIndex:[self.ymsPeripherals indexOfObject:yperipheral]];
}

- (void)removePeripheralAtIndex:(NSUInteger)index {
    [self removeObjectFromYmsPeripheralsAtIndex:index];
}

- (void)removeAllPeripherals {
    while ([self countOfYmsPeripherals] > 0) {
        [self removePeripheralAtIndex:0];
    }
}

- (NSUInteger)countOfYmsPeripherals {
    return _ymsPeripherals.count;
}

- (id)objectInYmsPeripheralsAtIndex:(NSUInteger)index {
    return [_ymsPeripherals objectAtIndex:index];
}

- (void)insertObject:(YMSCBPeripheral *)object inYmsPeripheralsAtIndex:(NSUInteger)index {
    [_ymsPeripherals insertObject:object atIndex:index];
}

- (void)removeObjectFromYmsPeripheralsAtIndex:(NSUInteger)index {
    if (self.useStoredPeripherals) {
        YMSCBPeripheral *yperipheral = [self.ymsPeripherals objectAtIndex:index];
        if (yperipheral.cbPeripheral.identifier != nil) {
            [YMSCBStoredPeripherals deleteUUID:yperipheral.cbPeripheral.identifier];
        }
    }
    [_ymsPeripherals removeObjectAtIndex:index];
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
    NSArray *peripheralsCopy = [NSArray arrayWithArray:self.ymsPeripherals];
    
    for (YMSCBPeripheral *yPeripheral in peripheralsCopy) {
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

- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs {
    NSArray *result = [self.manager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
    [self centralManager:self.manager didRetrieveConnectedPeripherals:result];
    return result;
}


- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers {
    NSArray *result = [self.manager retrievePeripheralsWithIdentifiers:identifiers];
    [self centralManager:self.manager didRetrievePeripherals:result];
    return result;
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
    // CALL SUPER METHOD
    // THIS METHOD MUST BE INVOKED BY SUBCLASSES THAT OVERRIDE THIS METHOD
    [_ymsPeripherals removeAllObjects];
}

- (void)managerUnauthorizedHandler {
    // THIS METHOD IS TO BE OVERRIDDEN
}

- (void)managerUnsupportedHandler {
    // THIS METHOD IS TO BE OVERRIDDEN
}

#pragma mark - CBCentralManagerDelegate Protocol Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    __weak YMSCBCentralManager *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        switch (central.state) {
            case CBCentralManagerStatePoweredOn:
                [this managerPoweredOnHandler];
                break;
                
            case CBCentralManagerStateUnknown:
                [this managerUnknownHandler];
                break;
                
            case CBCentralManagerStatePoweredOff:
                [this managerPoweredOffHandler];
                break;
                
            case CBCentralManagerStateResetting:
                [this managerResettingHandler];
                break;
                
            case CBCentralManagerStateUnauthorized:
                [this managerUnauthorizedHandler];
                break;
                
            case CBCentralManagerStateUnsupported: {
                [this managerUnsupportedHandler];
                break;
            }
        }

        if ([this.delegate respondsToSelector:@selector(centralManagerDidUpdateState:)]) {
            [this.delegate centralManagerDidUpdateState:central];

        }
    });
}



- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    __weak YMSCBCentralManager *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        if (this.useStoredPeripherals) {
            if (peripheral.identifier) {
                [YMSCBStoredPeripherals saveUUID:peripheral.identifier];
            }
        }
        
        if (this.discoveredCallback) {
            this.discoveredCallback(peripheral, advertisementData, RSSI, nil);
        } else {
            [this handleFoundPeripheral:peripheral];
        }
        
        if ([this.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
            [this.delegate centralManager:central
                    didDiscoverPeripheral:peripheral
                        advertisementData:advertisementData
                                     RSSI:RSSI];
        }
    });
}


- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    __weak YMSCBCentralManager *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        for (CBPeripheral *peripheral in peripherals) {
            [this handleFoundPeripheral:peripheral];
        }
        
        if ([this.delegate respondsToSelector:@selector(centralManager:didRetrievePeripherals:)]) {
            [this.delegate centralManager:central didRetrievePeripherals:peripherals];
        }
    });
}


- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    __weak YMSCBCentralManager *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        
        for (CBPeripheral *peripheral in peripherals) {
            [this handleFoundPeripheral:peripheral];
        }
        
        if ([this.delegate respondsToSelector:@selector(centralManager:didRetrieveConnectedPeripherals:)]) {
            [this.delegate centralManager:central didRetrieveConnectedPeripherals:peripherals];
        }
    });
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    __weak YMSCBCentralManager *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        YMSCBPeripheral *yp = [this findPeripheral:peripheral];
        
        [yp handleConnectionResponse:nil];
        
        if ([this.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
            [this.delegate centralManager:central didConnectPeripheral:peripheral];
        }
    });
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    __weak YMSCBCentralManager *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        YMSCBPeripheral *yp = [this findPeripheral:peripheral];
        
        for (id key in yp.serviceDict) {
            YMSCBService *service = yp.serviceDict[key];
            service.cbService = nil;
            service.isOn = NO;
            service.isEnabled = NO;
        }
        
        if ([this.delegate respondsToSelector:@selector(centralManager:didDisconnectPeripheral:error:)]) {
            [this.delegate centralManager:central didDisconnectPeripheral:peripheral error:error];
        }
    });
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    __weak YMSCBCentralManager *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        YMSCBPeripheral *yp = [this findPeripheral:peripheral];
        [yp handleConnectionResponse:error];
        if ([this.delegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
            [this.delegate centralManager:central didFailToConnectPeripheral:peripheral error:error];
        }
    });
}

@end
