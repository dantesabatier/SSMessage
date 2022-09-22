//
//  SSKeychain.h
//  SSMessage
//
//  Created by Dante Sabatier on 9/24/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "SSMessageDeliveryAccount.h"

NS_ASSUME_NONNULL_BEGIN

@class SSKeychainItem;

/*!
 @class SSKeychain
  @brief Class to get a save keychain internet items. Can retrive both, MobileMe and regular SMTP accounts but you cannot modify MobileMe items.
 */

NS_CLASS_AVAILABLE_MAC(10_6)
@interface SSKeychain : NSObject {
@private
    SecKeychainRef _keychain;
}

/*!
 @brief Unavailable for this class.
 */

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));

/*!
 @brief shared instance.
 */

+ (nullable instancetype)sharedKeychain __attribute__((const));

/*!
 @brief attempts to add a new item to keychain.
 @discussion If item exists, this method returns the same as in @link keychainItemForAccount: keychainItemForAccount: @/link.
 @param account
 NSDictionary containing hostName, userName, port, and password.
 @result the <tt>SSKeychainItem</tt> for account.
 */

- (nullable SSKeychainItem *)addKeychainItemForAccount:(id <SSMessageDeliveryAccount>)account;

/*!
 @brief returns a keychain item for account (if exists).
 @param account
 NSDictionary containing hostName and userName.
 @result the <tt>SSKeychainItem</tt> for account.
 */

- (nullable SSKeychainItem *)keychainItemForAccount:(id <SSMessageDeliveryAccount>)account;

/*!
 @brief returns the password for given account (if exists).
 @param account
 NSDictionary containing hostName and userName.
 @result the password.
 */

- (nullable NSString *)passwordForAccount:(id <SSMessageDeliveryAccount>)account;

/*!
 @brief returns YES if password is set, NO otherwise.
 @param password
 NSString the new password.
 @param account
 NSDictionary containing hostName and userName.
 @result YES if password is set, NO otherwise.
 */

- (BOOL)setPassword:(NSString *)password forAccount:(id <SSMessageDeliveryAccount>)account;

@end

NS_ASSUME_NONNULL_END
