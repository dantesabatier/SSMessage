//
//  SSMessageErrors.h
//  SSMessage
//
//  Created by Dante Sabatier on 07/01/19.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSError.h>

/*!
 @const SSMessageErrorDomain
 @discussion NSError domain for the framework.
 */

extern NSErrorDomain SSMessageErrorDomain;

/*!
 @typedef SSMessageErrorCode
 @discussion Constants that represent some posible errors at the time to send an email.
 @constant SSMessageErrorCodeGeneric Everything else not enumerated.
 @constant SSMessageErrorCodeWrongArguments Message without sender or something like that.
 @constant SSMessageErrorCodeEHLOMessage SMTP server refused our EHLO message.
 @constant SSMessageErrorCodeConnectionFailed Error while trying to make the connection.
 @constant SSMessageErrorCodeConnectionTimeout Timeout while connecting. Default timeout 60 segs.
 @constant SSMessageErrorCodeUnsupportedAuthenticationScheme Framework does not support the authentication mechanism specified by SMTP server.
 @constant SSMessageErrorCodeAuthenticationFailed Authentication failed, bad username or password.
 @constant SSMessageErrorCodeMessageDataExceedLimits Message data exceeds limit specified by the server.
 @constant SSMessageErrorCodeSenderRefused SMTP server refused \@"From" address.
 @constant SSMessageErrorCodeRecipientsRefused All recipient addresses refused by SMTP server.
 @constant SSMessageErrorCodeInvalidMessageData SMTP server refused to accept the message data.
 @constant SSMessageErrorCodeSSLConnectionFailed SSL connection failed.
 @constant SSMessageErrorCodeSSLCertificateDoesNotVerify SSL certificate doesn't verify.
 @constant SSMessageErrorCodeSSLCertificateDoesNotMatchHostName SSL certificate common name doesn't match host name.
 */

typedef NS_ERROR_ENUM(SSMessageErrorDomain, SSMessageErrorCode) {
    SSMessageErrorCodeGeneric = 0,
    SSMessageErrorCodeWrongArguments = 11,
    SSMessageErrorCodeEHLOMessage = 4,
    SSMessageErrorCodeConnectionFailed = 5,
    SSMessageErrorCodeConnectionTimeout = 7,
    SSMessageErrorCodeUnsupportedAuthenticationScheme = 10,
    SSMessageErrorCodeAuthenticationFailed = 535,
    SSMessageErrorCodeMessageDataExceedLimits = 9,
    SSMessageErrorCodeSenderRefused = 8,
    SSMessageErrorCodeRecipientsRefused = 6,
    SSMessageErrorCodeInvalidMessageData = 354,
    SSMessageErrorCodeSSLConnectionFailed = 1,
    SSMessageErrorCodeSSLCertificateDoesNotVerify = 2,
    SSMessageErrorCodeSSLCertificateDoesNotMatchHostName = 3
};
