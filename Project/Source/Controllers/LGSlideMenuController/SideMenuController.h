//
//  SideMenuController.h
//  iTransmission
//
//  Created by Beecher Adams on 5/2/17.
//
//

#import <UIKit/UIKit.h>
#import <LGSideMenuController/LGSideMenuController.h>
#import <LGSideMenuController/UIViewController+LGSideMenuController.h>

@class Controller;
@class TorrentViewController;

@interface SideMenuController : LGSideMenuController

- (void)setTransmission:(Controller *)transmission torrentView:(TorrentViewController *)torrentView;

@end
