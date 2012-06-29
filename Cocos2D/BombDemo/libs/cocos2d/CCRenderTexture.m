/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCRenderTexture.h"
#import "CCDirector.h"
#import "ccMacros.h"

@implementation CCRenderTexture

@synthesize sprite=sprite_;

+(id)renderTextureWithWidth:(int)w height:(int)h
{
	return [[[self alloc] initWithWidth:w height:h] autorelease];
}

-(id)initWithWidth:(int)w height:(int)h
{
	self = [super init];
	if (self)
	{
		glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO_);
		CCTexture2DPixelFormat format = kCCTexture2DPixelFormat_RGBA8888;  
		// textures must be power of two squared
		int pow = 8;
		while (pow < w || pow < h) pow*=2;
    
		void *data = malloc((int)(pow * pow * 4));
		memset(data, 0, (int)(pow * pow * 4));
		texture_ = [[CCTexture2D alloc] initWithData:data pixelFormat:format pixelsWide:pow pixelsHigh:pow contentSize:CGSizeMake(w, h)];
		free( data );
    
		// generate FBO
		glGenFramebuffersOES(1, &fbo_);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo_);
    
		// associate texture with FBO
		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, texture_.name, 0);
    
		// check if it worked (probably worth doing :) )
		GLuint status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
		if (status != GL_FRAMEBUFFER_COMPLETE_OES)
		{
			[NSException raise:@"Render Texture" format:@"Could not attach texture to framebuffer"];
		}
		sprite_ = [CCSprite spriteWithTexture:texture_];
		[texture_ release];
		[sprite_ setScaleY:-1];
		[self addChild:sprite_];
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO_);
	}
	return self;
}

-(void)dealloc
{
//	[self removeAllChildrenWithCleanup:YES];
	glDeleteFramebuffersOES(1, &fbo_);
	[super dealloc];
}

-(void)begin
{
	CC_DISABLE_DEFAULT_GL_STATES();
	// Save the current matrix
	glPushMatrix();
	
	CGSize texSize = [texture_ contentSize];

	// Calculate the adjustment ratios based on the old and new projections
	CGRect frame = [[[CCDirector sharedDirector] openGLView] frame];
	float widthRatio = frame.size.width / texSize.width;
	float heightRatio = frame.size.height / texSize.height;

	// Adjust the orthographic propjection and viewport
	glOrthof((float)-1.0 / widthRatio,  (float)1.0 / widthRatio, (float)-1.0 / heightRatio, (float)1.0 / heightRatio, -1,1);
	glViewport(0, 0, texSize.width, texSize.height);

	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO_);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo_);//Will direct drawing to the frame buffer created above
	
	CC_ENABLE_DEFAULT_GL_STATES();	
}

-(void)end
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO_);
	// Restore the original matrix and viewport
	glPopMatrix();
	CGRect frame = [[[CCDirector sharedDirector] openGLView] frame];
	glViewport(0, 0, frame.size.width, frame.size.height);

	glColorMask(TRUE, TRUE, TRUE, TRUE);
}


-(void)clear:(float)r g:(float)g b:(float)b a:(float)a
{
	[self begin];
	glClearColor(r, g, b, a);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glColorMask(TRUE, TRUE, TRUE, FALSE);
	[self end];
}

-(BOOL)saveBuffer:(NSString*)name
{
	return [self saveBuffer:name format:kImageFormatJPG];
}

-(BOOL)saveBuffer:(NSString*)fileName format:(int)format
{
	UIImage *myImage				= [self getUIImageFromBuffer];
  
	NSArray *paths					= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory	= [paths objectAtIndex:0];
	NSString *fullPath				= [documentsDirectory stringByAppendingPathComponent:fileName];
  
	NSData *data;
  
	if (format == kImageFormatPNG)
		data = UIImagePNGRepresentation(myImage);
	else
		data = UIImageJPEGRepresentation(myImage, 1.0f);
  
	return [data writeToFile:fullPath atomically:YES];
}

/* get buffer as UIImage */
-(UIImage *)getUIImageFromBuffer
{
	int tx = texture_.contentSize.width;
	int ty = texture_.contentSize.height;
  
	int bitsPerComponent			= 8;
	int bitsPerPixel				= 32;
	int bytesPerPixel				= (bitsPerComponent * 4)/8;
	int bytesPerRow					= bytesPerPixel * tx;
	NSInteger myDataLength			= bytesPerRow * ty;
  
	NSMutableData *buffer	= [[NSMutableData alloc] initWithCapacity:myDataLength];
	NSMutableData *pixels	= [[NSMutableData alloc] initWithCapacity:myDataLength];

	if( ! (buffer && pixels) ) {
		CCLOG(@"cocos2d: CCRenderTexture#getUIImageFromBuffer: not enough memory");
		[buffer release];
		[pixels release];
		return nil;
	}

	[self begin];
	glReadPixels(0,0,tx,ty,GL_RGBA,GL_UNSIGNED_BYTE, [buffer mutableBytes]);
	[self end];
	/*
	 CGImageCreate(size_t width, size_t height,
	 size_t bitsPerComponent, size_t bitsPerPixel, size_t bytesPerRow,
	 CGColorSpaceRef space, CGBitmapInfo bitmapInfo, CGDataProviderRef provider,
	 const CGFloat decode[], bool shouldInterpolate,
	 CGColorRenderingIntent intent)
	 */
	// make data provider with data.
  
	CGBitmapInfo bitmapInfo			= kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
	CGDataProviderRef provider		= CGDataProviderCreateWithData(NULL, [buffer mutableBytes], myDataLength, NULL);
	CGColorSpaceRef colorSpaceRef	= CGColorSpaceCreateDeviceRGB();
	CGImageRef iref					= CGImageCreate(tx, ty,
                                          bitsPerComponent, bitsPerPixel, bytesPerRow,
                                          colorSpaceRef, bitmapInfo, provider,
                                          NULL, false,
                                          kCGRenderingIntentDefault);
	/* Create a bitmap context. The context draws into a bitmap which is `width'
	 pixels wide and `height' pixels high. The number of components for each
	 pixel is specified by `colorspace', which may also specify a destination
	 color profile. The number of bits for each component of a pixel is
	 specified by `bitsPerComponent'. The number of bytes per pixel is equal
	 to `(bitsPerComponent * number of components + 7)/8'. Each row of the
	 bitmap consists of `bytesPerRow' bytes, which must be at least `width *
	 bytes per pixel' bytes; in addition, `bytesPerRow' must be an integer
	 multiple of the number of bytes per pixel. `data' points a block of
	 memory at least `bytesPerRow * height' bytes. `bitmapInfo' specifies
	 whether the bitmap should contain an alpha channel and how it's to be
	 generated, along with whether the components are floating-point or
	 integer.
   
	 CGContextRef CGBitmapContextCreate(void *data, size_t width,
	 size_t height, size_t bitsPerComponent, size_t bytesPerRow,
	 CGColorSpaceRef colorspace, CGBitmapInfo bitmapInfo)
	 */
	CGContextRef context			= CGBitmapContextCreate([pixels mutableBytes], tx,
                                                    ty, CGImageGetBitsPerComponent(iref), CGImageGetBytesPerRow(iref),
                                                    CGImageGetColorSpace(iref), bitmapInfo);
	CGContextTranslateCTM(context, 0.0f, ty);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, tx, ty), iref);   
	CGImageRef outputRef			= CGBitmapContextCreateImage(context);
	UIImage* image					= [[UIImage alloc] initWithCGImage:outputRef];
  
	CGImageRelease(iref);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	CGImageRelease(outputRef);
	
	[pixels release];
	[buffer release];
  
	return [image autorelease];
}
@end
