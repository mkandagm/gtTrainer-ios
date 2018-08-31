//
//  gtTrainerAppDelegate.h
//  gtTrainer
//
//  Created by Masanori Kanda on 09/07/24.
//  Copyright com.mkanda 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class gtTrainerViewController;

@interface gtTrainerAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet gtTrainerViewController *viewController;

@end

