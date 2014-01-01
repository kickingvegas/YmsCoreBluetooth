//
//  DEMSimpleKeysViewCell.m
//  Deanna
//
//  Created by Charles Choi on 6/2/13.
//  Copyright (c) 2013-2014 Yummy Melon Software. All rights reserved.
//

#import "DEMSimpleKeysViewCell.h"
#import "DEASensorTag.h"
#import "DEASimpleKeysService.h"

@implementation DEMSimpleKeysViewCell


- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    self.service = sensorTag.serviceDict[@"simplekeys"];
    
    for (NSString *key in @[@"keyValue", @"isOn", @"isEnabled"]) {
        [self.service addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self.button1 setEnabled:self.service.isEnabled];
    [self.button2 setEnabled:self.service.isEnabled];
}

- (void)deconfigure {
    for (NSString *key in @[@"keyValue", @"isOn", @"isEnabled"]) {
        [self.service removeObserver:self forKeyPath:key];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object != self.service) {
        return;
    }
    
    DEASimpleKeysService *sks = (DEASimpleKeysService *)object;
    
    if ([keyPath isEqualToString:@"keyValue"]) {
        int keyValue = [sks.keyValue intValue];
        
        if (keyValue & 1) {
            [self.button1 setState:NSOnState];
        } else {
            [self.button1 setState:NSOffState];
        }
        
        if (keyValue & 2) {
            [self.button2 setState:NSOnState];
        } else {
            [self.button2 setState:NSOffState];
        }
        
        
        
    } else if ([keyPath isEqualToString:@"isOn"]) {
        //[self.notifySwitch setOn:ts.isOn animated:YES];
        
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.button1 setEnabled:self.service.isEnabled];
        [self.button2 setEnabled:self.service.isEnabled];
    }
    
    
}




@end
