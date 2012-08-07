//
//  CGLTextureImageProvider.h
//  kinectComposer
//
//  Created by Devin Chalmers on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>

#include "cinder/gl/gl.h"
#include "cinder/Camera.h"
#include "cinder/gl/Texture.h"
#include "cinder/app/AppBasic.h"

using namespace ci;
using namespace ci::gl;

class Pendulum;

@interface CGLTextureImageProvider : NSObject <QCPlugInOutputImageProvider>
{
	//cinder::gl::Texture texture;
	CGColorSpaceRef colorSpace;
    float               mSize;
}

//@property (nonatomic, assign) cinder::gl::Texture texture;

- (id)initWithPendulums:(Pendulum**)pendulums;

@end
