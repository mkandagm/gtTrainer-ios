//
//  gtTrainerAppDelegate.m
//  gtTrainer
//
//  Created by Masanori Kanda on 09/07/24.
//  Copyright com.mkanda 2009. All rights reserved.
//

#import "gtTrainerAppDelegate.h"
#import "gtTrainerViewController.h"

@implementation gtTrainerAppDelegate

@synthesize window=_window;
@synthesize viewController=_viewController;



bool lastidleTimerDisabled;

- (void)applicationWillTerminate:(UIApplication *)application
{
	application.idleTimerDisabled = lastidleTimerDisabled;
}

void myInterruptionListenerCallback(void *inUserData,
									UInt32 inInterruption)
{
	if (inInterruption == kAudioSessionEndInterruption) {
//		AudioSessionSetActive(true);
		NSLog(@"EndInterruption\n");
//		[controller setInterrupt:NO];
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
		NSLog(@"BeginInterruption\n");
//		[controller setInterrupt:YES];
	}
}


// Audio session callback function for responding to audio route changes. If playing 
//		back application audio when the headset is unplugged, this callback pauses 
//		playback and displays an alert that allows the user to resume or stop playback.
void audioRouteChangeListenerCallback (
									   void                      *inUserData,
									   AudioSessionPropertyID    inPropertyID,
									   UInt32                    inPropertyValueSize,
									   const void                *inPropertyValue
) {
	
	// ensure that this callback was invoked for the correct property change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.idleTimerDisabled = YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    application.idleTimerDisabled = lastidleTimerDisabled;
}

/*
-(void)preventDim:(id)sender
{
//	NSTimer* theTimer = sender;
//	UIApplication* application = [theTimer userInfo];
//	application.idleTimerDisabled = m_isdisableAutoLockSleep;
}
*/
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{   
	lastidleTimerDisabled = application.idleTimerDisabled;
///	NSLog(@"applicationDidFinishLaunching : isdisableAutoLockSleep %d", lastidleTimerDisabled );
    
    application.idleTimerDisabled = YES;
	
//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//	m_isdisableAutoLockSleep=[defaults boolForKey:@"disableAutoLockSleep"];
//	[UIApplication sharedApplication].idleTimerDisabled = m_isdisableAutoLockSleep;
	
	// initialize audio session
//	AudioSessionInitialize(NULL, kCFRunLoopDefaultMode, myInterruptionListenerCallback, viewController);
	// register a property listener so we're notified when there's a route change
	///	AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
	///									myAudioRouteChangeListenerCallback, self);
	// set the audio session category - kAudioSessionCategory_MediaPlayback
	// will ensure our audio playback contiues when the device is locked
///	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
///	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	// activate the audio session immmediately before playback starts
///	AudioSessionSetActive(true);
	

	// Override point for customization after app launch    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	
//	[NSTimer scheduledTimerWithTimeInterval: 5.0
//									 target:self
//								   selector:@selector(preventDim:)
//								   userInfo:application
//									repeats:YES];	
	
}


- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}


@end
