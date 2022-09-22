//
//  SSMessageDelivery.m
//  SSMessage
//
//  Created by Dante Sabatier on 30/08/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSMessageDelivery.h"
#import "SSMessage.h"
#import "SSMessageDeliveryWorker.h"
#import "NSArray+SSAdditions.h"

@interface SSMessageDelivery ()

@end

@implementation SSMessageDelivery

@dynamic deliveryAccount;

static BOOL sharedMessageDeliveryCanBeDestroyed = NO;
static SSMessageDelivery *sharedMessageDelivery = nil;

+ (instancetype)sharedMessageDelivery {
#if (!TARGET_OS_IPHONE && defined(__MAC_10_6)) || (TARGET_OS_IPHONE && defined(__IPHONE_4_0))
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id observedObject = nil;
        NSString *notificationName = nil;
#if TARGET_OS_IPHONE
        observedObject = [UIApplication sharedApplication];
        notificationName = UIApplicationWillTerminateNotification;
#else
        observedObject = NSApp;
        notificationName = NSApplicationWillTerminateNotification;
#endif
        sharedMessageDelivery = [[self alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:notificationName object:observedObject queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            
            sharedMessageDeliveryCanBeDestroyed = YES;
            
            [sharedMessageDelivery release];
        }];
    });
#endif
    
    return sharedMessageDelivery;
}

#pragma mark Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount {
    self = [super init];
    if (self) {
        self.deliveryAccount = deliveryAccount;
    }
	return self;
}

- (void)dealloc {
    if ((self == sharedMessageDelivery) && !sharedMessageDeliveryCanBeDestroyed) {
        return;
    }
    [self cancelAllMessageDeliveries];
    [_private release];
    [_deliveryAccount release];
    [super ss_dealloc];
}

#pragma mark public methods

- (void)asynchronousyDeliverMessage:(SSMessage *)message completion:(void (^)(SSMessage *message, SSMessageDeliveryResult result, NSError *__nullable error))completion {
    SSMessageDeliveryWorker *worker = [[[SSMessageDeliveryWorker alloc] initWithDeliveryAccount:self.deliveryAccount message:message] autorelease];
    if (!_private) {
        _private = [[NSMutableArray alloc] init];
    }
    [(NSMutableArray <SSMessageDeliveryWorker *>*)_private addObject:worker];
    [worker asynchronousyDeliverMessage:message completion:^(SSMessage *message, SSMessageDeliveryResult result, NSError *__nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(message, result, error);
            [(NSMutableArray <SSMessageDeliveryWorker *>*)_private removeObject:[(NSArray <SSMessageDeliveryWorker *>*)_private firstObjectPassingTest:^BOOL(SSMessageDeliveryWorker * _Nonnull obj) {
                return [obj.message isEqual:message];
            }]];
        });
    }];
}

- (void)cancelMessageDeliveryForMessage:(SSMessage *)message {
    [[(NSArray <SSMessageDeliveryWorker *>*)_private firstObjectPassingTest:^BOOL(SSMessageDeliveryWorker * _Nonnull obj) {
        return [obj.message isEqual:message];
    }] cancel];
}

- (void)cancelAllMessageDeliveries {
    [_private makeObjectsPerformSelector:@selector(cancel)];
}

#pragma mark Accesors

- (id <SSDeliveryAccount>)deliveryAccount {
	return SSAtomicAutoreleasedGet(_deliveryAccount);
}

- (void)setDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount  {
     SSAtomicCopiedSet(_deliveryAccount, deliveryAccount);
}

@end
