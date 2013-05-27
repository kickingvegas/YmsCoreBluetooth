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

#import "DEABaseService.h"
#import "YMSCBCharacteristic.h"
#import "DEASensorTagUtils.h"

@implementation DEABaseService

- (void)addCharacteristic:(NSString *)cname withOffset:(int)addrOffset {
    YMSCBCharacteristic *yc;
    
    yms_u128_t pbase = self.base;
    
    CBUUID *uuid = [DEASensorTagUtils createCBUUID:&pbase withIntOffset:addrOffset];
    
    yc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            parent:self.parent
                                              uuid:uuid
                                            offset:addrOffset];
    
    self.characteristicDict[cname] = yc;
}


- (void)turnOff {
    __weak DEABaseService *this = self;

    YMSCBCharacteristic *configCt = self.characteristicDict[@"config"];
    [configCt writeByte:0x0 withBlock:^(NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSLog(@"TURNED OFF: %@", this.name);
    }];
    
    YMSCBCharacteristic *dataCt = self.characteristicDict[@"data"];
    [dataCt setNotifyValue:NO withBlock:^(NSError *error) {
        NSLog(@"Data notification for %@ off", this.name);

    }];
    
    self.isOn = NO;
}

- (void)turnOn {
    __weak DEABaseService *this = self;
    
    YMSCBCharacteristic *configCt = self.characteristicDict[@"config"];
    [configCt writeByte:0x1 withBlock:^(NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSLog(@"TURNED ON: %@", this.name);
    }];
    
    YMSCBCharacteristic *dataCt = self.characteristicDict[@"data"];
    [dataCt setNotifyValue:YES withBlock:^(NSError *error) {
        NSLog(@"Data notification for %@ on", this.name);
    }];

    self.isOn = YES;
}


@end
