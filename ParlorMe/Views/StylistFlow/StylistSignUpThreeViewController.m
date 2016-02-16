//
//  StylistSignUpViewController.m
//  ParlorMe
//

#import "StylistSignUpThreeViewController.h"
#import "StylistSignUpTwoViewController.h"
#import "StylistSignUpOneViewController.h"
#import "StylistSignUpFourViewController.h"
#import "StylistReviewInfoCustomCell.h"
#import "StylistBasicInfoCustomCell.h"
#import "Utility.h"
#import "BirthDatePopoverViewController.h"
#import "WebserviceViewController.h"
#import "Constants.h"
#import "UserAccount.h"
#import "SingletonClass.h"

@interface StylistSignUpThreeViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate,WebserviceViewControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,BirthdatePopOverDelegate, UIPopoverPresentationControllerDelegate>
{
    NSArray *placeholderList;
    NSMutableArray *basicInfoList;
    UITextField *lastTextFieldSelected;
    UITapGestureRecognizer *tapGesture;
    long selectedButtontag;
    CGRect frame;
}
@property (weak, nonatomic) IBOutlet UITableView *stylistInfoTableView;
@property (weak, nonatomic) IBOutlet UIButton *basicInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *licenseBtn;

@property (nonatomic, retain) BirthDatePopoverViewController *popOverViewController;
@property (nonatomic, retain) UIPopoverController *displayPopoverCntrlr;

- (IBAction)basicInfoButtonTapped:(id)sender;
- (IBAction)licenseButtonTapped:(id)sender;
- (IBAction)submitTopButtonTapped:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)nextTextField:(UITextField*)sender;

@end

@implementation StylistSignUpThreeViewController
@synthesize basicInfoList,stylistDriverLicensephoto,stylistLicensephoto,ssnFront,ssnMiddle,ssnLast,zipCode;

#pragma mark-view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stylistInfoTableView.scrollEnabled = YES;
    placeholderList = [[NSArray alloc]initWithObjects:@"Fullname",@"Email address",@"Password",@"Birthday",@"Mobile phone#", nil];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.basicInfoBtn setImage:[UIImage imageNamed:@"step-complete"] forState:UIControlStateNormal];
    [self.licenseBtn setImage:[UIImage imageNamed:@"step-complete"] forState:UIControlStateNormal];
    
    [[SingletonClass shareManager]showBackBtn:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([_delegate respondsToSelector:@selector(changeImage:andImage:)])
    {
        [_delegate changeImage:self.stylistLicensephoto andImage:self.stylistDriverLicensephoto];
        [_delegate changeSSN:self.ssnFront andSSNMiddle:self.ssnMiddle andSSNLast:self.ssnLast andZipCode:self.zipCode];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark- Tap Gesture

-(void)tapped
{
    [self.view endEditing:YES];
}

#pragma mark- Submit Application Button Action

- (void)submitApplicationButtonTapped:(id)sender
{
    BOOL isAllInfoFilled = YES;
    
    NSString *zipCodeStr = @"[0-9]{5}";
    NSPredicate *zipCodePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zipCodeStr];
    
    NSString *ssnFrontStr  = @"[0-9]{3}";
    NSPredicate *ssnFrontPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ssnFrontStr];
    
    NSString *ssnMiddleStr = @"[0-9]{2}";
    NSPredicate *ssnMiddlePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ssnMiddleStr];
    
    NSString *ssnLastStr  = @"[0-9]{4}";
    NSPredicate *ssnLastPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ssnLastStr];
    
    for(int i = 0; i < 5 ; i++)
    {
        NSString *infoText = [[basicInfoList objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(!infoText || [infoText length] == 0)
        {
            isAllInfoFilled = NO;
            break;
        }
    }
    
    NSMutableArray *ssnAndZipCodeList = [[NSMutableArray alloc]init];
    
    [ssnAndZipCodeList removeAllObjects];
    [ssnAndZipCodeList addObject:self.ssnFront];
    [ssnAndZipCodeList addObject:self.ssnMiddle];
    [ssnAndZipCodeList addObject:self.ssnLast];
    [ssnAndZipCodeList addObject:self.zipCode];
    
    for(int i = 0; i < 4 ; i++)
    {
        NSString *infoText = [[ssnAndZipCodeList objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(!infoText || [infoText length] == 0)
        {
            isAllInfoFilled = NO;
            break;
        }
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
        
        if (![zipCodePred evaluateWithObject:self.zipCode])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Zip Code" message:@"Please provide valid zip code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else if (![ssnFrontPred evaluateWithObject:self.ssnFront])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SSN" message:@"Please provide valid SSN number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else if (![ssnMiddlePred evaluateWithObject:self.ssnMiddle])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SSN" message:@"Please provide valid SSN number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else if (![ssnLastPred evaluateWithObject:self.ssnLast])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SSN" message:@"Please provide valid SSN number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else
        {
            [Utility showActivity:self];
            WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
            webserviceViewController.delegate = self;
            
            NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *stylistLicenseDictionary = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *driverLicenseDictionary = [[NSMutableDictionary alloc]init];
            NSMutableArray *pictureList= [[NSMutableArray alloc]init];
            
            NSData *dataOfStylistLicenceImage = UIImageJPEGRepresentation(self.stylistLicensephoto,0.5F);
            NSString *base64StringOfStylistLicenceImage  = [dataOfStylistLicenceImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            NSData *dataOfStylistDriverLicenceImage = UIImageJPEGRepresentation(self.stylistDriverLicensephoto,0.5F);
            NSString *base64StringOfStylistDriverLicenceImage  = [dataOfStylistDriverLicenceImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            [userDictionary setObject:[basicInfoList objectAtIndex:0] forKey:@"name"];
            [userDictionary setObject:[[basicInfoList objectAtIndex:1] lowercaseString] forKey:@"email"];
            [userDictionary setObject:[basicInfoList objectAtIndex:2] forKey:@"password"];
            [userDictionary setObject:[basicInfoList objectAtIndex:3] forKey:@"dob"];
            [userDictionary setObject:[basicInfoList objectAtIndex:4] forKey:@"mobile_phone"];
            [userDictionary setObject:[NSString stringWithFormat:@"%@%@%@",self.ssnFront,self.ssnMiddle,self.ssnLast] forKey:@"ssn"];
            [userDictionary setObject:self.zipCode forKey:@"zip_code"];
            
            if(base64StringOfStylistDriverLicenceImage)
            {
                [driverLicenseDictionary setObject:base64StringOfStylistDriverLicenceImage forKey:@"data"];
                [driverLicenseDictionary setObject:@"drivers_license" forKey:@"file_name"];
                [pictureList addObject:driverLicenseDictionary];
            }
            if(base64StringOfStylistLicenceImage)
            {
                [stylistLicenseDictionary setObject:base64StringOfStylistLicenceImage forKey:@"data"];
                [stylistLicenseDictionary setObject:@"stylist_license" forKey:@"file_name"];
                [pictureList addObject:stylistLicenseDictionary];
            }
            
            [postDictionary setObject:kAppId forKey:@"app_id"];
            
            UserAccount *userAccount = [UserAccount sharedInstance];
            
            if(userAccount.deviceToken.length > 0)
            {
                [userDictionary setObject:userAccount.deviceToken forKey:@"device_token"];
            }
            
            [postDictionary setObject:userDictionary forKey:@"partner"];
            [postDictionary setObject:pictureList forKey:@"pictures"];
            
            [webserviceViewController registerStylist:postDictionary];
        }
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information Required." message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark- Basic info button tapped

- (IBAction)basicInfoButtonTapped:(id)sender
{
    for (id viewController in [self.navigationController viewControllers])
    {
        if ([viewController isKindOfClass:[StylistSignUpOneViewController class]])
        {
            self.delegate = viewController;
            [viewController changeImage:self.stylistLicensephoto andImage:self.stylistDriverLicensephoto];
            [viewController changeSSN:self.ssnFront andSSNMiddle:self.ssnMiddle andSSNLast:self.ssnLast andZipCode:self.zipCode];
            [self.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}

#pragma mark- Other Methods

- (IBAction)licenseButtonTapped:(id)sender
{
    
}

- (IBAction)submitTopButtonTapped:(id)sender
{
    
}

- (IBAction)next:(id)sender
{
    UITextField *currentTextfield = (UITextField *)sender;
    NSUInteger indexes[] = {0,currentTextfield.tag+1};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
    StylistBasicInfoCustomCell *subcategoryCell = (StylistBasicInfoCustomCell *)[self.stylistInfoTableView cellForRowAtIndexPath: indexPath];
    
    if(currentTextfield.tag == 2)
    {
        [self birthdayButtonTapped:subcategoryCell.birthdayButton];
    }
    else if (currentTextfield.tag == 4)
    {
        [self tapped];
    }
    else
    {
        [subcategoryCell.basicInfoTextField becomeFirstResponder];
    }
}

- (IBAction)nextTextField:(UITextField*)sender
{
    UITextField *nextTextfield = (UITextField *)[self.view viewWithTag:sender.tag+1];
    [nextTextfield becomeFirstResponder];
}

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 5;
    else if(section == 1)
        return 2;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        StylistBasicInfoCustomCell *subcategoryCell = [tableView dequeueReusableCellWithIdentifier:@"BasicView"];
        
        if(basicInfoList.count>0)
            subcategoryCell.basicInfoTextField.text = [basicInfoList objectAtIndex:indexPath.row];
        
        subcategoryCell.basicInfoTextField.placeholder = [placeholderList objectAtIndex:indexPath.row];
        [subcategoryCell.basicInfoTextField setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        subcategoryCell.basicInfoTextField.tag = indexPath.row;
        subcategoryCell.birthdayButton.tag = indexPath.row;
        subcategoryCell.birthdayButton.hidden = YES;
        [subcategoryCell.birthdayButton addTarget:self action:@selector(birthdayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        subcategoryCell.basicInfoTextField.delegate = self;
        subcategoryCell.basicInfoTextField.returnKeyType = UIReturnKeyNext;
        subcategoryCell.basicInfoTextField.enablesReturnKeyAutomatically = YES;
        
        if(indexPath.row == 2)
        {
            subcategoryCell.basicInfoTextField.secureTextEntry = YES;
        }
        
        else
        {
            subcategoryCell.basicInfoTextField.secureTextEntry = NO;
        }
        
        if (indexPath.row == 1)
        {
            subcategoryCell.basicInfoTextField.keyboardType = UIKeyboardTypeEmailAddress;
        }
        
        else if(indexPath.row == 3)
        {
            subcategoryCell.basicInfoTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            subcategoryCell.birthdayButton.hidden = NO;
        }
        
        else if (indexPath.row == 4)
        {
            subcategoryCell.basicInfoTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            subcategoryCell.basicInfoTextField.returnKeyType = UIReturnKeyDone;
            subcategoryCell.basicInfoTextField.enablesReturnKeyAutomatically = YES;
        }
        
        else
        {
            subcategoryCell.basicInfoTextField.keyboardType = UIKeyboardTypeDefault;
        }
        
        subcategoryCell.basicInfoTextField.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textUpdated:) name: UITextFieldTextDidChangeNotification object:nil];
        
        [self ChangeTextfieldBorder: subcategoryCell.basicInfoTextField];
        
        return subcategoryCell;
    }
    
    else if(indexPath.section == 1)
    {
        StylistReviewInfoCustomCell *subcategoryCell = [tableView dequeueReusableCellWithIdentifier:@"LicenseView"];
        
        if(indexPath.row == 0)
        {
            subcategoryCell.headingLabel.text = @"Stylist License:";
            subcategoryCell.stylistImageView.image = self.stylistLicensephoto;
            [subcategoryCell.imageViewBtn setBackgroundImage:self.stylistLicensephoto forState:UIControlStateNormal];
        }
        
        else
        {
            subcategoryCell.headingLabel.text = @"Drivers License:";
            subcategoryCell.stylistImageView.image = self.stylistDriverLicensephoto;
            [subcategoryCell.imageViewBtn setBackgroundImage:self.stylistDriverLicensephoto forState:UIControlStateNormal];
        }
        
        subcategoryCell.stylistImageView.tag = 670+indexPath.row;
        subcategoryCell.addPhotoBtn.tag = 670+indexPath.row;
        subcategoryCell.removePhotoBtn.tag = 670+indexPath.row;
        
        [subcategoryCell.addPhotoBtn addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [subcategoryCell.removePhotoBtn addTarget:self action:@selector(removePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        return subcategoryCell;
    }
    
    else
    {
        UITableViewCell *subcategoryCell = [tableView dequeueReusableCellWithIdentifier:@"SecurityNumberView"];
        
        UITextField *textFldSSNFront = (UITextField*) [subcategoryCell viewWithTag:981];
        UITextField *textFldSSNMiddle = (UITextField*) [subcategoryCell viewWithTag:982];
        UITextField *textFldSSNLast = (UITextField*) [subcategoryCell viewWithTag:983];
        UITextField *textFldZipCode = (UITextField*) [subcategoryCell viewWithTag:984];
        
        textFldSSNFront.delegate = self;
        textFldSSNMiddle.delegate = self;
        textFldSSNLast.delegate = self;
        textFldZipCode.delegate = self;
        
        textFldSSNFront.text = self.ssnFront;
        textFldSSNMiddle.text = self.ssnMiddle;
        textFldSSNLast.text = self.ssnLast;
        textFldZipCode.text = self.zipCode;
        
        [textFldSSNFront setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        [textFldSSNMiddle setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        [textFldSSNLast setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        [textFldZipCode setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        
        [self ChangeTextfieldBorder:textFldSSNFront];
        [self ChangeTextfieldBorder:textFldSSNMiddle];
        [self ChangeTextfieldBorder:textFldSSNLast];
        [self ChangeTextfieldBorder:textFldZipCode];
        
        UIButton *submitApplicationBtn = (UIButton*)[subcategoryCell viewWithTag:550];
        [submitApplicationBtn addTarget:self action:@selector(submitApplicationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        return subcategoryCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 50;
    }
    
    else
    {
        return 200;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 2)
    {
        return 0.0f;
    }
    
    else
        return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderView"];
    
    UILabel *titleLabel = (UILabel*) [headerCell viewWithTag:1];
    
    if (section == 0)
    {
        titleLabel.text = @"Basic Information:";
    }
    
    else if (section == 1)
    {
        titleLabel.text = @"Licenses:";
    }
    
    return headerCell.contentView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

#pragma mark - Text Updated Action

// If user edits any textbox call this method to update text
-(void)textUpdated:(NSNotification*)notification
{
    UITextField *senderTxt = (UITextField *)[notification object];
    int tag = (int)senderTxt.tag;
    if(tag < 980)
    {
        [basicInfoList removeObjectAtIndex:tag];
        [basicInfoList insertObject:senderTxt.text atIndex:tag];
    }
    
    else if (tag == 981)
    {
        self.ssnFront = senderTxt.text;
    }
    
    else if (tag == 982)
    {
        self.ssnMiddle = senderTxt.text;
    }
    
    else if (tag == 983)
    {
        self.ssnLast = senderTxt.text;
    }
    
    else if (tag == 984)
    {
        self.zipCode = senderTxt.text;
    }
}

#pragma mark - Birthday button tapped

- (void)birthdayButtonTapped:(id)sender
{
    UIButton *birthdayButton = (UIButton*)sender;
    frame = birthdayButton.frame;
    
    if(birthdayButton.tag != 3)
        return;
    
    [self tapped];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self performSegueWithIdentifier:@"signUp3BirthdayPopOver" sender:self];
    }
    
    else
    {
        [self showPopOver:sender];
    }
}

#pragma mark - popover realted methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    frame.origin.y = self.view.frame.origin.y - self.stylistInfoTableView.contentOffset.y + 370;
    
    if([segue.identifier isEqualToString:@"signUp3BirthdayPopOver"])
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
    frame.origin.y = self.view.frame.origin.y - self.stylistInfoTableView.contentOffset.y + 370;
    
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
        [basicInfoList removeObjectAtIndex:3];
        [basicInfoList insertObject:dateOfBirth atIndex:3];
    }
    else
    {
        [basicInfoList removeObjectAtIndex:3];
        [basicInfoList insertObject:dateString atIndex:3];
    }
    
    [self.displayPopoverCntrlr dismissPopoverAnimated:YES];
    [self.stylistInfoTableView reloadData];
    
    NSUInteger indexes[] = {0,4};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
    StylistBasicInfoCustomCell *subcategoryCell = (StylistBasicInfoCustomCell *)[self.stylistInfoTableView cellForRowAtIndexPath: indexPath];
    [subcategoryCell.basicInfoTextField becomeFirstResponder];
}

- (void)dismissPopOverView:(NSString *)dateOfBirth
{
    [self dismissPopOver:dateOfBirth];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - Add/Remove Photo

- (void)addPhoto:(UIButton*)sender
{
    [self.view endEditing:YES];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select from gallery", @"Take a new picture", nil];
    selectedButtontag = sender.tag;
    [sheet showInView:self.view];
}

- (void)removePhoto:(UIButton*)sender
{
    if(sender.tag == 670)
    {
        self.stylistLicensephoto = [UIImage imageNamed:@""];
    }
    
    else
    {
        self.stylistDriverLicensephoto = [UIImage imageNamed:@""];
    }
    
    [self.stylistInfoTableView reloadData];
}

#pragma mark - Action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) // Select from gallery
    {
        BOOL libraryIsAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
        
        if (libraryIsAvailable)
        {
            [self pickPictureFromLibrary];
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No photo library" message:@"A library isn't available on this device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Display/dismiss your alert
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Display/dismiss your alert
                    [alert show];
                });
            });
        }
    }
    
    else if (buttonIndex == 1) // Take a new picture
    {
        BOOL cameraIsAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        
        if (cameraIsAvailable)
        {
            [self takePicture];
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No camera" message:@"A camera isn't available on this device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Display/dismiss your alert
                [alert show];
            });
        }
    }
}

#pragma mark - Image picker controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo = (UIImage *)info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(selectedButtontag == 670)
    {
        self.stylistLicensephoto = photo;
    }
    
    else if(selectedButtontag == 671)
    {
        self.stylistDriverLicensephoto = photo;
    }
    
    [self.stylistInfoTableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma make - Methods for selecting photos

- (void)pickPictureFromLibrary
{
    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
    camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    camera.delegate = self;
    
    [self presentViewController:camera animated:YES completion:nil];
}

- (void)takePicture
{
    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.allowsEditing = NO;
    camera.delegate = self;
    
    [self presentViewController:camera animated:YES completion:nil];
}

#pragma mark - textfield delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(textField.tag == 4)
    {
        [self.stylistInfoTableView setContentOffset:CGPointMake(0, 100)];
    }
    
    else if(textField.tag > 980)
    {
        [self.stylistInfoTableView setContentOffset:CGPointMake(0, 650)];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if(textField.tag == 4)
    {
        //[self animateTextField: textField up: NO];
        [self.stylistInfoTableView setContentOffset:CGPointMake(0, 0)];
    }
    
    else if(textField.tag == 984)
    {
        //[self animateTextField: textField up: NO];
        [self.stylistInfoTableView setContentOffset:CGPointMake(0, 0)];
    }
    
    //[self.stylistInfoTableView setContentOffset:CGPointMake(0, 0)];
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
    
    if(newLength > 20 && textField.tag == 0)
    {
        return NO;
    }
    
    else if(newLength > 50 && textField.tag == 1)
    {
        return NO;
    }
    
    else if(newLength > 50 && textField.tag == 2)
    {
        return NO;
    }
    
    else if(newLength > 10 && textField.tag == 4)
    {
        return NO;
    }
    
    else if(newLength > 3 && textField.tag == 981)
    {
        return NO;
    }
    
    else if(newLength > 2 && textField.tag == 982)
    {
        return NO;
    }
    
    else if(newLength > 4 && textField.tag == 983)
    {
        return NO;
    }
    
    else if(newLength > 5 && textField.tag == 984)
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

#pragma mark - webservice delegates

- (void)receivedResponse:(id)response
{
    [Utility removeActivityIndicator];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StylistSignUpFourViewController *stylistSignUpFourViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistSignUp4SB"];
    
    if([response isEqualToString:@"Yes"])
    {
        [self.navigationController pushViewController:stylistSignUpFourViewController animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Stylist SignUp Failed." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Stylist SignUp Failed." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
