//
//  gtTrainerViewController.m
//  gtTrainer
//
//  Created by Masanori Kanda on 09/07/24.
//  Copyright com.mkanda 2009. All rights reserved.
//

#import "gtTrainerViewController.h"

@implementation gtTrainerViewController

@synthesize userMediaItemCollection;	// the media item collection created by the user, using the media item picker	
@synthesize musicPlayer;				// the music player, which plays media items from the iPod library

-(void)setMusicView:(MusicTableViewController*)musicView
{
    m_musicTableView=musicView;
}


#pragma mark Media item picker delegate methods________
// Invoked when the user taps the Done button in the table view.
- (void) musicTableViewControllerDidFinish: (MusicTableViewController *) controller
{
	//NSLog(@"musicTableViewControllerDidFinish");
	// save to userdefaults 
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
	NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:combinedMediaItems];
	[defaults setObject:theData forKey:@"last_music_collection"];
	[defaults synchronize];
	[combinedMediaItems release]; 
//	[self dismissModalViewControllerAnimated: YES];
	[self dismissViewControllerAnimated:YES completion:nil];
	
	m_openMusicList=NO;
	[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
	/*
	[NSTimer scheduledTimerWithTimeInterval: 0.05
									 target:self
								   selector:@selector(AfterStop:)
								   userInfo:nil
									repeats:NO];
	*/
}


// Invoked when the user taps the Done button in the media item picker after having chosen
//		one or more media items to play.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
	// Dismiss the media item picker.
	//[self dismissModalViewControllerAnimated: YES];
	[self dismissViewControllerAnimated:YES completion:nil];
	
	// Apply the chosen songs to the music player's queue.
	[self updatePlayerQueueWithMediaCollection: mediaItemCollection];
}

// Invoked when the user taps the Done button in the media item picker having chosen zero
//		media items to play
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
	//[self dismissModalViewControllerAnimated: YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)AfterChangePlayItem:(id)sender
{
	NSTimer* theTimer = sender;
    UITableView* tableView=[theTimer userInfo];
    [tableView reloadData];
}

- (void) changePlayItem: (NSUInteger)index table:(UITableView*)tableView
{
	MPMediaItem *anItem = (MPMediaItem *)[userMediaItemCollection.items objectAtIndex: index];


    if( [musicPlayer playbackState] != MPMusicPlaybackStatePlaying ){
        [musicPlayer setNowPlayingItem:anItem];
        [musicPlayer play];
    }
    else if( [musicPlayer playbackState] == MPMusicPlaybackStatePlaying ){
        NSUInteger nowPlayingIndex=[musicPlayer indexOfNowPlayingItem];
        if( nowPlayingIndex==index ){
            [musicPlayer pause];
        }
        else {
            [musicPlayer setNowPlayingItem:anItem];
       }
    }
	[NSTimer scheduledTimerWithTimeInterval: 0.25
									 target:self
								   selector:@selector(AfterChangePlayItem:)
								   userInfo:tableView
									repeats:NO];
}

- (void) swapPlayerQueueWithIndex: (NSUInteger)fromindex toIndex:(NSUInteger)toindex
{
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	if (playbackState == MPMusicPlaybackStatePlaying || playbackState ==MPMusicPlaybackStatePaused ||
		playbackState == MPMusicPlaybackStateSeekingForward || playbackState ==MPMusicPlaybackStateSeekingBackward ) {
		[musicPlayer stop];
	}
		//NSLog(@"swapPlayerQueueWithIndex from %d to %d", fromindex, toindex);
	// Combine the previously-existing media item collection with the new one
	NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
	[combinedMediaItems exchangeObjectAtIndex:fromindex withObjectAtIndex:toindex];
//	[userMediaItemCollection release];
	[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];
	[combinedMediaItems release];
}

- (void) removePlayerQueueAll
{
	//NSLog(@"removePlayerQueueWithIndex");
	[self setUserMediaItemCollection: nil];
	loopingnow=NO;
	[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];	
	
}

- (void) removePlayerQueueWithIndex: (NSUInteger)index
{
	//NSLog(@"removePlayerQueueWithIndex %d", index );
	// Combine the previously-existing media item collection with the new one
	NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
	[combinedMediaItems removeObjectAtIndex:index];
	
	if( [combinedMediaItems count]>0 ){
		[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];
	}
	else {
		[self setUserMediaItemCollection:nil];
	}
	
	[combinedMediaItems release];
	////NSLog(@"removePlayerQueueWithIndex setQueueWithItemCollection" );
	loopingnow=NO;
	[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];	
	
	
}


- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection 
{
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
		
		// If there's no playback queue yet...
		if (userMediaItemCollection == nil) {
			
			// apply the new media item collection as a playback queue for the music player
			[self setUserMediaItemCollection: mediaItemCollection];
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			[m_btn_playpause setImage:[UIImage imageNamed:@"imgbtn_pause.png"] forState:UIControlStateNormal];
			nowplayIndex=1;
			[m_label_musicIndex setText:[NSString stringWithFormat:@"%d / %d",nowplayIndex,[userMediaItemCollection count]]];
			m_openMusicList=NO;
			[NSTimer scheduledTimerWithTimeInterval: 0.05
											 target:self
										   selector:@selector(AfterStop:)
										   userInfo:nil
											repeats:NO];	
			
			// Obtain the music player's state so it can then be
			//		restored after updating the playback queue.
		} else {
			
			// Take note of whether or not the music player is playing. If it is
			//		it needs to be started again at the end of this method.
			BOOL wasPlaying = NO;
			if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
				wasPlaying = YES;
			}
			
			// Save the now-playing item and its current playback time.
			MPMediaItem *nowPlayingItem			= musicPlayer.nowPlayingItem;
			NSTimeInterval currentPlaybackTime	= musicPlayer.currentPlaybackTime;
			
			// Combine the previously-existing media item collection with the new one
			NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
			NSArray *newMediaItems				= [mediaItemCollection items];
			[combinedMediaItems addObjectsFromArray: newMediaItems];
			
			[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];
			[combinedMediaItems release];
			
			// Apply the new media item collection as a playback queue for the music player.
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			
			// Restore the now-playing item and its current playback time.
			musicPlayer.nowPlayingItem			= nowPlayingItem;
			musicPlayer.currentPlaybackTime		= currentPlaybackTime;
			
			// If the music player was playing, get it playing again.
			if (wasPlaying) {
				[musicPlayer play];
			}
		}
		// save to userdefaults 
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
		NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:combinedMediaItems];
		[defaults setObject:theData forKey:@"last_music_collection"];
		[defaults synchronize];
		[combinedMediaItems release]; 
		
		// Finally, because the music player now has a playback queue, ensure that 
		//		the music play/pause button in the Navigation bar is enabled.
		//		navigationBar.topItem.leftBarButtonItem.enabled = YES;
		
		//		[addOrShowMusicButton	setTitle: NSLocalizedString (@"Show Music", @"Alternate title for 'Add Music' button, after user has chosen some music")
		//							  forState: UIControlStateNormal];
	}
}


#pragma mark OnInformation handlers__________________

-(IBAction)OnInformation:(id)sender
{
	// configuraton idleTimerDisabled for dim screen 
	//	and display easy manual
	InfoViewController *controller = [[InfoViewController alloc] initWithNibName: @"infoView" bundle: nil];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	//[self presentModalViewController: controller animated: YES];
	[self presentViewController:controller animated:YES completion:nil];
	[controller release];
}

- (void) InfoViewControllerDidFinish: (InfoViewController *) controller
{
	//NSLog(@"InfoViewControllerDidFinish");
	// save to userdefaults 
//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//	m_isdisableAutoLockSleep = [defaults boolForKey:@"disableAutoLockSleep"];

	//[self dismissModalViewControllerAnimated: YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Musiclist handlers__________________

-(IBAction)OnMusicList:(id)sender
{
	m_openMusicList=YES;
	// if the user has already chosen some music, display that list
	if (userMediaItemCollection) {
		
		MusicTableViewController *controller = [[MusicTableViewController alloc] initWithNibName: @"MusicTableView" bundle: nil];
		controller.delegate = self;
		
		controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleCrossDissolve;
		
		//[self presentModalViewController: controller animated: YES];
		[self presentViewController:controller animated:YES completion:nil];

		[controller release];
		
		// else, if no music is chosen yet, display the media item picker
	} else {
		
		MPMediaPickerController *picker =
		[[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio]; // MPMediaTypeAnyAudio MPMediaTypeMusic
		
		picker.delegate						= self;
		picker.allowsPickingMultipleItems	= YES;
		picker.prompt						= NSLocalizedString (@"Please add music to play", nil);
		
		//[self presentModalViewController: picker animated: YES];
		[self presentViewController:picker animated:YES completion:nil];

		[picker release];
	}
	
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


#pragma mark Music notification handlers__________________

// When the now-playing item changes, update the media item artwork and the now-playing label.
- (void) handle_NowPlayingItemChanged: (id) notification 
{
	NSLog(@"handle_NowPlayingItemChanged");
	MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
	
//	if (musicPlayer.playbackState != MPMusicPlaybackStateStopped) {
    {
		long itemCount=[userMediaItemCollection count];
		if( itemCount>0 ){
				
			// Assume that there is no artwork for the media item.
			UIImage *artworkImage = [UIImage imageNamed:@"no_artwork.png"];
			
			// Get the artwork from the current media item, if it has artwork.
			MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
			
			// Obtain a UIImage object from the MPMediaItemArtwork object
			if (artwork) {
				artworkImage = [artwork imageWithSize: CGSizeMake (80, 80)];
			}
            if( artworkImage==nil ){
                artworkImage = [UIImage imageNamed:@"no_artwork.png"];
            }
			[m_imageView_artwork setImage:artworkImage];
			
			// Display the artist and song name for the now-playing media item
			[m_label_titlename setText:[currentItem valueForProperty: MPMediaItemPropertyTitle]]; 
			[m_label_albumname setText:[currentItem valueForProperty: MPMediaItemPropertyAlbumTitle]]; 
			[m_label_artistname setText:[currentItem valueForProperty: MPMediaItemPropertyArtist]]; 
			nowplayID=[currentItem valueForProperty: MPMediaItemPropertyPersistentID];
			//NSLog(@"Current PersistentID =%@", nowplayID);
			
			// set duration for slider
			NSNumber* duration=[currentItem valueForProperty: MPMediaItemPropertyPlaybackDuration];
			[m_slider_timeline setMaximumValue:[duration floatValue]];
			[m_slider_timeline setValue:0];
			
			nowplayIndex=1;
			NSArray* musicArray=[userMediaItemCollection items];
			for( NSUInteger loop=0; loop<[userMediaItemCollection count]; loop++ ){
				MPMediaItem* therec=[musicArray objectAtIndex:loop];
				NSNumber* thenumber=[therec valueForProperty: MPMediaItemPropertyPersistentID];
				if( [nowplayID compare:thenumber] == NSOrderedSame ){
					nowplayIndex=loop+1;
					//NSLog(@"PersistentID =%@ index=%d", thenumber, nowplayIndex);
					break;
				}
			}
			[m_label_musicIndex setText:[NSString stringWithFormat:@"%d / %d",nowplayIndex,[userMediaItemCollection count]]];
			m_loopinTime=m_loopoutTime=0;
			[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
			[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
			[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
			seekingbacknow=NO;
			seekingforwardnow=NO;
			loopingnow=NO;
			[m_label_loopintime setText:@"-- : -- : --"];
			[m_label_loopouttime setText:@"-- : -- : --"];
		}
	}
	
	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
		if( seekingbacknow==YES || seekingforwardnow==YES ){
			seekingbacknow=NO;
			seekingforwardnow=NO;
		}
		// Provide a suitable prompt to the user now that their chosen music has 
		//		finished playing.
		//		[nowPlayingLabel setText: [
		//								   NSString stringWithFormat: @"%@",
		//								   NSLocalizedString (@"Music-ended Instructions", @"Label for prompting user to play music again after it has stopped")]];
		
	}
    if( musicPlayer.playbackState == MPMusicPlaybackStatePlaying ){
        if( m_musicTableView!=nil ){
            [m_musicTableView updateMusicListView];
        }
    }
}



// When the playback state changes, set the play/pause button in the Navigation bar
//		appropriately.
- (void) handle_PlaybackStateChanged: (id) notification
{
	switch(musicPlayer.playbackState){
		case MPMusicPlaybackStateStopped: 
			NSLog(@"StateChanged MPMusicPlaybackStateStopped"); break;
		case MPMusicPlaybackStatePlaying: 
			NSLog(@"StateChanged MPMusicPlaybackStatePlaying"); break;
		case MPMusicPlaybackStatePaused: 
			NSLog(@"StateChanged MPMusicPlaybackStatePaused"); break;
		case MPMusicPlaybackStateInterrupted: 
			NSLog(@"StateChanged MPMusicPlaybackStateInterrupted"); break;
		case MPMusicPlaybackStateSeekingForward: 
			NSLog(@"StateChanged MPMusicPlaybackStateSeekingForward"); break;
		case MPMusicPlaybackStateSeekingBackward: 
			NSLog(@"StateChanged MPMusicPlaybackStateSeekingBackward"); break;
		default:
			NSLog(@"StateChanged unknown state"); break;
	}

	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
	if (playbackState == MPMusicPlaybackStatePaused) {
		
		[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[m_btn_playpause setImage:[UIImage imageNamed:@"imgbtn_play.png"] forState:UIControlStateNormal];
		
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		
		[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[m_btn_playpause setImage:[UIImage imageNamed:@"imgbtn_pause.png"] forState:UIControlStateNormal];
		
	} else if (playbackState == MPMusicPlaybackStateStopped) {
		
		[m_slider_timeline setValue:0];
		[m_label_loopintime setText:@"-- : -- : --"];
		[m_label_loopouttime setText:@"-- : -- : --"];
		[m_label_timeline setText:@"-- : --"];
		[m_label_timelineRemain setText:@"-- : --"];
		[m_label_musicIndex setText:@"- / -"];
		[m_btn_playpause setImage:[UIImage imageNamed:@"imgbtn_play.png"] forState:UIControlStateNormal];
		[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		UIImage *artworkImage = [UIImage imageNamed:@"no_artwork.png"];
		[m_imageView_artwork setImage:artworkImage];
		[m_label_titlename setText:@"---"]; 
		[m_label_albumname setText:@"---"];  
		[m_label_artistname setText:@"---"]; 
		
		// Even though stopped, invoking 'stop' ensures that the music player will play  
		//		its queue from the start.
		[musicPlayer stop];
		seekingbacknow=NO;
		seekingforwardnow=NO;
		loopingnow=NO;
        /*
		[NSTimer scheduledTimerWithTimeInterval: 0.05
										 target:self
									   selector:@selector(AfterStop:)
									   userInfo:nil
										repeats:NO];	
         */
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
}

-(bool)loadMusiclist
{
	// save to userdefaults 
	//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//	NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
	//	NSData *theData=[NSKeyedArchiver archivedDataWithRootObject:combinedMediaItems];
	//	[defaults setObject:theData forKey:@"last_music_collection"];
	
	BOOL isChanged=NO;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSData* lastMediaItemsData=[defaults dataForKey:@"last_music_collection"];
	if( lastMediaItemsData ){
		MPMediaItemCollection* lastMediaCollection=[NSKeyedUnarchiver unarchiveObjectWithData:lastMediaItemsData];
		if( lastMediaCollection ){
			@try {
				NSArray* mediaItems=(NSArray*)lastMediaCollection;
				NSMutableArray* existMediaItem=[NSMutableArray array];
				for( long loop=0; loop<[mediaItems count]; loop++ ){
					MPMediaItem* item=[mediaItems objectAtIndex:loop];
					if( [item valueForProperty:MPMediaItemPropertyTitle] ){
						// exist in ipod library
						[existMediaItem addObject:item];
					}
					else {
						// not exit in ipod library
						isChanged=YES;
					}
					///					NSLog(@"%@", [item valueForProperty:MPMediaItemPropertyTitle]);
				}
				if( [existMediaItem count]>0 ){
					[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems:(NSArray*)existMediaItem]];
					[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
					[musicPlayer play];
					[musicPlayer pause];
					[musicPlayer setCurrentPlaybackTime:0];
				}
				else {
					[self setUserMediaItemCollection:nil];
					[musicPlayer stop];
				}
			}
			@catch(...){
				NSLog(@"catch error. loading last_music_collection");
			}
		}
	}
	return isChanged;
}

-(void)timerHandleCheckMusicLibrary:(id)sender
{
	if( [self loadMusiclist] ){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iPod library changed.",nil)
														message:NSLocalizedString(@"Please confirm Music list.",nil)
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];		
	}
	[m_indicator stopAnimating];
}

-(void)timerHandleiPodLibraryChanged:(id)sender
{
	if( [self loadMusiclist] ){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iPod library changed.",nil)
														message:NSLocalizedString(@"Please quit and launch again gtTrainer.",nil)
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];		
	}
	[m_indicator stopAnimating];
}


- (void) handle_iPodLibraryChanged: (id) notification
{
//	NSLog(@"handle_iPodLibraryChanged");	
	// Implement this method to update cached collections of media items when the 
	// user performs a sync while your application is running. This sample performs 
	// no explicit media queries, so there is nothing to update.
	[m_indicator startAnimating];
	[NSTimer scheduledTimerWithTimeInterval: 0.1
									 target:self
								   selector:@selector(timerHandleiPodLibraryChanged:)
								   userInfo:nil
									repeats:NO];	
}

- (void) handle_VolumeChanged: (id) notification
{
	[m_slider_volume setValue:[musicPlayer volume]]; // MPVolumeView
	//AVAudioSession *aSession = [AVAudioSession sharedInstance];
	//[m_slider_volume setValue:aSession.outputVolume];

}

// To learn about notifications, see "Notifications" in Cocoa Fundamentals Guide.
- (void) registerForMediaPlayerNotifications
{
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_VolumeChanged:)
							   name: MPMusicPlayerControllerVolumeDidChangeNotification
							 object: musicPlayer];
	
	
	[notificationCenter addObserver: self
							selector: @selector (handle_iPodLibraryChanged:)
								name: MPMediaLibraryDidChangeNotification
							  object: mediaLibray];
	 
	[[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
	[musicPlayer beginGeneratingPlaybackNotifications];
}


- (void)OnBtnTimer:(id)sender
{
	if(m_loopinTime>=0 && m_loopoutTime>0 ){
		[m_btn_loop setEnabled:YES];	
		[m_btn_loop setImage:[UIImage imageNamed:@"imgbtn_loop.png"] forState:UIControlStateNormal];	
	}
	else {
		[m_btn_loop setEnabled:NO];	
		[m_btn_loop setImage:[UIImage imageNamed:@"imgbtn_loopng.png"] forState:UIControlStateDisabled];	
	}
	{
		MPMusicPlaybackState playbackState = [musicPlayer playbackState];
		if (playbackState == MPMusicPlaybackStatePlaying ) {
			[m_btn_forward setEnabled:YES];	
			[m_btn_rewind setEnabled:YES];	
			[m_btn_forward setImage:[UIImage imageNamed:@"imgbtn_ff.png"] forState:UIControlStateNormal];	
			[m_btn_rewind setImage:[UIImage imageNamed:@"imgbtn_fr.png"] forState:UIControlStateNormal];	
		}
		else if (playbackState == MPMusicPlaybackStateSeekingForward || playbackState == MPMusicPlaybackStateSeekingBackward  ) {
		}
		else {
			[m_btn_forward setEnabled:NO];	
			[m_btn_rewind setEnabled:NO];	
			[m_btn_forward setImage:[UIImage imageNamed:@"imgbtn_ffng.png"] forState:UIControlStateDisabled];	
			[m_btn_rewind setImage:[UIImage imageNamed:@"imgbtn_frng.png"] forState:UIControlStateDisabled];	
		}
		long itemCount=[userMediaItemCollection count];
		if( itemCount==0 ){
			[m_slider_timeline setValue:0];
			[m_label_loopintime setText:@"-- : -- : --"];
			[m_label_loopouttime setText:@"-- : -- : --"];
			[m_label_timeline setText:@"-- : --"];
			[m_label_timelineRemain setText:@"-- : --"];
			[m_label_musicIndex setText:@"- / -"];
			[m_btn_playpause setImage:[UIImage imageNamed:@"imgbtn_play.png"] forState:UIControlStateNormal];
			UIImage *artworkImage = [UIImage imageNamed:@"no_artwork.png"];
			[m_imageView_artwork setImage:artworkImage];
			[m_label_titlename setText:@"---"]; 
			[m_label_albumname setText:@"---"];  
			[m_label_artistname setText:@"---"]; 
		}
	}
}

- (void)OnTimer:(id)sender
{

	if( !m_openMusicList ){
		long itemCount=[userMediaItemCollection count];
		if( itemCount>0 ){
			MPMusicPlaybackState playbackState = [musicPlayer playbackState];
			if (playbackState == MPMusicPlaybackStatePlaying || playbackState ==MPMusicPlaybackStatePaused ||
				playbackState == MPMusicPlaybackStateSeekingForward || playbackState ==MPMusicPlaybackStateSeekingBackward ) {
				NSTimeInterval current=[musicPlayer currentPlaybackTime];
				long currentsec=(long)(current);
				long currentmin=(long)(current/60);
				long currentmsec=(long)((current-currentsec)*100);
				NSString* timestr=[NSString stringWithFormat:@"%02d:%02d",
								   (int)currentmin, (int)(currentsec%60) ];
				[m_label_timeline setText:timestr];
				NSTimeInterval remainTime=[m_slider_timeline maximumValue]-current;
				currentsec=(long)(remainTime);
				currentmin=(long)(remainTime/60);
				currentmsec=(long)((remainTime-currentsec)*100);
				NSString* timestrRemain=[NSString stringWithFormat:@"-%02d:%02d",
								   (int)currentmin, (int)(currentsec%60) ];
				[m_label_timelineRemain setText:timestrRemain];
				[m_slider_timeline setValue:current];

				// control loop play
				if( loopingnow && playbackState == MPMusicPlaybackStatePlaying ){
					if( current>m_loopoutTime ){
						[musicPlayer setCurrentPlaybackTime:m_loopinTime];
					}	
					if( current<m_loopinTime-1.0 ){
						[musicPlayer setCurrentPlaybackTime:m_loopinTime];
					}	
				}
				
				if( seekingforwardnow==YES ){
					// debug for seekbackward until currentPlaybackTime<0
					if( remainTime<4.0 ){
						//NSLog(@"force seekebd for backward 1st track.");
						seekingforwardnow=NO;
						[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
						[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
						[musicPlayer endSeeking];
						[musicPlayer pause];
						[musicPlayer setCurrentPlaybackTime:[m_slider_timeline maximumValue]];
					}
				}
				if( seekingbacknow==YES ){
					// debug for seekbackward until currentPlaybackTime<0
					if( current<4.0 ){
						//NSLog(@"force seekebd for backward 1st track.");
						seekingbacknow=NO;
						[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
						[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
						[musicPlayer endSeeking];
						[musicPlayer pause];
						[musicPlayer setCurrentPlaybackTime:0];
					}
				}
				
			}
		}
	}
	[NSTimer scheduledTimerWithTimeInterval: 0.5
									 target:self
								   selector:@selector(OnTimer:)
								   userInfo:nil
									repeats:NO];	
}

-(void)setInterrupt:(bool)isInterrupt
{
}

- (void) didEnterBackground 
{
	NSLog(@"didEnterBackground");
}
- (void) willEnterForeground 
{
	NSLog(@"willEnterForeground");
	[NSTimer scheduledTimerWithTimeInterval: 0.05
									 target:self
								   selector:@selector(AfterStop:)
								   userInfo:nil
									repeats:NO];	
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"outputVolume"]) {
        AVAudioSession *aSession = [AVAudioSession sharedInstance];
		[m_slider_volume setValue:aSession.outputVolume];
		
        //self.volumeLabel.text = [NSString stringWithFormat:@"%.1f",aSession.outputVolume];
    }
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    m_musicTableView=nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) 
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) 
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];	

	AVAudioSession *aSession = [AVAudioSession sharedInstance];
	[aSession addObserver:self
			   forKeyPath:@"outputVolume"
				  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
				  context:NULL];
	
    UIImage *thumbImage = [UIImage imageNamed:@"sliderthumb.png"];
	[m_slider_timeline setThumbImage:thumbImage forState:UIControlStateNormal];
	[m_slider_volume setThumbImage:thumbImage forState:UIControlStateNormal];
	
//  UIImage *thumbbackImage = [UIImage imageNamed:@"sliderback.png"];
//  [m_slider_timeline setMinimumTrackImage:thumbbackImage forState:UIControlStateNormal];
//  [m_slider_timeline setMaximumTrackImage:thumbbackImage forState:UIControlStateNormal];

/*
	UIImage *thumbImage = [UIImage imageNamed:@"sliderthumb.png"];
	[m_slider_timeline setThumbImage:thumbImage forState:UIControlStateNormal];
	[m_slider_volume setThumbImage:thumbImage forState:UIControlStateNormal];
	UIImage *thumbbackImage = [[UIImage imageNamed:@"sliderback.png"]
								stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	[m_slider_timeline setMinimumTrackImage:thumbbackImage forState:UIControlStateNormal];
	[m_slider_timeline setMaximumTrackImage:thumbbackImage forState:UIControlStateNormal];
	[m_slider_volume setMinimumTrackImage:thumbbackImage forState:UIControlStateNormal];
	[m_slider_volume setMaximumTrackImage:thumbbackImage forState:UIControlStateNormal];
*/	
	seekingbacknow=NO;
	seekingforwardnow=NO;
	m_loopinTime=m_loopoutTime=0;
	loopingnow=NO;
	m_openMusicList=NO;
	
	[self setMusicPlayer: [MPMusicPlayerController applicationMusicPlayer]];
	
	// By default, an application music player takes on the shuffle and repeat modes
	//		of the built-in iPod app. Here they are both turned off.
	[musicPlayer setShuffleMode: MPMusicShuffleModeOff];
	[musicPlayer setRepeatMode: MPMusicRepeatModeNone];

	//[m_slider_volume setValue:[musicPlayer volume]];
	[m_slider_volume setValue:aSession.outputVolume];

	[self registerForMediaPlayerNotifications];
	[musicPlayer beginGeneratingPlaybackNotifications];
	
	// ipod media library
	mediaLibray=[MPMediaLibrary defaultMediaLibrary]; 
	
//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//	m_isdisableAutoLockSleep=[defaults boolForKey:@"disableAutoLockSleep"];
//	[UIApplication sharedApplication].idleTimerDisabled = m_isdisableAutoLockSleep;
///	NSLog(@"viewDidLoad : isdisableAutoLockSleep %d", m_isdisableAutoLockSleep );
	
	
	[m_indicator startAnimating];
	[NSTimer scheduledTimerWithTimeInterval: 0.1
									 target:self
								   selector:@selector(timerHandleCheckMusicLibrary:)
								   userInfo:nil
									repeats:NO];	
	
	[NSTimer scheduledTimerWithTimeInterval: 0.05
									 target:self
								   selector:@selector(OnTimer:)
								   userInfo:nil
									repeats:NO];	
	
	[NSTimer scheduledTimerWithTimeInterval: 0.1
									 target:self
								   selector:@selector(OnBtnTimer:)
								   userInfo:nil
									repeats:YES];	
	
	
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

}


- (void)dealloc 
{

	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: musicPlayer];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];

	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMediaLibraryDidChangeNotification
												  object: mediaLibray];
	[userMediaItemCollection	release];
	[super dealloc];
}

#pragma mark Play control

-(IBAction)OnSliderPos:(id)sender
{
	if (userMediaItemCollection) {
		[musicPlayer setCurrentPlaybackTime:[m_slider_timeline value]];
		if( loopingnow && m_loopinTime>=0 && m_loopoutTime>0 ){
			NSTimeInterval pos=[m_slider_timeline value];
			if( pos+0.001<m_loopinTime || pos>m_loopoutTime+5.0 ){
				// exit loop play
				[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
				loopingnow=NO;
			}
		}
		if( !loopingnow && ([m_slider_timeline value]+1.0>[m_slider_timeline maximumValue]) ){
			MPMusicPlaybackState playbackState = [musicPlayer playbackState];
			if (playbackState == MPMusicPlaybackStatePlaying) {
				[self OnNextSong:nil];
			}
		}
	}
}
-(IBAction)OnSliderPosTouchBegin:(id)sender
{
	if (userMediaItemCollection) {
		MPMusicPlaybackState playbackState = [musicPlayer playbackState];
		if (playbackState == MPMusicPlaybackStatePlaying) {
//			[musicPlayer pause];
		}
	}
	
}

-(IBAction)OnSliderPosTouchEnd:(id)sender
{
/*	if (userMediaItemCollection) {
		MPMusicPlaybackState playbackState = [musicPlayer playbackState];
		if (playbackState == MPMusicPlaybackStatePlaying) {
			[musicPlayer play];
		}
	}
*/
}

-(IBAction)OnPlayOrPause:(id)sender
{
	if (userMediaItemCollection) {
		MPMusicPlaybackState playbackState = [musicPlayer playbackState];
		if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
			[musicPlayer play];
		} 
		else if (playbackState == MPMusicPlaybackStateSeekingForward || playbackState == MPMusicPlaybackStateSeekingBackward) {
			seekingbacknow=NO;
			seekingforwardnow=NO;
			[musicPlayer endSeeking];
		} 
		else if (playbackState == MPMusicPlaybackStatePlaying) {
			seekingbacknow=NO;
			seekingforwardnow=NO;
			[musicPlayer pause];
		}
	}	
}

-(void)AfterStop:(id)sender
{
    long itemCount=[userMediaItemCollection count];
    if( itemCount>0 ){
        [musicPlayer play];
        [musicPlayer pause];
        [musicPlayer setCurrentPlaybackTime:0];
    }
}

-(void)AfterStopNext:(id)sender
{
    seekingbacknow=NO;
    seekingforwardnow=NO;
    loopingnow=NO;
    [self setUserMediaItemCollection:nil];
    [musicPlayer stop];
    [self loadMusiclist];
    usleep(200);
    [NSTimer scheduledTimerWithTimeInterval: 0.2
                                     target:self
                                   selector:@selector(AfterStop:)
                                   userInfo:nil
                                    repeats:NO];
}

-(IBAction)OnStop:(id)sender
{
	seekingbacknow=NO;
	seekingforwardnow=NO;
	loopingnow=NO;
//    [self setUserMediaItemCollection:nil];
    [musicPlayer stop];
//    [self loadMusiclist];
    usleep(200);
	[NSTimer scheduledTimerWithTimeInterval: 0.2
									 target:self
								   selector:@selector(AfterStopNext:)
								   userInfo:nil
									repeats:NO];	
	
//	[musicPlayer setQueueWithItemCollection: nil];
//	[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
//	[musicPlayer play];
//	[musicPlayer pause];
//	[musicPlayer setCurrentPlaybackTime:0];
	
}

-(IBAction)OnSliderVolume:(id)sender
{
	musicPlayer.volume=[m_slider_volume value];
	//AVAudioSession *aSession = [AVAudioSession sharedInstance];
	//aSession.outputVolume=[m_slider_volume value];

}

/*
-(IBAction)OnTempoUp:(id)sender
{
	
}
-(IBAction)OnTempoDown:(id)sender
{
	
}
-(IBAction)OnPitchUp:(id)sender
{
	
}
-(IBAction)OnPitchDown:(id)sender
{
	
}
*/

-(IBAction)OnLoop:(id)sender
{
	if( loopingnow ){
		loopingnow=NO;
		[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];	
	}
	else {
		if(m_loopinTime>=0 && m_loopoutTime>0 ){
			[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_backpushed.png"] forState:UIControlStateNormal];
			loopingnow=YES;
			[musicPlayer setCurrentPlaybackTime:m_loopinTime];
		}
	}
}


-(IBAction)OnLoopIN:(id)sender
{
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	if (playbackState == MPMusicPlaybackStatePlaying || playbackState == MPMusicPlaybackStatePaused ) {
		NSTimeInterval current=[musicPlayer currentPlaybackTime];
		m_loopinTime=current+0.001;
		long currentsec=(long)(current);
		long currentmin=(long)(current/60);
		long currentmsec=(long)((current-currentsec)*100);
		NSString* timestr=[NSString stringWithFormat:@"%02d:%02d:%02d",
						   (int)(currentmin), (int)(currentsec%60), (int)currentmsec ];
		[m_label_loopintime setText:timestr];
		if( m_loopinTime>m_loopoutTime ){
			[m_label_loopouttime setText:@"-- : -- : --"];
			m_loopoutTime=0;
			loopingnow=NO;
		}
		if( m_loopinTime>=0.001 && m_loopoutTime>0 ){
			[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_backpushed.png"] forState:UIControlStateNormal];
			loopingnow=YES;
		}
	}
}


-(IBAction)OnLoopOUT:(id)sender
{
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	if (playbackState == MPMusicPlaybackStatePlaying || playbackState == MPMusicPlaybackStatePaused ) {
		NSTimeInterval current=[musicPlayer currentPlaybackTime];
		if( current+5.0 > [m_slider_timeline maximumValue] ){
			current=[m_slider_timeline maximumValue]-5.0;
		}
		m_loopoutTime=current;
		long currentsec=(long)(current);
		long currentmin=(long)(current/60);
		long currentmsec=(long)((current-currentsec)*100);
		NSString* timestr=[NSString stringWithFormat:@"%02d:%02d:%02d",
						   (int)(currentmin), (int)(currentsec%60), (int)currentmsec ];
		[m_label_loopouttime setText:timestr];
		if( m_loopinTime>m_loopoutTime ){
			[m_label_loopintime setText:@"-- : -- : --"];
			m_loopinTime=0;
			loopingnow=NO;
		}
		if(m_loopinTime>=0.001 && m_loopoutTime>0 ){
			[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_backpushed.png"] forState:UIControlStateNormal];
			loopingnow=YES;
		}
	}
}



-(IBAction)OnPreviosSong:(id)sender
{
	if( seekingbacknow || seekingforwardnow ){
		seekingbacknow=NO;
		seekingforwardnow=NO;
		[musicPlayer endSeeking];
		[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
	}
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	if (playbackState == MPMusicPlaybackStatePlaying ) {
		if( seekingbacknow || seekingforwardnow ){
			[musicPlayer endSeeking];
		}
		// if play intro 3 sec then back to rewind the song
		NSTimeInterval current=[musicPlayer currentPlaybackTime];
		if( current>3.0 || nowplayIndex==1 ){
			[musicPlayer setCurrentPlaybackTime:0];
		}
		else {
			[musicPlayer skipToPreviousItem];
		}
		loopingnow=NO;
		[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
	}
	else {
		if( nowplayIndex>1 ){
			loopingnow=NO;
			[musicPlayer skipToPreviousItem];
		}
		else {
			[musicPlayer setCurrentPlaybackTime:0];
			loopingnow=NO;
			[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		}
	}
}


-(IBAction)OnNextSong:(id)sender
{
	if( seekingbacknow || seekingforwardnow ){
		seekingbacknow=NO;
		seekingforwardnow=NO;
		[musicPlayer endSeeking];
		[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
	}
	if( nowplayIndex<[userMediaItemCollection count] ){
		loopingnow=NO;
		[musicPlayer skipToNextItem];
		[m_btn_loop setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
	}
}


-(IBAction)OnForward:(id)sender
{
//	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
//	if (playbackState != MPMusicPlaybackStatePlaying) {
//		return;
//	}
	if( seekingbacknow==YES ){
		seekingbacknow=NO;
		[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[musicPlayer endSeeking];
	}
	if( seekingforwardnow==YES ){
		seekingforwardnow=NO;
		[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[musicPlayer endSeeking];
	}
	else {
		seekingforwardnow=YES;
		[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_backpushed.png"] forState:UIControlStateNormal];
		[musicPlayer beginSeekingForward];
	}
}


-(IBAction)OnRewind:(id)sender
{
//	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
//	if (playbackState != MPMusicPlaybackStatePlaying) {
//		return;
//	}
	if( seekingforwardnow==YES ){
		seekingforwardnow=NO;
		[m_btn_forward setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[musicPlayer endSeeking];
	}
	if( seekingbacknow==YES ){
		seekingbacknow=NO;
		[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_back.png"] forState:UIControlStateNormal];
		[musicPlayer endSeeking];
	}
	else {
		seekingbacknow=YES;
		[m_btn_rewind setBackgroundImage:[UIImage imageNamed:@"imgbtn_backpushed.png"] forState:UIControlStateNormal];
		[musicPlayer beginSeekingBackward];
	}
}




@end
