//
//  SSMessageDeliveryWorker.h
//  SSFoundation
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSMessageDeliveryTask.h"

NS_ASSUME_NONNULL_BEGIN

@class SSMessage;

@interface SSMessageDeliveryWorker : SSMessageDeliveryTask {
@private
    SSMessage *_message;
}

- (instancetype)initWithDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount message:(SSMessage *)message;
@property (readonly, copy) SSMessage *message;

@end

NS_ASSUME_NONNULL_END