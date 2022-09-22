//
//  SSMessageUtilities.m
//  SSMessage
//
//  Created by Dante Sabatier on 26/08/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSMessageUtilities.h"
#import "SSMessage.h"
#import "NSAttributedString+SSAdditions.h"
#import "NSData+SSAdditions.h"
#import "SSMessageDefines.h"
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import "SSKeychain.h"
#import "SSKeychainItem.h"
#import <WebKit/WebKit.h>
#import <CoreServices/CoreServices.h>
#endif

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))

NSString * __nullable SSMessageGetPasswordForAccount(id <SSDeliveryAccount> account) {
	return [[SSKeychain sharedKeychain] passwordForAccount:account];
}

BOOL SSMessageSetPasswordForAccount(NSString *password, id <SSDeliveryAccount> account) {
	return [[SSKeychain sharedKeychain] setPassword:password forAccount:account];
}

#endif

BOOL SSMessageValidateEmailAddress(NSString *emailAddress) {
    if (!emailAddress.length) {
        return NO;
    }

	NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
	
	return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx] evaluateWithObject:emailAddress];
	
}

BOOL SSMessageIsMacHost(NSString *hostName) {
    NSArray <NSString *>*hosts = @[@"smtp.mac.com", @"smtp.me.com", @"smtp.icloud.com", @"p04-smtp.mail.me.com"];
    for (NSString *host in hosts) {
        if ([hostName caseInsensitiveCompare:host] == NSOrderedSame) {
            return YES;
        }
    }
	return NO;
}

CFNetDiagnosticStatus SSMessageValidateConnectionWithURL(NSURL *url, NSString **diagnosticDescription) {
	CFStringRef description = nil;
    CFNetDiagnosticStatus status = kCFNetDiagnosticErr;
    if (url) {
        CFNetDiagnosticRef diagnostic = CFNetDiagnosticCreateWithURL(CFAllocatorGetDefault(), (__bridge CFURLRef)url);
        status = CFNetDiagnosticCopyNetworkStatusPassively(diagnostic, &description);
        CFRelease(diagnostic);
        
        if (diagnosticDescription) {
            *diagnosticDescription = [[(__bridge NSString *)description copy] autorelease];
        }
        
        if (description) {
            CFRelease(description);
        }
    }
	return status;
}

CFNetDiagnosticStatus SSMessageValidateInternetConnection(NSString **diagnosticDescription) {
	return SSMessageValidateConnectionWithURL([NSURL URLWithString:@"https://www.apple.com"], diagnosticDescription);
}

BOOL SSMessageIsInternetConnectionUp() {
    return SSMessageValidateInternetConnection(NULL) == kCFNetDiagnosticConnectionUp;
}

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))

OSStatus SSMessageGetCertificateRefForEmail(NSString *email, SecKeychainItemRef *itemRef) {
	SecKeychainAttributeList attrList;
    SecKeychainAttribute attrib;
    attrList.count = 1;
    attrList.attr  = &attrib;
    attrib.tag = kSecAlias;
    attrib.data = (void *) email.UTF8String;
    attrib.length = (UInt32)strlen(attrib.data);
	
    SecKeychainSearchRef searchRef = nil;
	
    OSStatus status = SecKeychainSearchCreateFromAttributes(NULL, kSecCertificateItemClass, &attrList, &searchRef);
	if (status != noErr) {
		NSLog(@"SSMessageGetCertificateRefForEmail err* %s", GetMacOSStatusErrorString(status));
		return status;
	}
	
    status = SecKeychainSearchCopyNext(searchRef, itemRef);
    
    if (searchRef) {
        CFRelease(searchRef);
    }
	
    return status;
}

#endif

CFStringRef SSMessageGetUTIOfFile(NSString *filename) {
    NSString *extension = filename.pathExtension;
    if (extension.length) {
        return SSAutorelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL));
    }
    return NULL;
}

BOOL SSMessageFileConformsToUTI(NSString *filename, CFStringRef inConformsToUTI) {
	CFStringRef inUTI = SSMessageGetUTIOfFile(filename);
    if (!inUTI) {
        return NO;
    }
    
    return UTTypeConformsTo(inUTI, inConformsToUTI);
}

NSString *SSMessageGetMIMETypeOfFile(NSString *filename) {
	CFStringRef UTI = SSMessageGetUTIOfFile(filename);
    if (!UTI) {
        return nil;
    }
    
	NSString *registeredType = (__bridge NSString *)SSAutorelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    if (!registeredType) {
        registeredType = @"application/octet-stream";
    }
    
	return registeredType;
}

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))

BOOL SSMessageMailContentsOfURL(NSURL *URL, NSError **error) {
	NSCParameterAssert(URL);
    OSStatus status = noErr;
    NSString *mailerPath = nil;
#if 0
    CFURLRef mailerURLRef;
	status = LSGetApplicationForURL((__bridge CFURLRef)[NSURL URLWithString:@"mailto:xxx"], kLSRolesAll, NULL, &mailerURLRef);
	if (status != noErr) {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
		return NO;
	}
	
	mailerPath = ((NSURL *)mailerURLRef).path;
	CFRelease(mailerURLRef);
#endif
    
    if (!mailerPath) {
        mailerPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.mail"];
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:mailerPath];
	NSNumber *mailPageSupported = (bundle.infoDictionary)[@"MailPageSupported"];
    if (!mailPageSupported || !mailPageSupported.boolValue) {
        return NO;
    }
    
	NSString *bundleIdentifier = bundle.bundleIdentifier;
    if (![[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:bundleIdentifier options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifier:NULL]) {
        return NO;
    }
    
	WebView *webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 512.0, 512.0)];
	[webView.mainFrame loadRequest:[NSURLRequest requestWithURL:URL]];
	
	while (webView.isLoading) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
	}
	
	WebArchive *webArchive = webView.mainFrame.dataSource.webArchive;
	NSString *subject = webView.mainFrame.dataSource.pageTitle;
	
	[webView release];
	
    if (!webArchive) {
        return NO;
    }
    
	const char *bundleIdChar = bundleIdentifier.UTF8String;
	
	NSAppleEventDescriptor *dataDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:'tdta' data:webArchive.data];
	NSAppleEventDescriptor *subjectDesc = [NSAppleEventDescriptor descriptorWithString:subject];
	NSAppleEventDescriptor *targetDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:typeApplicationBundleID bytes:bundleIdChar length:strlen(bundleIdChar)];
	NSAppleEventDescriptor *appleEvent = [NSAppleEventDescriptor appleEventWithEventClass:'mail' eventID:'mlpg' targetDescriptor:targetDesc returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
	[appleEvent setParamDescriptor:dataDesc forKeyword:keyDirectObject];
	[appleEvent setParamDescriptor:subjectDesc forKeyword:'urln'];
	
	status = AESendMessage(appleEvent.aeDesc, NULL, kAECanInteract, kAEDefaultTimeout);
	if (status != noErr) {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
		return NO;
	}
	return YES;
}

BOOL SSMessageMailLinkToURL(NSURL *URL) {
	NSCParameterAssert(URL);
	NSString *title = @"";
    NSString *subject = [NSString stringWithFormat:@"SUBJECT=%@", [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *body = [NSString stringWithFormat:@"BODY=%@", [[NSString stringWithFormat:@"\n\n<%@>", URL.absoluteString] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	return [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@?%@&%@", @"", subject, body]]];
}

#endif
