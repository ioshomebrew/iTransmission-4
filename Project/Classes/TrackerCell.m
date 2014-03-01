//
//  TrackerCell.m
//  iTransmission
//
//  Created by Dhruvit Raithatha on 02/12/13.
//
//

#import "TrackerCell.h"

@implementation TrackerCell

@synthesize TrackerLastAnnounceTime = fTime;
@synthesize TrackerURL = fURL;
@synthesize SeedNumber = fSeedNumber;
@synthesize SeedLabel = fSeedLabel;
@synthesize PeerNumber = fPeerNumber;
@synthesize PeerLabel = fPeerLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) {
        self.TrackerURL.textColor = [UIColor blackColor];
    } else {
        self.TrackerURL.textColor = [UIColor blackColor];
    }
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.TrackerURL.textColor = [UIColor blackColor];
    }
    else {
        self.TrackerURL.textColor =[UIColor blackColor] ;
    }
}

+ (id)cellFromNib
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TrackerCell" owner:nil options:nil];
    TrackerCell *cell = (TrackerCell*)[objects objectAtIndex:0];
    
    return cell;
}

@end
