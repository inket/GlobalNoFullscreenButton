//
//  GlobalNoFullscreenButton.m
//  GlobalNoFullscreenButton
//
//  Created by Mahdi Bchetnia on 19/04/2014.
//  Copyright (c) 2014 Mahdi Bchetnia. Licensed under GNU GPL v3.0. See LICENSE for details.
//

#import "GlobalNoFullscreenButton.h"

static GlobalNoFullscreenButton* plugin = nil;

@implementation NSObject (GlobalNoFullscreenButton)

// Fullscreen button is recreated when leaving fullscreen mode
// Intercept that and tell it to hide itself
- (id)new_initWithFrame:(NSRect)frame {
    id original = [self new_initWithFrame:frame];
    
    if ([self class] == NSClassFromString(@"_NSThemeFullScreenButton"))
        [original setHidden:YES];
    
    return original;
}

- (void)new_setHidden:(BOOL)val {
    if ([self class] == NSClassFromString(@"_NSThemeFullScreenButton"))
        [self new_setHidden:YES];
    else
        [self new_setHidden:val];
}

@end

@implementation GlobalNoFullscreenButton

#pragma mark SIMBL methods and loading

+ (GlobalNoFullscreenButton*)sharedInstance {
	if (plugin == nil)
		plugin = [[GlobalNoFullscreenButton alloc] init];
	
	return plugin;
}

+ (void)load {
	[[GlobalNoFullscreenButton sharedInstance] loadPlugin];
	
	NSLog(@"GlobalNoFullscreenButton loaded.");
}

- (void)loadPlugin {
    Class class = NSClassFromString(@"_NSThemeFullScreenButton");
    Method new = class_getInstanceMethod(class, @selector(new_setHidden:));
    Method old = class_getInstanceMethod(class, @selector(setHidden:));
    method_exchangeImplementations(new, old);
    
    new = class_getInstanceMethod(class, @selector(new_initWithFrame:));
    old = class_getInstanceMethod(class, @selector(initWithFrame:));
    method_exchangeImplementations(new, old);

    for (NSWindow *window in [[NSApplication sharedApplication] windows])
    {
        for (NSView* view in [[[window contentView] superview] subviews])
        {
            if ([view class] == class)
                [view setHidden:YES];
        }
    }
}

@end