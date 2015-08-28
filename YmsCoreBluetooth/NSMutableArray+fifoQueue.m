//
// Copyright 2013-2014 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
//


#import "NSMutableArray+fifoQueue.h"

@implementation NSMutableArray (fifoQueue)

- (void)push:(id)anObject {
    [self addObject:anObject];
}

- (id)pop {
    id result = nil;
    
    if ([self count] > 0) {
        result = [self objectAtIndex:0];
        [self removeObjectAtIndex:0];
    }

    return result;
}

- (id)peekTail {
    id result = nil;
    
    if ([self count] > 0) {
        result = [self objectAtIndex:0];
    }
    
    return result;
}

@end
