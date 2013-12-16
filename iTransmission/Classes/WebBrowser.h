//
//  WebBrowser.h
//  iTransmission
//
//  Created by Lion User on 29/01/2013.
//
//

#import <UIKit/UIKit.h>
#import "Controller.h"

@interface WebBrowser : UIViewController

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UINavigationItem *webTitle;
@property (retain, nonatomic) IBOutlet UITextField *urlbar;
@property (retain, nonatomic) NSString *magnet;
@property (retain, nonatomic) NSString *torrent;
@property (retain, nonatomic) UINavigationController *controller;
@property (retain, nonatomic) Controller *libtransmission;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil navigigationController:(UINavigationController*)navigationController controller:(Controller *)transmission;
- (IBAction)go:(id)sender;

@end
