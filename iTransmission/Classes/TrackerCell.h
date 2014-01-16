//
//  TrackerCell.h
//  iTransmission
//
//  Created by Dhruvit Raithatha on 02/12/13.
//
//

#import <UIKit/UIKit.h>

@interface TrackerCell : UITableViewCell {
    UILabel *fURL;
    UILabel *fTime;
    UILabel *fTimeLabel;
    UILabel *fSeedLabel;
    UILabel *fSeedNumber;
    UILabel *fPeerLabel;
    UILabel *fPeerNumber;
}

+ (id)cellFromNib;

@property (nonatomic, retain) IBOutlet UILabel *TrackerURL;
@property (nonatomic, retain) IBOutlet UILabel *TrackerLastAnnounceTime;
@property (nonatomic, retain) IBOutlet UILabel *SeedLabel;
@property (nonatomic, retain) IBOutlet UILabel *SeedNumber;
@property (nonatomic, retain) IBOutlet UILabel *PeerLabel;
@property (nonatomic, retain) IBOutlet UILabel *PeerNumber;

@end
