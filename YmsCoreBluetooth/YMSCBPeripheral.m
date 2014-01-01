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
#import "YMSCBDescriptor.h"

@interface YMSCBPeripheral ()
@end

@implementation YMSCBPeripheral

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                           central:(YMSCBCentralManager *)owner
                            baseHi:(int64_t)hi
                            baseLo:(int64_t)lo {
    
    self = [super init];
    
    if (self) {
        _central = owner;
        _base.hi = hi;
        _base.lo = lo;
        
        _cbPeripheral = peripheral;
        peripheral.delegate = self;
        
        _rssiPingPeriod = 2.0;

        //_peripheralConnectionState = YMSCBPeripheralConnectionStateUnknown;
        _watchdogTimerInterval = 5.0;
    }

    return self;
}


#pragma mark - Peripheral Methods

- (NSString *)name {
    NSString *result = nil;
    if (self.cbPeripheral) {
        result = self.cbPeripheral.name;
    }
    
    return result;
}

- (BOOL)isConnected {
    
    BOOL result = NO;
    
    if (self.cbPeripheral.state == CBPeripheralStateConnected) {
        result = YES;
    }
    
    return result;
}


- (id)objectForKeyedSubscript:(id)key {
    return self.serviceDict[key];
}


- (NSArray *)services {
    NSArray *result;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.serviceDict) {
        YMSCBService *service = self.serviceDict[key];
        [tempArray addObject:service.uuid];
    }
    
    result = [NSArray arrayWithArray:tempArray];
    return result;
}

- (NSArray *)servicesSubset:(NSArray *)keys {
    NSArray *result = nil;
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:keys.count];
    
    for (NSString *key in keys) {
        YMSCBService *btService = (YMSCBService *)self[key];
        
        if (btService) {
            [tempArray addObject:btService.uuid];
        } else {
            NSLog(@"WARNING: service key '%@' is not found in peripheral '%@' for servicesSubset:", key, [self.cbPeripheral.identifier UUIDString]);
        }
    }
    
    result = [NSArray arrayWithArray:tempArray];
    return result;

    
}

- (YMSCBService *)findService:(CBService *)service {
    YMSCBService *result;
    
    for (NSString *key in self.serviceDict) {
        YMSCBService *btService = self.serviceDict[key];
        
        if ([service.UUID isEqual:btService.uuid]) {
            result = btService;
            break;
        }
        
    }
    return result;
}

#pragma mark - Connection Methods

- (void)connect {
    // Watchdog aware method
    [self resetWatchdog];

    [self connectWithOptions:nil withBlock:^(YMSCBPeripheral *yp, NSError *error) {
        if (error) {
            return;
        }

        [yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
            if (error) {
                return;
            }
            
            for (YMSCBService *service in yservices) {
                __weak YMSCBService *thisService = (YMSCBService *)service;
                
                [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                    if (error) {
                        return;
                    }

                    for (NSString *key in chDict) {
                        YMSCBCharacteristic *ct = chDict[key];
                        //NSLog(@"%@ %@ %@", ct, ct.cbCharacteristic, ct.uuid);
                        
                        [ct discoverDescriptorsWithBlock:^(NSArray *ydescriptors, NSError *error) {
                            if (error) {
                                return;
                            }
                            for (YMSCBDescriptor *yd in ydescriptors) {
                                NSLog(@"Descriptor: %@ %@ %@", thisService.name, yd.UUID, yd.cbDescriptor);
                            }
                        }];
                    }
                }];
            }
        }];
    }];
}


- (void)disconnect {
    // Watchdog aware method
    if (self.watchdogTimer) {
        [self.watchdogTimer invalidate];
        self.watchdogTimer = nil;
    }

    [self cancelConnection];
}

- (void)resetWatchdog {
    [self invalidateWatchdog];

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.watchdogTimerInterval
                                                      target:self
                                                    selector:@selector(watchdogDisconnect)
                                                    userInfo:nil
                                                     repeats:NO];
    self.watchdogTimer = timer;
}

- (void)invalidateWatchdog {
    if (self.watchdogTimer) {
        [self.watchdogTimer invalidate];
        self.watchdogTimer = nil;
        self.watchdogRaised = NO;
    }
}

- (void)watchdogDisconnect {
    // Watchdog aware method
    if (self.cbPeripheral.state != CBPeripheralStateConnected) {
        self.watchdogRaised = YES;
        [self disconnect];
    }
    self.watchdogTimer = nil;
}

- (void)connectWithOptions:(NSDictionary *)options withBlock:(void (^)(YMSCBPeripheral *, NSError *))connectCallback {
    self.connectCallback = connectCallback;
    [self.central.manager connectPeripheral:self.cbPeripheral options:options];
}


- (void)cancelConnection {
    if (self.connectCallback) {
        self.connectCallback = nil;
    }
    [self.central.manager cancelPeripheralConnection:self.cbPeripheral];
}


- (void)handleConnectionResponse:(NSError *)error {
    YMSCBPeripheralConnectCallbackBlockType callback = [self.connectCallback copy];
    
    [self invalidateWatchdog];
    
    if (callback) {
        callback(self, error);
        self.connectCallback = nil;
        
    } else {
        [self defaultConnectionHandler];
    }
}

- (void)defaultConnectionHandler {
    NSAssert(NO, @"[YMSCBPeripheral defaultConnectionHandler] must be overridden if connectCallback is nil.");
}

- (void)readRSSI {
    [self.cbPeripheral readRSSI];
}

#pragma mark - Services Discovery

- (void)discoverServices:(NSArray *)serviceUUIDs withBlock:(void (^)(NSArray *, NSError *))callback {
    self.discoverServicesCallback = callback;
    
    [self.cbPeripheral discoverServices:serviceUUIDs];
}


#pragma mark - CBPeripheralDelegate Methods
/** @name CBPeripheralDelegate Methods */
/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral that the services belong to.
 @param error If an error occurred, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        
        if (this.discoverServicesCallback) {
            NSMutableArray *services = [NSMutableArray new];
            
            // TODO: add method syncServices
            
            @synchronized(self) {
                for (CBService *service in peripheral.services) {
                    YMSCBService *btService = [this findService:service];
                    if (btService) {
                        btService.cbService = service;
                        [services addObject:btService];
                    }
                }
            }
            
            this.discoverServicesCallback(services, error);
            this.discoverServicesCallback = nil;
        }
        
        if ([this.delegate respondsToSelector:@selector(peripheral:didDiscoverServices:)]) {
            [this.delegate peripheral:peripheral didDiscoverServices:error];
        }
    });
}

/**
 CBPeripheralDelegate implementation.  Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param service The CBService object containing the included service.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    // TBD
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        if ([this.delegate respondsToSelector:@selector(peripheral:didDiscoverIncludedServicesForService:error:)]) {
            [this.delegate peripheral:peripheral didDiscoverIncludedServicesForService:service error:error];
        }
    });
}

/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral providing this information.
 @param service The service that the characteristics belong to.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        YMSCBService *btService = [this findService:service];
        
        [btService syncCharacteristics:service.characteristics];
        [btService handleDiscoveredCharacteristicsResponse:btService.characteristicDict withError:error];
        
        if ([this.delegate respondsToSelector:@selector(peripheral:didDiscoverCharacteristicsForService:error:)]) {
            [this.delegate peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
        }
    });
}


/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic that the characteristic descriptors belong to.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        YMSCBService *btService = [this findService:characteristic.service];
        YMSCBCharacteristic *ct = [btService findCharacteristic:characteristic];
        
        [ct syncDescriptors:characteristic.descriptors];
        [ct handleDiscoveredDescriptorsResponse:ct.descriptors withError:error];
        
        if ([this.delegate respondsToSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)]) {
            [this.delegate peripheral:peripheral didDiscoverDescriptorsForCharacteristic:characteristic error:error];
            
        }
    });
}


/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        YMSCBService *btService = [this findService:characteristic.service];
        YMSCBCharacteristic *yc = [btService findCharacteristic:characteristic];
        
        if (yc.cbCharacteristic.isNotifying) {
            [btService notifyCharacteristicHandler:yc error:error];
            
        } else {
            if ([yc.readCallbacks count] > 0) {
                [yc executeReadCallback:characteristic.value error:error];
            }
        }
        
        if ([this.delegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]) {
            [this.delegate peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
        }
    });
}


/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param descriptor The characteristic descriptor whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    // TBD
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        if ([this.delegate respondsToSelector:@selector(peripheral:didUpdateValueForDescriptor:error:)]) {
            [this.delegate peripheral:peripheral didUpdateValueForDescriptor:descriptor error:error];
        }
    });
}

/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        YMSCBService *btService = [this findService:characteristic.service];
        YMSCBCharacteristic *ct = [btService findCharacteristic:characteristic];
        
        [ct executeNotificationStateCallback:error];
        
        if ([this.delegate respondsToSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
            [this.delegate peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
            
        }
    });
}


/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral providing this information.
 @param characteristic The characteristic whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        
        YMSCBService *btService = [this findService:characteristic.service];
        YMSCBCharacteristic *yc = [btService findCharacteristic:characteristic];
        
        if ([yc.writeCallbacks count] > 0) {
            [yc executeWriteCallback:error];
        } else {
            // TODO is this dangerous?
            [btService notifyCharacteristicHandler:yc error:error];
        }
        
        if ([this.delegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]) {
            [this.delegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
        }
    });
}


/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 @param peripheral The peripheral providing this information.
 @param descriptor The characteristic descriptor whose value has been retrieved.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    // TBD
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        if ([this.delegate respondsToSelector:@selector(peripheral:didWriteValueForDescriptor:error:)]) {
            [this.delegate peripheral:peripheral didWriteValueForDescriptor:descriptor error:error];
            
        }
    });
}

/**
 CBPeripheralDelegate implementation.
 
 @param peripheral The peripheral providing this information.
 @param error If an error occured, the cause of the failure.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        if ([this.delegate respondsToSelector:@selector(peripheralDidUpdateRSSI:error:)]) {
            [this.delegate peripheralDidUpdateRSSI:peripheral error:error];
        }
    });
}



/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 iOS only.
 
 @param peripheral The peripheral providing this information.
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
#if TARGET_OS_IPHONE
    // TBD
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{

        if ([this.delegate respondsToSelector:@selector(peripheralDidUpdateName:)]) {
            [this.delegate peripheralDidUpdateName:peripheral];
        }
    });
#endif
}



/**
 CBPeripheralDelegate implementation. Not yet supported.
 
 iOS only.
 
 @param peripheral The peripheral providing this information.
 */
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
#if TARGET_OS_IPHONE
    // TBD
    __weak YMSCBPeripheral *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{

        if ([this.delegate respondsToSelector:@selector(peripheralDidInvalidateServices:)]) {
            [this.delegate peripheralDidInvalidateServices:peripheral];
        }
    });
#endif
}



@end
