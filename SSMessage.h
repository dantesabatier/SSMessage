//
//  SSMessage.h
//  SSMessage
//
//  Created by Dante Sabatier on 30/08/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import "NSArray+SSAdditions.h"
#import "NSAttributedString+SSAdditions.h"
#import "NSData+SSAdditions.h"
#import "NSDictionary+SSAdditions.h"
#import "NSString+SSAdditions.h"
#import "NSTextAttachment+SSAdditions.h"
#import "NSURL+SSAdditions.h"
#import "SSMessageAddressee.h"
#import "SSMessageAttachment.h"
#import "SSMessageDelivery.h"
#import "SSMessageUtilities.h"
#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#import "SSKeychain.h"
#import "SSKeychainItem.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/*!
 @enum SSMessagePriority
 @discussion Constants the represent the message priority.
 @constant SSMessagePriorityHigh High priority.
 @constant SSMessagePriorityNormal Normal priority. This is the default value.
 @constant SSMessagePriorityLow Low priority.
 */

typedef NS_ENUM(NSInteger, SSMessagePriority) {
    SSMessagePriorityHigh = 1,
	SSMessagePriorityNormal = 3,
	SSMessagePriorityLow = 5,
} NS_SWIFT_NAME(SSMessage.MessagePriority);

/*!
 @class SSMessage
 @brief Class that represents an email message.
 @discussion <tt>SSMessage</tt> is a subclass of class <tt>SSMessagePart</tt> the represents an email message.
*/

@interface SSMessage : SSMessagePart {
@private
    id <SSMessageAddressee> _sender;
    NSArray <id <SSMessageAddressee>>*_replyTo;
    NSArray <id <SSMessageAddressee>>*_toRecipients;
    NSArray <id <SSMessageAddressee>>*_ccRecipients;
    NSArray <id <SSMessageAddressee>>*_bccRecipients;
    NSArray <id <SSMessageAddressee>>*_recipients;
    NSArray <id <SSMessageAttachment>>*_attachments;
    NSArray <id <SSMessagePart>>*_parts;
    NSString *_subject;
    NSString *_source;
    NSDate *_dateSent;
    NSStringEncoding _encoding;
    SSMessagePriority _priority;
    NSString *_relatedBoundary;
    id _representedObject;
}

/*!
 @brief Initializes a new message with the provided parameters.
 @discussion If message format is diferent from <tt><i>SSMessageFormatMultipartAlternative</i></tt> any rich text or attachments will be lost.
 @param messageHeaders
 Contains all of the values that will appear in the message header.
 @param messageBody
 The contents of the message.
 @param messageFormat
 The format of the message. Can be <tt><i>SSMessageFormatPlainText</i></tt>, <tt><i>SSMessageFormatHTML</i></tt> or <tt><i>SSMessageFormatMultipartAlternative</i></tt>.
 */

- (instancetype)initWithHeaders:(NSDictionary <SSMessageHeaderKey, id>*)messageHeaders content:(NSAttributedString *)messageBody format:(SSMessageFormat)messageFormat;

/*!
 @brief As in @link initWithHeaders:content:format: initWithHeaders:content:format: @/link, but passing SSMessageFormatMultipartAlternative as message format.
 */

- (instancetype)initWithHeaders:(NSDictionary <SSMessageHeaderKey, id>*)messageHeaders content:(NSAttributedString *)messageBody;

/*!
 @brief the headers of the message.
 */

@property (nullable, copy) NSDictionary <SSMessageHeaderKey, id>*headers;

/*!
 @brief See SSMessageHeaderKeyFrom.
 @discussion Taken from <tt>headers</tt>. This property returns the value for <tt>SSMessageHeaderKeyFrom</tt>. Can be anything conforming the <tt>SSMessageAddressee</tt> protocol including an instance of <tt>SSMessageAddressee</tt> (recommended).
 */

@property (nullable, readonly, copy) id <SSMessageAddressee> sender;

/*!
 @brief See SSMessageHeaderKeySubject.
 @discussion Taken from <tt>headers</tt>. This property returns the value for <tt>SSMessageHeaderKeySubject</tt>.
 */

@property (nullable, readonly, copy) NSString *subject;

/*!
 @brief See SSMessageHeaderKeyReplyTo.
 @discussion Taken from <tt>headers</tt>. This property returns the value for <tt>SSMessageHeaderKeyReplyTo</tt>, you can explicitly provide instances of <tt>SSMessageAddressee</tt> within the message <tt>headers</tt>.
 */

@property (nullable, readonly, copy) NSArray <id <SSMessageAddressee>>*replyTo;

/*!
 @brief See SSMessageHeaderKeyToRecipients.
 @discussion Taken from <tt>headers</tt>. This property returns the value for <tt>SSMessageHeaderKeyToRecipients</tt>, you can explicitly provide instances of <tt>SSMessageAddressee</tt> within the message <tt>headers</tt>.
 */

@property (nullable, readonly, copy) NSArray <id <SSMessageAddressee>>*toRecipients;

/*!
 @brief See SSMessageHeaderKeyCcRecipients.
 @discussion Taken from <tt>headers</tt>. This property returns the value for <tt>SSMessageHeaderKeyCcRecipients</tt>, you can explicitly provide instances of <tt>SSMessageAddressee</tt> within the message <tt>headers</tt>.
 */

@property (nullable, readonly, copy) NSArray <id <SSMessageAddressee>>*ccRecipients;

/*!
 @brief See SSMessageHeaderKeyBccRecipients.
 @discussion Taken from <tt>headers</tt>. This property returns the value for <tt>SSMessageHeaderKeyBccRecipients</tt>, you can explicitly provide instances of <tt>SSMessageAddressee</tt> within the message <tt>headers</tt>.
 */

@property (nullable, readonly, copy) NSArray <id <SSMessageAddressee>>*bccRecipients;

/*!
 @brief An array of objects conforming the <tt>SSMessageAddressee</tt> protocol, the sum of all the recipients.
 */

@property (nullable, readonly, copy) NSArray <id <SSMessageAddressee>>*recipients;

/*!
 @brief the parts of the message.
 @discussion the message <tt>source</tt> is created based on this property, you don't have to deal with message parts but you can provide them if you want (recommended, specially if you use a WebView in your application), if you do so, you should also provide your own message @link source source @/link.
 */

@property (nullable, copy) NSArray <id <SSMessagePart>>*parts;

/*!
 @brief the raw source of the message.
 @discussion The row source of the message, as is send to the server. Uses a lazy getter just in case you don't provide one.
 */

@property (nullable, copy) NSString *source;

/*!
 @brief the attachments of the message.
 @discussion This property is taken from @link //maildelivery_ref/occ/data/SSMessagePart/content content @/link.
 */

@property (nullable, copy) NSArray <id <SSMessageAttachment>>*attachments;

/*!
 @brief date sent
 */

@property (nullable, copy) NSDate *dateSent;

/*!
 @brief the string encoding of the message. Default is NSASCIIStringEncoding.
 */

@property NSStringEncoding encoding;

/*!
 @brief priority of the message.
 */

@property SSMessagePriority priority;

/*!
 @brief .
 */

@property (readonly, copy) NSString *relatedBoundary;

/*!
 @brief can be anything or nothing.
 */

@property (nullable, strong) id representedObject;

@end

NS_ASSUME_NONNULL_END


