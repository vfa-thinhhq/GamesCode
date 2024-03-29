//
//  ViewAnimationDemoViewController.h
//  ViewAnimationDemo
//
//  Created by Nicholas Vellios on 7/11/10.
//  Copyright 2010 Nick Vellios. All rights reserved.
//
//	http://www.Vellios.com
//	nick@vellios.com
//
//	This code is released under the "Take a kid fishing or hunting license"
//	In order to use any code in your project you must take a kid fishing or
//	hunting and give some sort of credit to the author of the code either
//	on your product's website, about box, or legal agreement.
//

#import <UIKit/UIKit.h>

@interface ViewAnimationDemoViewController : UIViewController {
	IBOutlet UIButton *showHideButton; // outlet to allow us access to our button Title
	UIImageView *imageView; // This is the subview we will show/hide
	BOOL viewVisible; // Will be YES if our imageView is visible, NO otherwise.
}

- (IBAction)onButtonClick:(id)sender; // IBAction handler for our button click
- (void)showHideView; // Our code to show/hide and animate our imageView will be here

@property (nonatomic, retain) IBOutlet UIButton *showHideButton;
@property (nonatomic, retain) UIImageView *imageView;

@end

