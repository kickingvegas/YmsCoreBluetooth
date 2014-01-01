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

#import <Foundation/Foundation.h>
@class DEAPeripheralTableViewCell;

typedef NS_ENUM(NSInteger, DEAButtonStyle) {
    DEAButtonStyleDefault
};

typedef NS_ENUM(NSInteger, DEATableViewStyle) {
    DEAPeripheralTableViewStyle,
    DEAPeripheralDetailTableViewStyle
};


@protocol DEATheme <NSObject>

- (UIColor *)bodyTextColor;
- (UIColor *)backgroundColor;
- (UIColor *)navbarBackgroundColor;
- (UIColor *)borderColor;
- (UIColor *)highlightTextColor;
- (UIColor *)shadowColor;
- (UIColor *)tableviewSeparatorColor;
- (UIColor *)rssiTextColor;
- (UIColor *)disabledColor;
- (UIColor *)connectedColor;
- (UIColor *)advertisingColor;
- (UIColor *)pairingColor;
- (UIColor *)signalColor;


- (UIFont *)bodyFontWithSize:(CGFloat)ptSize;

@end

@interface DEATheme : NSObject

+ (id <DEATheme>)sharedTheme;

+ (void)customizeApplication;
+ (void)customizeView:(UIView *)view;
+ (void)customizeButton:(UIButton *)button forType:(DEAButtonStyle)buttonStyle;
+ (void)customizePeripheralTableViewCell:(DEAPeripheralTableViewCell *)viewCell;
+ (void)customizeSensorTableViewCell:(UITableViewCell *)viewCell;
+ (void)customizeTableView:(UITableView *)tableView forType:(DEATableViewStyle)tableViewStyle;
+ (void)customizeNavigationController:(UINavigationController *)nc;

@end
