//
//  DEMBarometerViewCell.h
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEMBaseViewCell.h"



@class DEABarometerService;
@class DEASensorTag;


/**
 View and control logic for the SensorTag barometer service.
 */
@interface DEMBarometerViewCell : DEMBaseViewCell

/// Display ambient temperature
@property (strong, nonatomic) IBOutlet NSTextField *ambientTemperatureLabel;

/// Display object temperature
@property (strong, nonatomic) IBOutlet NSTextField *pressureLabel;

/// Calibration button
@property (strong, nonatomic) IBOutlet NSButton *calibrateButton;


/**
 Action method to handle calibrateButton.
 
 @param sender calibrateButton
 */
- (IBAction)calibrateButtonAction:(id)sender;


@end
