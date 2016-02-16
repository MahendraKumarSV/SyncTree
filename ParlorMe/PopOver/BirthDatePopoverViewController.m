//
//  BirthDatePopoverViewController.m
//  ParlorMe
//

#import "BirthDatePopoverViewController.h"

@interface BirthDatePopoverViewController ()

- (IBAction)doneBtnTapped:(id)sender;

@end

@implementation BirthDatePopoverViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.preferredContentSize = CGSizeMake(300,208);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Done button Action
- (IBAction)doneBtnTapped:(id)sender
{
    //setting date selected by user
    NSDate *date = [self.birthDatePicker date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    dateFormater.dateFormat = @"MM/dd/yyyy";
    NSString *dateString = [dateFormater stringFromDate:date];
    
    //dismissing popover
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // using delegate for dismissing popover in iOS 8
    [self.delegate dismissPopOverView:dateString];
}

@end
