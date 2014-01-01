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

#import "DEADeviceInfoViewCell.h"
#import "DEADeviceInfoService.h"
#import "DEASensorTag.h"

@implementation DEADeviceInfoViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    
    if (self.keyList == nil) {
        self.keyList = @[@"system_id"
                         , @"model_number"
                         , @"serial_number"
                         , @"firmware_rev"
                         , @"hardware_rev"
                         , @"software_rev"
                         , @"manufacturer_name"
                         , @"ieee11073_cert_data"
                         ];

    }
    
    self.service = sensorTag.serviceDict[@"devinfo"];
    
    for (NSString *key in self.keyList) {
        NSString *labelKey = [NSString stringWithFormat:@"%@Label", key];
        UILabel *label = (UILabel *)[self valueForKey:labelKey];
        
        label.text = [self.service valueForKey:key];
    }

    for (NSString *key in self.keyList) {
        [self.service addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
}

- (void)deconfigure {
    for (NSString *key in self.keyList) {
        [self.service removeObserver:self forKeyPath:key];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    for (NSString *key in self.keyList) {
        
        if ([key isEqualToString:keyPath]) {
            
            NSString *labelKey = [NSString stringWithFormat:@"%@Label", key];
            UILabel *label = (UILabel *)[self valueForKey:labelKey];
            
            label.text = (NSString *)change[NSKeyValueChangeNewKey];

            break;
        }
    }
}



@end
