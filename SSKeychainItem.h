//
//  SSKeychainItem.h
//  SSMessage
//
//  Created by Dante Sabatier on 9/24/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @class SSKeychainItem
 @brief Class that representes a keychain item.
 @discussion Represents the kind of keychain item that this framework use. The properties change some of their names in order to avoid confusions, specially with concepts like delivery account and their properties.
 */

NS_CLASS_AVAILABLE_MAC(10_6)
@interface SSKeychainItem : NSObject {
@private
    SecKeychainItemRef _keychainItemRef;
    NSString *_host;
    NSString *_user;
    NSString *_password;
}

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithKeychainItemRef:(SecKeychainItemRef)keychainItemRef __attribute__((objc_designated_initializer));

/*!
 @property keychainItemRef
  @brief the <tt>keychainItemRef</tt>.
 */

@property (nullable, readonly) SecKeychainItemRef keychainItemRef;

/*!
 @property host
  @brief the <tt>kSecServerItemAttr</tt> attribute.
 */

@property (nullable, copy) NSString *host;

/*!
 @property user
  @brief the <tt>kSecAccountItemAttr</tt> attribute.
 */

@property (nullable, copy) NSString *user;

/*!
 @property password
  @brief the password for the keychain item.
 */

@property (nullable, copy) NSString *password;

@end

extern OSStatus SSKeychainItemModifyAttribute(SSKeychainItem *self, SecItemAttr itemAttribute, NSString *attributeValue);

NS_ASSUME_NONNULL_END
