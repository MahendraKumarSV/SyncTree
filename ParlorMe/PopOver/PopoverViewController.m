//
//  PopoverViewController.m
//  ParlorMe
//

#import "PopoverViewController.h"

@interface PopoverViewController ()

- (IBAction)gotItButtonTapped:(id)sender;

@end

@implementation PopoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark- Got It button Action
- (IBAction)gotItButtonTapped:(id)sender
{
    //dismissing popover
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // using delegate for dismissing popover in iOS 8
    [self.delegate dismissPopOverView];
}

@end
