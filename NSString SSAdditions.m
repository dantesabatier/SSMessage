//
//  NSString+SSAdditions.m
//  SSMessage
//
//  Created by Dante Sabatier on 26/08/09.
//  Copyright 2008 Dante Sabatier. All rights reserved.
//

#import "NSString+SSAdditions.h"
#import "NSAttributedString+SSAdditions.h"
#import "NSData+SSAdditions.h"
#import "SSMessageUtilities.h"
#import "SSMessageDefines.h"
#import <objc/objc-sync.h>

@implementation NSString(SSMessageAddresseeAdditions)

- (nullable instancetype)displayName {
    if ([self rangeOfString:@"<"].location == NSNotFound) {
        return nil;
    }
    
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSString *displayName = @"";
	@try {
		[scanner scanUpToString:@"<" intoString:&displayName];	
	}
	@catch (NSException * e) {
		return nil;
	}
	return [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (nullable instancetype)address {
    if ([self rangeOfString:@"@"].location == NSNotFound) {
        return nil;
    }
    
	NSString *email = self;
	NSArray *emails = [[self stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
	if (emails.count)
        email = emails[0];
	if ([email rangeOfString:@"<"].location != NSNotFound) {
		NSScanner *scanner = [NSScanner scannerWithString:email];
		NSString *address = @"";
		@try {
			[scanner scanUpToString:@"<" intoString:nil];
			scanner.scanLocation = scanner.scanLocation + 1;
			[scanner scanUpToString:@">" intoString:&address];	
		}
		@catch (NSException * e) {
			return nil;
		}
		return [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (nullable instancetype)domain {
	NSString *address = self.address;
    if (!address.length) {
        return nil;
    }
	
	NSString *domain = [address componentsSeparatedByString:@"@"].lastObject;
	NSArray *components = [domain componentsSeparatedByString:@"."];
    if (components.count > 2) {
        return [NSString stringWithFormat:@"%@.%@", components[0], components[1]];
    }
	return domain;
}

- (nullable instancetype)hostName {
	NSString *domain = self.domain;
    if (!domain.length) {
        return nil;
    }
    
	NSString *hostName = [NSString stringWithFormat:@"smtp.%@", domain];
    if ([domain rangeOfString:@"yahoo"].location != NSNotFound) {
        hostName = [NSString stringWithFormat:@"smtp.mail.%@", domain];
    } else if (([domain rangeOfString:@"msn"].location != NSNotFound) || [domain rangeOfString:@"hotmail"].location != NSNotFound) {
        hostName = @"smtp.live.com";
    }
	return hostName;
}

- (nullable instancetype)userName {
	NSString *address = self.address;
    if (!address.length) {
        return nil;
    }
	return [address componentsSeparatedByString:@"@"][0];
}

- (nullable instancetype)fullMessageAddress; {
    if (!self.address) {
        return nil;
    }
    return self;
}

@end

@implementation NSString(SSMessageEncodingAdditions)

+ (instancetype)mimeNameOfStringEncoding:(NSStringEncoding)encoding {
	NSDictionary *mimeNames = @{@(NSASCIIStringEncoding): @"US-ASCII",
    @(NSISOLatin1StringEncoding) : @"ISO-8859-1",
    @(NSISOLatin2StringEncoding) : @"ISO-8859-2",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin3)) : @"ISO-8859-3",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin4)) : @"ISO-8859-4",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinCyrillic)) : @"ISO-8859-5",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinArabic)) : @"ISO-8859-6",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinGreek)) : @"ISO-8859-7",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinHebrew)) : @"ISO-8859-8",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin5)) : @"ISO-8859-9",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin6)) : @"ISO-8859-10",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinThai)) : @"ISO-8859-11",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin7)) : @"ISO-8859-13",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin8)) : @"ISO-8859-14",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin9)) : @"ISO-8859-15",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingKOI8_R)) : @"KOI8-R",
    @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingHZ_GB_2312)) : @"HZ-GB-2312",
    @(NSISO2022JPStringEncoding): @"ISO-2022-JP",
    @(NSUTF8StringEncoding) : @"UTF-8"};
	
	return mimeNames[@(encoding)];
}

- (NSStringEncoding)proposedStringEncoding; {
    NSStringEncoding encoding[] = {
		NSASCIIStringEncoding,
		NSISOLatin1StringEncoding,
		NSISOLatin2StringEncoding,
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin3),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin4),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinCyrillic),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinArabic),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinGreek),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinHebrew),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin5),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin6),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinThai),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin7),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin8),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin9),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingKOI8_R),
		CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingHZ_GB_2312),
		NSISO2022JPStringEncoding,
		NSUTF8StringEncoding,
        0 };
	
	for (NSStringEncoding i = 0; encoding[i]; i++) {
        if ([self canBeConvertedToEncoding:encoding[i]]) {
            return encoding[i];
        }
	}
	return NSUTF8StringEncoding;
}

@end

@interface _SSStringHelper : NSObject {
	NSString *_plainText;
}

- (NSString *)convertHTMLStringToPlainText:(NSString *)HTMLString;

@end

@implementation _SSStringHelper

- (void)dealloc {
	[_plainText release];
	
	[super dealloc];
}

- (NSString *)convertHTMLStringToPlainText:(NSString *)HTMLString;  {
    objc_sync_enter(self);
    if (!_plainText) {
        NSStringEncoding encoding = HTMLString.proposedStringEncoding;
        NSData *data = [HTMLString dataUsingEncoding:encoding allowLossyConversion:YES];
#if TARGET_OS_IPHONE
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(encoding)} documentAttributes:NULL error:NULL];
#else
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTML:data options: @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentOption: @(encoding), NSExcludedElementsDocumentAttribute: @[@"DOCTYPE", @"XML"]} documentAttributes:NULL];
#endif
        if (attributedString) {
            _plainText = [attributedString.plainText copy];
            
            [attributedString release];
        }
    }
    objc_sync_exit(self);
	return SSAtomicAutoreleasedGet(_plainText);
}

@end

@implementation NSString(SSMessageAdditions)

- (instancetype)stringByRemovingHTML; {
    if (!self.length) {
        return self;
    }
    
	_SSStringHelper *helper = [[_SSStringHelper alloc] init];
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        [helper performSelectorOnMainThread:@selector(convertHTMLStringToPlainText:) withObject:self waitUntilDone:YES];
    }
    
	NSString *string = [helper convertHTMLStringToPlainText:self];
	
	[helper release];
	
	return string;
}

- (instancetype)stringWithCRLFLineBreaks {
	NSMutableString *string = [[NSMutableString alloc] init];
	NSScanner *scanner = [NSScanner scannerWithString:self];
	while (!scanner.isAtEnd) {
		NSString *line = nil;
        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line] && line) {
            [string appendFormat:@"%@\r\n", [line stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]]];
        }  
	}
	return [string autorelease];
}

@end
