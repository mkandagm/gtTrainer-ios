#import "InfoViewController.h"

@implementation InfoViewController

@synthesize delegate;					// The main view controller is the delegate for this class.

-(IBAction)OnClose:(id)sender
{
	[self.delegate InfoViewControllerDidFinish: self];	
}

-(IBAction)OnDimSwitch:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:[m_disableDim isOn] forKey:@"disableAutoLockSleep"];
	[defaults synchronize];
	[UIApplication sharedApplication].idleTimerDisabled = [m_disableDim isOn];
}

// Configures the table view.
- (void) viewDidLoad 
{
///	NSLog(@"InfoViewController viewDidLoad");
    [super viewDidLoad];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[m_disableDim setOn:[defaults boolForKey:@"disableAutoLockSleep"]];
	[UIApplication sharedApplication].idleTimerDisabled = [m_disableDim isOn];
	
	m_webView.scalesPageToFit=NO;
	NSString* resourcepath=NSLocalizedString(@"helphtml",nil);
	NSString *helpPath = [[NSBundle mainBundle] pathForResource:resourcepath ofType:@"html" inDirectory:@"help"];
	NSURL *helpURL = [NSURL fileURLWithPath:helpPath];
	[m_webView loadRequest:[NSURLRequest requestWithURL:helpURL]];
	
}


- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
    [super dealloc];
}



#pragma mark Application state management_____________
// Standard methods for managing application state.
- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


@end
