//
//  DEAPeripheralWindow.h
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DEASensorTag;
@class DEMAccelerometerViewCell;
@class DEMBarometerViewCell;


@interface DEASensorTagWindow : NSWindowController<NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property (strong, nonatomic) DEASensorTag *sensorTag;

/// Array of names of service cells.
@property (strong, nonatomic) NSArray *cbServiceCells;

@property (strong) IBOutlet NSTableView *servicesTableView;
@property (strong) IBOutlet DEMAccelerometerViewCell *accelerometerViewCell;
@property (strong) IBOutlet DEMBarometerViewCell *barometerViewCell;

@end
