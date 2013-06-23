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

#import "DEABaseButton.h"
#import "DEAStyleSheet.h"
#import <QuartzCore/QuartzCore.h>

@implementation DEABaseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)applyStyle {
    [self setTitleColor:kDEA_STYLE_BASIC_TEXTCOLOR forState:UIControlStateNormal];
    [self setTitleColor:kDEA_STYLE_WHITECOLOR forState:UIControlStateDisabled];
    [self setTitleColor:kDEA_STYLE_WHITECOLOR forState:UIControlStateHighlighted];
    
    [self setBackgroundColor:kDEA_STYLE_BACKGROUNDCOLOR];
    
    self.layer.cornerRadius = 5.0f;
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [kDEA_STYLE_BORDERCOLOR CGColor];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
