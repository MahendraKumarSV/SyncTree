//
//  LoginViewController.m
//  ParlorMe
//

#import "LoginViewController.h"
#import "ForgotPasswordViewController.h"
#import "Utility.h"
#import "WebserviceViewController.h"
#import "StylistLoginViewController.h"
#import "UserAccount.h"
#import "CoreDataModel.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Constants.h"
#import "CreateFacebookUserViewController.h"
#import "ServicesViewController.h"
#import "SWRevealViewController.h"
#import "StylistAccount.h"
#import "SingletonClass.h"
#import "JoinParlorViewController.h"
#import "StylistDetails.h"
#import "SetScheduleViewController.h"
#import <CoreData/CoreData.h>

@interface LoginViewController ()<WebserviceViewControllerDelegate, UIGestureRecognizerDelegate,FBSDKLoginButtonDelegate>
{
    NSDictionary *userData;
}

@property (nonatomic, weak) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UITextField *txtfldEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtfldPassword;
@property (nonatomic, weak) IBOutlet FBSDKLoginButton *facebookLoginButton;
@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordBtn;
@property (nonatomic, weak) IBOutlet UIButton *signInAsStylistBtn;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logo_TopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FBIcon_BottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FP_PasswordConstraints;

- (IBAction)next:(id)sender;

@end

@implementation LoginViewController

#pragma-mark  View Lifecycle Related Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_birthday"];
    self.facebookLoginButton.imageView.image = nil;
    //To give borders to textfields and navigation bar
    [self changeTextfieldBorder:_txtfldEmail];
    [self changeTextfieldBorder:_txtfldPassword];
    
    // To change placeholder text color to lightgray
    [_txtfldPassword setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtfldEmail setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    // Adding Tap gesture to hide keyboard on single tap
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    userData = [[NSDictionary alloc]init];
    //add gesture to view, to open the left menu
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    ///adjust constarints to fit screen height <= 568.0
    if([[UIScreen mainScreen] bounds].size.height <= 568.0)
    {
        self.logo_TopLayoutConstraint.constant = self.logo_TopLayoutConstraint.constant - 40.0;
        self.FBIcon_BottomConstraints.constant = self.FBIcon_BottomConstraints.constant - 30.0;
        self.FBIcon_BottomConstraints.constant = self.FBIcon_BottomConstraints.constant - 20.0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    // To set continue button name if the user is logged in via Facebbok
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbUserName"];
    
    if ([FBSDKAccessToken currentAccessToken] && ![name isEqualToString:@""])
    {
        [self loadFbUserData];
        /*self.bgImg.image = nil;
        [self.forgotPasswordBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.signInAsStylistBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.view.backgroundColor = [UIColor colorWithRed:229/255.0 green:199/255.0 blue:194/255.0 alpha:1];*/
        [self.continueButton setTitle:[NSString stringWithFormat:@"Continue As %@",name] forState:UIControlStateNormal];
        [self.continueButton setHidden:YES];
    }
    
    else
    {
        /*self.view.backgroundColor = [UIColor clearColor];
        [self.forgotPasswordBtn setTitleColor:[UIColor colorWithRed:172/255.0 green:173/255.0 blue:174/255.0 alpha:1] forState:UIControlStateNormal];
        [self.signInAsStylistBtn setTitleColor:[UIColor colorWithRed:172/255.0 green:173/255.0 blue:174/255.0 alpha:1] forState:UIControlStateNormal];
        self.bgImg.image = [UIImage imageNamed:@"StyleSignInImage"];*/
        [self.continueButton setTitle:@"" forState:UIControlStateNormal];
        [self.continueButton setHidden:YES];
    }
    
    [self checkUsersInDB];
}

#pragma mark CheckUser
- (void)checkUsersInDB
{
    NSArray *userRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:nil andSortDescriptor:nil forContext:nil];
    
    if(userRecords.count > 0)
    {
        User *currentUser = [userRecords objectAtIndex:0];
        
        if ([currentUser.isUserTypeClient boolValue])
        {
            UserAccount *userAccount = [UserAccount sharedInstance];
            userAccount.userId = currentUser.userId;
            userAccount.accessToken = currentUser.accessToken;
            userAccount.isUserTypeClient = [currentUser.isUserTypeClient boolValue];
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ServicesViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[svc] animated: NO];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        }
        
        else
        {
            StylistAccount *stylistAccount = [StylistAccount sharedInstance];
            stylistAccount.userId = currentUser.userId;
            stylistAccount.accessToken = currentUser.accessToken;
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SetScheduleViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"SetScheduleViewControllerSB"];
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[svc] animated: NO];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        }
    }
}

#pragma mark - Button Actions
- (IBAction)buttonActions:(UIButton *)sender
{
    if (sender.tag == 1) {//Forgot password
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ForgotPasswordViewController *forgotPasswordViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"ForgotPasswordSB"];
        [self.navigationController pushViewController:forgotPasswordViewController animated:NO];
    }
    
    else if (sender.tag == 2) {//Sign in
        // Checking validations
        [self validateOnSignIn];
    }
    
    else if (sender.tag == 3) {//Stylist Login
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StylistLoginViewController *stylistLoginViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistLoginSB"];
        [self.navigationController pushViewController:stylistLoginViewController animated:NO];
    }
    
    else if (sender.tag == 4) {//Sign up
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        JoinParlorViewController *joinParlorViewController = [storyBoard instantiateViewControllerWithIdentifier:@"JoinParlorSB"];
        [self.navigationController pushViewController:joinParlorViewController animated:NO];
    }
    
    /*else if (sender.tag == 5) {// To continue as same user via Facebook account
        [Utility showActivity:self];
        WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
        webserviceViewController.delegate = self;
        
        NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
        
        //Forming Json Object
        [postDictionary setObject:kAppId forKey:@"app_id"];
        [postDictionary setObject:[[FBSDKAccessToken currentAccessToken]tokenString] forKey:@"fb_token"];
        
        //Calling webservice
        [webserviceViewController checkIfFacebookUserExists:postDictionary];
    }*/
}

#pragma mark - Validate Login
- (IBAction)validateOnSignIn {
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
    {   // Calling Login API
        [Utility showActivity:self];
        WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
        webserviceViewController.delegate = self;
        [webserviceViewController loginForUser:_txtfldEmail.text andPassword:_txtfldPassword.text];
    }
}

#pragma mark- Tap Gesture
// To end editing if user taps anywhere on the screen
-(void)tapped
{
    [self.view endEditing:YES];
}

#pragma mark - Textfield Bottom Border

// Set Bottom Border for Textfields
- (void)changeTextfieldBorder: (UITextField*) txtfld
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, txtfld.frame.size.height - 1, txtfld.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor darkGrayColor].CGColor;
    [txtfld.layer addSublayer:bottomBorder];
}

#pragma mark- Facebook Login Related Methods

// To get User data from Facebook if user is already logged in then just fetch data
- (void)loadFbUserData
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email, birthday"}];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                 // result is a dictionary with the user's Facebook data
                 userData = (NSDictionary *)result;
             }
             else
             {
                 UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to process request." message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }
         }];
    }
    else
    {
        //NSLog(@"Invalid access token");
    }
}

// To get User data from Facebook if user logs in via Facebook, also call webservice to check if user is already present
- (void)loadData
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email, birthday"}];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                 // result is a dictionary with the user's Facebook data
                 userData = (NSDictionary *)result;
                 NSString *name = userData[@"name"];
                 //NSLog(@"name: %@",name);
                 [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"fbUserName"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [Utility showActivity:self];
                 WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
                 webserviceViewController.delegate = self;
                 
                 NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
                 
                 //Forming Json Object
                 [postDictionary setObject:kAppId forKey:@"app_id"];
                 [postDictionary setObject:[[FBSDKAccessToken currentAccessToken]tokenString] forKey:@"fb_token"];
                 
                 //Calling webservice
                 [webserviceViewController checkIfFacebookUserExists:postDictionary];
             }
             
             else
             {
                 UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to process request." message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }
         }];
    }
    
    else
    {
        //NSLog(@"Invalid access token");
    }
}

#pragma mark - FBSDKLoginButtonDelegate

// To check if user is able to login into the facebook successfully
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if (error)
    {
        //NSLog(@"Unexpected login error: %@", error);
        NSString *alertMessage = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?: @"There was a problem logging in. Please try again later.";
        NSString *alertTitle = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops";
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    else
    {
        //NSLog(@"Result-------%@",result);
        [self loadData];
    }
}

// To check if user logouts out from Facebook
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    [self.continueButton setTitle:@"" forState:UIControlStateNormal];
    [self.continueButton setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"fbUserName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Textfield Delegates

// Check for maxLength of textfields
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

// On tap of Next button on Keyboard, Textfield focus shoule move on next item
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - Next Action
// to bring focus to new textfield
- (IBAction)next:(id)sender
{
    UITextField *currentTextfield = (UITextField *)sender;
    UITextField *newResponder = (UITextField*)[self.view viewWithTag:currentTextfield.tag+1];
    [newResponder becomeFirstResponder];
}

#pragma mark - Create User in DataBase
// To create record in database
-(void)createUserData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    User *newUser = (User*)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"User" forContext:nil];
    newUser.userId = userAccount.userId;
    newUser.accessToken = userAccount.accessToken;
    //newUser.isUserTypeClient = [NSNumber numberWithBool:userAccount.isUserTypeClient];
    newUser.isUserTypeClient = [NSNumber numberWithBool:YES];
    
    newUser.password = _txtfldPassword.text;
    newUser.name = userAccount.userName;
    newUser.email = _txtfldEmail.text;
    
    [[CoreDataModel sharedCoreDataModel]saveContext];
}

#pragma mark - Navigate to Rate View Controller method
// To navigate to SelectService screen
- (void)navigateToSelectServiceView
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    if( [firstLoad count]==0)
    {
        [self createUserData];
    }
        
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ServicesViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
    
    UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
    [navController setViewControllers: @[svc] animated: NO ];
    [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
}

#pragma mark - webservice delegates
//Check response recieved from Web-service
- (void)receivedResponse:(id)response
{
    [Utility removeActivityIndicator];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    CreateFacebookUserViewController *createFacebookUserViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"FacebookSignUpSB"];
    
    if([response isEqualToString:@"Yes"])
    {
        [self navigateToSelectServiceView];
    }
    else if ([response isEqualToString:@"IsAFacebookUser"])
    {
        [self navigateToSelectServiceView];
    }
    else if ([response isEqualToString:@"UserNotRegistered"])
    {
        createFacebookUserViewController.tokenString = [[FBSDKAccessToken currentAccessToken]tokenString];
        createFacebookUserViewController.userData = userData;
        [self.navigationController pushViewController:createFacebookUserViewController animated:NO];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Login Failed." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

// Check if web-service failed
- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Login Failed." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
