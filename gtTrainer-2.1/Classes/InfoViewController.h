#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol InfoViewControllerDelegate; // forward declaration

@interface InfoViewController : UIViewController
{
	id <InfoViewControllerDelegate>	delegate;
	IBOutlet UIWebView*		m_webView;
	IBOutlet UISwitch*		m_disableDim;
}
@property (nonatomic, assign) id <InfoViewControllerDelegate>	delegate;

-(IBAction)OnClose:(id)sender;
-(IBAction)OnDimSwitch:(id)sender;

@end

@protocol InfoViewControllerDelegate

// implemented in MainViewController.m
- (void) InfoViewControllerDidFinish: (InfoViewController *) controller;

@end
