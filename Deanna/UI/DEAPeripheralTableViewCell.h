//
//  DEAPeripheralTableViewCell.h
//  Deanna
//
//  Created by Charles Choi on 4/18/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YMSCBPeripheral;
@class CBPeripheral;
@class DEABaseButton;

@interface DEAPeripheralTableViewCell : UITableViewCell


@property (weak, nonatomic) YMSCBPeripheral *yperipheral;
        
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rssiLabel;
@property (strong, nonatomic) IBOutlet UILabel *signalLabel;
@property (strong, nonatomic) IBOutlet DEABaseButton *connectButton;
@property (strong, nonatomic) IBOutlet UILabel *dbLabel;
@property (strong, nonatomic) IBOutlet UILabel *peripheralStatusLabel;

- (IBAction)connectButtonAction:(id)sender;

- (void)configureWithPeripheral:(YMSCBPeripheral *)yp;

- (void)updateDisplay;

- (void)applyStyle;

@end
