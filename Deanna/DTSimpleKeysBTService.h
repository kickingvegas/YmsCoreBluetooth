//
//  DTSimpleKeysBTService.h
//  Deanna
//
//  Created by Charles Choi on 12/20/12.
//  Copyright (c) 2012 Yummy Melon Software. All rights reserved.
//

#import "DEABaseCBService.h"

@interface DTSimpleKeysBTService : DEABaseCBService

@property (nonatomic, strong) NSNumber *keyValue;

- (void)updateKeyPress;

@end
