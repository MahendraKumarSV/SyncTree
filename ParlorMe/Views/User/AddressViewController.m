//
//  AddressViewController.m
//  ParlorMe

#import "AddressViewController.h"

#import "SWRevealViewController.h"
#import "ServicesViewController.h"
#import "WebserviceViewController.h"
#import "Utility.h"
#import "UserAccount.h"
#import "Constants.h"
#import "SingletonClass.h"

@interface AddressViewController ()<UITextViewDelegate, UITextFieldDelegate,WebserviceViewControllerDelegate,UIGestureRecognizerDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addressNameTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *streetAddressTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *streetAddressLine2TxtFld;
@property (weak, nonatomic) IBOutlet UITextField *cityTextFld;
@property (weak, nonatomic) IBOutlet UITextField *stateTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeTxtFld;
@property (weak, nonatomic) IBOutlet UITextView *notesTxtView;
@property (weak, nonatomic) IBOutlet UIView *notesView;
@property (weak, nonatomic) IBOutlet UIButton *saveAddressButton;
@property (weak, nonatomic) IBOutlet UIScrollView *addressScrollView;

- (IBAction)saveAddressButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)next:(id)sender;

@end

@implementation AddressViewController
{
    UITapGestureRecognizer *tapGesture;
    CLLocationManager *locationManager;
    CLLocation *location;
    NSString *currentAPI;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

#pragma mark-view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Adding Bottom layer to all text fields
    [self ChangeTextfieldBorder:self.addressNameTxtFld];
    [self ChangeTextfieldBorder:self.streetAddressTxtFld];
    [self ChangeTextfieldBorder:self.streetAddressLine2TxtFld];
    [self ChangeTextfieldBorder:self.cityTextFld];
    [self ChangeTextfieldBorder:self.stateTxtFld];
    [self ChangeTextfieldBorder:self.zipCodeTxtFld];
    
    // Adding border to notesView
    self.notesView.layer.borderColor=[[UIColor blackColor]CGColor];
    self.notesView.layer.borderWidth=1.0f;
    
    // To change UI of save address button
    self.saveAddressButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
    //self.saveAddressButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.saveAddressButton.layer.borderWidth=1.0f;
    self.saveAddressButton.layer.cornerRadius=3.0f;
    
    // To give placeholder feel in text view
    self.notesTxtView.text = @"ex. \"Doorbell is broken\"";
    self.notesTxtView.textColor = [UIColor lightGrayColor];
    currentAPI = @"";
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    if(![Constants isWifiAvailable])
    {
        [self showNetworkError];
    }
    else
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager requestAlwaysAuthorization];
        [locationManager startUpdatingLocation];
        geocoder = [[CLGeocoder alloc] init];
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
            [locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager performSelector:@selector(requestAlwaysAuthorization) withObject:NULL];
        }
        else
        {
            [locationManager startUpdatingLocation];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
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

#pragma mark- Show Network Error

- (void)showNetworkError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NetworkErrMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark- CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    location=newLocation;
    
    if (location != nil)
    {
        [locationManager stopUpdatingLocation];
        [self prepopulateCurrentAddress];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
}

#pragma mark- Prepopulate Address

-(void)prepopulateCurrentAddress
{
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        // NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            /*NSLog(@"Address----------%@", [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                           placemark.subThoroughfare, placemark.thoroughfare,
                                           placemark.postalCode, placemark.locality,
                                           placemark.administrativeArea,
                                           placemark.country]);*/
            
            if(placemark.subThoroughfare)
                self.streetAddressTxtFld.text = [NSString stringWithFormat:@"%@ %@",placemark.subThoroughfare, placemark.thoroughfare];
            else
                self.streetAddressTxtFld.text = [NSString stringWithFormat:@"%@",placemark.thoroughfare];
            self.zipCodeTxtFld.text = [NSString stringWithFormat:@"%@",placemark.postalCode];
            self.cityTextFld.text = [NSString stringWithFormat:@"%@",placemark.locality];
            self.stateTxtFld.text = [NSString stringWithFormat:@"%@",[[placemark.administrativeArea substringToIndex:2]uppercaseString]];
            
        }
        
        else
        {
            //NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    /*
     NSString *requestPathStr=@"http://maps.googleapis.com/maps/api/geocode/json?latlng=";
     NSString *requestLatitudeStr=[[NSString alloc]init];
     
     requestLatitudeStr=[ NSString stringWithFormat:@"%.20lf", location.coordinate.latitude];
     requestLatitudeStr=[requestPathStr stringByAppendingString:requestLatitudeStr];
     requestLatitudeStr=[requestLatitudeStr stringByAppendingString:@","];
     
     NSString *requestLongitudeStr=[[NSString alloc]init];
     
     requestLongitudeStr=[ NSString stringWithFormat:@"%.20lf",location.coordinate.longitude];
     NSString* requestLatLongitudeStr=[requestLatitudeStr stringByAppendingString:requestLongitudeStr];
     
     requestLatLongitudeStr=[requestLatLongitudeStr stringByAppendingString:@"&sensor=false"];
     NSLog(@"URL:%@",requestLatLongitudeStr);
     
     [Utility showActivity:self];
     WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
     webserviceViewController.delegate = self;
     currentAPI = kGetAddressUsingGPS;
     [webserviceViewController getAddressUsingGPS:requestLatLongitudeStr];
     */
}

#pragma mark - textfield delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if(newLength > 20 && textField.tag == 601)
    {
        return NO;
    }
    else if(newLength > 20 && textField.tag == 602)
    {
        return NO;
    }
    else if(newLength > 20 && textField.tag == 603)
    {
        return NO;
    }
    else if(newLength > 20 && textField.tag == 604)
    {
        return NO;
    }
    else if(newLength > 2 && textField.tag == 605)
    {
        return NO;
    }
    else if(newLength > 5 && textField.tag == 606)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(textField.tag == 606)
    {
        [self.addressScrollView setContentOffset:CGPointMake(0, 200)];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
    //  [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if(textField.tag == 606)
    {
        [self.addressScrollView setContentOffset:CGPointMake(0, 0)];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 100; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void) animateTextView: (UITextView*) textView up: (BOOL) up
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)checkForAddressDuplicacy
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    BOOL isUserAddressDuplicate = NO;
    
    for(NSDictionary *address in userAccount.userAddressList)
    {
        NSString *line1Address = [[address valueForKey:@"line_1"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *streetAddress = [_streetAddressTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *city = [[address valueForKey:@"city"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *userCity = [_cityTextFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *state = [[address valueForKey:@"state"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *userState = [_stateTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *zipcode = [[address valueForKey:@"zip_code"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *userZipcode = [_zipCodeTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSCharacterSet *specialchars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"] invertedSet];
        
        line1Address = [[[line1Address componentsSeparatedByCharactersInSet:specialchars] componentsJoinedByString:@""]lowercaseString];
        streetAddress = [[[streetAddress componentsSeparatedByCharactersInSet:specialchars] componentsJoinedByString:@""]lowercaseString];
        city = [[[city componentsSeparatedByCharactersInSet:specialchars] componentsJoinedByString:@""]lowercaseString];
        userCity = [[[userCity componentsSeparatedByCharactersInSet:specialchars] componentsJoinedByString:@""]lowercaseString];
        state = [[[state componentsSeparatedByCharactersInSet:specialchars] componentsJoinedByString:@""]lowercaseString];
        userState = [[[userState componentsSeparatedByCharactersInSet:specialchars] componentsJoinedByString:@""]lowercaseString];
        zipcode = [[[zipcode componentsSeparatedByCharactersInSet:specialchars] componentsJoinedByString:@""]lowercaseString];
        userZipcode = [[[userZipcode componentsSeparatedByCharactersInSet:specialchars] componentsJoinedByString:@""]lowercaseString];
        
        if([line1Address isEqualToString:streetAddress] && [city isEqualToString:userCity] && [state isEqualToString:userState] && [zipcode isEqualToString:userZipcode])
        {
            isUserAddressDuplicate = YES;
            break;
        }
        else
        {
            isUserAddressDuplicate = NO;
        }
    }
    
    return isUserAddressDuplicate;
}

#pragma mark- save address button action

- (IBAction)saveAddressButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
    BOOL isAllinfoFilled = YES;
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *zipCode = @"[0-9]{5}";
    NSPredicate *zipCodePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zipCode];
    
    NSCharacterSet *specialchars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    NSRange specialCharactersRange = [_stateTxtFld.text rangeOfCharacterFromSet:specialchars];
    
    for(int i=0; i<7; i++)
    {
        UITextField *currenttextField = (UITextField *)[self.view viewWithTag:601+i];
        
        NSString *infoText = [currenttextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if((!infoText || [infoText length] == 0) && (currenttextField.tag != 603))
        //if((!infoText || [infoText length] == 0))
        {
            isAllinfoFilled = NO;
            break;
        }
    }
    
    //check for validations
    if(!isAllinfoFilled)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information Required." message:@"Kindly provide all the required information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    else if ([self checkForAddressDuplicacy])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Address." message:@"Address already exists" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    else if (![zipCodePred evaluateWithObject:_zipCodeTxtFld.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Zip Code" message:@"Please provide valid zip code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    else if (specialCharactersRange.location != NSNotFound)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"State" message:@"Please provide valid initials of state" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    else if ([[_cityTextFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] < 4)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"City" message:@"Please provide valid name of city" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*else if(_notesTxtView.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notes" message:@"Please provide some notes to proceed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }*/
        
    else
    {
        [Utility showActivity:self];
        WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
        webserviceViewController.delegate = self;
        currentAPI = kSaveAddress;
        
        NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
        
        [userDictionary setObject:[_addressNameTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ]forKey:@"name"];
        [userDictionary setObject:[_streetAddressTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] forKey:@"line_1"];
        [userDictionary setObject:[_streetAddressLine2TxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"line_2"];
        [userDictionary setObject:[_cityTextFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]forKey:@"city"];
        [userDictionary setObject:[[_stateTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]uppercaseString] forKey:@"state"];
        [userDictionary setObject:[_zipCodeTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"zip_code"];
        [userDictionary setObject:[_notesTxtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]forKey:@"notes"];
        
        //Forming Json Object
        [postDictionary setObject:userAccount.userId forKey:@"user_id"];
        [postDictionary setObject:userDictionary forKey:@"address"];
        
        //Calling webservice
        [webserviceViewController saveUserAddress:postDictionary];
    }
}

#pragma mark- close button action

- (IBAction)closeButtonTapped:(id)sender
{
//    if (self.isFromSignUpPage) {
//        //after signup get into the select service page
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
//        ServicesViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
//        [navController setViewControllers:@[svc] animated: NO];
//        [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
//    }
//    else
        [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - TextView Delegate

// to give placeholder feel in text view
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.notesTxtView.text = @"";
    self.notesTxtView.textColor = [UIColor blackColor];
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self animateTextView:textView up:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self animateTextView:textView up:NO];
}

- (void) textViewDidChange:(UITextView *)textView
{
    if( self.notesTxtView.text.length == 0){
        self.notesTxtView.textColor = [UIColor lightGrayColor];
        self.notesTxtView.text = @"ex. \"Doorbell is broken\"";
        [ self.notesTxtView resignFirstResponder];
    }
}

#pragma mark - Other Methods
// to bring focus to next text field
- (IBAction)next:(id)sender
{
    UITextField *currentTextfield=(UITextField *)sender;
    
    if(currentTextfield.tag!=606)
    {
        UITextField *newResponder=(UITextField*)[self.view viewWithTag:currentTextfield.tag+1];
        [newResponder becomeFirstResponder];
    }
    else
    {
        UITextView *newResponder=(UITextView*)[self.view viewWithTag:currentTextfield.tag+1];
        [newResponder becomeFirstResponder];
    }
}

#pragma mark-webservice delegates
- (void)receivedResponse:(id)response
{
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"] && currentAPI == kSaveAddress)
    {
        //as a guest user and signed up (or) just a logged in user adds an address
        if([_delegate respondsToSelector:@selector(getNewlySavedAddress)]) {
            [_delegate getNewlySavedAddress];
        }
        
        //[self dismissViewControllerAnimated:YES completion:nil];
        
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        [[SingletonClass shareManager]setDirectSignUp:@"YES"];
        
        //[self performSelector:@selector(showServicesScreen) withObject:self afterDelay:0.01];
        
        /*UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
        ServicesViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
        [navController setViewControllers:@[svc] animated: NO];
        [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];*/
        
        //[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    else if([response isEqualToString:@"Yes"] && currentAPI == kGetAddressUsingGPS)
    {
        //NSLog(@"parseAddress");
    }
    
    else if(currentAPI == kGetAddressUsingGPS)
    {
        [locationManager stopUpdatingLocation];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to get Location Using GPS." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to save Address." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)showServicesScreen
{
    
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to save Address." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
