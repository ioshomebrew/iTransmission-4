//
//  LeftMenuController.h
//  iTransmission
//
//  Created by Beecher Adams on 5/2/17.
//
//

#import <UIKit/UIKit.h>
#import "LeftMenuCell.h"
#import "WebViewController.h"
#import "Controller.h"
#import "SideMenuController.h"
#import "PrefViewController.h"
#import "TorrentViewController.h"

@interface LeftMenuController : UITableViewController

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) Controller *transmission;
@property (nonatomic, strong) WebViewController *web;
@property (nonatomic, strong) SideMenuController *torrentView;
@property (nonatomic, strong) TorrentViewController *transmissionView;
@property (nonatomic, strong) PrefViewController *prefView;

- (void)setData:(Controller *)trans transView:(TorrentViewController *)transView;

@end
