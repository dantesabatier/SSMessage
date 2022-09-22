//
//  NSTextAttachment+SSAdditions.h
//  SSMessage
//
//  Created by Dante Sabatier on 08/09/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSMessageAttachment.h"
#if TARGET_OS_IPHONE
#import <UIKit/NSTextAttachment.h>
#else
#import <AppKit/NSTextAttachment.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSTextAttachment(SSMessageAdditions) <SSMessageAttachment>

@end

NS_ASSUME_NONNULL_END
