//
//  HelloWorldLayer.h
//  TerrainTest
//
//  Created by Nicholas Vellios on 8/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	CGFloat screenWidth, screenHeight;
	float touchPt;
}

typedef struct surface {
	float x;
	float y;
} surface;

surface *surfaceArray;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
