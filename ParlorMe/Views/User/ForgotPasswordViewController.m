//
//  ForgotPasswordViewController.m
//  ParlorMe

#import "ForgotPasswordViewController.h"
#import "WebserviceViewController.h"
#import "Constants.h"
#import "Utility.h"
#import "SingletonClass.h"

@interface ForgotPasswordViewController ()<WebserviceViewControllerDelegate,UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer *tapGesture ;
}
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

- (IBAction)forgotPasswordButtonTapped:(id)sender;

@end

@implementation ForgotPasswordViewController

#pragma-mark  View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Adding bottom border to textfield
    [self ChangeTextfieldBorder:self.emailTextField];
    
    // To change colour of placeholder text
    [self.emailTextField setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [[SingletonClass shareManager]showBackBtn:self];
    
    // Adding Tap gesture to hide keyboard on single tap
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tap Gesture

// To end editing if user taps anywhere on the screen
-(void)tapped
{
    [self.view endEditing:YES];
}

#pragma-mark  Forgot Password Action

// Forgot Password Functionality implemented
- (IBAction)forgotPasswordButtonTapped:(id)sender
{
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    // Adding validations
    if(!email || [email length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Please provide valid email id" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if(![emailTest evaluateWithObject:email])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Please provide valid email id" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else
    {
        // to show activity indicator
        [Utility showActivity:self];
        WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
        webserviceViewController.delegate = self;
        
        NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
        [userDictionary setObject:[self.emailTextField.text lowercaseString] forKey:@"email"];
        [postDictionary setObject:kAppId forKey:@"app_id"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:@"IsStylistLoggingIn"])
        {
            [postDictionary setObject:userDictionary forKey:@"partner"];
            [webserviceViewController forgotStylistPassword:postDictionary];
        }
        
        else
        {
            [postDictionary setObject:userDictionary forKey:@"client"];
            [webserviceViewController forgotUserPassword:postDictionary];
        }
    }
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

#pragma mark - Textfield Delegates

// Check for maxLength of textfields
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if(newLength > 50)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

// On tap of Next button on Keyboard, Textfield focus shoule move on next item
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark- Webservice delegates

- (void)receivedResponse:(id)response
{
    // Removing activity indicator
    [Utility removeActivityIndicator];
    
    // Clearing email text
    self.emailTextField.text = @"";
    
    if([response isEqualToString:@"Yes"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Password Recovered." message:@"Password reset instructions have been sent successfully to your mail id" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Forgot Password Failed." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Forgot Password Failed." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
