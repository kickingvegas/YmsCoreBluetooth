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

#import "DEASimpleKeysService.h"
#import "YMSCBCharacteristic.h"

@implementation DEASimpleKeysService


- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withAddress:kSensorTag_SIMPLEKEYS_SERVICE];
        [self addCharacteristic:@"data" withAddress:kSensorTag_SIMPLEKEYS_DATA];
    }
    return self;
}

- (NSArray *)characteristics {
    
    NSArray *result = @[
    [(YMSCBCharacteristic *)(self.characteristicDict[@"data"]) uuid]
    ];
    
    return result;
}


- (void)updateCharacteristic:(YMSCBCharacteristic *)yc {
    if ([yc.name isEqualToString:@"data"]) {
        NSData *data = yc.cbCharacteristic.value;
        
        char val[data.length];
        [data getBytes:&val length:data.length];
        
        
        int16_t value = val[0];
        
        
        self.keyValue = [NSNumber numberWithInt:value];
        
        NSLog(@"key value: %@", self.keyValue);

    }
    
}


@end
