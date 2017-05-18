//
//  WebViewController.h
//  iTransmission
//
//  Created by Beecher Adams on 4/25/17.
//
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AdColony/AdColony.h>
#import "Controller.h"
#import "SideMenuController.h"

@interface WebViewController : UIViewController <UIWebViewDelegate>

//- (id)initWithAddress:(NSString *)nibName bundle:(NSBundle *)bun urlString:(NSString *)url controller:(Controller *)libtransmission navigationController:(UINavigationController *)nav;
- (void)setData:(NSString *)url controller:(Controller *)libtransmission;

// web view
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *currentURL;

// disappering toolbar
@property (nonatomic, strong) IBOutlet UITextField *URLTextfield;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *back;

// ads
@property (nonatomic, strong) IBOutlet GADBannerView *bannerView;

// lib transmission
@property (nonatomic, strong) UINavigationController *controller;
@property (nonatomic, strong) Controller *transmission;

@property (nonatomic, strong) TorrentViewController *torrentView;
@property (nonatomic, strong) SideMenuController *sideMenu;

- (void)loadURL:(NSURL*)URL;

- (IBAction) goBackClicked:(UIBarButtonItem *)sender;
- (IBAction) closeClicked:(UIBarButtonItem *)sender;

@end
