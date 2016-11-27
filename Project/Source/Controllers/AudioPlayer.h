//
//  AudioPlayer.h
//  iTransmission
//
//  Created by Beecher Adams on 7/31/16.
//
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "Torrent.h"
#import "FileListNode.h"

@interface AudioPlayer : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic, retain) IBOutlet MPVolumeView *volume;
@property (strong, nonatomic) AVAudioPlayer *audio;
@property (nonatomic, retain) IBOutlet UIButton *pause;
@property (nonatomic, retain) IBOutlet UILabel *stitle;
@property (nonatomic, retain) IBOutlet UILabel *artist;
@property (nonatomic, retain) IBOutlet UILabel *album;
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) NSMutableArray *queue;
@property (nonatomic, retain) Torrent *torrent;
@property (nonatomic, assign) NSInteger currentItem;
@property (nonatomic, assign) NSInteger lastItem;
@property (nonatomic, retain) IBOutlet UISlider *progress;
@property (nonatomic, retain) IBOutlet UILabel *currentTime;
@property (nonatomic, retain) IBOutlet UILabel *duration;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, assign) double newTime;
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil file:(NSString*)url torrent:(Torrent*)t;
- (IBAction)pauseClicked:(id)sender;
- (IBAction)nextClicked:(id)sender;
- (IBAction)prevClicked:(id)sender;
- (IBAction)sliderChanged:(UISlider*)sender;
- (NSString*)time:(NSTimeInterval)t;

@end
