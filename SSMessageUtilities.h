/*
 SSMessageUtilities.h
 SSMessage
 
 Created by Dante Sabatier on 26/08/09.
 Copyright 2009 Dante Sabatier. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "SSDeliveryAccount.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @param account
 the account
 */

extern NSString * __nullable SSMessageGetPasswordForAccount(id <SSDeliveryAccount> account) NS_AVAILABLE(10_5, NA);

/*!
 @param password
 the password.
 @param account
 the account.
 */

extern BOOL SSMessageSetPasswordForAccount(NSString *password, id <SSDeliveryAccount> account) NS_AVAILABLE(10_5, NA);

/*!
 @brief Checks if an mail address is valid.
 @param emailAddress
 the email address.
 @result YES if email is valid.
 */

extern BOOL SSMessageValidateEmailAddress(NSString *emailAddress);

/*!
 @param hostName
 the name of the server.
 */

extern BOOL SSMessageIsMacHost(NSString *hostName);

/*!
 @brief Searchs a certificate for specified email. You must CFRelease() the resulting (SecCertificateRef)itemRef.
 @param email
 the email
 @param itemRef
 a pointer to the wanted certificate.
 */

#if !TARGET_OS_IPHONE
extern OSStatus SSMessageGetCertificateRefForEmail(NSString *email, __nonnull SecKeychainItemRef * __nonnull itemRef) NS_AVAILABLE(10_5, NA);
#endif

/*!
 @param url
 NSURL referring to the connection.
 @param diagnosticDescription
 a pointer to the diagnostic description.
 */

extern CFNetDiagnosticStatus SSMessageValidateConnectionWithURL(NSURL *url, NSString *__nullable * __nullable diagnosticDescription) NS_DEPRECATED(10_6, 10_13, 6_0, 11_0);

/*!
 @brief see below.
 */

extern CFNetDiagnosticStatus SSMessageValidateInternetConnection(NSString * __nullable * __nullable diagnosticDescription) NS_DEPRECATED(10_6, 10_13, 6_0, 11_0);

/*!
 @brief see below.
 */

extern BOOL SSMessageIsInternetConnectionUp(void) NS_DEPRECATED(10_6, 10_13, 6_0, 11_0);

/*!
 @brief Used to get UTI of a file.
 @param filename
 can be either full path of just the filename, filename must contain path extension.
 */

extern CFStringRef __nullable SSMessageGetUTIOfFile(NSString *filename) CF_RETURNS_NOT_RETAINED;

/*!
 @brief Used to decide <tt>SSMessagePart</tt> <tt>contentDisposition</tt>.
 @param filename
 can be either full path of just the filename, filename must contain path extension.
 */

extern BOOL SSMessageFileConformsToUTI(NSString *filename, CFStringRef inConformsToUTI);

/*!
 @brief Used to get mime type of a file.
 @param filename
 can be either full path of just the filename, filename must contain path extension.
 */

extern NSString * __nullable SSMessageGetMIMETypeOfFile(NSString *filename);

/*!
 @param URL
 .
 */

extern BOOL SSMessageMailContentsOfURL(NSURL *URL, NSError *__nullable *__nullable error) NS_AVAILABLE(10_5, NA);

/*!
 @param URL
 .
 */

extern BOOL SSMessageMailLinkToURL(NSURL *URL) NS_AVAILABLE(10_5, NA);

NS_ASSUME_NONNULL_END
