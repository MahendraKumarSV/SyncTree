//
//  SettingsViewController.m
//  ParlorMe
//

#import "SettingsViewController.h"
#import "RateViewController.h"
#import "UserAccount.h"
#import "WebserviceViewController.h"
#import "BirthDatePopoverViewController.h"
#import "Utility.h"
#import "Constants.h"
#import "CoreDataModel.h"
#import "Constants.h"
#import "SingletonClass.h"
#import "ServicesViewController.h"
#import "SWRevealViewController.h"

@interface SettingsViewController ()<WebserviceViewControllerDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,BirthdatePopOverDelegate,UIPopoverPresentationControllerDelegate,UIPopoverControllerDelegate>
{
    UITapGestureRecognizer* tapGesture;
    NSString *currentAPICalled;
}
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIScrollView *tabScrollView;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *birthdayButton;
@property (weak, nonatomic) IBOutlet UILabel *accountSettingsLbl;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuBtn;

@property (nonatomic, retain) BirthDatePopoverViewController *popOverViewController;
@property (nonatomic, retain)  UIPopoverController *displayPopoverCntrlr;

- (IBAction)logOutButtonTapped:(id)sender;
- (IBAction)editButtonTapped:(UIButton*)sender;
- (IBAction)showPopover:(id)sender;

@end

@implementation SettingsViewController

#pragma mark - View LifeCycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // To hide Navigation Bar
    self.navigationController.navigationBarHidden = true;
    
    [self.leftMenuBtn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    // To change UI of Logout button
    self.logOutButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
    self.logOutButton.layer.borderWidth=1.0f;
    self.logOutButton.layer.cornerRadius=3.0f;
    
    // To change UI of AboutParlor button
    self.aboutButton.layer.borderColor=[[UIColor colorWithRed:58/255.0f green:57/255.0f blue:57/255.0f alpha:1]CGColor];
    self.aboutButton.layer.borderWidth=1.0f;
    self.aboutButton.layer.cornerRadius=3.0f;
    
    for(int counter = 0; counter < 2; counter++)
    {
        UIButton *bottomBarButton = (UIButton*)[self.view viewWithTag:(9090 + counter)];
        bottomBarButton.layer.borderColor = [[UIColor blackColor]CGColor];
        bottomBarButton.layer.borderWidth = 2.0f;
    }
    
    // Adding Tap gesture to hide keyboard on single tap
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    [_birthdayButton setEnabled:NO];
    
    [Utility showActivity:self];
    WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
    currentAPICalled = kGetUserDetails;
    webserviceViewController.delegate = self;
    [webserviceViewController getUserDetails];
    
    //add pan gesture to open the left menu
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Tap Gesture

-(IBAction)tapped
{
    [self.view endEditing:YES];
}

#pragma mark - Other Methods
// to bring focus on new text field
- (IBAction)next:(id)sender
{
    UITextField *currentTextfield = (UITextField *)sender;
    
    UITextField *newResponder = (UITextField*)[self.view viewWithTag:currentTextfield.tag+1];
    [newResponder becomeFirstResponder];
}

#pragma mark - Log out button Action

- (IBAction)logOutButtonTapped:(id)sender
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    NSString *isPaymentDone;
    
    if(userRecords.count == 1)
    {
        isPaymentDone = [[userRecords objectAtIndex:0]isPaymentDone];
    }
    
    if([isPaymentDone isEqualToString:@"Yes"])
    {
        [self deletePreviousData];
        [self.tabBarController setSelectedIndex:0];
    }
    
    //UserAccount *userAccount = [UserAccount sharedInstance];
    userAccount.userId = nil;
    userAccount.selectedStylistName = nil;
    UINavigationController *navigationController = (UINavigationController*)self.presentingViewController;
    [navigationController popToRootViewControllerAnimated:FALSE];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Delete Old Data from database

// to delete previous data corresponding to this user and keep the new one
- (void)deletePreviousData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    userAccount.appointmentId = nil;
    userAccount.fromTime = nil;
    userAccount.selectedDate = nil;
    userAccount.selectedServicesList = nil;
    userAccount.selectedsubCategoryList = nil;
    
    NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    [[userRecords objectAtIndex:0]setSelectedDate:nil];
    [[userRecords objectAtIndex:0]setSelectedTime:nil];
    [[userRecords objectAtIndex:0]setIsStlistSelected:@"No"];
    [[userRecords objectAtIndex:0]setIsServicesSelected:@"No"];
    [[userRecords objectAtIndex:0]setIsCreditCardSelected:@"No"];
    [[userRecords objectAtIndex:0]setSelectedStylistTag:nil];
    [[userRecords objectAtIndex:0]setSelectedStylistName:nil];
    [[userRecords objectAtIndex:0]setSelectedCreditCardTag:nil];
    [[userRecords objectAtIndex:0]setIsPaymentDone:@"No"];
    [[userRecords objectAtIndex:0]setSelectedCategories:nil];
    [[userRecords objectAtIndex:0]setSelectedServices:nil];
    
    [[CoreDataModel sharedCoreDataModel]saveContext];
}

#pragma mark - Edit button Action

- (IBAction)editButtonTapped:(UIButton*)sender
{
    if([sender.titleLabel.text isEqualToString:@"Done"])
    {
        BOOL isAllInfoFilled = YES;
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        dateFormater.dateFormat = @"MM/dd/yyyy";
        NSDate* birthDate = [dateFormater dateFromString:_birthdayTextField.text];
        
        NSDate* now = [NSDate date];
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                           components:NSCalendarUnitYear
                                           fromDate:birthDate
                                           toDate:now
                                           options:0];
        NSInteger age = [ageComponents year];
        
        for(int i = 0; i < 5 ; i++)
        {
            UITextField *currentTextField = (UITextField *)[self.view viewWithTag:601 + i];
            
            NSString *infoText = [currentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if(!infoText || [infoText length] == 0)
            {
                isAllInfoFilled = NO;
                break;
            }
        }
        
        if(isAllInfoFilled)
        {
            NSString *mobileNumberPattern = @"[0-9]{10}";
            NSString *email = _emailTextField.text;
            NSPredicate *mobileNumberPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileNumberPattern];
            
            NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
            
            if (![mobileNumberPred evaluateWithObject:_mobilePhoneTextField.text])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mobile Phone" message:@"Please provide valid mobile phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            else if(![emailTest evaluateWithObject:email])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Please provide valid email id" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            else if (age<18)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Birthday" message:@"Users should 18+" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                [Utility showActivity:self];
                
                WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
                webserviceViewController.delegate = self;
                currentAPICalled = kSaveUserDetails;
                
                NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
                NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
                
                [userDictionary setObject:[_emailTextField.text lowercaseString] forKey:@"email"];
                
                if([_passwordTextField.text isEqualToString:@"********"])
                    // [userDictionary setObject:@"" forKey:@"password"];
                {
                    
                }
                else
                    [userDictionary setObject:_passwordTextField.text forKey:@"password"];
                
                [userDictionary setObject:_mobilePhoneTextField.text forKey:@"mobile_phone"];
                [userDictionary setObject:_nameTextField.text forKey:@"name"];
                [userDictionary setObject:_birthdayTextField.text forKey:@"dob"];
                
                UserAccount *userAccount = [UserAccount sharedInstance];
                
                if(userAccount.deviceToken.length > 0)
                {
                    [userDictionary setObject:userAccount.deviceToken forKey:@"device_token"];
                }
                
                //Forming Json Object
                [postDictionary setObject:userDictionary forKey:@"client"];
                
                //Calling webservice
                [webserviceViewController saveUserDetails:postDictionary];
            }
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information Required." message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    
    else
    {
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        _nameTextField.userInteractionEnabled = YES;
        _emailTextField.userInteractionEnabled = YES;
        _birthdayTextField.userInteractionEnabled = YES;
        _passwordTextField.userInteractionEnabled = YES;
        _mobilePhoneTextField.userInteractionEnabled = YES;
        [_birthdayButton setEnabled:YES];
    }
}


#pragma mark - Birthday button action

- (IBAction)showPopover:(id)sender
{
    [self tapped];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self performSegueWithIdentifier:@"settingsBirthdayPopoverSB" sender:self];
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
    frame.origin.y = self.view.frame.origin.y - self.mainScrollView.contentOffset.y + 370;
    
    if([segue.identifier isEqualToString:@"settingsBirthdayPopoverSB"])
    {
        BirthDatePopoverViewController *birthdatePopoverViewController = [segue destinationViewController];
        birthdatePopoverViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        birthdatePopoverViewController.popoverPresentationController.delegate = self;
        
        birthdatePopoverViewController.preferredContentSize = CGSizeMake(300, 208);
        [birthdatePopoverViewController.doneBtn addTarget:self action:@selector(dismissPopOver:) forControlEvents:UIControlEventTouchUpInside];
        birthdatePopoverViewController.popoverPresentationController.sourceRect = frame;
        birthdatePopoverViewController.popoverPresentationController.sourceView = self.view;
        birthdatePopoverViewController.delegate = self;
    }
}

// To show popover ( iOS < 8 )
- (IBAction)showPopOver:(UIButton*)sender
{
    CGRect frame = self.birthdayButton.frame;
    frame.origin.y = self.view.frame.origin.y - self.mainScrollView.contentOffset.y + 370;
    
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
        self.birthdayTextField.text = dateOfBirth;
    }
    else
    {
        self.birthdayTextField.text = dateString;
    }
    
    [self.displayPopoverCntrlr dismissPopoverAnimated:YES];
    [self.mobilePhoneTextField becomeFirstResponder];
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
    //  [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(textField.tag == 605)
    {
        [self.mainScrollView setContentOffset:CGPointMake(0, 100)];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
    // [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if(textField.tag == 605)
    {
        [self.mainScrollView setContentOffset:CGPointMake(0, 0)];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 100;
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
    
    if(newLength > 20 && textField.tag == 601)
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

#pragma mark Alertview delegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 11211 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:000-000-0000"]]];
    }
}

#pragma mark - Webservice delegates

- (void)receivedResponse:(id)response
{
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"]  && currentAPICalled == kGetUserDetails)
    {
        UserAccount *userAccount = [UserAccount sharedInstance];
        NSArray *mobileNumberArray = [userAccount.mobilePhone componentsSeparatedByString:@"+1"];
        _nameTextField.text = userAccount.userName;
        _emailTextField.text = userAccount.email;
        _birthdayTextField.text = userAccount.birthday;
        _mobilePhoneTextField.text = [mobileNumberArray objectAtIndex:1];
        _passwordTextField.text = @"********";
    }
    
    else if ([response isEqualToString:@"Yes"] && currentAPICalled == kSaveUserDetails)
    {
        [_editButton setTitle:@" " forState:UIControlStateNormal];
        [_editButton setImage:[UIImage imageNamed:@"edit-button.png"] forState:UIControlStateNormal];
        _nameTextField.userInteractionEnabled = NO;
        _emailTextField.userInteractionEnabled = NO;
        _birthdayTextField.userInteractionEnabled = NO;
        _passwordTextField.userInteractionEnabled = NO;
        _mobilePhoneTextField.userInteractionEnabled = NO;
        [_birthdayButton setEnabled:NO];
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to process Request." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    NSLog(@"errorDescription: %@",errorDescription);
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to process Request." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
