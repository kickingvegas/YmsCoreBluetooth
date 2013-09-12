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

#import <QuartzCore/QuartzCore.h>
#import "DEAStyleSheet.h"
#import "DEATheme.h"
#import "DEADefaultTheme.h"
#import "DEAPeripheralTableViewCell.h"
#import "DEAAccelerometerViewCell.h"
#import "DEABarometerViewCell.h"
#import "DEADeviceInfoViewCell.h"
#import "DEAGyroscopeViewCell.h"
#import "DEAHumidityViewCell.h"
#import "DEAMagnetometerViewCell.h"
#import "DEASimpleKeysViewCell.h"
#import "DEATemperatureViewCell.h"
#import "YMSCBPeripheral.h"

@implementation DEATheme

+ (id <DEATheme>)sharedTheme {
    static id <DEATheme> sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTheme = [[DEADefaultTheme alloc] init];
    });
    
    return sharedTheme;
}


+ (void)customizeApplication {
    id <DEATheme> theme = [self sharedTheme];
    
    [[UINavigationBar appearance] setBarTintColor:[theme navbarBackgroundColor]];
    [[UIToolbar appearance] setBarTintColor:[theme navbarBackgroundColor]];
    
    NSShadow *barButtonShadow = [NSShadow new];
    barButtonShadow.shadowOffset = CGSizeMake(0, -1);
    barButtonShadow.shadowColor = [theme shadowColor];
    
    [[UINavigationBar appearance]
     setTitleTextAttributes:@{
                              NSForegroundColorAttributeName: [theme highlightTextColor],
                              NSShadowAttributeName: barButtonShadow,
                              NSFontAttributeName: [theme bodyFontWithSize:0.0] }];
    
    
    [[UIBarButtonItem appearance]
     setTitleTextAttributes:@{
                              NSForegroundColorAttributeName: [theme highlightTextColor],
                              NSShadowAttributeName: barButtonShadow,
                              NSFontAttributeName: [theme bodyFontWithSize:0.0] }
     forState:UIControlStateNormal];

    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[theme highlightTextColor]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setShadowColor:nil];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[theme bodyFontWithSize:16.0]];
    
    //[[UISwitch appearance] setTintColor:[theme navbarBackgroundColor]];
    
}

+ (void)customizeView:(UIView *)view {
    id <DEATheme> theme = [self sharedTheme];
    UIColor *backgroundColor = [theme backgroundColor];
    if (backgroundColor) {
        [view setBackgroundColor:backgroundColor];
    }
}

+ (void)customizeButton:(UIButton *)button forType:(DEAButtonStyle)buttonStyle {
    id <DEATheme> theme = [self sharedTheme];
    switch (buttonStyle) {
        case DEAButtonStyleDefault: {
            [button setTitleColor:[theme bodyTextColor] forState:UIControlStateNormal];
            [button setTitleColor:[theme disabledColor] forState:UIControlStateDisabled];
            [button setTitleColor:[theme highlightTextColor] forState:UIControlStateHighlighted];
            [button.titleLabel setFont:[theme bodyFontWithSize:18.0]];
            
            [button setBackgroundColor:[theme backgroundColor]];
            
            button.layer.cornerRadius = 5.0f;
            button.layer.borderWidth = 2.0f;
            button.layer.borderColor = [[theme borderColor] CGColor];
            break;
        }

        default:
            break;
    }
}

+ (void)customizePeripheralTableViewCell:(DEAPeripheralTableViewCell *)viewCell {
    id <DEATheme> theme = [self sharedTheme];
    
    [DEATheme customizeView:viewCell.contentView.superview];
    viewCell.dbLabel.textColor = [theme highlightTextColor];
    viewCell.rssiLabel.textColor = [theme rssiTextColor];
    viewCell.nameLabel.textColor = [theme highlightTextColor];
    viewCell.signalLabel.textColor = [theme signalColor];
    
    if (viewCell.yperipheral.isConnected)
        viewCell.peripheralStatusLabel.textColor = [theme connectedColor];
    else
        viewCell.peripheralStatusLabel.textColor = [theme bodyTextColor];
    
    [DEATheme customizeButton:viewCell.connectButton forType:DEAButtonStyleDefault];

    [viewCell.dbLabel setFont:[theme bodyFontWithSize:10.0]];
    [viewCell.rssiLabel setFont:[theme bodyFontWithSize:18.0]];
    [viewCell.nameLabel setFont:[theme bodyFontWithSize:20.0]];
    [viewCell.signalLabel setFont:[theme bodyFontWithSize:18.0]];
    [viewCell.peripheralStatusLabel setFont:[theme bodyFontWithSize:18.0]];

}

+ (void)customizeTableView:(UITableView *)tableView forType:(DEATableViewStyle)tableViewStyle {
    id <DEATheme> theme = [self sharedTheme];
    switch (tableViewStyle) {
        case DEAPeripheralTableViewStyle: {
            [DEATheme customizeView:tableView];
            tableView.separatorColor = [theme tableviewSeparatorColor];
            break;
        }
            
        case DEAPeripheralDetailTableViewStyle: {
            [DEATheme customizeView:tableView];
            tableView.separatorColor = [theme backgroundColor];
            
            UIView *backView = [UIView new];
            [backView setBackgroundColor:[theme backgroundColor]];
            [tableView setBackgroundView:backView];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            break;
        }
            
        default:
            break;
    }
}

+ (void)customizeSensorTableViewCell:(UITableViewCell *)viewCell {
    id <DEATheme> theme = [self sharedTheme];
    [DEATheme customizeView:viewCell.contentView];
    
    for (UIView *view in viewCell.contentView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [((UILabel *)view) setTextColor:[theme bodyTextColor]];
        } else if ([view isKindOfClass:[UIButton class]]) {
            [DEATheme customizeButton:(UIButton *)view forType:DEAButtonStyleDefault];
        }
    }

    if ([viewCell isKindOfClass:[DEAAccelerometerViewCell class]]) {
        DEAAccelerometerViewCell *cell = (DEAAccelerometerViewCell *)viewCell;
        [cell.accelXLabel setTextColor:[theme highlightTextColor]];
        [cell.accelYLabel setTextColor:[theme highlightTextColor]];
        [cell.accelZLabel setTextColor:[theme highlightTextColor]];

    } else if ([viewCell isKindOfClass:[DEABarometerViewCell class]]) {
        DEABarometerViewCell *cell = (DEABarometerViewCell *)viewCell;
        [cell.ambientTemperatureLabel setTextColor:[theme highlightTextColor]];
        [cell.pressureLabel setTextColor:[theme highlightTextColor]];
 
    } else if ([viewCell isKindOfClass:[DEADeviceInfoViewCell class]]) {
        DEADeviceInfoViewCell *cell = (DEADeviceInfoViewCell *)viewCell;
        [cell.system_idLabel setTextColor:[theme highlightTextColor]];
        [cell.model_numberLabel setTextColor:[theme highlightTextColor]];
        [cell.serial_numberLabel setTextColor:[theme highlightTextColor]];
        [cell.firmware_revLabel setTextColor:[theme highlightTextColor]];
        [cell.hardware_revLabel setTextColor:[theme highlightTextColor]];
        [cell.software_revLabel setTextColor:[theme highlightTextColor]];
        [cell.manufacturer_nameLabel setTextColor:[theme highlightTextColor]];
        [cell.ieee11073_cert_dataLabel setTextColor:[theme highlightTextColor]];
        
    } else if ([viewCell isKindOfClass:[DEAGyroscopeViewCell class]]) {
        DEAGyroscopeViewCell *cell = (DEAGyroscopeViewCell *)viewCell;
        [cell.rollLabel setTextColor:[theme highlightTextColor]];
        [cell.pitchLabel setTextColor:[theme highlightTextColor]];
        [cell.yawLabel setTextColor:[theme highlightTextColor]];

    } else if ([viewCell isKindOfClass:[DEAHumidityViewCell class]]) {
        DEAHumidityViewCell *cell = (DEAHumidityViewCell *)viewCell;
        [cell.ambientTemperatureLabel setTextColor:[theme highlightTextColor]];
        [cell.relativeHumidityLabel setTextColor:[theme highlightTextColor]];

    } else if ([viewCell isKindOfClass:[DEAMagnetometerViewCell class]]) {
        DEAMagnetometerViewCell *cell = (DEAMagnetometerViewCell *)viewCell;
        [cell.xLabel setTextColor:[theme highlightTextColor]];
        [cell.yLabel setTextColor:[theme highlightTextColor]];
        [cell.zLabel setTextColor:[theme highlightTextColor]];
                
    } else if ([viewCell isKindOfClass:[DEASimpleKeysViewCell class]]) {
        DEASimpleKeysViewCell *cell = (DEASimpleKeysViewCell *)viewCell;
        [DEATheme customizeButton:cell.button1 forType:DEAButtonStyleDefault];
        [DEATheme customizeButton:cell.button2 forType:DEAButtonStyleDefault];

    } else if ([viewCell isKindOfClass:[DEATemperatureViewCell class]]) {
        DEATemperatureViewCell *cell = (DEATemperatureViewCell *)viewCell;
        [cell.ambientTemperatureLabel setTextColor:[theme highlightTextColor]];
        [cell.objectTemperatureLabel setTextColor:[theme highlightTextColor]];
    }


}


+ (void)customizeNavigationController:(UINavigationController *)nc {
//    nc.navigationBar.translucent = NO;
//    nc.toolbar.translucent = NO;
}

@end
