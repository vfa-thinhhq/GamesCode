//
//  Controller.h
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
//

#import <Foundation/Foundation.h>
#import "PolygonView.h"

@interface Controller : NSObject {
	UIView *view;
	UILabel *label;
	UIButton *addButton;
	UIButton *subtractButton;
	NSUInteger count;
	PolygonView *polygon;
}

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIButton *addButton;
@property (nonatomic, retain) IBOutlet UIButton *subtractButton;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, retain) IBOutlet PolygonView *polygon;

- (void)loadView;
- (void)viewDidLoad;

- (void)updateView;
- (IBAction)add;
- (IBAction)subtract;

@end
