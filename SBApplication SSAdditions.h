//
//  SBApplication+SSAdditions.h
//  SSMessage
//
//  Created by Dante Sabatier on 25/03/13.
//
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBApplication (SSAdditions)

/*!
 @discussion Same as class method applicationWithBundleIdentifier: but without warnings.
 */

+ (nullable __kindof SBApplication *)appWithBundleIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
