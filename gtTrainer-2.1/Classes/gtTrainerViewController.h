//
//  gtTrainerViewController.h
//  gtTrainer
//
//  Created by Masanori Kanda on 09/07/24.
//  Copyright com.mkanda 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicTableViewController.h"
#import "InfoViewController.h"

@interface gtTrainerViewController : UIViewController<AVAudioPlayerDelegate,MPMediaPickerControllerDelegate,MusicTableViewControllerDelegate,InfoViewControllerDelegate>
{
	IBOutlet UIImageView*	m_imageView_artwork;
//	IBOutlet UIButton*	m_btn_tempoUp;
//	IBOutlet UIButton*	m_btn_tempoDown;
//	IBOutlet UITextField* m_text_tempo;
	
//	IBOutlet UIButton*	m_btn_pitchUp;
//	IBOutlet UIButton*	m_btn_pitchDown;
//	IBOutlet UITextField* m_text_pitch;
	
	IBOutlet UIActivityIndicatorView*	m_indicator;

	IBOutlet UISlider*	m_slider_volume;
	
	IBOutlet UISlider*	m_slider_timeline;
	IBOutlet UILabel*	m_label_artistname;
	IBOutlet UILabel*	m_label_albumname;
	IBOutlet UILabel*	m_label_titlename;
	IBOutlet UILabel*	m_label_timeline;
	IBOutlet UILabel*	m_label_timelineRemain;
	
	IBOutlet UILabel*	m_label_loopintime;
	IBOutlet UILabel*	m_label_musicIndex;
	IBOutlet UILabel*	m_label_loopouttime;

	
	IBOutlet UIButton*	m_btn_loop;
	IBOutlet UIButton*	m_btn_loopIn;
	IBOutlet UIButton*	m_btn_loopOut;
	
	IBOutlet UIButton*	m_btn_begin;
	IBOutlet UIButton*	m_btn_end;
	IBOutlet UIButton*	m_btn_forward;
	IBOutlet UIButton*	m_btn_rewind;
	IBOutlet UIButton*	m_btn_playpause;
	IBOutlet UIButton*	m_btn_stop;

	MPMusicPlayerController*	musicPlayer;	
	MPMediaItemCollection*		userMediaItemCollection;
	MPMediaLibrary*				mediaLibray;
	
	NSInteger					nowplayIndex;
	NSNumber*					nowplayID;
	BOOL						seekingbacknow;
	BOOL						seekingforwardnow;
	
	NSTimeInterval				m_loopinTime;
	NSTimeInterval				m_loopoutTime;
	BOOL						loopingnow;
	
	BOOL						m_openMusicList;

    MusicTableViewController*   m_musicTableView;
	// TODO for 3.1
//	BOOL						m_isdisableAutoLockSleep;
}

@property (nonatomic, retain)	MPMediaItemCollection*		userMediaItemCollection; 
@property (nonatomic, retain)	MPMusicPlayerController*	musicPlayer;

-(IBAction)OnInformation:(id)sender;
-(IBAction)OnMusicList:(id)sender;
/*
-(IBAction)OnTempoUp:(id)sender;
-(IBAction)OnTempoDown:(id)sender;
-(IBAction)OnPitchUp:(id)sender;
-(IBAction)OnPitchDown:(id)sender;
*/
-(IBAction)OnLoop:(id)sender;
-(IBAction)OnLoopIN:(id)sender;
-(IBAction)OnLoopOUT:(id)sender;

-(IBAction)OnPreviosSong:(id)sender;
-(IBAction)OnNextSong:(id)sender;
-(IBAction)OnForward:(id)sender;
-(IBAction)OnRewind:(id)sender;

-(IBAction)OnPlayOrPause:(id)sender;
-(IBAction)OnStop:(id)sender;

-(IBAction)OnSliderPos:(id)sender;
-(IBAction)OnSliderPosTouchBegin:(id)sender;
-(IBAction)OnSliderPosTouchEnd:(id)sender;

-(IBAction)OnSliderVolume:(id)sender;

-(void)setInterrupt:(bool)isInterrupt;

-(void)setMusicView:(MusicTableViewController*)musicView;

@end

