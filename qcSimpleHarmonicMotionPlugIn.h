//
//  qcSimpleHarmonicMotionPlugin.h
//  qcSimpleHarmonicMotionPlugin
//
//  Created by Joel Pryde on 12/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>

#include "cinder/gl/gl.h"
#include "cinder/gl/Texture.h"

class Pendulum;

@interface qcSimpleHarmonicMotionPlugIn : QCPlugIn
{
    float mStartTime;
    bool mIsGLSetup;
    
    CGSize mSize;
    float mWidth;
    float mHeight;
    NSTimeInterval mTime;
    double mLastTime;
    
    int mCount;
    Pendulum* mPendulums[100];
    float mPendulumSize;
}

@property (assign) double inputWidth;
@property (assign) double inputHeight;

@property (assign) double inputCount;
@property (assign) double inputSize;

@property (assign) CGSize size;

+ (void)addFloatAttribute:(NSString *)key Default:(float)def Min:(float)min Max:(float)max;
+ (void)addBoolAttribute:(NSString *)key Default:(bool)def;
- (float)floatParam:(NSString*)paramName;
- (NSString*)stringParam:(NSString*)paramName;
- (bool)boolParam:(NSString*)paramName;

- (void)setup;
- (void)glSetup;
- (void)update:(NSTimeInterval)time;
- (void)render;

@end
