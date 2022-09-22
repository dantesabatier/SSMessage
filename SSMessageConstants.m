//
//  SSMessageConstants.m
//  SSMessage
//
//  Created by Dante Sabatier on 22/12/16.
//
//

#import "SSMessageConstants.h"

SSDeliveryAccountKey const SSDeliveryAccountKeyName = @"AccountName";
SSDeliveryAccountKey const SSDeliveryAccountKeyHostName = @"Hostname";
SSDeliveryAccountKey const SSDeliveryAccountKeyFullUserName = @"FullUserName";
SSDeliveryAccountKey const SSDeliveryAccountKeySenders = @"EmailAddresses";
SSDeliveryAccountKey const SSDeliveryAccountKeyDesignatedSender = @"DesignatedEmailAddress";
SSDeliveryAccountKey const SSDeliveryAccounKeyUserName = @"Username";
SSDeliveryAccountKey const SSDeliveryAccountKeyAuthenticationScheme = @"AuthenticationScheme";
SSDeliveryAccountKey const SSDeliveryAccountKeyPassword = @"Password";
SSDeliveryAccountKey const SSDeliveryAccountKeyPortNumber = @"PortNumber";
SSDeliveryAccountKey const SSDeliveryAccountKeySSLEnabled = @"SSLEnabled";
SSDeliveryAccountKey const SSDeliveryAccountKeySecurityLevel = @"SSLSecurityLevel";
SSDeliveryAccountKey const SSDeliveryAccountKeyUsesDefaultPorts = @"UseDefaultPorts";

SSMessagePartContentDisposition const SSMessagePartContentDispositionInline = @"inline";
SSMessagePartContentDisposition const SSMessagePartContentDispositionAttachment = @"attachment";

SSMessagePartContentTransferEncoding const SSMessagePartContentTransferEncodingBase64 = @"base64";

SSMessagePartContentType const SSMessagePartContentTypePlainText = @"text/plain";
SSMessagePartContentType const SSMessagePartContentTypeHTML = @"text/html";
SSMessagePartContentType const SSMessagePartContentTypeMultipartAlternative = @"multipart/alternative";

SSMessageHeaderKey const SSMessageHeaderKeyFrom = @"From";
SSMessageHeaderKey const SSMessageHeaderKeyToRecipients = @"To";
SSMessageHeaderKey const SSMessageHeaderKeyBccRecipients = @"Bcc";
SSMessageHeaderKey const SSMessageHeaderKeyCcRecipients = @"Cc";
SSMessageHeaderKey const SSMessageHeaderKeyReplyTo = @"Reply-To";
SSMessageHeaderKey const SSMessageHeaderKeySubject = @"Subject";

SSMessageFormat const SSMessageFormatPlainText = @"text/plain";
SSMessageFormat const SSMessageFormatHTML = @"text/html";
SSMessageFormat const SSMessageFormatMultipartAlternative = @"multipart/alternative";

NSImageName const SSImageNameDeliveryAccount = @"DeliveryAccount";

NSNotificationName SSMessageDeliveryCompletedNotification = @"SSMessageDeliveryCompletedNotification";
NSNotificationName SSMessageDeliveryFailedNotification = @"SSMessageDeliveryFailedNotification";
NSString *const SSMessageDeliveryMessageKey = @"SSMessageDeliveryMessageKey";
NSString *const SSMessageDeliveryResultKey = @"SSMessageDeliveryResultKey";
NSString *const SSMessageDeliveryErrorKey = @"SSMessageDeliveryErrorKey";