//
//  SSMessageConstants.h
//  SSMessage
//
//  Created by Dante Sabatier on 22/12/16.
//
//

#import <Foundation/Foundation.h>

typedef NSString * SSDeliveryAccountKey NS_TYPED_EXTENSIBLE_ENUM;

/*!
 @const SSDeliveryAccountKeyName
 @discussion \@"AccountName", NSString containing the name of the account.
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeyName;

/*!
 @const SSDeliveryAccountKeyHostName
 @discussion \@"Hostname", NSString containing the name of the host.
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeyHostName;

/*!
 @const SSDeliveryAccountKeyFullUserName
 @discussion \@"FullUserName", NSString containing the full name of the user.
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeyFullUserName;

/*!
 @const SSDeliveryAccountKeySenders
 @discussion \@"EmailAddresses", NSArray of SSMessageAddressee of the account.
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeySenders;

/*!
 @const SSDeliveryAccountKeyDesignatedSender
 @discussion \@"DesignatedEmailAddress", default SSMessageAddressee for the account.
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeyDesignatedSender;

/*!
 @const SSDeliveryAccounKeyUserName
 @discussion \@"Username", NSString containing the user name of the account.
 */

extern SSDeliveryAccountKey const SSDeliveryAccounKeyUserName;

/*!
 @const SSDeliveryAccountKeyPassword
 @discussion \@"Password", NSString containing the password of the account.
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeyPassword;

/*!
 @const SSDeliveryAccountKeyAuthenticationScheme
 @discussion \@"AuthenticationScheme", NSNumber containing integer (SSConnectionAuthenticationScheme).
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeyAuthenticationScheme;

/*!
 @const SSDeliveryAccountKeyPortNumber
 @discussion \@"PortNumber", NSNumber containing integer, the port of the account.
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeyPortNumber;

/*!
 @const SSDeliveryAccountKeySSLEnabled
 @discussion \@"SSLEnabled", NSNumber containing bool, should use SSL.
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeySSLEnabled;

/*!
 @const SSDeliveryAccountKeySecurityLevel
 @discussion \@"SSLSecurityLevel", NSNumber containing integer (SSConnectionSecurityLevel).
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeySecurityLevel;

/*!
 @const SSDeliveryAccountKeyUsesDefaultPorts
 @discussion \@"UseDefaultPorts", NSNumber containing bool, should use defaults ports.
 */

extern SSDeliveryAccountKey const SSDeliveryAccountKeyUsesDefaultPorts;

typedef NSString * SSMessagePartContentDisposition NS_TYPED_ENUM;

/*!
 @const SSMessagePartContentDispositionInline
 @discussion \@"inline".
 */

extern SSMessagePartContentDisposition const SSMessagePartContentDispositionInline;

/*!
 @const SSMessagePartContentDispositionAttachment
 @discussion \@"attachment".
 */

extern SSMessagePartContentDisposition const SSMessagePartContentDispositionAttachment;

typedef NSString * SSMessagePartContentTransferEncoding NS_TYPED_EXTENSIBLE_ENUM;

/*!
 @const SSMessagePartContentTransferEncodingBase64
 @discussion \@"base64".
 */

extern SSMessagePartContentTransferEncoding const SSMessagePartContentTransferEncodingBase64;

typedef NSString * SSMessagePartContentType NS_TYPED_ENUM;

/*!
 @const SSMessagePartContentTypePlainText
 @discussion \@"text/plain", plain text message format.
 */

extern SSMessagePartContentType const SSMessagePartContentTypePlainText;

/*!
 @const SSMessagePartContentTypeHTML
 @discussion \@"text/html", HTML message format.
 */

extern SSMessagePartContentType const SSMessagePartContentTypeHTML;

/*!
 @const SSMessagePartContentTypeMultipartAlternative
 @discussion \@"multipart/alternative", multipart alternative message format.
 */

extern SSMessagePartContentType const SSMessagePartContentTypeMultipartAlternative;


typedef NSString * SSMessagePartFormat NS_TYPED_ENUM;
/*!
 @const SSMessagePartFormatFlowed
 @discussion \@"flowed" format.
 */

extern SSMessagePartFormat const SSMessagePartFormatFlowed;

typedef SSMessagePartFormat SSMessageFormat NS_TYPED_ENUM;

/*!
 @const SSMessageFormatPlainText
 @discussion \@"text/plain", plain text message format.
 */

extern SSMessageFormat const SSMessageFormatPlainText;

/*!
 @const SSMessageFormatHTML
 @discussion \@"text/html", HTML message format.
 */

extern SSMessageFormat const SSMessageFormatHTML;

/*!
 @const SSMessageFormatMultipartAlternative
 @discussion \@"multipart/alternative", multipart alternative message format.
 */

extern SSMessageFormat const SSMessageFormatMultipartAlternative;

typedef NSString * SSMessagePartHeaderKey NS_TYPED_EXTENSIBLE_ENUM;
typedef SSMessagePartHeaderKey SSMessageHeaderKey NS_TYPED_EXTENSIBLE_ENUM;

/*!
 @const SSMessageHeaderKeyFrom
 @discussion the \@"From" header of the message.
 */

extern SSMessageHeaderKey const SSMessageHeaderKeyFrom;

/*!
 @const SSMessageHeaderKeyToRecipients
 @discussion the \@"To", header of the message.
 */

extern SSMessageHeaderKey const SSMessageHeaderKeyToRecipients;

/*!
 @const SSMessageHeaderKeyBccRecipients
 @discussion the \@"Bcc" header of the message.
 */

extern SSMessageHeaderKey const SSMessageHeaderKeyBccRecipients;

/*!
 @const SSMessageHeaderKeyCcRecipients
 @discussion the \@"Cc" header of the message.
 */

extern SSMessageHeaderKey const SSMessageHeaderKeyCcRecipients;

/*!
 @const SSMessageHeaderKeyReplyTo
 @discussion the \@"Reply-To" header of the message.
 */

extern SSMessageHeaderKey const SSMessageHeaderKeyReplyTo;

/*!
 @const SSMessageHeaderKeySubject
 @discussion the \@"Subject" header of the message.
 */

extern SSMessageHeaderKey const SSMessageHeaderKeySubject;

extern NSImageName const SSImageNameDeliveryAccount NS_SWIFT_NAME(deliveryAccount);

extern NSNotificationName SSMessageDeliveryCompletedNotification NS_SWIFT_NAME(SSMessageDelivery.MessageDeliveryCompletedNotification);

extern NSString *const SSMessageDeliveryMessageKey;
extern NSString *const SSMessageDeliveryResultKey;
extern NSString *const SSMessageDeliveryErrorKey;
