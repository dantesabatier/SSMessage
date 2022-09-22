//
//  SSSMTPConnectionAuthenticationScheme.h
//  SSMessage
//
//  Created by Dante Sabatier on 07/01/19.
//

#import <Foundation/NSObjCRuntime.h>

/*!
 @typedef SSSMTPConnectionAuthenticationScheme
 @discussion Constants the represent the authentication scheme.
 @constant SSSMTPConnectionAuthenticationSchemeNone ...
 @constant SSSMTPConnectionAuthenticationSchemePlain AUTH PLAIN.
 @constant SSSMTPConnectionAuthenticationSchemeLogin AUTH LOGIN.
 */

typedef NS_ENUM(NSInteger, SSSMTPConnectionAuthenticationScheme) {
    SSSMTPConnectionAuthenticationSchemeNone,
    SSSMTPConnectionAuthenticationSchemePlain, /*Default*/
    SSSMTPConnectionAuthenticationSchemeLogin,
} NS_SWIFT_NAME(SSSMTPConnection.AuthenticationScheme);
