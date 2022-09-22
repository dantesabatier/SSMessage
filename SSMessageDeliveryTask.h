//
//  SSMessageDeliveryTask.h
//  SSFoundation
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSSMTPConnection.h"
#import "SSDeliveryAccount.h"
#import "SSMessageDefines.h"
#import "SSMessageDeliveryState.h"
#import "SSMessageDeliveryResult.h"

NS_ASSUME_NONNULL_BEGIN

@class SSMessage;

@protocol SSMessageDeliveryTaskDelegate

@optional
- (void)messageDeliveryCompleted:(NSNotification *)notification;

@end

@interface SSMessageDeliveryTask : NSObject {
@private
    SSSMTPConnection *_connection;
    id <SSDeliveryAccount>_deliveryAccount;
    __ss_weak id <SSMessageDeliveryTaskDelegate> _delegate;
    SSMessageDeliveryState _state;
    BOOL _cancelled;
}
- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount __attribute__((objc_designated_initializer));
@property (readonly, copy) id <SSDeliveryAccount>deliveryAccount;
@property (nullable, nonatomic, ss_weak) id <SSMessageDeliveryTaskDelegate> delegate;
@property (readonly, getter=isCancelled) BOOL cancelled
- (BOOL)deliverMessage:(SSMessage *)message error:(__autoreleasing NSError *__nullable *__nullable)error;
#if NS_BLOCKS_AVAILABLE
- (void)asynchronousyDeliverMessage:(SSMessage *)message completion:(void (^)(SSMessage *message, SSMessageDeliveryResult result, NSError *__nullable error))completion NS_AVAILABLE(10_6, 7_0);
#endif
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
