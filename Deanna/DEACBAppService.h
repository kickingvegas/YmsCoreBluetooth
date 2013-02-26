//
//  DEACBAppService.h
//  Deanna
//
//  Created by Charles Choi on 2/26/13.
//  Copyright (c) 2013 Yummy Melon Software. All rights reserved.
//

#import "YMSCBAppService.h"

@interface DEACBAppService : YMSCBAppService

/**
 Return singleton instance.
 */
+ (DEACBAppService *)sharedService;

@end
