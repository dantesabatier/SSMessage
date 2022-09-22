//
//  SSMessageDeliveryObserver.h
//  SSMessage
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSMessageDelivery.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SSMessageDeliveryObserverBlock)(__kindof SSMessage * __nullable message, SSMessageDeliveryState state, NSError * __nullable error);

@interface SSMessageDeliveryObserver : NSObject {
@private
    SSMessage *_message;
    NSOperationQueue *_queue;
    SSMessageDeliveryObserverBlock _block;
}

@property (copy) SSMessage *message;
@property (copy) SSMessageDeliveryObserverBlock block;
@property (strong) NSOperationQueue *queue;

@end

NS_ASSUME_NONNULL_END

