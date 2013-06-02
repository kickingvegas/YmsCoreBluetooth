//
//  DEMDeviceInfoViewCell.h
//  Deanna
//
//  Created by Charles Choi on 6/2/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEMBaseViewCell.h"

@interface DEMDeviceInfoViewCell : DEMBaseViewCell

/** @name Properties */
/// List of keys
@property (nonatomic, strong) NSArray *keyList;

/// System ID
@property (strong, nonatomic) IBOutlet NSTextField *system_idLabel;
/// Model Number
@property (strong, nonatomic) IBOutlet NSTextField *model_numberLabel;
/// Serial Number
@property (strong, nonatomic) IBOutlet NSTextField *serial_numberLabel;
/// Firmware Revision
@property (strong, nonatomic) IBOutlet NSTextField *firmware_revLabel;
/// Hardware Revision
@property (strong, nonatomic) IBOutlet NSTextField *hardware_revLabel;
/// Software Revision
@property (strong, nonatomic) IBOutlet NSTextField *software_revLabel;
/// Manufacturer Name
@property (strong, nonatomic) IBOutlet NSTextField *manufacturer_nameLabel;
/// IEEE 11073-20601 Regulatory Certification Data List
@property (strong, nonatomic) IBOutlet NSTextField *ieee11073_cert_dataLabel;


@end
