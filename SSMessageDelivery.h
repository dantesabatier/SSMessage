//
//  SSMessageDelivery.h
//  SSMessage
//
//  Created by Dante Sabatier on 30/08/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSDeliveryAccount.h"

NS_ASSUME_NONNULL_BEGIN

@class SSMessage;

/*!
 @class SSMessageDelivery
  @brief Class to send emails
 */

@interface SSMessageDelivery : NSObject {
@private
    id _private;
    id <SSDeliveryAccount>_deliveryAccount;
}

- (instancetype)init __attribute__((objc_designated_initializer));
- (instancetype)initWithDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount __attribute__((objc_designated_initializer));
@property (class, nonatomic, readonly, ss_strong) SSMessageDelivery *sharedMessageDelivery SS_CONST;
@property (copy) id <SSDeliveryAccount>deliveryAccount;
- (void)asynchronousyDeliverMessage:(SSMessage *)message completion:(void (^)(SSMessage *message, SSMessageDeliveryResult result, NSError *__nullable error))completion;
- (void)cancelMessageDeliveryForMessage:(SSMessage *)message;
- (void)cancelAllMessageDeliveries;

@end

NS_ASSUME_NONNULL_END
