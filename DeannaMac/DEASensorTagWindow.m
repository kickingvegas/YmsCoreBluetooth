//
//  DEAPeripheralWindow.m
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEASensorTagWindow.h"
#import "DEMAccelerometerViewCell.h"
#import "DEMBarometerViewCell.h"
#import "DEASensorTag.h"

@implementation DEASensorTagWindow

- (id)init {
    self = [super initWithWindowNibName:@"DEASensorTagWindow"];
    if (self) {
        /*
        _cbServiceCells = @[@"simplekeys"
                            , @"temperature"
                            , @"accelerometer"
                            , @"magnetometer"
                            , @"gyroscope"
                            , @"humidity"
                            , @"barometer"
                            , @"devinfo"
                            ];
         */
        
        _cbServiceCells = @[@"accelerometer"
                            , @"barometer"];
    }
    return self;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 114.0;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSView *serviceView;
    NSString *prefix  = self.cbServiceCells[row];
    serviceView = [self valueForKey:[NSString stringWithFormat:@"%@ViewCell", prefix]];
    
    
    return serviceView;
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    [self.accelerometerViewCell configureWithSensorTag:self.sensorTag];
    [self.barometerViewCell configureWithSensorTag:self.sensorTag];
}


- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"window is about to close");
    
    
    for (NSString *prefix in self.cbServiceCells) {
        NSView *serviceView;
        serviceView = [self valueForKey:[NSString stringWithFormat:@"%@ViewCell", prefix]];
    }
    

    [self.accelerometerViewCell deconfigure];
    [self.barometerViewCell deconfigure];
}


@end
