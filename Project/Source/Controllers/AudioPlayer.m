//
//  AudioPlayer.m
//  iTransmission
//
//  Created by Beecher Adams on 7/31/16.
//
//

#import "AudioPlayer.h"

@interface AudioPlayer ()

@end

@implementation AudioPlayer
@synthesize volume;
@synthesize audio;
@synthesize pause;
@synthesize stitle;
@synthesize album;
@synthesize artist;
@synthesize image;
@synthesize torrent;
@synthesize queue;
@synthesize currentItem;
@synthesize lastItem;
@synthesize progress;
@synthesize currentTime;
@synthesize duration;
@synthesize updateTimer;
@synthesize newTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil file:(NSString*)url torrent:(Torrent *)t
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
        
        // assign torrent
        self.torrent = t;
        
        // play audio
        NSURL *audioURL = [NSURL fileURLWithPath:url];
        NSError *error;
        self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
        NSLog(@"Audio error: %@", error.localizedDescription);
        self.audio.numberOfLoops = 0;
        [self.audio setVolume:1.0];
        [self.audio setDelegate:self];
        [self.audio prepareToPlay];
        [self.audio play];
        
        // create queue
        NSArray *audioTypes = [NSArray arrayWithObjects:@"mp3", @"aac", @"adts", @"ac3", @"aif", @"aiff", @"aifc", @"caf", @"m4a", @"snd", @"au", @"sd2", @"wav", nil];
        self.queue = [[NSMutableArray alloc] init];
        for(int i = 0; i < [[self.torrent flatFileList] count]; i++)
        {
            FileListNode *node = [[self.torrent flatFileList] objectAtIndex:i];
            NSString *file = [[[(Controller *)[UIApplication sharedApplication].delegate defaultDownloadDir] stringByAppendingPathComponent:[node path]] stringByAppendingPathComponent:[node name]];
            NSString *extension = [file pathExtension];
            for(int j = 0; j < [audioTypes count]; j++)
            {
                if([audioTypes[j] compare:extension options:NSCaseInsensitiveSearch] == NSOrderedSame)
                {
                    // add to queue
                    [self.queue addObject:file];
                }
            }
        }
        
        // set current queue item
        for(int i = 0; i < [self.queue count]; i++)
        {
            if([self.queue[i] compare:url options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                self.currentItem = i;
                break;
            }
        }
        self.lastItem = [[self.torrent flatFileList] count];
        
        NSLog(@"Current queue item: %i", self.currentItem);
        NSLog(@"Last item is: %i", self.lastItem);
    }
    
    return self;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type == UIEventTypeRemoteControl){
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                if([self.audio isPlaying])
                {
                    [self.pause setTitle:@"Play" forState:UIControlStateNormal];
                    [self.audio pause];
                }
                else
                {
                    [self.pause setTitle:@"Pause" forState:UIControlStateNormal];
                    [self.audio play];
                }
            }
            break;
                
            case UIEventSubtypeRemoteControlNextTrack:
            {
                [self nextClicked:nil];

            }
            break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                [self prevClicked:nil];
            }
            break;
                
            case UIEventSubtypeRemoteControlBeginSeekingForward:
            {
                self.newTime = self.audio.currentTime;
                self.newTime += 5;
            }
            break;
                
            case UIEventSubtypeRemoteControlEndSeekingForward:
            {
                self.audio.currentTime = self.newTime;
            }
            break;
                
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
            {
                self.newTime = self.audio.currentTime;
                self.newTime -= 5;
            }
            break;
            
            case UIEventSubtypeRemoteControlEndSeekingBackward:
            {
                self.audio.currentTime = self.newTime;
            }
            break;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Audio Player (beta)";
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked)];
    [self.navigationItem setRightBarButtonItem:closeButton];
    
    // init admob
    self.bannerView.adUnitID = @"ca-app-pub-5972525945446192/5283882861";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ kGADSimulatorID ];
    [self.bannerView loadRequest:request];
    
    // init mpvolumeview
    [[self volume] setBackgroundColor:[UIColor clearColor]];
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame:[[self volume] bounds]];
    [self.volume addSubview:myVolumeView];
    
    // get metadata
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.audio.url options:nil];
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    
    for (NSString *format in [asset availableMetadataFormats])
    {
        for (AVMetadataItem *metadataItem in [asset metadataForFormat:format])
        {
            if ([metadataItem.commonKey isEqualToString:@"artwork"])
            {
                //UIImage* songImage = [UIImage imageWithData:[(NSDictionary*)metadataItem.value objectForKey:@"data"]];
                //MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:songImage];
                //[self.image setImage:songImage];
                //[songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            }
            else if ([metadataItem.commonKey isEqualToString:@"title"])
            {
                self.stitle.text = [metadataItem.value description];
                NSLog(@"Title is: %@", [metadataItem.value description]);
                [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyTitle];
            }
            else if ([metadataItem.commonKey isEqualToString:@"albumName"])
            {
                [self.album setText:[metadataItem.value description]];
                NSLog(@"Album is: %@", [metadataItem.value description]);
                [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyAlbumTitle];
            }
            else if ([metadataItem.commonKey isEqualToString:@"artist"])
            {
                [self.artist setText:[metadataItem.value description]];
                NSLog(@"Artist is: %@", [metadataItem.value description]);
                [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyArtist];
            }
        }
    }
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    
    // set duration and current time
    self.duration.text = [self time:self.audio.duration];
    self.currentTime.text = [self time:0.0];
    
    // init progress view
    [self.progress setValue:0.0];
    
    // init timer
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [self updateUI];
}

- (void)updateUI
{
    double percent;
    if([self.audio isPlaying])
    {
        // update progress bar
        percent = (self.audio.duration - self.audio.currentTime)/self.audio.duration;
        
        // reverse percent
        percent = 1.0 - percent;
        
        [self.progress setValue:percent];
        
        // update current time
        self.currentTime.text = [self time:self.audio.currentTime];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneClicked
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    [self.audio stop];
    
    // continue background downloading audio
    NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];
    if([fDefaults boolForKey:@"BackgroundDownloading"])
    {
        NSNumber *value = [NSNumber numberWithBool:TRUE];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioPrefChanged" object:value];
    }
}

- (IBAction)pauseClicked:(id)sender
{
    if([self.audio isPlaying])
    {
        [self.pause setTitle:@"Play" forState:UIControlStateNormal];
        [self.audio pause];
    }
    else
    {
        [self.pause setTitle:@"Pause" forState:UIControlStateNormal];
        [self.audio play];
    }
}

- (IBAction)prevClicked:(id)sender
{
    // restart track
    NSLog(@"currentTime: %f", self.audio.currentTime);
    if(self.audio.currentTime >= 3.0)
    {
        // restart track
        self.audio.currentTime = 0.0;
        [self.audio play];
    }
    else
    {
        NSLog(@"Prev track");
        if(self.currentItem > 0)
        {
            // go to previous item
            self.currentItem--;
            FileListNode *node = [[self.torrent flatFileList] objectAtIndex:self.currentItem];
            NSString *file = [[[(Controller *)[UIApplication sharedApplication].delegate defaultDownloadDir] stringByAppendingPathComponent:[node path]] stringByAppendingPathComponent:[node name]];
            NSLog(@"Next file is: %@", file);
            NSURL *audioURL = [NSURL fileURLWithPath:file];
            NSError *error;
            self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
            NSLog(@"Audio error: %@", error.localizedDescription);
            self.audio.numberOfLoops = 0;
            [self.audio setVolume:1.0];
            [self.audio setDelegate:self];
            [self.audio prepareToPlay];
            [self.audio play];
            
            // get metadata
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.audio.url options:nil];
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            
            for (NSString *format in [asset availableMetadataFormats])
            {
                for (AVMetadataItem *metadataItem in [asset metadataForFormat:format])
                {
                    if ([metadataItem.commonKey isEqualToString:@"artwork"])
                    {
                        UIImage* songImage = [UIImage imageWithData:[(NSDictionary*)metadataItem.value objectForKey:@"data"]];
                        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:songImage];
                        [self.image setImage:songImage];
                        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                    }
                    else if ([metadataItem.commonKey isEqualToString:@"title"])
                    {
                        self.stitle.text = [metadataItem.value description];
                        NSLog(@"Title is: %@", [metadataItem.value description]);
                        [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyTitle];
                    }
                    else if ([metadataItem.commonKey isEqualToString:@"albumName"])
                    {
                        [self.album setText:[metadataItem.value description]];
                        NSLog(@"Album is: %@", [metadataItem.value description]);
                        [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyAlbumTitle];
                    }
                    else if ([metadataItem.commonKey isEqualToString:@"artist"])
                    {
                        [self.artist setText:[metadataItem.value description]];
                        NSLog(@"Artist is: %@", [metadataItem.value description]);
                        [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyArtist];
                    }
                }
            }
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
        else
        {
            // restart track
            self.audio.currentTime = 0.0;
            [self.audio play];
        }
    }
}

- (IBAction)nextClicked:(id)sender
{
    NSLog(@"Next track");
    if(self.currentItem < self.lastItem)
    {
        // go to next item
        self.currentItem++;
        FileListNode *node = [[self.torrent flatFileList] objectAtIndex:self.currentItem];
        NSString *file = [[[(Controller *)[UIApplication sharedApplication].delegate defaultDownloadDir] stringByAppendingPathComponent:[node path]] stringByAppendingPathComponent:[node name]];
        NSLog(@"Next file is: %@", file);
        NSURL *audioURL = [NSURL fileURLWithPath:file];
        NSError *error;
        self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
        NSLog(@"Audio error: %@", error.localizedDescription);
        self.audio.numberOfLoops = 0;
        [self.audio setVolume:1.0];
        [self.audio setDelegate:self];
        [self.audio prepareToPlay];
        [self.audio play];
        
        // get metadata
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.audio.url options:nil];
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        for (NSString *format in [asset availableMetadataFormats])
        {
            for (AVMetadataItem *metadataItem in [asset metadataForFormat:format])
            {
                if ([metadataItem.commonKey isEqualToString:@"artwork"])
                {
                    UIImage* songImage = [UIImage imageWithData:[(NSDictionary*)metadataItem.value objectForKey:@"data"]];
                    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:songImage];
                    [self.image setImage:songImage];
                    [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                }
                else if ([metadataItem.commonKey isEqualToString:@"title"])
                {
                    self.stitle.text = [metadataItem.value description];
                    NSLog(@"Title is: %@", [metadataItem.value description]);
                    [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyTitle];
                }
                else if ([metadataItem.commonKey isEqualToString:@"albumName"])
                {
                    [self.album setText:[metadataItem.value description]];
                    NSLog(@"Album is: %@", [metadataItem.value description]);
                    [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyAlbumTitle];
                }
                else if ([metadataItem.commonKey isEqualToString:@"artist"])
                {
                    [self.artist setText:[metadataItem.value description]];
                    NSLog(@"Artist is: %@", [metadataItem.value description]);
                    [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyArtist];
                }
            }
        }
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
    else
    {
        // go to first item
        self.currentItem = 0;
        FileListNode *node = [[self.torrent flatFileList] objectAtIndex:self.currentItem];
        NSString *file = [[[(Controller *)[UIApplication sharedApplication].delegate defaultDownloadDir] stringByAppendingPathComponent:[node path]] stringByAppendingPathComponent:[node name]];
        NSLog(@"Next file is: %@", file);
        NSURL *audioURL = [NSURL fileURLWithPath:file];
        NSError *error;
        self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
        NSLog(@"Audio error: %@", error.localizedDescription);
        self.audio.numberOfLoops = 0;
        [self.audio setVolume:1.0];
        [self.audio setDelegate:self];
        [self.audio prepareToPlay];
        [self.audio play];
        
        // get metadata
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.audio.url options:nil];
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        for (NSString *format in [asset availableMetadataFormats])
        {
            for (AVMetadataItem *metadataItem in [asset metadataForFormat:format])
            {
                if ([metadataItem.commonKey isEqualToString:@"artwork"])
                {
                    UIImage* songImage = [UIImage imageWithData:[(NSDictionary*)metadataItem.value objectForKey:@"data"]];
                    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:songImage];
                    [self.image setImage:songImage];
                    [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                }
                else if ([metadataItem.commonKey isEqualToString:@"title"])
                {
                    self.stitle.text = [metadataItem.value description];
                    NSLog(@"Title is: %@", [metadataItem.value description]);
                    [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyTitle];
                }
                else if ([metadataItem.commonKey isEqualToString:@"albumName"])
                {
                    [self.album setText:[metadataItem.value description]];
                    NSLog(@"Album is: %@", [metadataItem.value description]);
                    [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyAlbumTitle];
                }
                else if ([metadataItem.commonKey isEqualToString:@"artist"])
                {
                    [self.artist setText:[metadataItem.value description]];
                    NSLog(@"Artist is: %@", [metadataItem.value description]);
                    [songInfo setObject:metadataItem.value forKey:MPMediaItemPropertyArtist];
                }
            }
        }
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

- (IBAction)sliderChanged:(UISlider*)sender
{
    // update progress bar
    double percent = sender.value;
    double newTime1 = percent * self.audio.duration;

    self.audio.currentTime = newTime1;
}

- (NSString*)time:(NSTimeInterval)t
{
    NSString *result;
    NSInteger minutes = t / 60.0;
    NSInteger seconds = fmod(t, 60.0);
    
    if(seconds < 10)
    {
        result = [[NSString alloc] initWithFormat:@"%i:0%i", minutes, seconds];
    }
    else
    {
        result = [[NSString alloc] initWithFormat:@"%i:%i", minutes, seconds];
    }
    
    return result;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    // go to next track
    [self nextClicked:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
