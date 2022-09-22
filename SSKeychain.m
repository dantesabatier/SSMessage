//
//  SSKeychain.m
//  SSMessage
//
//  Created by Dante Sabatier on 9/24/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSKeychain.h"
#import "SSKeychainItem.h"
#import "NSDictionary+SSAdditions.h"
#import "NSString+SSAdditions.h"
#import "SSMessageUtilities.h"
#import "SSMessageDefines.h"

static BOOL __kSharedKeychainCanBeDestroyed = NO;

@implementation SSKeychain

static SSKeychain *sharedKeychain = nil;

+ (nullable instancetype)sharedKeychain {
#if defined(__MAC_10_6)
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedKeychain = [[self alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            
            __kSharedKeychainCanBeDestroyed = YES;
            
            [sharedKeychain release];
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
#endif
	return sharedKeychain;
}

- (instancetype)init {
    OSStatus status = SecKeychainCopyDefault(&_keychain);
    if (status != CSSM_OK) {
        return nil;
    }
    
    self = [super init];
	if (self) {
		
	}
	return self;
}

- (void)dealloc {
    if ((self == sharedKeychain) && !__kSharedKeychainCanBeDestroyed) {
        return;
    }
    
    if (_keychain) {
        CFRelease(_keychain);
    }
    
	[super ss_dealloc];
}

- (nullable SSKeychainItem *)addKeychainItemForAccount:(id <SSMessageDeliveryAccount>)account {
	NSString *host = account.host;
	NSString *user = account.user;
	
    if (!host || !host.length || !user || !user.length) {
        return nil;
    }
    
	SSKeychainItem *item = [self keychainItemForAccount:account];
    if (item) {
        return item;
    }
    
	NSString *password = account.password;
    if (!password.length) {
        return nil;
    }
    
	NSInteger port = account.port;
	
	const char *pass = password.UTF8String;
	const char *server = host.UTF8String;
	const char *user = user.UTF8String;
	const char *path = "";
	
	SecKeychainItemRef itemRef;
	OSStatus status = SecKeychainAddInternetPassword(_keychain, (UInt32)strlen(server),  server, 0, NULL, (UInt32)strlen(user), user, (UInt32)strlen(path), path, port, kSecProtocolTypeSMTP, kSecAuthenticationTypeDefault, (UInt32)strlen(pass), (void *)pass, &itemRef);
	if (status != noErr) {
		SSDebugLog(@"%@ %@ (%@)", self.class, NSStringFromSelector(_cmd), (__bridge NSString *)SSAutorelease(SecCopyErrorMessageString(status, NULL)));
		return nil;
	}
	
	item = [[SSKeychainItem alloc] initWithKeychainItemRef:itemRef];
	item.host = host;
	item.user = user;
	item.password = password;
	
	return [item autorelease];
}

- (nullable SSKeychainItem *)keychainItemForAccount:(id <SSMessageDeliveryAccount>)account {
    //SSDebugLog(@"%@ %@%@", self.class, NSStringFromSelector(_cmd), account);
	NSString *host = account.host;
	NSString *user = account.user;
    if (!host || !user){
        return nil;
    }
    
	const char *serviceName = host.UTF8String;
	const char *serviceUserName = user.UTF8String;
	const char *path = "";
	
	UInt32 passwordLength = 0;
	char *pass = nil;
	
	OSStatus status = noErr;
	SecKeychainItemRef itemRef = NULL;
	if (SSMessageIsMacHost(host)) {
        NSMutableArray *services = [NSMutableArray arrayWithCapacity:2];
        [services addObject:@"iTools"];
        
        NSString *address = account.designatedSender.address;
        if (address) {
            [services addObject:address];
        }
        
        for (NSString *service in services) {
            serviceName = service.UTF8String;
            status = SecKeychainFindGenericPassword(_keychain, (UInt32)strlen(serviceName), serviceName, (UInt32)strlen(serviceUserName), serviceUserName, &passwordLength, (void **)&pass, &itemRef);
            if (status == noErr) {
                break;
            }
        }
    } else {
        status = SecKeychainFindInternetPassword(_keychain, (UInt32)strlen(serviceName), serviceName, 0, NULL, (UInt32)strlen(serviceUserName), serviceUserName, (UInt32)strlen(path), path, 0, kSecProtocolTypeAny, kSecAuthenticationTypeAny, &passwordLength, (void **)&pass, &itemRef);
    }
    
	if (status != noErr) {
		SSDebugLog(@"%@ %@(%@) %@", self, NSStringFromSelector(_cmd), account, (__bridge NSString *)SSAutorelease(SecCopyErrorMessageString(status, NULL)));
		return nil;
	}
    
    NSString *password = [[[NSString alloc] initWithBytes:pass length:passwordLength encoding:NSUTF8StringEncoding] autorelease];
    SecKeychainItemFreeContent(NULL, pass);
	
	SSKeychainItem *item = [[SSKeychainItem alloc] initWithKeychainItemRef:itemRef];
	item.host = host;
	item.user = user;
	item.password = password;
    
	return [item autorelease];
}

- (nullable NSString *)passwordForAccount:(id <SSMessageDeliveryAccount>)account {
    return [self keychainItemForAccount:account].password;
}

- (BOOL)setPassword:(NSString *)password forAccount:(id <SSMessageDeliveryAccount>)account {
    SSKeychainItem *item = [self addKeychainItemForAccount:account];
    if (item) {
        item.password = password;
        return YES;
    }
    return NO;
}

@end


