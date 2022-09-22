//
//  SSMessageDeliveryWorker.m
//  SSFoundation
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSMessageDeliveryWorker.h"
#import "SSMessageDefines.h"

@interface SSMessageDeliveryWorker ()

@property (readwrite, copy) SSMessage *message;

@end

@implementation SSMessageDeliveryWorker

- (instancetype)- (instancetype)initWithDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount message:(SSMessage *)message {
    self = [super initWithDeliveryAccount:deliveryAccount];
    if (self) {
        self.message = message;
    }
    return self;
}

- (void)dealloc {
    [_message release];
    [super ss_dealloc];
}

- (SSMessage *)message {
    return SSAtomicAutoreleasedGet(_message);
}

- (void)setMessage:(SSMessage *)message {
    SSAtomicCopiedSet(_message, message);
}

@end
