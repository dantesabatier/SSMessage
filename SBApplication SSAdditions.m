//
//  SBApplication+SSAdditions.m
//  SSMessage
//
//  Created by Dante Sabatier on 25/03/13.
//
//

#import "SBApplication+SSAdditions.h"

@implementation SBApplication (SSAdditions)

+ (nullable __kindof SBApplication *)appWithBundleIdentifier:(NSString *)identifier {
    int old_stderr = dup(STDERR_FILENO);
    close(STDERR_FILENO);
    int fd = open("/dev/null", O_WRONLY);
    dup2(fd, STDERR_FILENO);
    close(fd);
    id application = [SBApplication applicationWithBundleIdentifier:identifier];
    close(STDERR_FILENO);
    dup2(old_stderr, STDERR_FILENO);
    close(old_stderr);
    return application;
}

@end
