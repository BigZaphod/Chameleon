//
//  main.m
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 10.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#define kDDAppDelegateClassKey @"DDAppDelegateClass"
#define kNSMainNibFileKey @"NSMainNibFile"
#define kNSPrincipalClassKey @"NSPrincipalClass"

#if TARGET_OS_IPHONE
#define kNSPrincipalClassDefault @"UIApplication"
#else
#define kNSPrincipalClassDefault @"NSApplication"
#endif

id DDAppDelegate = nil;

int main(int argc, char *argv[])
{
    int status = -1;
    
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#else
    @autoreleasepool
#endif
    {
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *appDelegateClassName = [infoDict objectForKey:kDDAppDelegateClassKey];
        NSString *nibName = [infoDict objectForKey:kNSMainNibFileKey];
        NSString *principalClassName = [infoDict objectForKey:kNSPrincipalClassKey];
        
        BOOL hasAppDelegateClassName = appDelegateClassName.length;
        BOOL hasNibName = nibName.length;
        BOOL hasCustomPrincipalClassName = (principalClassName.length && ![principalClassName isEqualToString:kNSPrincipalClassDefault]);
        
        assert((hasAppDelegateClassName || hasNibName || hasCustomPrincipalClassName) && "need to specify EITHER a xib file (via NSMainNibFile key) OR a class name to use as delegate for the application (via DDAppDelegateClass key) OR the name of the custom principal class (via NSPrincipalClass key)");
        
#if TARGET_OS_IPHONE
        status = UIApplicationMain(argc, argv, principalClassName, appDelegateClassName);
#else
        id appDelegate = nil;
        if(hasAppDelegateClassName) {
            Class appDelegateClass = NSClassFromString(appDelegateClassName);
            DDAppDelegate = [[appDelegateClass alloc] init];
            [[NSApplication sharedApplication] setDelegate:DDAppDelegate];
        }
        status = NSApplicationMain(argc, (const char **)argv);
#if !__has_feature(objc_arc)
        [appDelegate autorelease];
#endif
        appDelegate = nil;
#endif
    }
#if !__has_feature(objc_arc)
    [pool drain];
#endif
    
    return status;
}
