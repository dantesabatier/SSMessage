/*
 *  SSMessageDefines.h
 *  SSMessage
 *
 *  Created by Dante Sabatier on 3/18/10.
 *  Copyright 2010 Dante Sabatier. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <AvailabilityMacros.h>
#import <Availability.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSZone.h>
#import <objc/runtime.h>
#import <objc/objc-sync.h>
#if !TARGET_OS_IPHONE
#import <AppKit/NSApplication.h>
#import <AppKit/NSNibDeclarations.h>
#endif

id objc_getProperty(id self, SEL _cmd, ptrdiff_t offset, BOOL atomic);
void objc_setProperty(id self, SEL _cmd, ptrdiff_t offset, id newValue, BOOL atomic, BOOL shouldCopy);
void objc_copyStruct(void *dest, const void *src, ptrdiff_t size, BOOL atomic, BOOL hasStrong);

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#ifndef __has_attribute
#define __has_attribute(x) 0
#endif

#ifndef ss_retain
#if __has_feature(objc_arc)
#define ss_retain self
#define ss_dealloc self
#define release self
#define autorelease self
#else
#define ss_retain retain
#define ss_dealloc dealloc
#define __bridge
#endif
#endif

#ifndef ss_weak
#if (__has_feature(objc_arc)) && ((defined __IPHONE_OS_VERSION_MIN_REQUIRED && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0) || (defined __MAC_OS_X_VERSION_MIN_REQUIRED && __MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_7))
#define ss_weak weak
#define __ss_weak __weak
#else
#define ss_weak unsafe_unretained
#define __ss_weak __unsafe_unretained
#endif
#endif

#ifndef SSAutorelease
#if __has_feature(objc_arc)
#define SSAutorelease(x) (__bridge __typeof(x))CFBridgingRelease(x)
#else
#define SSAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]
#endif
#endif

#ifndef SSRetainedTypeSet
#define SSRetainedTypeSet(a, b) do {if (a != b){if (a) {CFRelease(a); a = NULL;} if (b) a = (__typeof(b))CFRetain(b);}} while(0)
#endif

#ifndef SSAtomicRetainedSet
#define SSAtomicRetainedSet(dest, source) objc_setProperty(self, _cmd, (ptrdiff_t)(&dest) - (ptrdiff_t)(self), source, YES, NO)
#endif

#ifndef SSAtomicCopiedSet
#define SSAtomicCopiedSet(dest, source) objc_setProperty(self, _cmd, (ptrdiff_t)(&dest) - (ptrdiff_t)(self), source, YES, YES)
#endif

#ifndef SSAtomicAutoreleasedGet
#define SSAtomicAutoreleasedGet(source) objc_getProperty(self, _cmd, (ptrdiff_t)(&source) - (ptrdiff_t)(self), YES)
#endif

#ifndef SSAtomicStruct
#define SSAtomicStruct(dest, source) objc_copyStruct(&dest, &source, sizeof(__typeof__(source)), YES, NO)
#endif

#ifndef SSNonAtomicRetainedSet
#define SSNonAtomicRetainedSet(a, b) do {if (![a isEqual:b]){ if (a) { [a release]; a = nil;} if (b) a = [b ss_retain]; }} while (0)
#endif

#ifndef SSNonAtomicCopiedSet
#define SSNonAtomicCopiedSet(a, b) do {if (![a isEqual:b]){ if (a) { [a release]; a = nil;} if (b) a = [b copy]; }} while (0)
#endif

#ifndef SSGetAssociatedValueForKey
#define SSGetAssociatedValueForKey(key) objc_getAssociatedObject(self, (__bridge const void *)(key));
#endif

#ifndef SSSetAssociatedValueForKey
#define SSSetAssociatedValueForKey(key, value, associationPolicy) objc_setAssociatedObject(self, (__bridge const void *)(key), value, associationPolicy);
#endif

#ifndef SSLocalizedString
#define SSLocalizedString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]
#endif

#ifndef SSParameterAssert
#if DEBUG
#define SSParameterAssert(condition) NSParameterAssert(condition)
#else
#define SSParameterAssert(condition)
#endif
#endif

#ifndef SSDebugLog
#if DEBUG
#define SSDebugLog(...) NSLog(__VA_ARGS__)
#else
#define SSDebugLog(...)
#endif
#endif
