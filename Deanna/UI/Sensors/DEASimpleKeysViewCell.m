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


#import "DEASimpleKeysViewCell.h"
#import "DEASimpleKeysService.h"
#import "DEASensorTag.h"
#import "DEATheme.h"

@implementation DEASimpleKeysViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


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
            self.button1.titleLabel.textColor = [UIColor redColor];
        } else {
            self.button1.titleLabel.textColor = [[DEATheme sharedTheme] bodyTextColor];
        }

        if (keyValue & 2) {
            self.button2.titleLabel.textColor = [UIColor redColor];
        } else {
            self.button2.titleLabel.textColor = [[DEATheme sharedTheme] bodyTextColor];
        }

        
        /*
         This is an interim implementation of raising a local notification when a SensorTag 
         key is pressed and the application is in the background or in an inactive state.
         Note that this will only work when DEASensorTagViewController is in view.
         
         TODO: Change to have the application observe the keyValue.
         */
        UIApplication *app = [UIApplication sharedApplication];

        if ((app.applicationState == UIApplicationStateBackground) ||
            (app.applicationState == UIApplicationStateInactive)) {
            
            if (keyValue != 0) {
                NSLog(@"Background Key Value %d", keyValue);
            
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                if (localNotif == nil) {
                    return;
                }
            
                localNotif.soundName = UILocalNotificationDefaultSoundName;
                localNotif.applicationIconBadgeNumber = keyValue;
                localNotif.alertBody = [NSString stringWithFormat:@"You pressed button %d", keyValue];
                //localNotif.alertAction = @"Deanna got something for you";
                localNotif.hasAction = NO;

                [app presentLocalNotificationNow:localNotif];
            }

        }
        
        
    } else if ([keyPath isEqualToString:@"isOn"]) {
        //[self.notifySwitch setOn:ts.isOn animated:YES];
        
    } else if ([keyPath isEqualToString:@"isEnabled"]) {
        [self.button1 setEnabled:self.service.isEnabled];
        [self.button2 setEnabled:self.service.isEnabled];
    }
    
    
}


@end
