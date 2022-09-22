//
//  SSMessageAttachment.h
//  SSMessage
//
//  Created by Dante Sabatier on 13/04/19.
//

#import "SSMessagePart.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSMessageAttachment <SSMessagePart>

@optional
@property (nullable, readonly, copy) NSData *data;

@end

@interface SSMessageAttachment : SSMessagePart <SSMessageAttachment>

- (nullable instancetype)initWithMessageAttachment:(id <SSMessageAttachment>)messageAttachment;

@end

NS_ASSUME_NONNULL_END
