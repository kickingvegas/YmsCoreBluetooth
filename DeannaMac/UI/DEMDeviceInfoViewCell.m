//
//  DEMDeviceInfoViewCell.m
//  Deanna
//
//  Created by Charles Choi on 6/2/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEMDeviceInfoViewCell.h"
#import "DEASensorTag.h"
#import "DEADeviceInfoService.h"
#import "DEABaseService.h"

@implementation DEMDeviceInfoViewCell

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
        NSTextField *label = (NSTextField *)[self valueForKey:labelKey];
        
        NSString *hey = (NSString *)[self.service valueForKey:key];
        
        if (hey) {
            label.stringValue = hey;
        } else {
            label.stringValue = @"";
        }
    }
    
    for (NSString *key in self.keyList) {
        [self.service addObserver:self
                       forKeyPath:key
                          options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                          context:NULL];
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
            NSTextField *label = (NSTextField *)[self valueForKey:labelKey];
            
            label.stringValue = (NSString *)change[NSKeyValueChangeNewKey];
            
            break;
        }
    }
}



@end
