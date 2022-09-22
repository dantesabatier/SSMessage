//
//  SSDeliveryAccount.h
//  SSMessage
//
//  Created by Dante Sabatier on 23/05/19.
//

#import <Foundation/Foundation.h>
#import "SSConnectionSecurityLevel.h"
#import "SSConnectionAuthenticationScheme.h"
#import "SSMessageConstants.h"
#import "SSMessageAddressee.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol SSDeliveryAccount <NSObject, NSCopying, NSCoding>

@required

/*!
 @discussion all senders for an account.
 */

@property (nullable, readonly, copy) NSArray <id <SSMessageAddressee>>*senders;

/*!
 @discussion the default sender for an account.
 */

@property (nullable, readonly, copy) id <SSMessageAddressee>designatedSender;

/*!
 @brief the host.
 */

@property (nullable, readonly, copy) NSString *host;

/*!
 @brief the user.
 */

@property (nullable, readonly, copy) NSString *user;

/*!
 @brief password.
 */

@property (nullable, readonly, copy) NSString *password;

/*!
 @brief the identifier of the account.
 @discussion E.g. smtp.domain.com:janedoe.
 */

@property (nullable, readonly, copy) NSString *identifier;

@optional

/*!
 @brief the name of this account.
 */

@property (nullable, readonly, copy) NSString *name;

/*!
 @brief port.
 */

@property (readonly) NSInteger port;

/*!
 @brief usesDefaultPorts.
 */

@property (readonly) BOOL usesDefaultPorts;

/*!
 @brief usesSSL.
 */

@property (readonly) BOOL usesSSL;

/*!
 @brief securityLevel.
 */

@property (readonly) SSConnectionSecurityLevel securityLevel;

/*!
 @brief authenticationScheme.
 */

@property (readonly) SSConnectionAuthenticationScheme authenticationScheme;

/*!
 @brief the icon of the account.
 */

#if TARGET_OS_IPHONE
@property (nullable, readonly, copy) UIImage *icon;
#else
@property (nullable, readonly, copy) NSImage *icon;
#endif

@end

@interface SSDeliveryAccount : NSObject <SSDeliveryAccount> {
@private
    NSString *_identifier;
    NSString *_name;
    NSString *_host;
    NSString *_user;
    NSString *_password;
    NSInteger _port;
    NSArray <id <SSMessageAddressee>>*_senders;
    id <SSMessageAddressee>_designatedSender;
    SSConnectionAuthenticationScheme _authenticationScheme;
    SSConnectionSecurityLevel _securityLevel;
    BOOL _usesDefaultPorts;
    BOOL _usesSSL;
    id _icon;
}

- (instancetype)init __attribute__((objc_designated_initializer));
- (instancetype)initWithCoder:(NSCoder *)decoder __attribute__((objc_designated_initializer));
- (instancetype)initWithDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount __attribute__((objc_designated_initializer));
@property (nullable, copy) NSString *identifier;
@property (nullable, copy) NSString *name;
@property (nullable, copy) NSString *host;
@property (nullable, copy) NSString *user;
@property (nullable, copy) NSString *password;
@property (nullable, copy) NSArray <id <SSMessageAddressee>>*senders;
@property (nullable, copy) id <SSMessageAddressee>designatedSender;
@property NSInteger port;
@property  SSConnectionAuthenticationScheme authenticationScheme;
@property  SSConnectionSecurityLevel securityLevel;
@property BOOL usesDefaultPorts;
@property BOOL usesSSL;
#if TARGET_OS_IPHONE
@property (nullable, copy) UIImage *icon;
#else
@property (nullable, copy) NSImage *icon;
#endif

@end

NS_ASSUME_NONNULL_END
