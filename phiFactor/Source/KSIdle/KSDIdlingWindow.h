//
//  KSDIdlingWindow.h
//
//  Created by Brian King on 4/13/10.
//  Copyright 2010 King Software Designs. All rights reserved.
//
// Based off: 
//  http://stackoverflow.com/questions/273450/iphone-detecting-user-inactivity-idle-time-since-last-screen-touch
//

#import <UIKit/UIKit.h>

extern NSString * const KSDIdlingWindowIdleNotification;
extern NSString * const KSDIdlingWindowActiveNotification;

@interface KSDIdlingWindow : UIWindow {
	NSTimer *idleTimer;
	NSTimeInterval idleTimeInterval;
}

@property (assign) NSTimeInterval idleTimeInterval;

@property (nonatomic, retain) NSTimer *idleTimer;

@end
