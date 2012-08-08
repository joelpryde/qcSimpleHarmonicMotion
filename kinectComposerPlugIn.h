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
    int count;
    Pendulum* pendulums[100];
    float startTime;
    
    float size;
    float width;
    float height;
}

@property (assign) id<QCPlugInOutputImageProvider> outputVideoImage;

@property (assign) double inputCount;
@property (assign) double inputSize;
@property (assign) double inputWidth;
@property (assign) double inputHeight;

@end
