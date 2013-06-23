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
    
    [[UINavigationBar appearance] setTintColor:[theme navbarBackgroundColor]];
    [[UIToolbar appearance] setTintColor:[theme navbarBackgroundColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                UITextAttributeTextColor: [theme highlightTextColor],
                          UITextAttributeTextShadowColor: [theme shadowColor],
                         UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                     UITextAttributeFont: [theme bodyFontWithSize:0.0] }];
     

    
    [[UIBarButtonItem appearance]
     setTitleTextAttributes:@{
     UITextAttributeTextColor: [theme highlightTextColor],
     UITextAttributeTextShadowColor: [theme shadowColor],
     UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
     UITextAttributeFont: [theme bodyFontWithSize:0.0] }
     forState:UIControlStateNormal];

      
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
            [button setTitleColor:[theme highlightTextColor] forState:UIControlStateDisabled];
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
    viewCell.signalLabel.textColor = [theme bodyTextColor];
    viewCell.peripheralStatusLabel.textColor = [theme bodyTextColor];
    
    [DEATheme customizeButton:viewCell.connectButton forType:DEAButtonStyleDefault];

    [viewCell.dbLabel setFont:[theme bodyFontWithSize:10.0]];
    [viewCell.rssiLabel setFont:[theme bodyFontWithSize:18.0]];
    [viewCell.nameLabel setFont:[theme bodyFontWithSize:20.0]];
    [viewCell.signalLabel setFont:[theme bodyFontWithSize:18.0]];
    [viewCell.peripheralStatusLabel setFont:[theme bodyFontWithSize:18.0]];
    

}


@end
