//
//  SSMessageDeliveryObserver.m
//  SSMessage
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSMessageDeliveryObserver.h"

@implementation SSMessageDeliveryObserver

- (void)dealloc {
    [_message release];
    [_block release];
    [_queue release];
    [super ss_dealloc];
}

- (SSMessage *)message {
    return SSAtomicAutoreleasedGet(_message);
}

- (void)setMessage:(SSMessage *)message {
    SSAtomicCopiedSet(_message, message);
}

- (SSMessageDeliveryObserverBlock)block {
    return SSAtomicAutoreleasedGet(_block);
}

- (void)setBlock:(SSMessageDeliveryObserverBlock)block {
    SSAtomicCopiedSet(_block, block);
}

- (NSOperationQueue *)queue {
    return SSAtomicAutoreleasedGet(_queue);
}

- (void)setQueue:(NSOperationQueue *)queue {
    SSAtomicRetainedSet(_queue, queue);
}

@end
