//
//  NSURL+SSAdditions.m
//  SSMessage
//
//  Created by Dante Sabatier on 26/10/19.
//

#import "NSURL+SSAdditions.h"
#import "SSMessageDefines.h"
#import "SSMessageUtilities.h"
#if TARGET_OS_IPHONE
#import <CoreServices/CoreServices.h>
#endif

@implementation NSURL (SSMessageAdditions)

- (NSString *)filename {
    BOOL isDirectory;
    if ([NSFileManager.defaultManager fileExistsAtPath:self.path isDirectory:&isDirectory] && !isDirectory) {
        return self.lastPathComponent;
    }
    return nil;
}

- (id)content {
    BOOL isDirectory;
    if ([NSFileManager.defaultManager fileExistsAtPath:self.path isDirectory:&isDirectory] && !isDirectory) {
        return [NSData dataWithContentsOfURL:self options:0 error:NULL];
    }
    return nil;
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
