//
//  JoinParlorViewController.m
//  ParlorMe
//

#import "JoinParlorViewController.h"
#import "WebserviceViewController.h"
#import "BirthDatePopoverViewController.h"
#import "Utility.h"
#import "Constants.h"
#import "AddressViewController.h"
#import "CoreDataModel.h"
#import "UserAccount.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "StylistSignUpOneViewController.h"
#import "SingletonClass.h"

@interface JoinParlorViewController ()<WebserviceViewControllerDelegate,UIGestureRecognizerDelegate,UIPopoverControllerDelegate,BirthdatePopOverDelegate, UIPopoverPresentationControllerDelegate,UITextFieldDelegate,FBSDKLoginButtonDelegate>
{
    UITapGestureRecognizer* tapGesture;
}
@property (weak, nonatomic) IBOutlet UITextField *txtfldFullName;
@property (weak, nonatomic) IBOutlet UITextField *txtfldEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtfldPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtfldBirthday;
@property (weak, nonatomic) IBOutlet UITextField *txtfldMobile;
@property (weak, nonatomic) IBOutlet UIButton *birthdayButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewSlider;

@property (nonatomic, retain) BirthDatePopoverViewController *popOverViewController;
@property (nonatomic, retain)  UIPopoverController *displayPopoverCntrlr;
@property (nonatomic, strong) IBOutlet FBSDKLoginButton *loginButton;

- (IBAction)skipForNowButtonTapped:(id)sender;
- (IBAction)joinParlorButtonTapped:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)birthdayButtonTapped:(id)sender;
-(IBAction)dismissView:(id)sender;

@end

@implementation JoinParlorViewController

-(IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma-mark  View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_birthday"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:) name:FBSDKProfileDidChangeNotification object:nil];
    
    // To give bottom border to textfields
    [self ChangeTextfieldBorder:_txtfldFullName];
    [self ChangeTextfieldBorder:_txtfldEmail];
    [self ChangeTextfieldBorder:_txtfldPassword];
    [self ChangeTextfieldBorder:_txtfldBirthday];
    [self ChangeTextfieldBorder:_txtfldMobile];
    
    // to change text color of textfield placeholders
    [_txtfldFullName setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtfldEmail setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtfldPassword setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtfldBirthday setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtfldMobile setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    // Adding Tap gesture to hide keyboard on single tap
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // to load User data fetched from facebook
    [self loadData];
    
    [[SingletonClass shareManager]showBackBtn:self];
}

#pragma-mark  Load Data fetched from Facebook Methods

- (void)updateContent:(NSNotification *)notification
{
    // to load User data fetched from facebook
    [self loadData];
}

// to load User data fetched from facebook
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
                 NSDictionary *userData = (NSDictionary *)result;
                 NSString *name = userData[@"name"];
                 NSString *email = userData[@"email"];
                 NSString *birthday = userData[@"birthday"];
                 
                 // Now add the data to the UI elements
                 _txtfldBirthday.text = birthday;
                 _txtfldFullName.text = name;
                 _txtfldEmail.text = email;
                 _txtfldPassword.text = @"********";
             }
             
             else
             {
                 //NSLog(@"Error %@",error);
             }
         }];
    }
    
    else
    {
        //NSLog(@"Invalid access token");
    }
}

#pragma mark - FBSDKLoginButtonDelegate

// To get User data from Facebook if user logs in via facebook
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
    _txtfldBirthday.text = @"";
    _txtfldFullName.text = @"";
    _txtfldEmail.text = @"";
    _txtfldPassword.text = @"";
    _txtfldMobile.text = @"";
}

#pragma mark - Observations

// To check if user Facebook profile changes
- (void)observeProfileChange:(NSNotification *)notfication
{
    if ([FBSDKProfile currentProfile])
    {
        [self loadData];
    }
}

// To check if user Facebook profile changes
- (void)observeTokenChange:(NSNotification *)notfication
{
    if (![FBSDKAccessToken currentAccessToken])
    {
        //  [self.continueButton setTitle:@"continue as a guest" forState:UIControlStateNormal];
    }
    
    else
    {
        [self observeProfileChange:nil];
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
- (void)ChangeTextfieldBorder: (UITextField*) txtfld
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, txtfld.frame.size.height - 1, txtfld.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor darkGrayColor].CGColor;
    [txtfld.layer addSublayer:bottomBorder];
}

#pragma mark - NavigationBar Bottom Border

// Set Bottom Border for Navigation Bar
- (void)ChangeNavigationBarBorder: (UINavigationController*) navcntrl
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, navcntrl.navigationBar.frame.size.height - 1, navcntrl.navigationBar.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [navcntrl.navigationBar.layer addSublayer:bottomBorder];
}

#pragma mark - Other Methods

// to bring focus on new text field
- (IBAction)next:(id)sender
{
    UITextField *currentTextfield = (UITextField *)sender;
    
    UITextField *newResponder = (UITextField*)[self.view viewWithTag:currentTextfield.tag+1];
    [newResponder becomeFirstResponder];
}

#pragma mark - Skip Button Action

// To navigate back to main view
- (void)skipForNowButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Join Parlor Button Action

// Register User functionality implememnted here
- (IBAction)joinParlorButtonTapped:(id)sender
{
    // Creating Pattern to check if mobile number contains 10 digits
    NSString *mobileNumberPattern = @"[0-9]{10}";
    NSPredicate *mobileNumberPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileNumberPattern];
    
    NSString *fullname = [_txtfldFullName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [_txtfldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [_txtfldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *birthday = [_txtfldBirthday.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *mobilePhone = [_txtfldMobile.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    dateFormater.dateFormat = @"MM/dd/yyyy";
    NSDate* birthDate = [dateFormater dateFromString:birthday];
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:birthDate
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
    // Adding Validations
    if(!fullname || [fullname length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name" message:@"Please provide full name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if(!email || [email length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Please provide valid email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if(![emailTest evaluateWithObject:email])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Please provide valid email id" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if(!password || [password length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password" message:@"Please provide password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    
    else if ([[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password" message:@"Password should have minimum 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if(!birthday || [birthday length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Birthday" message:@"Please provide date of birth" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if(age < 18)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Birthday" message:@"Users with 18+ age can only register" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if(!mobilePhone || [mobilePhone length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mobile Phone" message:@"Please provide mobile phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if (![mobileNumberPred evaluateWithObject:mobilePhone])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mobile Phone" message:@"Please provide valid mobile phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else
    {
        //Check if user is not logged in Via facebook and call webservice to register user
        if(![_txtfldPassword.text isEqualToString:@"********"])
        {
            [Utility showActivity:self];
            WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
            webserviceViewController.delegate = self;
            
            NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
            
            [userDictionary setObject:[email lowercaseString] forKey:@"email"];
            [userDictionary setObject:password forKey:@"password"];
            [userDictionary setObject:mobilePhone forKey:@"mobile_phone"];
            [userDictionary setObject:fullname forKey:@"name"];
            [userDictionary setObject:birthday forKey:@"dob"];
            
            //Forming Json Object
            [postDictionary setObject:kAppId forKey:@"app_id"];
            
            UserAccount *userAccount = [UserAccount sharedInstance];
            
            if(userAccount.deviceToken.length > 0)
            {
                [userDictionary setObject:userAccount.deviceToken forKey:@"device_token"];
            }
            
            [postDictionary setObject:userDictionary forKey:@"client"];
            
            //Calling webservice
            [webserviceViewController registerUser:postDictionary];
        }
        
        //Check if user logged in Via facebook and call webservice to register facebook user
        else
        {
            
            [Utility showActivity:self];
            WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
            webserviceViewController.delegate = self;
            
            NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
            
            [userDictionary setObject:mobilePhone forKey:@"mobile_phone"];
            [userDictionary setObject:birthday forKey:@"dob"];
            
            //Forming Json Object
            [postDictionary setObject:kAppId forKey:@"app_id"];
            [postDictionary setObject:[[FBSDKAccessToken currentAccessToken]tokenString] forKey:@"fb_token"];
            
            UserAccount *userAccount = [UserAccount sharedInstance];
            
            if(userAccount.deviceToken.length > 0)
            {
                [userDictionary setObject:userAccount.deviceToken forKey:@"device_token"];
            }
            
            [postDictionary setObject:userDictionary forKey:@"client"];
            
            //Calling webservice
            [webserviceViewController createUserUsingFaceBook:postDictionary];
        }
    }
}

#pragma mark- Birthday Button Action

// to show native date picker for selecting DOB
- (IBAction)birthdayButtonTapped:(id)sender
{
    [self tapped];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self performSegueWithIdentifier:@"joinParlorBirthdayPopoverSB" sender:self];
    }
    else
    {
        [self showPopOver:sender];
    }
}

#pragma mark-popover realted methods

// To show popover ( iOS >= 8 )
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CGRect frame = self.birthdayButton.frame;
    frame.origin.y = self.view.frame.origin.y - self.scrollViewSlider.contentOffset.y + 350;
    
    if([segue.identifier isEqualToString:@"joinParlorBirthdayPopoverSB"])
    {
        BirthDatePopoverViewController *birthDatePopoverViewController = [segue destinationViewController];
        birthDatePopoverViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        birthDatePopoverViewController.popoverPresentationController.delegate = self;
        
        birthDatePopoverViewController.preferredContentSize = CGSizeMake(300, 208);
        [birthDatePopoverViewController.doneBtn addTarget:self action:@selector(dismissPopOver:) forControlEvents:UIControlEventTouchUpInside];
        birthDatePopoverViewController.popoverPresentationController.sourceRect = frame;
        birthDatePopoverViewController.popoverPresentationController.sourceView = self.view;
        birthDatePopoverViewController.delegate = self;
    }
}

// To show popover ( iOS < 8 )
- (void)showPopOver:(UIButton*)sender
{
    CGRect frame = self.birthdayButton.frame;
    frame.origin.y = self.view.frame.origin.y - self.scrollViewSlider.contentOffset.y + 350;
    
    if(!self.popOverViewController)
    {
        self.popOverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BirthDatePopoverSB"];
        self.popOverViewController.preferredContentSize = CGSizeMake(300,208);
    }
    
    if(!self.displayPopoverCntrlr)
    {
        self.displayPopoverCntrlr = [[UIPopoverController alloc]initWithContentViewController:self.popOverViewController];
        [self.displayPopoverCntrlr setDelegate:self];
    }
    
    [self.popOverViewController.doneBtn addTarget:self action:@selector(dismissPopOver:) forControlEvents:UIControlEventTouchUpInside];
    self.popOverViewController.preferredContentSize = CGSizeMake(300,208);
    [self.displayPopoverCntrlr presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

// To dismiss popover (iOS >= 8 )
- (void)dismissPopOver:(NSString *)dateOfBirth
{
    NSDate *date = [self.popOverViewController.birthDatePicker date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    dateFormater.dateFormat = @"MM/dd/yyyy";
    NSString *dateString = [dateFormater stringFromDate:date];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        self.txtfldBirthday.text = dateOfBirth;
    }
    
    else
    {
        self.txtfldBirthday.text = dateString;
    }
    
    [self.displayPopoverCntrlr dismissPopoverAnimated:YES];
    [self.txtfldMobile becomeFirstResponder];
}

// To dismiss popover (iOS < 8 )
- (void)dismissPopOverView:(NSString *)dateOfBirth
{
    [self dismissPopOver:dateOfBirth];
}

// To give popover feel for iOS >= 8
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - Textfield delegates

// to move textfields up/down when Keyboard shows/hides
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[self animateTextField: textField up: YES];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(textField.tag == 605)
    {
        //[self.scrollViewSlider setContentOffset:CGPointMake(0, 100)];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //[self animateTextField: textField up: NO];
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if(textField.tag == 605)
    {
        //[self.scrollViewSlider setContentOffset:CGPointMake(0, 0)];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 200;
    const float movementDuration = 0.5f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.scrollViewSlider.frame = CGRectOffset(self.scrollViewSlider.frame, 0, movement);
    [UIView commitAnimations];
}

// Check for maxLength of textfields
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if(newLength >20 && textField.tag == 601)
    {
        return NO;
    }
    
    else if(newLength > 50 && textField.tag == 602)
    {
        return NO;
    }
    
    else if(newLength > 50 && textField.tag == 603)
    {
        return NO;
    }
    
    else if(newLength > 10 && textField.tag == 605)
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

#pragma mark - Check if facebook user already present

// Check if Facebook User is already registered
- (BOOL)checkIfUserAlreadyPresent
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSArray *currentUser= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    if( [currentUser count] > 0 && ![userAccount.userId isEqualToString:@"Guest"])
    {
        //userAccount.userId = @"Guest";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"User Already Present." message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - Update User Details in Database

// If user is registered successfully, Update the User Details in data base from Guest to the details recieved from webservice
- (void)modifyGuestUserData
{
    NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@", @"Guest"] andSortDescriptor:nil forContext:nil];
    
    if( [firstLoad count] > 0 )
    {
        UserAccount *userAccount = [UserAccount sharedInstance];
        
        User *newUser = [firstLoad objectAtIndex:0];
        newUser.accessToken = userAccount.accessToken;
        //newUser.isUserTypeClient = [NSNumber numberWithBool:userAccount.isUserTypeClient];
        newUser.isUserTypeClient = [NSNumber numberWithBool:YES];
        newUser.userId = userAccount.userId;
        newUser.password = _txtfldPassword.text;
        newUser.name = userAccount.userName;
        newUser.email = _txtfldEmail.text;
        
        [[CoreDataModel sharedCoreDataModel]saveContext];
    }
    
    else
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
}

#pragma mark- Webservice delegates

//Check response recieved from Web-service
- (void)receivedResponse:(id)response
{
    // To remove activity indicator
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"])
    {
        BOOL isUserAlreadyPresent = [self checkIfUserAlreadyPresent];
        
        if(isUserAlreadyPresent)
        {
            return;
        }
        
        else
        {
            [self modifyGuestUserData];
            
            //Clearing entered data
            _txtfldFullName.text = @"";
            _txtfldEmail.text = @"";
            _txtfldPassword.text = @"";
            _txtfldBirthday.text = @"";
            _txtfldMobile.text = @"";
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AddressViewController *addressViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"AddressSB"];
            addressViewController.delegate = _delegate;
            [self presentViewController:addressViewController animated:YES completion:nil];
        }
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Registration Failed." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

// Check if web-service failed
- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Registration Failed." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

#pragma mark - SignUp Button Action
- (IBAction)stytlistSignUpButtonTapped:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StylistSignUpOneViewController *stylistSignUpOneViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistSignUp1SB"];
    [self.navigationController pushViewController:stylistSignUpOneViewController animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
