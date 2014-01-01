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

#import <Foundation/Foundation.h>

/**
 FIFO queue implementation using NSMutableArray
 */
@interface NSMutableArray (fifoQueue)

/**
 Push object to the back of the queue.
 @param anObject Object to push.
 */
- (void)push:(id)anObject;

/**
 Pop object from the front of the queue.
 @return object from the front of the queue.
 */
- (id)pop;

@end
