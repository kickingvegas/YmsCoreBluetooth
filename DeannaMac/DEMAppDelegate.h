//
//  DEMAppDelegate.h
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#import "DEAPeripheralViewCell.h"

@class DEASensorTagWindow;

@interface STTAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, DEAPeripheralViewCellDelegate>
@property (nonatomic, assign) int oldCount;
@property (nonatomic, strong) NSMutableArray *peripheralWindows;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *scanButton;
@property (weak) IBOutlet NSTableView *peripheralTableView;



- (IBAction)scanAction:(id)sender;



@end
