
#import <MediaPlayer/MediaPlayer.h>

#import "CellView.h"

@interface thumbnailInfoRec : NSObject 
{
	UITableViewCell*	targetCell;
	NSIndexPath*		infoindex;
}
@property (nonatomic, retain)	UITableViewCell*	targetCell; 
@property (nonatomic, retain)	NSIndexPath*		infoindex; 
@end

@protocol MusicTableViewControllerDelegate; // forward declaration


@interface MusicTableViewController : UIViewController <MPMediaPickerControllerDelegate, UITableViewDelegate,UIActionSheetDelegate> {
	
	id <MusicTableViewControllerDelegate>	delegate;
	IBOutlet UITableView*					mediaItemCollectionTable;
	IBOutlet UIBarButtonItem*				addMusicButton;
	IBOutlet UIBarButtonItem*				doneMusicButton;
	
	IBOutlet UIToolbar*						m_toolbar;
	IBOutlet UIBarButtonItem*				editButton;
	IBOutlet UIBarButtonItem*				deleteAllButton;
	
	NSOperationQueue*						operationQueue;
}

@property (nonatomic, assign) id <MusicTableViewControllerDelegate>	delegate;
@property (nonatomic, retain) UITableView							*mediaItemCollectionTable;
@property (nonatomic, retain) UIBarButtonItem						*addMusicButton;

- (IBAction) showMediaPicker: (id) sender;
- (IBAction) doneShowingMusicList: (id) sender;

- (IBAction) OnEditTableItem: (id) sender;
- (IBAction) OnDeleteAllItem: (id) sender;
- (void) updateMusicListView;

@end



@protocol MusicTableViewControllerDelegate

// implemented in MainViewController.m
- (void) musicTableViewControllerDidFinish: (MusicTableViewController *) controller;
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;
- (void) removePlayerQueueWithIndex: (NSUInteger)index;
- (void) removePlayerQueueAll;
- (void) swapPlayerQueueWithIndex: (NSUInteger)fromindex toIndex:(NSUInteger)toindex ;
- (void) changePlayItem: (NSUInteger)index table:(UITableView*)tableView;

@end
