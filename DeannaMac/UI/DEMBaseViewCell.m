//
//  DEMBaseViewCell.m
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEMBaseViewCell.h"
#import "DEABaseService.h"

@implementation DEMBaseViewCell

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag {
    
}

- (void)deconfigure {
    
}


- (IBAction)notifySwitchAction:(id)sender {
    if (self.notifySwitch.state == NSOnState) {
        [self.service turnOn];
    } else if (self.notifySwitch.state == NSOffState) {
        [self.service turnOff];
    }
}

@end
