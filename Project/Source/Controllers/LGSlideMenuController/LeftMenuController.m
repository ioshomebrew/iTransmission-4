//
//  LeftMenuController.m
//  iTransmission
//
//  Created by Beecher Adams on 5/2/17.
//
//

#import "LeftMenuController.h"
#import "UIViewController+LGSideMenuController.h"

@interface LeftMenuController ()

@end

@implementation LeftMenuController

@synthesize array;
@synthesize transmission;
@synthesize web;
@synthesize torrentView;
@synthesize transmissionView;
@synthesize prefView;

- (void)setData:(Controller *)trans transView:(TorrentViewController *)transView;
{
    // set transmission instance
    self.transmission = trans;
    self.torrentView = (SideMenuController *)self.sideMenuController;
    self.transmissionView = transView;
    
    // init web view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_Storyboard" bundle:nil];
    self.web = [storyboard instantiateViewControllerWithIdentifier:@"web"];
    [self.web setData:@"http://google.com" controller:self.transmission];
    self.web.torrentView = self.transmissionView;
    self.web.sideMenu = self.torrentView;
    
    // init pref view controller
    self.prefView = [storyboard instantiateViewControllerWithIdentifier:@"pref"];
    self.prefView.torrentView = self.transmissionView;
    self.prefView.sideMenu = self.torrentView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.array = @[@"Add Torrent from Web", @"Add Torrent from URL", @"Connect to remote Transmission", @"Preferences"];
    
    [self.tableView registerClass:[LeftMenuCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 44.0, 0.0);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

// table view cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = self.array[indexPath.row];
    
    // log indexpath
    NSLog(@"Indexpath is: %li", (long)indexPath.row);
    
    return cell;
}

- (void)tableView:(UITableView *)ftableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navigationController = (UINavigationController *)self.torrentView.rootViewController;
    
    NSLog(@"indexPath: %li", (long)indexPath.row);
    
    switch (indexPath.row) {
        // web view controller
        case 0:
        {
            // go to web view controller
            [navigationController setViewControllers:@[self.web]];
            
            // make table view disappear
            [self.torrentView hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
        }
        break;
         
        // add from URL
        case 1:
        {
            UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Add from magnet" message:@"Please input torrent or magnet" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *data = dialog.textFields.firstObject.text;
                NSString *magnetSubstring = [data substringWithRange:NSMakeRange(0,6)];
                NSLog(@"Magnet substring: %@", magnetSubstring);
                if([magnetSubstring isEqualToString:@"magnet"])
                {
                    // add torrent from magnet
                    NSError *error = [self.transmission addTorrentFromManget:data];
                    if (error) {
                        NSLog(@"Error adding magnet");
                    }
                }
            }];
            [dialog addAction:okAction];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [dialog addAction:cancelAction];
            
            [dialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                textField.autocorrectionType = UITextAutocorrectionTypeNo;
                textField.enablesReturnKeyAutomatically = YES;
                textField.keyboardAppearance = UIKeyboardAppearanceDefault;
                textField.keyboardType = UIKeyboardTypeURL;
                textField.returnKeyType = UIReturnKeyDone;
                textField.secureTextEntry = NO;
            }];
            
            [navigationController presentViewController:dialog animated:YES completion:nil];
            
            // make table view disappear
            [self.torrentView hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
        }
            break;
            
        // TODO: Implement Connect to web interface
        case 2:
        {
            
        }
            break;
            
        // open preferences
        case 3:
        {
            // go to web view controller
            [navigationController setViewControllers:@[self.prefView]];
            
            // make table view disappear
            [self.torrentView hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
        }
        break;
            
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
