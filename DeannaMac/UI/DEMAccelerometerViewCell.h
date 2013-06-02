//
//  DEMAccelerometerViewCell.h
//  DeannaMac
//
//  Created by Charles Choi on 6/1/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "DEMBaseViewCell.h"
@class DEASensorTag;

@interface DEMAccelerometerViewCell : DEMBaseViewCell

@property (strong) IBOutlet NSTextField *accelXLabel;
@property (strong) IBOutlet NSTextField *accelYLabel;
@property (strong) IBOutlet NSTextField *accelZLabel;





@end
