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

#import "DEASimpleKeysService.h"
#import "YMSCBCharacteristic.h"

@interface DEASimpleKeysService ()

@property (nonatomic, strong) NSNumber *keyValue;

@end

@implementation DEASimpleKeysService


- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
               serviceOffset:(int)serviceOffset {
    
    self = [super initWithName:oName
                        parent:pObj
                        baseHi:hi
                        baseLo:lo
                 serviceOffset:serviceOffset];
    
    if (self) {
        [self addCharacteristic:@"data" withAddress:kSensorTag_SIMPLEKEYS_DATA];
    }
    return self;
}




- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error {
    if (error) {
        return;
    }

    if ([yc.name isEqualToString:@"data"]) {
        NSData *data = yc.cbCharacteristic.value;
        
        char val[data.length];
        [data getBytes:&val length:data.length];
        
        
        int16_t value = val[0];
        
        __weak DEASimpleKeysService *this = self;
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            [self willChangeValueForKey:@"sensorValues"];
            this.keyValue = [NSNumber numberWithInt:value];
            [self didChangeValueForKey:@"sensorValues"];
        });
    }
}


- (void)turnOff {
    __weak DEASimpleKeysService *this = self;
    YMSCBCharacteristic *ct = self.characteristicDict[@"data"];
    [ct setNotifyValue:NO withBlock:^(NSError *error) {
        if (error) {
            return;
        }
        NSLog(@"Turned Off: %@", this.name);
    }];
    
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        this.isOn = NO;
    });
}

- (void)turnOn {
    __weak DEASimpleKeysService *this = self;
    YMSCBCharacteristic *ct = self.characteristicDict[@"data"];
    [ct setNotifyValue:YES withBlock:^(NSError *error) {
        if (error) {
            return;
        }
        NSLog(@"Turned On: %@", this.name);
    }];
    
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        this.isOn = YES;
    });
}

- (NSDictionary *)sensorValues
{
    return @{ @"keyValue": self.keyValue };
}

@end
