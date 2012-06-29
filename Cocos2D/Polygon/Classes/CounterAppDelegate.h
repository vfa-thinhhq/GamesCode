//
//  CounterAppDelegate.h
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

#import <UIKit/UIKit.h>
#import "Controller.h"

@interface CounterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	Controller *controller;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Controller *controller;

@end

