//
//  kinectComposerPlugIn.m
//  kinectComposer
//
//  Created by Devin Chalmers on 12/19/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "qcSimpleHarmonicMotionPlugIn.h"
#import "CGLTextureImageProvider.h"
#import "Pendulum.h"

#define	kQCPlugIn_Name				@"qcSimpleHarmonicMotion"
#define	kQCPlugIn_Description		@"A Cinder port of Memo's Simple Harmonic Motion test"

using namespace ci;
using namespace ci::app;
using namespace std;

@implementation qcSimpleHarmonicMotionPlugIn

@dynamic outputVideoImage;
@dynamic inputCount;
@dynamic inputSize;
@dynamic inputWidth;
@dynamic inputHeight;

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
                            @"Count", QCPortAttributeNameKey,
                            [NSNumber numberWithFloat:15], QCPortAttributeDefaultValueKey,
                            [NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
                            [NSNumber numberWithFloat:100], QCPortAttributeMaximumValueKey,
                            nil],
                           @"inputCount",
                       
						[NSDictionary dictionaryWithObjectsAndKeys:
							@"Size", QCPortAttributeNameKey,
							[NSNumber numberWithFloat:0.0f], QCPortAttributeDefaultValueKey,
							[NSNumber numberWithFloat:0.0f], QCPortAttributeMinimumValueKey,
							[NSNumber numberWithFloat:1000.0f], QCPortAttributeMaximumValueKey,
							nil],
						@"inputSize",
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Width", QCPortAttributeNameKey,
                        [NSNumber numberWithFloat:640.0f], QCPortAttributeDefaultValueKey,
                        [NSNumber numberWithFloat:0.0f], QCPortAttributeMinimumValueKey,
                        [NSNumber numberWithFloat:4000.0f], QCPortAttributeMaximumValueKey,
                        nil],
                       @"inputWidth",
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Height", QCPortAttributeNameKey,
                        [NSNumber numberWithFloat:480.0f], QCPortAttributeDefaultValueKey,
                        [NSNumber numberWithFloat:0.0f], QCPortAttributeMinimumValueKey,
                        [NSNumber numberWithFloat:4000.0f], QCPortAttributeMaximumValueKey,
                        nil],
                       @"inputHeight",
                       
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

@implementation qcSimpleHarmonicMotionPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context;
{
    count = 15;
    for (int i=0; i<count; i++)
    {
        float freq = (51.0 + i)/60.0;
        pendulums[i] = new Pendulum(count, i, freq, 0);
    }
    size = 40.0f;
    width = 640.0f; height = 480.0f;
        
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
    
    NSRect bounds = [context bounds];
    
    // update
    // seconds since we started the app (minus setup time)
    float secs = time / 2.0f;
        
    if ([self didValueForInputKeyChange:@"inputCount"]) 
    {
        count = [[self valueForInputKey:@"inputCount"] intValue];
        for (int i=0; i<count; i++)
        {
            float freq = (51.0 + i)/60.0;
            pendulums[i] = new Pendulum(count, i, freq, 0);
        }
    }
    if ([self didValueForInputKeyChange:@"inputSize"]) 
        size = [[self valueForInputKey:@"inputSize"] floatValue];
    if ([self didValueForInputKeyChange:@"inputWidth"]) 
        width = [[self valueForInputKey:@"inputWidth"] floatValue];
    if ([self didValueForInputKeyChange:@"inputHeight"]) 
        height = [[self valueForInputKey:@"inputHeight"] floatValue];
    
    // loop through, update and draw pendulums
    for (int c=0; c<count; c++) 
        pendulums[c]->update(secs, c, width, height, size);
    
    MyTextureImageProvider* textureImageProvider = [MyTextureImageProvider alloc];
    self.outputVideoImage = [[textureImageProvider initWithPendulums:pendulums withSize:CGSizeMake(width, height) withCount:count] autorelease];
    
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
