//
//  KSDIdlingWindow.m
//
//  Created by Brian King on 4/13/10.
//  Copyright 2010 King Software Designs. All rights reserved.
//
// Based off: 
//  http://stackoverflow.com/questions/273450/iphone-detecting-user-inactivity-idle-time-since-last-screen-touch
//

#import "KSDIdlingWindow.h"

NSString * const KSDIdlingWindowIdleNotification   = @"KSDIdlingWindowIdleNotification";
NSString * const KSDIdlingWindowActiveNotification = @"KSDIdlingWindowActiveNotification";

@interface KSDIdlingWindow (PrivateMethods)
- (void)windowIdleNotification;
- (void)windowActiveNotification;


@end


@implementation KSDIdlingWindow
@synthesize idleTimer, idleTimeInterval;

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.idleTimeInterval = 10;
	}
	return self;
}
#pragma mark activity timer

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
	
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0) {

		// To reduce timer resets only reset the timer on a Began or Ended touch.
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
		if (phase == UITouchPhaseBegan || phase == UITouchPhaseEnded) {
			if (!idleTimer) {
				[self windowActiveNotification];
			} else {
				[idleTimer invalidate];
			}
			if (idleTimeInterval != 0) {
				self.idleTimer = [NSTimer scheduledTimerWithTimeInterval:idleTimeInterval 
																  target:self 
																selector:@selector(windowIdleNotification) 
																userInfo:nil repeats:NO];
			}
		}
	}
}


- (void)windowIdleNotification {
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	[dnc postNotificationName:KSDIdlingWindowIdleNotification 
					   object:self
					 userInfo:nil];
	self.idleTimer = nil;
}

- (void)windowActiveNotification {
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	[dnc postNotificationName:KSDIdlingWindowActiveNotification 
					   object:self
					 userInfo:nil];
}

- (void)dealloc {
	if (self.idleTimer) {
		[self.idleTimer invalidate];
		self.idleTimer = nil;
	}
//    [super dealloc];
}


@end
