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

#import "DEASensorTagWindow.h"
#import "DEASensorTag.h"
#import "DEMAccelerometerViewCell.h"
#import "DEMBarometerViewCell.h"
#import "DEMDeviceInfoViewCell.h"

@implementation DEASensorTagWindow

- (id)init {
    self = [super initWithWindowNibName:@"DEASensorTagWindow"];
    if (self) {
        _cbServiceCells = @[@"simplekeys"
                            , @"temperature"
                            , @"accelerometer"
                            , @"magnetometer"
                            , @"gyroscope"
                            , @"humidity"
                            , @"barometer"
                            , @"devinfo"
                            ];
    }
    return self;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.cbServiceCells count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSView *serviceView;
    NSString *prefix  = self.cbServiceCells[row];
    serviceView = [self valueForKey:[NSString stringWithFormat:@"%@ViewCell", prefix]];

    CGFloat height = serviceView.bounds.size.height;
    return height;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSView *serviceView;
    NSString *prefix  = self.cbServiceCells[row];
    serviceView = [self valueForKey:[NSString stringWithFormat:@"%@ViewCell", prefix]];
    
    
    return serviceView;
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    
    for (NSString *prefix in self.cbServiceCells) {
        DEMBaseViewCell *serviceView;
        serviceView = [self valueForKey:[NSString stringWithFormat:@"%@ViewCell", prefix]];
        [serviceView configureWithSensorTag:self.sensorTag];
    }
    
}


- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"window is about to close");
    
    for (NSString *prefix in self.cbServiceCells) {
        DEMBaseViewCell *serviceView;
        serviceView = [self valueForKey:[NSString stringWithFormat:@"%@ViewCell", prefix]];
        [serviceView deconfigure];
    }
}


@end
