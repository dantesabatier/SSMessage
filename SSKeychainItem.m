//
//  SSKeychainItem.m
//  SSMessage
//
//  Created by Dante Sabatier on 9/24/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSKeychainItem.h"
#import "SSMessageUtilities.h"
#import "SSMessageDefines.h"

@implementation SSKeychainItem

- (instancetype)initWithKeychainItemRef:(SecKeychainItemRef)keychainItemRef; {
    self = [super init];
    if (self) {
        _keychainItemRef = keychainItemRef;
    }
    return self;
}

- (void)dealloc {
    if (_keychainItemRef) {
        CFRelease(_keychainItemRef);
    }
    
	[_host release];
	[_user release];
	[_password release];

	[super ss_dealloc];
}

- (NSString *)user {
    return SSAtomicAutoreleasedGet(_user);
}

- (void)setUserName:(NSString *)user {
    if (!SSMessageIsMacHost(self.host)) {
        SSKeychainItemModifyAttribute(self, kSecAccountItemAttr, user);
    }
    
    SSAtomicCopiedSet(_user, user);
}

- (NSString *)password  {
    return SSAtomicAutoreleasedGet(_password);
}

- (void)setPassword:(NSString *)password  {
	if (!SSMessageIsMacHost(self.host)) {
        OSStatus status = SecKeychainItemModifyAttributesAndData(_keychainItemRef, NULL, (UInt32) strlen(password.UTF8String), (void *) password.UTF8String);
        if (status != noErr) {
            NSLog(@"%@ Error:%@", self, (__bridge NSString *)SSAutorelease(SecCopyErrorMessageString(status, NULL)));
        }
    }
    
    SSAtomicCopiedSet(_password, password);
}

- (NSString *)host  {
    return SSAtomicAutoreleasedGet(_host);
}

- (void)setHostName:(NSString *)host {
    if (!SSMessageIsMacHost(host)) {
        SSKeychainItemModifyAttribute(self, kSecServerItemAttr, host);
    }
    
    SSAtomicCopiedSet(_host, host);
}

- (SecKeychainItemRef)keychainItemRef {
    return _keychainItemRef;
}

@end

OSStatus SSKeychainItemModifyAttribute(SSKeychainItem *self, SecItemAttr itemAttribute, NSString *attributeValue) {
	const char *value = attributeValue.UTF8String;
	SecKeychainAttribute attributes[1];
	attributes[0].tag = itemAttribute;
	attributes[0].length = (UInt32)strlen(value);
	attributes[0].data = (void *)value;
	
	SecKeychainAttributeList list;
	list.count = 1;
	list.attr = attributes;
	
	OSStatus status = SecKeychainItemModifyAttributesAndData(self.keychainItemRef, &list, 0, NULL);
    if (status != noErr) {
        NSLog(@"%@ Error:%@", self, (__bridge NSString *)SSAutorelease(SecCopyErrorMessageString(status, NULL)));
    }
    
	return status;
}
