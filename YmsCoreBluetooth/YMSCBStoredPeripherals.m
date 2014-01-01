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

#import "YMSCBStoredPeripherals.h"

@implementation YMSCBStoredPeripherals

+ (void)initializeStorage {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [userDefaults arrayForKey:@"storedPeripherals"];
    if (devices == nil) {
        [userDefaults setObject:@[] forKey:@"storedPeripherals"];
        [userDefaults synchronize];
    }

}

+ (NSArray *)genIdentifiers {
    NSMutableArray *result= [NSMutableArray new];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [userDefaults arrayForKey:@"storedPeripherals"];
    
    for (id uuidString in devices) {
        if (![uuidString isKindOfClass:[NSString class]]) {
            continue;
        }
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];

        if (!uuid)
            continue;
        
        [result addObject:uuid];
    }
    
    return result;
}

+ (void)saveUUID:(NSUUID *)UUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *existingDevices = [userDefaults objectForKey:@"storedPeripherals"];
    NSMutableArray *devices;
    NSString *uuidString = nil;
    if (UUID != nil) {
        uuidString = [UUID UUIDString];

        if (existingDevices != nil) {
            devices = [[NSMutableArray alloc] initWithArray:existingDevices];
            
            if (uuidString) {
                BOOL test = YES;
                
                for (NSString *obj in existingDevices) {
                    if ([obj isEqualToString:uuidString]) {
                        test = NO;
                        break;
                    }
                }
                
                if (test) {
                    [devices addObject:uuidString];
                }
            }
        }
        else {
            devices = [[NSMutableArray alloc] init];
            [devices addObject:uuidString];
            
        }
        
        [userDefaults setObject:devices forKey:@"storedPeripherals"];
        [userDefaults synchronize];
    }
    
}

+ (void)deleteUUID:(NSUUID *)UUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [userDefaults arrayForKey:@"storedPeripherals"];
    NSMutableArray *newDevices = [NSMutableArray arrayWithArray:devices];
    
    NSString *uuidString = [UUID UUIDString];
    
    [newDevices removeObject:uuidString];
    
    [userDefaults setObject:newDevices forKey:@"storedPeripherals"];
    [userDefaults synchronize];

    
}

@end
