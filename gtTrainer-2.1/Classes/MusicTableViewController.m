
#import "MusicTableViewController.h"
#import "gtTrainerViewController.h"

@implementation thumbnailInfoRec
@synthesize targetCell;
@synthesize infoindex;
- (void)dealloc 
{
	[targetCell release];
	[infoindex release];
    [super dealloc];
}

@end


@implementation MusicTableViewController


@synthesize delegate;					// The main view controller is the delegate for this class.
@synthesize mediaItemCollectionTable;	// The table shown in this class's view.
@synthesize addMusicButton;				// The button for invoking the media item picker. Setting the title
//		programmatically supports localization.

/*
-(void)timerHandleUpdateCellDisplay:(id)sender
{

	gtTrainerViewController* mainViewController = (gtTrainerViewController *) self.delegate;
    
    if( mainViewController.musicPlayer.playbackState != MPMusicPlaybackStatePlaying ){
    }
    else {
        NSUInteger nowPlayingIndex=[mainViewController.musicPlayer indexOfNowPlayingItem];
        NSArray *visible = [mediaItemCollectionTable indexPathsForVisibleRows];
        if( visible!=nil ){
            NSInteger row=0;
            for( row=0; row<[visible count]; row++ ){
                NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:row];
                CellView* cell=(CellView*)[mediaItemCollectionTable cellForRowAtIndexPath:indexpath];
                if( cell!=nil ){
                    if( row==nowPlayingIndex ){
                        [cell.imagePlayingView setHidden:NO];
                    }
                    else {
                        [cell.imagePlayingView setHidden:YES];
                    }
                 }
            }
        }
    }

    [NSTimer scheduledTimerWithTimeInterval: 0.3
									 target:self
								   selector:@selector(timerHandleUpdateCellDisplay:)
								   userInfo:nil
									repeats:NO];	

}
*/

// Configures the table view.
- (void) viewDidLoad 
{
    [super viewDidLoad];
	operationQueue=[NSOperationQueue new];
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	gtTrainerViewController *mainViewController = (gtTrainerViewController *) self.delegate;
    [mainViewController setMusicView:self];
    
/*    [NSTimer scheduledTimerWithTimeInterval: 0.3
									 target:self
								   selector:@selector(timerHandleUpdateCellDisplay:)
								   userInfo:nil
									repeats:NO];	
*/    

}


// When the user taps Done, invokes the delegate's method that dismisses the table view.
- (IBAction) doneShowingMusicList: (id) sender
{
	gtTrainerViewController *mainViewController = (gtTrainerViewController *) self.delegate;
    [mainViewController setMusicView:nil];
	[self.delegate musicTableViewControllerDidFinish: self];
}


// Configures and displays the media item picker.
- (IBAction) showMediaPicker: (id) sender {
	
	MPMediaPickerController *picker =
	[[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio]; // MPMediaTypeAnyAudio 
	
	picker.delegate						= self;
	picker.allowsPickingMultipleItems	= YES;
	picker.prompt						= NSLocalizedString (@"Please add music to play", nil);
	
	
	//[self presentModalViewController: picker animated: YES];
	[self presentViewController:picker animated:YES completion:nil];
	[picker release];
}


// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection 
{
	//[self dismissModalViewControllerAnimated: YES];
	[self dismissViewControllerAnimated:YES completion:nil];
	[self.delegate updatePlayerQueueWithMediaCollection: mediaItemCollection];
	[self.mediaItemCollectionTable reloadData];
}


// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker 
{
	//[self dismissModalViewControllerAnimated: YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark Table view methods________________________

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch(buttonIndex){
		case 0:
			[self.delegate removePlayerQueueAll];
			[self.mediaItemCollectionTable reloadData];
			break;
	}
}

- (IBAction) OnDeleteAllItem: (id) sender
{
	NSString* sheetTitlestr=NSLocalizedString(@"AlertDiscardMusicList_title",nil);
	NSString* sheetCancelButtonstr=NSLocalizedString(@"Cancel",nil);
	NSString* sheetButton1str=NSLocalizedString(@"OnButtonAction_Discard",nil);
	UIActionSheet *actionSheet;
	actionSheet=[[UIActionSheet alloc] initWithTitle:sheetTitlestr
											delegate:self 
								   cancelButtonTitle:sheetCancelButtonstr 
							  destructiveButtonTitle:sheetButton1str
								   otherButtonTitles:nil];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
}

- (IBAction) OnEditTableItem: (id) sender
{
	BOOL isEditing=[mediaItemCollectionTable isEditing];
	[mediaItemCollectionTable setEditing:!isEditing animated:YES];
	if( isEditing ){
		[editButton setTitle:NSLocalizedString(@"Edit",nil)];
		[editButton setStyle:UIBarButtonItemStyleBordered];
		[deleteAllButton setEnabled:YES];
		[addMusicButton setEnabled:YES];
		[doneMusicButton setEnabled:YES];
		[deleteAllButton setEnabled:YES];
	}
	else {
		[editButton setTitle:NSLocalizedString(@"Done",nil)];
		[editButton setStyle:UIBarButtonItemStyleDone];
		[deleteAllButton setEnabled:NO];
		[addMusicButton setEnabled:NO];
		[doneMusicButton setEnabled:NO];
		[deleteAllButton setEnabled:NO];
	}
}
- (void) updateMusicListView
{
    [self.mediaItemCollectionTable reloadData];
}

// swap item
- (void)tableView:(UITableView *)tableView
			moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
				  toIndexPath:(NSIndexPath *)toIndexPath 
{
	//NSLog(@"tableView moveRowAtIndexPath from %d to %d", fromIndexPath.row, toIndexPath.row );
	[self.delegate swapPlayerQueueWithIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

// remove item
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
			forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//NSLog(@"tableView commitEditingStyle delete row %d", indexPath.row );
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.delegate removePlayerQueueWithIndex: indexPath.row];
		[mediaItemCollectionTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
										withRowAnimation:UITableViewRowAnimationFade];
	} 
	else if (editingStyle == UITableViewCellEditingStyleInsert){
	}
}

// To learn about using table views, see the TableViewSuite sample code  
//		and Table View Programming Guide for iPhone OS.

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section
{
	gtTrainerViewController *mainViewController = (gtTrainerViewController *) self.delegate;
	MPMediaItemCollection *currentQueue = mainViewController.userMediaItemCollection;
	return [currentQueue.items count];
}

-(void)finishDisplayThumbnail:(thumbnailInfoRec*)inforec
{
    
	NSInteger row = [inforec.infoindex row];
	
	gtTrainerViewController *mainViewController = (gtTrainerViewController *) self.delegate;
	MPMediaItemCollection *currentQueue = mainViewController.userMediaItemCollection;
	MPMediaItem *anItem = (MPMediaItem *)[currentQueue.items objectAtIndex: row];
    
	MPMediaItemArtwork *artwork = [anItem valueForProperty: MPMediaItemPropertyArtwork];
	UIImage *artworkImage = [UIImage imageNamed:@"no_artworksmall.png"];
	if (artwork) {
		artworkImage = [artwork imageWithSize: CGSizeMake (40, 40)];
	}
    if( artworkImage==nil ){
        artworkImage = [UIImage imageNamed:@"no_artworksmall.png"];
    }
	inforec.targetCell.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[inforec.targetCell.imageView setImage:artworkImage];
	[inforec release];
}

-(void)displayThumbnail:(thumbnailInfoRec*)inforec
{
	[self performSelectorOnMainThread:@selector(finishDisplayThumbnail:) withObject:inforec waitUntilDone:YES];
	return;
    
}


-(UIImage*)blankImage
{
	CGSize  framesize = { 40, 40 };
	UIGraphicsBeginImageContext(framesize);
	CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0.5,0.5,0.5,1.0);
	CGRect frameRect=CGRectMake(0,0,40,40);
	UIRectFill(frameRect);
	UIImage* lastimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	return lastimage;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString* CellIdentifier = @"CustomCellView";
	
    NSInteger row = [indexPath row];
	//UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier];
	CellView *cell = (CellView*)[tableView dequeueReusableCellWithIdentifier: CellIdentifier];
	
	if (cell == nil) {
        
        CellViewController *controller = [[CellViewController alloc] initWithNibName: @"CellView" bundle:nil];
        cell = (CellView*)controller.view;
		[controller release];             
		//cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle 
		//							   reuseIdentifier: kCellIdentifier] autorelease];
	}

	gtTrainerViewController *mainViewController = (gtTrainerViewController *) self.delegate;
	MPMediaItemCollection *currentQueue = mainViewController.userMediaItemCollection;
	MPMediaItem *anItem = (MPMediaItem *)[currentQueue.items objectAtIndex: row];
	
	if (anItem) {
        cell.persistID = [anItem valueForProperty:MPMediaItemPropertyPersistentID];
		cell.songTitle.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
		cell.detailText.text = [NSString stringWithFormat:@"%@ - %@",
									 [anItem valueForProperty:MPMediaItemPropertyAlbumTitle], 
									 [anItem valueForProperty:MPMediaItemPropertyArtist] 
									];
        [cell.imagePlayingView setImage: [UIImage imageNamed:@"nowplaying.png"]];
        [cell.imagePlayingView setHidden:YES];
        
        if( mainViewController.musicPlayer.playbackState != MPMusicPlaybackStatePlaying ){
        }
        else {
            
            NSUInteger nowPlayingIndex=[mainViewController.musicPlayer indexOfNowPlayingItem];
            if( row==nowPlayingIndex ){
                [cell.imagePlayingView setHidden:NO];
            }
        }

		thumbnailInfoRec* theInfo=[[thumbnailInfoRec alloc] init];
		theInfo.targetCell=cell;
		theInfo.infoindex=indexPath;
		[cell.imageView setImage:[self blankImage]];
		NSInvocationOperation *op = [[NSInvocationOperation alloc]
									 initWithTarget:self
									 selector:@selector(displayThumbnail:)
									 object:theInfo];
		[operationQueue addOperation:op];
		[op release];	
		

	}
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	return cell;
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    [self.delegate changePlayItem:[indexPath row] table:tableView];
//    [self.mediaItemCollectionTable reloadData];
}


#pragma mark Application state management_____________
// Standard methods for managing application state.
- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[operationQueue release];
    [super dealloc];
}


@end
