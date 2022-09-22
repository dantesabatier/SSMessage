//
//  SSSMTPConnectionSecurityLevel.h
//  SSMessage
//
//  Created by Dante Sabatier on 07/01/19.
//

#import <Foundation/NSObjCRuntime.h>

/*!
 @enum SSSMTPConnectionSecurityLevel
 @discussion Constants the represent the SSL security level.
 @constant SSSMTPConnectionSecurityLevelNone Don't use SSL. Authentication may fail with some servers.
 @constant SSSMTPConnectionSecurityLevelSSLv3 Indicates to use SSLv3.
 @constant SSSMTPConnectionSecurityLevelTLSv1 Indicates to use only TLSv1. This is the default value.
 */

typedef NS_ENUM(NSInteger, SSSMTPConnectionSecurityLevel) {
    SSSMTPConnectionSecurityLevelNone = 0,
    SSSMTPConnectionSecurityLevelSSLv3 = 2,
    SSSMTPConnectionSecurityLevelTLSv1 = 4,
} NS_SWIFT_NAME(SSSMTPConnection.SecurityLevel);
