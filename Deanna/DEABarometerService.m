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


#import "DEABarometerService.h"
#import "YMSCBCharacteristic.h"

@implementation DEABarometerService


- (id)initWithName:(NSString *)oName {
    self = [super initWithName:oName];
    
    if (self) {
        [self addCharacteristic:@"service" withOffset:kSensorTag_BAROMETER_SERVICE];
        [self addCharacteristic:@"data" withOffset:kSensorTag_BAROMETER_DATA];
        [self addCharacteristic:@"config" withOffset:kSensorTag_BAROMETER_CONFIG];
        [self addCharacteristic:@"calibration" withOffset:kSensorTag_BAROMETER_CALIBRATION];
    }
    return self;
}

- (void)updateCharacteristic:(YMSCBCharacteristic *)yc {
    if ([yc.name isEqualToString:@"data"]) {
        NSData *data = yc.cbCharacteristic.value;
        
        char val[data.length];
        [data getBytes:&val length:data.length];
        
        
        int16_t v0 = val[0];
        int16_t v1 = val[1];
        int16_t v2 = val[2];
        int16_t v3 = val[3];
        
        
        int16_t rawP = ((v2 & 0xff)| ((v3 << 8) & 0xff00));
        
        int16_t ambT = ((v0 & 0xff)| ((v1 << 8) & 0xff00));

    }
    
}


@end
