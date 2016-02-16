//
//  StylistSignUpViewController.m
//  ParlorMe
//

#import "StylistSignUpFourViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SingletonClass.h"

@interface StylistSignUpFourViewController ()
{
    NSArray *placeholderList;
    NSMutableArray *basicInfoList;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewSlider;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *basicInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *licenseBtn;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

- (IBAction)basicInfoButtonTapped:(id)sender;
- (IBAction)licenseButtonTapped:(id)sender;
- (IBAction)submitTopButtonTapped:(id)sender;

@end

@implementation StylistSignUpFourViewController

#pragma mark-view life cycle method

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statusLabel.layer.borderColor = [[UIColor blackColor]CGColor];
    self.statusLabel.layer.borderWidth = 1.0f;
    
    placeholderList = [[NSArray alloc]initWithObjects:@"fullname",@"email address",@"password",@"birthday",@"mobile phone#", nil];
    basicInfoList = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollViewSlider scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.basicInfoBtn setImage:[UIImage imageNamed:@"step-complete"] forState:UIControlStateNormal];
    [self.licenseBtn setImage:[UIImage imageNamed:@"step-complete"] forState:UIControlStateNormal];
    [self.submitBtn setImage:[UIImage imageNamed:@"step-complete"] forState:UIControlStateNormal];
    
    [[SingletonClass shareManager]showBackBtn:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigate to root view

-(IBAction)pop
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Textfield Bottom Border

// Set Bottom Border for Textfields
- (void)ChangeTextfieldBorder: (UITextField*) txtfld
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, txtfld.frame.size.height - 1, txtfld.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor darkGrayColor].CGColor;
    [txtfld.layer addSublayer:bottomBorder];
}

#pragma mark - NavigationBar Bottom Border

// Set Bottom Border for Textfields
- (void)ChangeNavigationBarBorder: (UINavigationController*) navcntrl
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, navcntrl.navigationBar.frame.size.height - 1, navcntrl.navigationBar.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [navcntrl.navigationBar.layer addSublayer:bottomBorder];
}
#pragma mark- Other Methods

- (IBAction)basicInfoButtonTapped:(id)sender
{
    
}

- (IBAction)licenseButtonTapped:(id)sender
{
    
}

- (IBAction)submitTopButtonTapped:(id)sender
{
    
}

@end
