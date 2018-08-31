//
//  CellView.m
//  gtTrainer
//
//  Created by mkanda on 12/04/07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CellView.h"

@implementation CellView

@synthesize imageView;
@synthesize songTitle;
@synthesize detailText;
@synthesize imagePlayingView;
@synthesize persistID;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc {
    self.imageView = nil;
    self.songTitle = nil;
    self.detailText = nil;
    self.imagePlayingView = nil;
    self.persistID = nil;
    
    [super dealloc];
}


@end


@implementation CellViewController
@synthesize cell;

- (void)didReceiveMemoryWarning {
// Releases the view if it doesn't have a superview.
[super didReceiveMemoryWarning];

// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
[super viewDidUnload];
// Release any retained subviews of the main view.
// e.g. self.myOutlet = nil;
}


- (void)dealloc {
self.cell = nil;

[super dealloc];
}


@end