//
//  CGLTextureImageProvider.m
//  kinectComposer
//
//  Created by Devin Chalmers on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CGLTextureImageProvider.h"
#import "Pendulum.h"

#import <Accelerate/Accelerate.h>

#include "cinder/app/AppBasic.h"
#include <cinder/Surface.h>
#include <cinder/ImageIo.h>
#include "cinder/gl/Texture.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/gl/DisplayList.h"

using namespace ci;
using namespace ci::app;
using namespace std;

bool                mSetup;
Pendulum**          mPendulums;

@implementation CGLTextureImageProvider

- (id)initWithPendulums:(Pendulum**)pendulums
{
	if (!(self = [super init]))
		return nil;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (!mSetup)
    {
        mSetup = true;
    }
    mPendulums = pendulums;
	return self;
}

- (void)dealloc;
{
	// why doesn't this do anythin?
	// texture.reset()
	// but it works in the render call???
	CGColorSpaceRelease(colorSpace);
	[super dealloc];
}

- (NSRect)imageBounds;
{
    /*
	if (texture) 
    {
        //NSLog( @"image bounds: %d, %d", texture.getWidth(), texture.getHeight());
		return NSMakeRect(0, 0, texture.getWidth(), texture.getHeight());
	}
	else {
        //NSLog( @"image bounds: %d, %d", 640, 480);
		return NSMakeRect(0, 0, 640, 480);
	}*/
    return NSMakeRect(0, 0, 640, 480);
}

- (BOOL)renderWithCGLContext:(CGLContextObj)cgl_ctx forBounds:(NSRect)bounds;
{
	CGLContextObj ctx = CGLGetCurrentContext();
	CGLSetCurrentContext(cgl_ctx);
	
    // clear out the window with black
    gl::setMatricesWindowPersp(bounds.size.width, bounds.size.height);
	gl::clear( Color( 0, 0, 0 ) ); 
    
    // loop through, update and draw pendulums
    for (int c=0; c<15; c++) 
    {
        mPendulums[c]->draw(mPendulums);
    }
	
	CGLSetCurrentContext(ctx);
	//if (texture)
	//	texture.reset();
	
	return YES;
}

- (CGColorSpaceRef) imageColorSpace;
{
	return colorSpace;
}

- (BOOL) canRenderWithCGLContext:(CGLContextObj)cgl_ctx;
{
	return YES;
}

- (BOOL) renderToBuffer:(void*)baseAddress withBytesPerRow:(NSUInteger)rowBytes pixelFormat:(NSString*)format forBounds:(NSRect)bounds;
{
    return NO;
}

@end
