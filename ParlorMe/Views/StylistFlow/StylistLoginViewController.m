//
//  StylistLoginViewController.m
//  ParlorMe
//

#import "StylistLoginViewController.h"
#import "WebserviceViewController.h"
#import "ForgotPasswordViewController.h"
#import "Utility.h"
#import "SetScheduleViewController.h"
#import "Constants.h"
#import "StylistFlowModel.h"
#import "SingletonClass.h"
#import "StylistAccount.h"
#import "User.h"
#import "CoreDataModel.h"
#import "SWRevealViewController.h"

@interface StylistLoginViewController ()<WebserviceViewControllerDelegate,UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer *tapGesture ;
    NSString *currentAPICalled;
}

@property (weak, nonatomic) IBOutlet UITextField *txtfldEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtfldPassword;

- (IBAction)btnLoginClicked:(id)sender;
- (IBAction)btnForgotPasswordClicked:(id)sender;
- (IBAction)next:(id)sender;

@end

@implementation StylistLoginViewController

#pragma mark-view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self ChangeTextfieldBorder:_txtfldEmail];
    [self ChangeTextfieldBorder:_txtfldPassword];
    
    [_txtfldPassword setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtfldEmail setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[SingletonClass shareManager]showBackBtn:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Tap Gesture

-(void)tapped
{
    [self.view endEditing:YES];
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

#pragma mark - Login Button Action

- (IBAction)btnLoginClicked:(id)sender
{
    NSString *email = [_txtfldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [_txtfldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if(!email || [email length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Please provide valid email id" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if(!password || [password length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password" message:@"Please provide password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if(![emailTest evaluateWithObject:email])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Please provide valid email id" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else
    {
        [Utility showActivity:self];
        currentAPICalled = kLoginStylist;
        WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
        webserviceViewController.delegate = self;
        [webserviceViewController loginForStylist:_txtfldEmail.text andPassword:_txtfldPassword.text];
    }
}

#pragma mark - Textfield delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if(newLength > 50 && textField.tag == 601)
    {
        return NO;
    }
    
    else if(newLength > 50 && textField.tag == 602)
    {
        return NO;
    }
    
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - Forgot Password Action

- (IBAction)btnForgotPasswordClicked:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ForgotPasswordViewController *forgotPasswordViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"ForgotPasswordSB"];
    [self.navigationController pushViewController:forgotPasswordViewController animated:NO];
}

#pragma mark - Other Methods

- (IBAction)next:(id)sender
{
    UITextField *currentTextfield = (UITextField *)sender;
    UITextField *newResponder = (UITextField*)[self.view viewWithTag:currentTextfield.tag+1];
    [newResponder becomeFirstResponder];
}

#pragma mark - Webservice delegates

- (void)receivedResponse:(id)response
{
    if([currentAPICalled isEqualToString:kLoginStylist] && [response isEqualToString:@"Yes"])
    {
        //store stylist info in DB
        StylistAccount *stylistAccount = [StylistAccount sharedInstance];
        
        User *newUser = (User*)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"User" forContext:nil];
        newUser.userId = stylistAccount.userId;
        newUser.accessToken = stylistAccount.accessToken;
        newUser.isUserTypeClient = [NSNumber numberWithBool:NO];
        newUser.password = _txtfldPassword.text;
        newUser.email = _txtfldEmail.text;
        [[CoreDataModel sharedCoreDataModel]saveContext];
        
        [Utility removeActivityIndicator];
        
        //move to setschedule view page
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SetScheduleViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"SetScheduleViewControllerSB"];
        
        UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
        [navController setViewControllers: @[svc] animated: NO ];
        [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
    }
    
    else
    {
        [Utility removeActivityIndicator];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to process request." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Login Failed." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
