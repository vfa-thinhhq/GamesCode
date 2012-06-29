//
//  HelloWorldLayer.m
//  TerrainTest
//
//  Created by Nicholas Vellios on 8/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

// Import the interfaces
#import "HelloWorldScene.h"

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init] )) {
		CCLabel* label = [CCLabel labelWithString:@"Terrain Test" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		screenWidth = size.width;
		screenHeight = size.height;
		
		label.position =  ccp( size.width/2, size.height/2 );
		[self addChild: label];
	
		// Allocate our surfaceArray
		surfaceArray = (surface *)malloc(((int)screenWidth) * sizeof(surface));
		
		// Init our surfaceArray
		for (int i = 0; i < screenWidth; i++) {
			surfaceArray[i].x = i;
			surfaceArray[i].y = 0;
		}
		
		// If this isn't added, touches won't be recognized
		self.isTouchEnabled = YES;
	}
	return self;
}

- (void)draw {
	// Set color to blue
	glColor4f(0.2, 0.4, 0.85, 1.0);  
    glLineWidth(4.0f);
	
	// Loop through each point on the X-axis
	for (int i = 0; i <= screenWidth; i++) {
		// Draw a line from our point straight down
		ccDrawLine( ccp(screenWidth - surfaceArray[i].x, surfaceArray[i].y), ccp(screenWidth - surfaceArray[i].x, -screenHeight) );
		
		// If a point moved offscreen, recycle and respawn it
		if (surfaceArray[i].x > screenWidth) {
			surfaceArray[i].x = 0;
		} else { // If not, move to points to the left
			surfaceArray[i].x += 2;
		}
		
		// If the point is the furthest to the right, relocation its x-axis to the location of our touch
		if (surfaceArray[i].x == 0) {
			surfaceArray[i].y = touchPt;
		}
	}
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	
	touchPt = location.x;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	
	touchPt = location.x;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	touchPt = 0;
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{	
	free(surfaceArray);
	
	[super dealloc];
}
@end
