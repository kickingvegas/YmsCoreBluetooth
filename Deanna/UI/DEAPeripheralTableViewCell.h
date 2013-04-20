//
//  DEAPeripheralTableViewCell.h
//  Deanna
//
//  Created by Charles Choi on 4/18/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DEASensorTag;
@class CBPeripheral;

@interface DEAPeripheralTableViewCell : UITableViewCell


@property (weak, nonatomic) DEASensorTag *sensorTag;
        
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rssiLabel;
@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutlet UILabel *dbLabel;

- (IBAction)connectButtonAction:(id)sender;

- (void)configureWithSensorTag:(DEASensorTag *)sensorTag;

- (void)updateDisplay:(CBPeripheral *)peripheral;


@end
