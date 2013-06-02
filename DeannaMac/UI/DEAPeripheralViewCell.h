//
//  DEAPeripheralViewCell.h
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DEASensorTag.h"

@class YMSCBPeripheral;

@protocol DEAPeripheralViewCellDelegate <NSObject>

- (void)openPeripheralWindow:(YMSCBPeripheral *)yp;

@end


@interface DEAPeripheralViewCell : NSControl


@property (weak) id<DEAPeripheralViewCellDelegate> delegate;

@property (weak, nonatomic) DEASensorTag *sensorTag;
@property (assign, nonatomic) BOOL hasConnected;

@property (strong, nonatomic) NSTextField *nameLabel;
@property (strong, nonatomic) NSTextField *rssiLabel;
@property (strong, nonatomic) NSButton *connectButton;
@property (strong, nonatomic) NSTextField *dbLabel;
@property (strong, nonatomic) NSButton *detailButton;



- (void)connectButtonAction:(id)sender;

- (void)detailButtonAction:(id)sender;

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag;

- (void)updateDisplay:(CBPeripheral *)peripheral;

- (void)configureTextField:(NSTextField *)label;

@end
