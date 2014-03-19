//
//  DiscoveredTorrentCell.h
//  iTransmission
//
//  Created by Mike Chen on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DiscoveredTorrentCell : UITableViewCell {
    UILabel *fFilenameLabel;
    UILabel *fDirectoryLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *filenameLabel;
@property (nonatomic, retain) IBOutlet UILabel *directoryLabel;

+ (id)cellFromNib;

@end
