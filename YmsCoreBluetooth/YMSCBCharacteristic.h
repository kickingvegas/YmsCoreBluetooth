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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


/**
 Container class for TI SensorTag CoreBluetooth characteristic.
 
 The reason for this class not being a subclass of `CBCharacteristic` is that
 you know ahead of time the `name` and the `UUID` of the characteristic.
 
 `CBCharacteristic` instances are returned by discovery from `CBPeripheral` which for
 the purposes of this framework is too late. `YmsCoreBluetooth` presumes that you 
 initially know what characteristics exist in a device (captured by this class)
 and then upon discovery, pairs the found `CBCharacteristic` with it. This pairing is done
 in `YMSCBService`.

 
 */
@interface YMSCBCharacteristic : NSObject

/// Characteristic name.
@property (nonatomic, strong) NSString *name;

/// Characterisic CBUUID.
@property (nonatomic, strong) CBUUID *uuid;

/// Pointer to actual CBCharacterisic
@property (nonatomic, strong) CBCharacteristic *cbCharacteristic;

/// Offset address value, if applicable.
@property (nonatomic, strong) NSNumber *offset;


/**
 Class contructor.

 @param oName characteristic name
 @param oUUID characteristic CBUUID
 @param addrOffset characteristic address offset
 */
- (id)initWithName:(NSString *)oName uuid:(CBUUID *)oUUID offset:(int)addrOffset;

@end
