//
//  qcSimpleHarmonicMotionPlugin.mm
//  qcSimpleHarmonicMotionPlugin
//
//  Created by Joel Pryde on 12/19/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "qcSimpleHarmonicMotionPlugIn.h"
#import "Pendulum.h"

#include "cinder/cocoa/CinderCocoa.h"
#include "cinder/ImageSourceFileQuartz.h"
#include "cinder/ImageTargetFileQuartz.h"
#include "cinder/CinderMath.h"


#define	kQCPlugIn_Name				@"qcSimpleHarmonicMotion"
#define	kQCPlugIn_Description		@"A Cinder port of Memo's Simple Harmonic Motion test"

@implementation qcSimpleHarmonicMotionPlugIn

@dynamic inputWidth;
@dynamic inputHeight;

@dynamic inputCount;
@dynamic inputSize;

@synthesize size = mSize;

static NSMutableDictionary *sAttributes = nil;

+ (NSDictionary *)attributes;
{
    return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key;
{
    if (sAttributes == nil)
    {
        sAttributes = [[NSMutableDictionary alloc] init];
        [qcSimpleHarmonicMotionPlugIn addFloatAttribute:@"inputWidth" Default:640.0f Min:0.0f Max:4000.0f];
        [qcSimpleHarmonicMotionPlugIn addFloatAttribute:@"inputHeight" Default:640.0f Min:0.0f Max:4000.0f];
        
        [qcSimpleHarmonicMotionPlugIn addFloatAttribute:@"inputCount" Default:15.0f Min:0.0f Max:100.0f];
        [qcSimpleHarmonicMotionPlugIn addFloatAttribute:@"inputSize" Default:10.0f Min:0.0f Max:1000.0f];
    }
    return [sAttributes objectForKey:key];
}

+ (void)addFloatAttribute:(NSString *)key Default:(float)def Min:(float)min Max:(float)max
{
    [sAttributes setObject: [NSDictionary dictionaryWithObjectsAndKeys: key, QCPortAttributeNameKey, [NSNumber numberWithFloat:def], QCPortAttributeDefaultValueKey, [NSNumber numberWithFloat:min], QCPortAttributeMinimumValueKey, [NSNumber numberWithFloat:max], QCPortAttributeMaximumValueKey, nil] forKey:key];
}

+ (void)addBoolAttribute:(NSString *)key Default:(bool)def
{
    [sAttributes setObject: [NSDictionary dictionaryWithObjectsAndKeys: key, QCPortAttributeNameKey, [NSNumber numberWithBool:def], QCPortAttributeDefaultValueKey, nil] forKey:key];
}

- (float)floatParam:(NSString*)paramName
{
    return [[self valueForInputKey:paramName] floatValue];
}

- (int)intParam:(NSString*)paramName
{
    return [[self valueForInputKey:paramName] intValue];
}

- (bool)boolParam:(NSString*)paramName
{
    return [[self valueForInputKey:paramName] boolValue];
}

- (NSString*)stringParam:(NSString*)paramName
{
    return [self valueForInputKey:paramName];
}

+ (QCPlugInExecutionMode)executionMode;
{
    return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode)timeMode;
{
    return kQCPlugInTimeModeTimeBase;
}

- (void) finalize;
{
    /*
     Release any non garbage collected resources created in -init.
     */
    
    [super finalize];
}

- (void) dealloc;
{
    /*
     Release any resources created in -init.
     */
    
    [super dealloc];
}

- (void)setup
{
    mCount = 15;
    for (int i=0; i<mCount; i++)
    {
        float freq = (51.0 + i)/60.0;
        mPendulums[i] = new Pendulum(mCount, i, freq, 0);
    }
    mWidth = 640.0f; mHeight = 480.0f;
    
    // save time we have finished the setup, to ensure pendulums start at t==0
    //startTime = getElapsedSeconds();
}

fs::path getQCResourcePath( const fs::path &rsrcRelativePath )
{
    fs::path path = rsrcRelativePath.parent_path();
    fs::path fileName = rsrcRelativePath.filename();
    
    if( fileName.empty() )
        return string();
    
    NSString *pathNS = 0;
    if( ( ! path.empty() ) && ( path != rsrcRelativePath ) )
        pathNS = [NSString stringWithUTF8String:path.c_str()];
    
    NSString *resultPath;
    for ( NSBundle* bundle in [NSBundle allBundles])
    {
        resultPath = [bundle pathForResource:[NSString stringWithUTF8String:fileName.c_str()] ofType:nil inDirectory:pathNS];
        if( resultPath != nil )
            break;
    }
    
    return fs::path([resultPath cStringUsingEncoding:NSUTF8StringEncoding]);
}

DataSourceRef loadQCResource( const string &macPath )
{
    fs::path resourcePath = getQCResourcePath( macPath );
    if( resourcePath.empty() )
        throw ResourceLoadExc( macPath );
    else
        return DataSourcePath::create( resourcePath );
}

- (void)glSetup
{
    ImageSourceFileQuartz::registerSelf();
    mIsGLSetup = true;
}

- (void)update:(NSTimeInterval)elapsed
{
    // update
    // seconds since we started the app (minus setup time)
    float secs = mTime / 2.0f;
    
    if ([self didValueForInputKeyChange:@"inputCount"])
    {
        mCount = (int)[self floatParam:@"inputCount"];
        for (int i=0; i<mCount; i++)
        {
            float freq = (51.0 + i)/60.0;
            mPendulums[i] = new Pendulum(mCount, i, freq, 0);
        }
    }
    mPendulumSize = [self floatParam:@"inputSize"];
    mWidth = [[self valueForInputKey:@"inputWidth"] floatValue];
    mHeight = [[self valueForInputKey:@"inputHeight"] floatValue];
    
    // loop through, update and draw pendulums
    for (int c=0; c<mCount; c++)
        mPendulums[c]->update(secs, c, mWidth, mHeight, mPendulumSize);
}

- (void)render
{
    gl::setMatricesWindow(mWidth, mHeight);
    
    // clear out the window with black
    gl::clear( Color( 0, 0, 0 ) );
    
    //gl::setMatricesWindowPersp(size.width, size.height);
    //gl::clear( Color( 0, 0, 0 ) );
    
    // loop through, update and draw pendulums
    for (int c=0; c<mCount; c++)
        mPendulums[c]->draw(mPendulums, mCount);
}

- (BOOL)startExecution:(id<QCPlugInContext>)context;
{
    mWidth = 640.0f; mHeight = 480.0f;
    mSize = CGSizeMake(mWidth, mHeight);
    mLastTime = 0.0;
    mIsGLSetup = false;
    
    [self setup];
    
    // save time we have finished the setup, to ensure pendulums start at t==0
    //startTime = getElapsedSeconds();
    return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
    /*
     Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
     */
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
    CGLContextObj cgl_ctx = [context CGLContextObj];
    CGLSetCurrentContext(cgl_ctx);
    
    if (!mIsGLSetup)
        [self glSetup];
    
    mWidth = [self floatParam:@"inputWidth"];
    mHeight = [self floatParam:@"inputHeight"];
    mSize = CGSizeMake(mWidth, mHeight);
    
    // update
    double elapsed = (time-mLastTime) * 1.0f;//[self floatParam:@"inputSpeedScale"];
    mTime = mTime + elapsed * 1.0f;//[self floatParam:@"inputSpeedScale"];
    [self update:elapsed];
    mLastTime = time;
    
    // draw
    [self render];
    
    return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
    /*
     Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
     */
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
    /*
     Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
     */
}

@end