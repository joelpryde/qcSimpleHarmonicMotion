//
//  kinectComposerPlugIn.m
//  kinectComposer
//
//  Created by Devin Chalmers on 12/19/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "kinectComposerPlugIn.h"
#import "CGLTextureImageProvider.h"
#import "Pendulum.h"

#define	kQCPlugIn_Name				@"qcSimpleHarmonicMotion"
#define	kQCPlugIn_Description		@"A Cinder port of Memo's Simple Harmonic Motion test"

using namespace ci;
using namespace ci::app;
using namespace std;

@implementation kinectComposerPlugIn

@dynamic outputVideoImage;
@dynamic inputTilt;

+ (NSDictionary *)attributes;
{
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key;
{
	static NSDictionary *sAttributes = nil;
	if (!sAttributes) {
		sAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
						[NSDictionary dictionaryWithObjectsAndKeys:
							@"Output Video Image", QCPortAttributeNameKey,
							nil],
						@"outputVideoImage",
                       
						[NSDictionary dictionaryWithObjectsAndKeys:
							@"Tilt", QCPortAttributeNameKey,
							[NSNumber numberWithInt:0], QCPortAttributeDefaultValueKey,
							[NSNumber numberWithInt:-31], QCPortAttributeMinimumValueKey,
							[NSNumber numberWithInt:32], QCPortAttributeMaximumValueKey,
							nil],
						@"inputTilt",
                       
						nil];
	}
	return [sAttributes objectForKey:key];
}

+ (QCPlugInExecutionMode)executionMode;
{
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode)timeMode;
{
	return kQCPlugInTimeModeIdle;
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

@end

@implementation kinectComposerPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context;
{
    for (int i=0; i<15; i++)
    {
        float freq = (51.0 + i)/60.0;
        pendulums[i] = new Pendulum(i, freq, 0);
    }
        
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
	CGLContextObj ctx = CGLGetCurrentContext();
	CGLContextObj cgl_ctx = [context CGLContextObj];
	CGLSetCurrentContext(cgl_ctx);
    
    // update
    // seconds since we started the app (minus setup time)
    float secs = time;//getElapsedSeconds() - startTime;
        
    // loop through, update and draw pendulums
    size = 40.0f;
    for (int c=0; c<15; c++) 
    {
        pendulums[c]->update(secs, lmap((float)c, 0.0f, 15.0f-1.0f, size/2.0f, 640.0f - size/2.0f), size);
    }
    
	if ([self didValueForInputKeyChange:@"inputTilt"]) 
    {
        double size = [[self valueForInputKey:@"inputTilt"] floatValue];
        self.outputVideoImage = [[[CGLTextureImageProvider alloc] initWithPendulums:pendulums] autorelease];
    }
    else
    {
        self.outputVideoImage = [[[CGLTextureImageProvider alloc] initWithPendulums:pendulums] autorelease];
    }
    
	CGLSetCurrentContext(ctx);	
	return YES;
}


// should disconnect from kinect, but I didn't see it in the APIs

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
