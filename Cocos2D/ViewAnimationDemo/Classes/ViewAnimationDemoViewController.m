//
//  ViewAnimationDemoViewController.m
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

#import "ViewAnimationDemoViewController.h"

@implementation ViewAnimationDemoViewController

@synthesize showHideButton, imageView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIImage *guns = [UIImage imageNamed:@"guns.png"]; // load our image resource
	imageView = [[UIImageView alloc] initWithImage:guns]; // Init our UIImageView with our image
	[self.view addSubview:imageView]; // Add it as a subview of our main view
	[imageView setFrame:CGRectOffset([imageView frame], 0, -imageView.frame.size.height)]; // Move it up top and off screen
	viewVisible = NO;
}

- (IBAction)onButtonClick:(id)sender {
	[self showHideView]; // Show and hide our imageView in an animated fashion
}

- (void)showHideView {	
	if (viewVisible) { // If our imageView is on screen hide the view
		[UIView beginAnimations:@"animateImageOff" context:NULL]; // Begin animation
		[imageView setFrame:CGRectOffset([imageView frame], 0, -imageView.frame.size.height)]; // Move imageView off screen
		[UIView commitAnimations]; // End animations
		viewVisible = NO;
		[showHideButton setTitle:@"Show" forState:UIControlStateNormal]; // Change button title to "Show"
	} else { // if our imageView is off screen show the view
		[UIView beginAnimations:@"animateImageOn" context:NULL]; // Begin animation
		[imageView setFrame:CGRectOffset([imageView frame], 0, imageView.frame.size.height)]; // Move imageView on screen
		[UIView commitAnimations]; // End animations
		viewVisible = YES;
		[showHideButton setTitle:@"Hide" forState:UIControlStateNormal]; // Change button title to "Hide"
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[imageView release];
	
    [super dealloc];
}

@end
