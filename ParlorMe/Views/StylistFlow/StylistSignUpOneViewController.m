//
//  StylistSignUpViewController.m
//  ParlorMe
//

#import "StylistSignUpOneViewController.h"
#import "StylistSignUpThreeViewController.h"
#import "StylistSignUpTwoViewController.h"
#import "BirthDatePopoverViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SingletonClass.h"

@interface StylistSignUpOneViewController ()<UIGestureRecognizerDelegate,StylistSignUpThreeViewControllerDelegate, UIPopoverControllerDelegate,BirthdatePopOverDelegate, UIPopoverPresentationControllerDelegate,UITextFieldDelegate,StylistSignUpTwoViewControllerDelegate>
{
    NSArray *placeholderList;
    NSMutableArray *basicInfoList;
    UITapGestureRecognizer *tapGesture;
}
@property (weak, nonatomic) IBOutlet UIView *basicInfoView;
@property (weak, nonatomic) IBOutlet UITextField *txtfldFullName;
@property (weak, nonatomic) IBOutlet UITextField *txtfldEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtFldPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtFldBirthday;
@property (weak, nonatomic) IBOutlet UITextField *txtFldMobilePhone;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewSlider;
@property (weak, nonatomic) IBOutlet UIButton *birthdayButton;
@property (weak, nonatomic) IBOutlet UIButton *basicInfoBtn;

@property (nonatomic, retain) BirthDatePopoverViewController *popOverViewController;
@property (nonatomic, retain)  UIPopoverController *displayPopoverCntrlr;


- (IBAction)continueBasicViewButtonTapped:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)basicInfoButtonTapped:(id)sender;
- (IBAction)licenseButtonTapped:(id)sender;
- (IBAction)submitTopButtonTapped:(id)sender;
- (IBAction)birthdayButtonTapped:(id)sender;

@end

@implementation StylistSignUpOneViewController
@synthesize stylistDriverLicensephoto,stylistLicensephoto,ssnFront,ssnLast,ssnMiddle,zipCode;

#pragma mark-view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self ChangeNavigationBarBorder:self.navigationController];
    
    [self ChangeTextfieldBorder:_txtfldFullName];
    [self ChangeTextfieldBorder:_txtfldEmail];
    [self ChangeTextfieldBorder:_txtFldPassword];
    [self ChangeTextfieldBorder:_txtFldBirthday];
    [self ChangeTextfieldBorder:_txtFldMobilePhone];
    
    [_txtfldFullName setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtfldEmail setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtFldPassword setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtFldBirthday setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtFldMobilePhone setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    placeholderList = [[NSArray alloc]initWithObjects:@"fullname",@"email address",@"password",@"birthday",@"mobile phone#", nil];
    basicInfoList = [[NSMutableArray alloc]init];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.basicInfoBtn setImage:[UIImage imageNamed:@"step-1-incomplete"] forState:UIControlStateNormal];
    
    if(basicInfoList.count>0)
    {
        for(int i = 0; i < 5; i++)
        {
            UITextField *basicInfoTextField = (UITextField *)[self.basicInfoView viewWithTag:1101+i];
            basicInfoTextField.text = [basicInfoList objectAtIndex:i];
        }
    }
    
    [self.scrollViewSlider scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
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

#pragma mark- Change Image

- (void)changeImage:(UIImage *)stylistLicense andImage:(UIImage *)driverLicense
{
    self.stylistLicensephoto = stylistLicense;
    self.stylistDriverLicensephoto = driverLicense;
}

#pragma mark- Change SSN and Zip code

- (void)changeSSN:(NSString *)ssnFrontStr andSSNMiddle:(NSString *)ssnMiddleStr  andSSNLast:(NSString *)ssnLastStr  andZipCode:(NSString *)zipCodeStr
{
    self.ssnFront = ssnFrontStr;
    self.ssnMiddle = ssnMiddleStr;
    self.ssnLast = ssnLastStr;
    self.zipCode = zipCodeStr;
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

#pragma mark- Continue Button Action

- (IBAction)continueBasicViewButtonTapped:(id)sender
{
    BOOL isAllInfoFilled = YES;
    [basicInfoList removeAllObjects];
    
    for(int i = 0; i < 5; i++)
    {
        UITextField *basicInfoTextField = (UITextField *)[self.basicInfoView viewWithTag:1101+i];
        NSString *infoText = [basicInfoTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(!infoText || [infoText length] == 0)
        {
            isAllInfoFilled = NO;
            break;
        }
        [basicInfoList insertObject:basicInfoTextField.text atIndex:i];
    }
    
    if(isAllInfoFilled)
    {
        NSString *mobileNumberPattern = @"[0-9]{10}";
        NSString *email = [basicInfoList objectAtIndex:1];
        NSPredicate *mobileNumberPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileNumberPattern];
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        dateFormater.dateFormat = @"MM/dd/yyyy";
        NSDate* birthDate = [dateFormater dateFromString:[basicInfoList objectAtIndex:3]];
        
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
        NSDate* now = [NSDate date];
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                           components:NSCalendarUnitYear
                                           fromDate:birthDate
                                           toDate:now
                                           options:0];
        NSInteger age = [ageComponents year];
        
        if (![mobileNumberPred evaluateWithObject:[basicInfoList objectAtIndex:4]])
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Birthday" message:@"Users with 18+ age can only register" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else
        {
            [self.basicInfoBtn setAlpha:1.0];
            [self.basicInfoBtn setBackgroundColor:[UIColor clearColor]];
            [self.basicInfoBtn setImage:[UIImage imageNamed:@"step-complete"] forState:UIControlStateNormal];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            StylistSignUpTwoViewController *stylistSignUpTwoViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistSignUp2SB"];
            stylistSignUpTwoViewController.basicInfoList = basicInfoList;
            stylistSignUpTwoViewController.stylistLicensephoto = self.stylistLicensephoto;
            stylistSignUpTwoViewController.stylistDriverLicensephoto = self.stylistDriverLicensephoto;
            stylistSignUpTwoViewController.ssnFront = self.ssnFront;
            stylistSignUpTwoViewController.ssnMiddle = self.ssnMiddle;
            stylistSignUpTwoViewController.ssnLast = self.ssnLast;
            stylistSignUpTwoViewController.zipCode = self.zipCode;
            stylistSignUpTwoViewController.delegate = self;
            [self.navigationController pushViewController:stylistSignUpTwoViewController animated:YES];
        }
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information Required." message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark- Other Methods

- (IBAction)next:(id)sender
{
    UITextField *currentTextfield = (UITextField *)sender;
    UITextField *newResponder = (UITextField*)[self.view viewWithTag:currentTextfield.tag+1];
    [newResponder becomeFirstResponder];
}

- (IBAction)basicInfoButtonTapped:(id)sender
{
    
}

- (IBAction)licenseButtonTapped:(id)sender
{
    
}

- (IBAction)submitTopButtonTapped:(id)sender
{
    
}

#pragma mark- Birthday Button Action

- (IBAction)birthdayButtonTapped:(id)sender
{
    [self tapped];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self performSegueWithIdentifier:@"signUpBirthdayPopOver" sender:self];
    }
    
    else
    {
        [self showPopOver:sender];
    }
}

#pragma mark-popover realted methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CGRect frame = self.birthdayButton.frame;
    frame.origin.y = self.view.frame.origin.y - self.scrollViewSlider.contentOffset.y + 380;
    
    if([segue.identifier isEqualToString:@"signUpBirthdayPopOver"])
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

- (IBAction)showPopOver:(UIButton*)sender
{
    CGRect frame = self.birthdayButton.frame;
    frame.origin.y = self.view.frame.origin.y - self.scrollViewSlider.contentOffset.y + 380;
    
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

- (IBAction)dismissPopOver:(NSString *)dateOfBirth
{
    NSDate *date = [self.popOverViewController.birthDatePicker date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    dateFormater.dateFormat = @"MM/dd/yyyy";
    NSString *dateString = [dateFormater stringFromDate:date];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        self.txtFldBirthday.text = dateOfBirth;
    }
    
    else
    {
        self.txtFldBirthday.text = dateString;
    }
    
    [self.displayPopoverCntrlr dismissPopoverAnimated:YES];
    [self.txtFldMobilePhone becomeFirstResponder];
}

- (void)dismissPopOverView:(NSString *)dateOfBirth
{
    [self dismissPopOver:dateOfBirth];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - textfield delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[self animateTextField: textField up: YES];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(textField.tag == 1105)
    {
        [self.scrollViewSlider setContentOffset:CGPointMake(0, 100)];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //[self animateTextField: textField up: NO];
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if(textField.tag == 1105)
    {
        [self.scrollViewSlider setContentOffset:CGPointMake(0, 0)];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 200; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
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
    
    if(newLength > 20 && textField.tag == 1101)
    {
        return NO;
    }
    
    else if(newLength > 50 && textField.tag == 1102)
    {
        return NO;
    }
    
    else if(newLength > 50 && textField.tag == 1103)
    {
        return NO;
    }
    
    else if(newLength > 10 && textField.tag == 1105)
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

@end
