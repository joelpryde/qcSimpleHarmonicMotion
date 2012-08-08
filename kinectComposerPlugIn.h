//
//  kinectComposerPlugIn.h
//  kinectComposer
//
//  Created by Devin Chalmers on 12/19/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>

#include "cinder/gl/gl.h"
#include "cinder/gl/Texture.h"

class Pendulum;

@interface kinectComposerPlugIn : QCPlugIn
{
    Pendulum* pendulums[15];
    float startTime;
}

@property (assign) id<QCPlugInOutputImageProvider> outputVideoImage;
@property (assign) double inputSize;

@end
