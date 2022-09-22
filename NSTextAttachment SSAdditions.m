//
//  NSTextAttachment+SSAdditions.m
//  SSMessage
//
//  Created by Dante Sabatier on 08/09/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "NSTextAttachment+SSAdditions.h"
#import "SSMessageDefines.h"
#import "SSMessageUtilities.h"
#if TARGET_OS_IPHONE
#import <CoreServices/CoreServices.h>
#endif

@implementation NSTextAttachment (SSMessageAdditions)

- (NSString *)filename {
    NSString *filename = self.fileWrapper.filename ? self.fileWrapper.filename : self.fileWrapper.preferredFilename;
    if (!filename && [self.description rangeOfString:@"\""].location != NSNotFound) {
        NSScanner *scanner = [NSScanner scannerWithString:self.description];
        NSString *temp = @"";
        @try {
            [scanner scanUpToString:@"\"" intoString:nil];
            scanner.scanLocation = scanner.scanLocation + 1;
            [scanner scanUpToString:@"\"" intoString:&temp];
        }
        @catch (NSException * e) {
            SSDebugLog(@"%@ %@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), e);
            return nil;
        }
        filename = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
	return filename;
}

- (id)content {
    return self.fileWrapper.regularFileContents;
}

- (NSString *)contentType {
    return SSMessageGetMIMETypeOfFile(self.filename);
}

- ( NSString *)contentDisposition {
    NSString *filename = self.filename;
    if (!filename) {
        return nil;
    }
    return SSMessageFileConformsToUTI(filename, kUTTypeImage) ? SSMessagePartContentDispositionInline : SSMessagePartContentDispositionAttachment;
}

- (NSString *)contentTransferEncoding {
    return SSMessagePartContentTransferEncodingBase64;
}

- (NSString *)contentID {
    NSString *filename = self.filename;
    if (!filename) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@", (__bridge NSString *)SSAutorelease(CFUUIDCreateString(kCFAllocatorDefault, SSAutorelease(CFUUIDCreate(kCFAllocatorDefault)))), [filename stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
}

- (NSData *)data {
    return self.content;
}

@end
