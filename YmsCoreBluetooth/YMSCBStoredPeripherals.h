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

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif


//#define UUID2STRING(UUID) (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, UUID))

/**
 Class to manage the storage of discovered UUIDs into [NSUserDefaults standardUserDefaults].
 */
@interface YMSCBStoredPeripherals : NSObject

/** @name Methods */
/**
 Initialize array with key name `storedPeripherals` in standardUserDefaults.
 */
+ (void)initializeStorage;

/**
 Generate array of NSUUID objects to feed into [YMSCBCentralManager retrievePeripherals:]
 */
+ (NSArray *)genIdentifiers;

/**
 Save UUID in `storedPeripherals`.
 
 @param UUID peripheral UUID
 */
+ (void)saveUUID:(NSUUID *)UUID;

/**
 Delete UUID in `storedPeripherals`.
 
 @param UUID peripheral UUID
 */
+ (void)deleteUUID:(NSUUID *)UUID;

@end
