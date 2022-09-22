//
//  SSMessageAttachment.m
//  SSMessage
//
//  Created by Dante Sabatier on 13/04/19.
//

#import "SSMessageAttachment.h"
#import "SSMessageDefines.h"
#import "SSMessageUtilities.h"
#if TARGET_OS_IPHONE
#import <CoreServices/CoreServices.h>
#endif

@implementation SSMessageAttachment

- (nullable instancetype)initWithMessageAttachment:(id <SSMessageAttachment>)messageAttachment {
    NSString *filename = messageAttachment.filename;
    if (!filename.pathExtension) {
        return nil;
    }
    
    id  <NSCopying, NSCoding> content = messageAttachment.content;
    if (![content isKindOfClass:NSData.class]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.filename = filename;
        self.content = content;
        self.contentType = SSMessageGetMIMETypeOfFile(filename);
        self.contentDisposition = SSMessageFileConformsToUTI(filename, kUTTypeImage) ? SSMessagePartContentDispositionInline : SSMessagePartContentDispositionAttachment;
        self.contentTransferEncoding = SSMessagePartContentTransferEncodingBase64;
        self.contentID = [NSString stringWithFormat:@"%@/%@", (__bridge NSString *)SSAutorelease(CFUUIDCreateString(kCFAllocatorDefault, SSAutorelease(CFUUIDCreate(kCFAllocatorDefault)))), [filename stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    }
    return self;
}

- (NSData *)data {
    return self.content;
}

@end
