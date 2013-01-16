//
//  DTSimpleKeysBTService.h
//  Deanna
//
//  Created by Charles Choi on 12/20/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEABaseService.h"

@interface DTSimpleKeysBTService : DEABaseService

@property (nonatomic, strong) NSNumber *keyValue;

- (void)updateKeyPress;

@end
