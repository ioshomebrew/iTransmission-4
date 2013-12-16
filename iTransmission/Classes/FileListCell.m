//
//  FileListCell.m
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileListCell.h"

@implementation FileListCell
@synthesize filenameLabel = fFilenameLabel;
@synthesize sizeLabel = fSizeLabel;
@synthesize progressLabel = fProgressLabel;
@synthesize checkbox = fCheckbox;

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
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.filenameLabel.textColor = [UIColor whiteColor];
        self.progressLabel.textColor = [UIColor whiteColor];
        self.sizeLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.filenameLabel.textColor = [UIColor blackColor];
        self.progressLabel.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.6f alpha:1.0f];
        self.sizeLabel.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.6f alpha:1.0f];
    }

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.filenameLabel.textColor = [UIColor whiteColor];
        self.progressLabel.textColor = [UIColor whiteColor];
        self.sizeLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.filenameLabel.textColor = [UIColor blackColor];
        self.progressLabel.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.6f alpha:1.0f];
        self.sizeLabel.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.6f alpha:1.0f];
    }
}

+ (id)cellFromNib
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"FileListCell" owner:nil options:nil];
    FileListCell *cell = (FileListCell*)[objects objectAtIndex:0];
        
    return cell;
}

- (void)dealloc {
    self.filenameLabel = nil;
    self.sizeLabel = nil;
    self.progressLabel = nil;
    self.checkbox = nil;
    [super dealloc];
}

@end
