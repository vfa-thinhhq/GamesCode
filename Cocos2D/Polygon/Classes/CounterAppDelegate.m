//
//  CounterAppDelegate.m
//  Counter
//
//  Created by Nick Vellios on 3/22/10.
//  Copyright 2010 Nick Vellios. All rights reserved.
//
//	http://www.Vellios.com
//	nick@vellios.com
//
//	This code is released under the "Take a kid fishing or hunting license"
//	In order to use any code in your project you must take a kid fishing or
//	hunting and give some sort of credit to the author of the code either
//	on your product's website, about box, or legal agreement.
////

#import "CounterAppDelegate.h"

@implementation CounterAppDelegate

@synthesize window, controller;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
	UIView *view = [controller view];
	[window addSubview:view];
	
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
