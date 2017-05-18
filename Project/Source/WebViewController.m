//
//  WebViewController.m
//  iTransmission
//
//  Created by Beecher Adams on 4/25/17.
//
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webView;
@synthesize bannerView;
@synthesize currentURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init admob
    self.bannerView.adUnitID = @"ca-app-pub-5972525945446192/5805178468";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ kGADSimulatorID ];
    [self.bannerView loadRequest:request];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    // load current url
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.currentURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)goBackClicked:(UIBarButtonItem *)sender
{
    [self.webView goBack];
}

-(IBAction)closeClicked:(UIBarButtonItem *)sender
{
    UINavigationController *navigationController = (UINavigationController *)self.sideMenu.rootViewController;
    [navigationController setViewControllers:@[self.torrentView]];
}

- (void)setData:(NSString *)url controller:(Controller *)libtransmission
{
    [self loadURL:[NSURL URLWithString:url]];
    self.transmission = libtransmission;
    
    // check if libtransmission is nil
    if(libtransmission == nil)
    {
        NSLog(@"ltrans is nil");
    }
}

- (void)loadURL:(NSURL *)pageURL {
    self.currentURL = pageURL;
    [self.webView loadRequest:[NSURLRequest requestWithURL:pageURL]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)web
{
    // set current url
    self.URLTextfield.text = web.request.URL.absoluteString;
    self.currentURL = web.request.URL;
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // fix webview memory leak
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [self removeFromParentViewController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *requestedURL = [request URL];
    NSString *scheme = [requestedURL scheme];
    NSString *fileExtension = [requestedURL pathExtension];
    NSString *magnet;
    NSString *torrent;
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        // make network icon visible
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        if([scheme isEqualToString:@"magnet"])
        {
            magnet = [requestedURL absoluteString];
            
            NSLog(@"Magnet");
            
            // add magnet
            [self.transmission addTorrentFromManget:magnet];
            
            // close view controller
            [self.controller popViewControllerAnimated:YES];
        }
        
        else if([fileExtension isEqualToString:@"torrent"])
        {
            torrent = [requestedURL absoluteString];
            
            NSLog(@"Torrent");
            
            // add torrent
            [self.transmission addTorrentFromURL:torrent];
            
            // close view controller
            [self.controller popViewControllerAnimated:YES];
        }
    }
    
    return TRUE;
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
