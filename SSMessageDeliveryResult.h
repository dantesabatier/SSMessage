//
//  SSMessageDeliveryResult.h
//  SSMessage
//
//  Created by Dante Sabatier on 07/01/19.
//

#import <Foundation/NSObjCRuntime.h>

typedef NS_ENUM(NSInteger, SSMessageDeliveryResult) {
    SSMessageDeliveryResultFailed,
    SSMessageDeliveryResultSucceeded,
    SSMessageDeliveryResultCancelled
} NS_SWIFT_NAME(SSMessageDelivery.MessageDeliveryResult);
