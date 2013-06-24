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

#import "DEAStyleSheet.h"
#import "DEADefaultTheme.h"

@implementation DEADefaultTheme

- (UIColor *)bodyTextColor {
    return RGB(79, 85, 106);
}

- (UIColor *)backgroundColor {
    return RGB(29, 31, 37);
}

- (UIColor *)navbarBackgroundColor {
    return RGB(42, 45, 55);
}

- (UIColor *)highlightTextColor {
    return RGB(255, 255, 255);
}

- (UIColor *)borderColor {
    return RGB(79, 85, 106);
}

- (UIColor *)tableviewSeparatorColor {
    return RGB(31, 41, 51);
}

- (UIColor *)shadowColor {
    return RGBA(0, 0, 0, 0.8);
}

- (UIColor *)rssiTextColor {
    return RGB(90, 133, 183);
}

- (UIColor *)disabledColor {
    return RGB(90, 90, 90);
}

- (UIColor *)connectedColor {
    return RGBCSS(0x2ECC71);
}

- (UIColor *)advertisingColor {
    return RGBCSS(0x2980B9);
}

- (UIColor *)pairingColor {
    return RGBCSS(0xF1C40F);
}

- (UIColor *)signalColor {
    return RGBCSS(0xE67E22);
}

- (UIFont *)bodyFontWithSize:(CGFloat)ptSize {
    return [UIFont fontWithName:@"ArialRoundedMTBold" size:ptSize];
    //return [UIFont fontWithName:@"Copperplate" size:ptSize];
}



@end
