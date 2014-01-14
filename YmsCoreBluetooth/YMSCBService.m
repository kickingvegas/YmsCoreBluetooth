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

#import "YMSCBService.h"
#import "YMSCBUtils.h"
#import "YMSCBPeripheral.h"
#import "YMSCBCharacteristic.h"

@interface YMSCBService ()
@end

@implementation YMSCBService


- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
               serviceOffset:(int)serviceOffset {

    self = [super init];
    if (self) {
        _name = oName;
        _parent = pObj;
        _base.hi = hi;
        _base.lo = lo;
        _characteristicDict = [[NSMutableDictionary alloc] init];
        
        if ((hi == 0) && (lo == 0)) {
            NSString *addrString = [NSString stringWithFormat:@"%x", serviceOffset];
            _uuid = [CBUUID UUIDWithString:addrString];

        } else {
            _uuid = [YMSCBUtils createCBUUID:&_base withIntOffset:serviceOffset];
        }
    }
    return self;
}


- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
            serviceBLEOffset:(int)serviceOffset {

    
    self = [super init];
    if (self) {
        _name = oName;
        _parent = pObj;
        _base.hi = hi;
        _base.lo = lo;
        _characteristicDict = [[NSMutableDictionary alloc] init];
        
        if ((hi == 0) && (lo == 0)) {
            NSString *addrString = [NSString stringWithFormat:@"%x", serviceOffset];
            _uuid = [CBUUID UUIDWithString:addrString];
            
        } else {
            _uuid = [YMSCBUtils createCBUUID:&_base withIntBLEOffset:serviceOffset];
        }
    }
    return self;
}


- (id)objectForKeyedSubscript:(id)key {
    return self.characteristicDict[key];
}


- (void)addCharacteristic:(NSString *)cname withOffset:(int)addrOffset {
    YMSCBCharacteristic *yc;
    
    yms_u128_t pbase = self.base;
    
    CBUUID *uuid = [YMSCBUtils createCBUUID:&pbase withIntOffset:addrOffset];
    
    yc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            parent:self.parent
                                            uuid:uuid
                                          offset:addrOffset];
    yc.parent = self.parent;
    
    self.characteristicDict[cname] = yc;
}


- (void)addCharacteristic:(NSString *)cname withBLEOffset:(int)addrOffset {
    YMSCBCharacteristic *yc;
    
    yms_u128_t pbase = self.base;
    
    CBUUID *uuid = [YMSCBUtils createCBUUID:&pbase withIntBLEOffset:addrOffset];
    
    yc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            parent:self.parent
                                              uuid:uuid
                                            offset:addrOffset];
    yc.parent = self.parent;
    
    self.characteristicDict[cname] = yc;
}

- (void)addCharacteristic:(NSString *)cname withAddress:(int)addr {
    
    YMSCBCharacteristic *yc;
    NSString *addrString = [NSString stringWithFormat:@"%x", addr];
    
    
    CBUUID *uuid = [CBUUID UUIDWithString:addrString];
    yc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            parent:self.parent
                                            uuid:uuid
                                          offset:addr];
    self.characteristicDict[cname] = yc;
}


- (NSArray *)characteristics {
    NSArray *tempArray = [self.characteristicDict allValues];
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self.characteristicDict count]];
    
    for (YMSCBCharacteristic *yc in tempArray) {
        [result addObject:yc.uuid];
    }
    
    return result;
}

- (NSArray *)characteristicsSubset:(NSArray *)keys {
    NSArray *result = nil;
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:keys.count];
    
    for (NSString *key in keys) {
        YMSCBCharacteristic *yc = (YMSCBCharacteristic *)self[key];
        
        if (yc) {
            [tempArray addObject:yc.uuid];
        } else {
            NSLog(@"WARNING: characteristic key '%@' is not found in service '%@' for characteristicSubset:", key, self.name);
        }
    }
    
    result = [NSArray arrayWithArray:tempArray];
    return result;
}


- (void)syncCharacteristics:(NSArray *)foundCharacteristics {
    @synchronized(self) {
        for (NSString *key in self.characteristicDict) {
            YMSCBCharacteristic *yc = self.characteristicDict[key];
            for (CBCharacteristic *ct in foundCharacteristics) {
                if ([yc.uuid isEqual:ct.UUID]) {
                    yc.cbCharacteristic = ct;
                    break;
                }
            }
        }
    }
    
    __weak YMSCBService *this = self;
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        this.isEnabled = YES;
    });
    
}


- (YMSCBCharacteristic *)findCharacteristic:(CBCharacteristic *)ct {
    YMSCBCharacteristic *result;
    for (NSString *key in self.characteristicDict) {
        YMSCBCharacteristic *yc = self.characteristicDict[key];
            
        if ([yc.cbCharacteristic.UUID isEqual:ct.UUID]) {
            result = yc;
            break;
        }
    }
    return result;
}


- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error {
    if (error) {
        return;
    }
}


- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs withBlock:(void (^)(NSDictionary *, NSError *))callback {
    self.discoverCharacteristicsCallback = callback;
    
    [self.parent.cbPeripheral discoverCharacteristics:characteristicUUIDs
                                           forService:self.cbService];

}

- (void)handleDiscoveredCharacteristicsResponse:(NSDictionary *)chDict withError:(NSError *)error {
    YMSCBDiscoverCharacteristicsCallbackBlockType callback = [self.discoverCharacteristicsCallback copy];
    
    if (callback) {
        callback(chDict, error);
        self.discoverCharacteristicsCallback = nil;
         
    } else {
        NSAssert(NO, @"ERROR: discoveredCharacteristicsCallback is nil; please check for multi-threaded access of handleDiscoveredCharacteristicsResponse");
    }
    
}


@end
