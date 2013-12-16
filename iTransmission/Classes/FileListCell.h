//
//  FileListCell.h
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckboxControl.h"

@interface FileListCell : UITableViewCell
{
    UILabel *fFilenameLabel;
    UILabel *fSizeLabel;
    UILabel *fProgressLabel;
    CheckboxControl *fCheckbox;
}
@property (nonatomic, retain) IBOutlet UILabel* filenameLabel;
@property (nonatomic, retain) IBOutlet UILabel* sizeLabel;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet CheckboxControl *checkbox;

+ (id)cellFromNib;

@end
