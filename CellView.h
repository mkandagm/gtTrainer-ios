//
//  CellView.h
//  gtTrainer
//
//  Created by mkanda on 12/04/07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellView : UITableViewCell
{
    IBOutlet UIImageView*   imageView;
    IBOutlet UILabel*       songTitle;
    IBOutlet UILabel*       detailText;
    IBOutlet UIImageView*   imagePlayingView;
    NSNumber*   persistID;
}
@property (nonatomic, retain) IBOutlet UILabel *songTitle;
@property (nonatomic, retain) IBOutlet UILabel *detailText;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *imagePlayingView;
@property (nonatomic, retain) NSNumber *persistID;


@end


@interface CellViewController : UIViewController 
{
    CellView *cell;
}

@property (nonatomic, retain) IBOutlet CellView *cell;

@end
