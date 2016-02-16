//
//  CreateFacebookUserViewController.m
//  ParlorMe
//

#import "CreateFacebookUserViewController.h"
#import "CoreDataModel.h"
#import "UserAccount.h"
#import "WebserviceViewController.h"
#import "BirthDatePopoverViewController.h"
#import "Utility.h"
#import "Constants.h"
#import "ServicesViewController.h"
#import "SWRevealViewController.h"

@interface CreateFacebookUserViewController ()<WebserviceViewControllerDelegate,UIGestureRecognizerDelegate,UIPopoverControllerDelegate,BirthdatePopOverDelegate, UIPopoverPresentationControllerDelegate,UITextFieldDelegate>
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


- (IBAction)joinParlorButtonTapped:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)birthdayButtonTapped:(id)sender;

@end

@implementation CreateFacebookUserViewController
@synthesize userData,tokenString;

#pragma mark - view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Transparent Navigation Controller
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    // Unhide Navigation Bar
    self.navigationController.navigationBarHidden = FALSE;
    
    // To give bottom border to textfields
    [self ChangeTextfieldBorder:_txtfldFullName];
    [self ChangeTextfieldBorder:_txtfldEmail];
    [self ChangeTextfieldBorder:_txtfldPassword];
    [self ChangeTextfieldBorder:_txtfldBirthday];
    [self ChangeTextfieldBorder:_txtfldMobile];
    [self ChangeNavigationBarBorder:self.navigationController];
    
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
    self.navigationController.navigationBarHidden = false;
    NSString *name = userData[@"name"];
    NSString *email = userData[@"email"];
    NSString *birthday = userData[@"birthday"];
    
    // Now add the data to the UI elements
    _txtfldBirthday.text = birthday;
    _txtfldFullName.text = name;
    _txtfldEmail.text = email;
    _txtfldPassword.text = @"********";
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

// Set Bottom Border for Navigation Bar
- (void)ChangeNavigationBarBorder: (UINavigationController*) navcntrl
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, navcntrl.navigationBar.frame.size.height - 1, navcntrl.navigationBar.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [navcntrl.navigationBar.layer addSublayer:bottomBorder];
}

#pragma mark - other methods

// to bring focus on new text field
- (IBAction)next:(id)sender
{
    UITextField *currentTextfield = (UITextField *)sender;
    
    UITextField *newResponder = (UITextField*)[self.view viewWithTag:currentTextfield.tag+1];
    [newResponder becomeFirstResponder];
}

#pragma mark Join Parlor Button Action

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
    
    else if(!birthday || [birthday length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Birthday" message:@"Please provide date of birth" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if (age<18)
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
            [postDictionary setObject:tokenString forKey:@"fb_token"];
            
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
        [self performSegueWithIdentifier:@"signUpBirthdayPopoverSB" sender:self];
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
    frame.origin.y = self.view.frame.origin.y - self.scrollViewSlider.contentOffset.y + 335;
    
    if([segue.identifier isEqualToString:@"signUpBirthdayPopoverSB"])
    {
        BirthDatePopoverViewController *birthdayPopoverViewController = [segue destinationViewController];
        birthdayPopoverViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        birthdayPopoverViewController.popoverPresentationController.delegate = self;
        
        birthdayPopoverViewController.preferredContentSize = CGSizeMake(300, 208);
        [birthdayPopoverViewController.doneBtn addTarget:self action:@selector(dismissPopOver:) forControlEvents:UIControlEventTouchUpInside];
        birthdayPopoverViewController.popoverPresentationController.sourceRect = frame;
        birthdayPopoverViewController.popoverPresentationController.sourceView = self.view;
        birthdayPopoverViewController.delegate = self;
    }
}

// To show popover ( iOS < 8 )
- (IBAction)showPopOver:(UIButton*)sender
{
    CGRect frame = self.birthdayButton.frame;
    frame.origin.y = self.view.frame.origin.y - self.scrollViewSlider.contentOffset.y + 335;
    
    if(! self.popOverViewController)
    {
        self.popOverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BirthDatePopoverSB"];
        self.popOverViewController.preferredContentSize = CGSizeMake(300,208);
    }
    if( !self.displayPopoverCntrlr)
    {
        self.displayPopoverCntrlr = [[UIPopoverController alloc]
                                     initWithContentViewController:self.popOverViewController];
        [self.displayPopoverCntrlr setDelegate:self];
    }
    
    [self.popOverViewController.doneBtn addTarget:self action:@selector(dismissPopOver:) forControlEvents:UIControlEventTouchUpInside];
    self.popOverViewController.preferredContentSize = CGSizeMake(300,208);
    [self.displayPopoverCntrlr presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

// To dismiss popover (iOS >= 8 )
- (IBAction)dismissPopOver:(NSString *)dateOfBirth
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

#pragma mark - textfield delegates

// to move textfields up/down when Keyboard shows/hides
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(textField.tag == 605)
    {
        [self.scrollViewSlider setContentOffset:CGPointMake(0, 100)];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if(textField.tag == 605)
    {
        [self.scrollViewSlider setContentOffset:CGPointMake(0, 0)];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 200;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - save user data in data base

-(void)createUserData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    User *newUser = (User*)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"User" forContext:nil];
    newUser.userId = userAccount.userId;
    newUser.password = _txtfldPassword.text;
    newUser.name = userAccount.userName;
    newUser.email = _txtfldEmail.text;
    
    [[CoreDataModel sharedCoreDataModel]saveContext];
}

#pragma mark-webservice delegates

- (void)receivedResponse:(id)response
{
    // To remove activity indicator
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"])
    {
        //Clearing entered data
        _txtfldFullName.text = @"";
        _txtfldEmail.text = @"";
        _txtfldPassword.text = @"";
        _txtfldBirthday.text = @"";
        _txtfldMobile.text = @"";
        
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
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Registration Failed." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Registration Failed." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
