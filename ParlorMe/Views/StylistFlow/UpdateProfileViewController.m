//
//  UpdateProfileViewController.m
//  ParlorMe
//

#import "UpdateProfileViewController.h"
#import "ScheduleViewController.h"
#import "AddServiceViewController.h"
#import "SingletonClass.h"
#import "Constants.h"
#import <LatoFont/UIFont+Lato.h>
#import "WebserviceViewController.h"
#import "Utility.h"
#import "AsyncImageView.h"
#import "StylistFlowModel.h"
#import "UserAccount.h"
#import "ChangePasswordViewController.h"
#import "SWRevealViewController.h"

@interface UpdateProfileViewController ()<UIActionSheetDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, WebserviceViewControllerDelegate, UIAlertViewDelegate, FetchChangedPassword, UITextViewDelegate>
{
    SingletonClass *sharedObj;
    NSDictionary *stylistProfileDictionary;
    WebserviceViewController *webVC;
    NSString *selectedProductID;
    UIImage *chosenImage;
    NSString *locationTextFormResponse;
    UIImageView *cameraIconImg;
    NSString *stylistPassword;//it will hold the password when it has been changed in change password page..
}

@property (nonatomic, weak) IBOutlet UIScrollView *bgScroll;
@property (nonatomic, weak) IBOutlet AsyncImageView *stylistImageView;
@property (nonatomic, weak) IBOutlet UITextField *nameFld;
@property (nonatomic, weak) IBOutlet UITextField *emailFld;
@property (nonatomic, weak) IBOutlet UITextField *phoneNumFld;
@property (nonatomic, weak) IBOutlet UITextField *expFld;
@property (nonatomic, weak) IBOutlet UILabel *dotLbl;
@property (nonatomic, weak) IBOutlet UITextField *locationFld;
@property (nonatomic, weak) IBOutlet UIButton *changePwdBtn;
@property (nonatomic, weak) IBOutlet UIButton *saveProfileBtn;
@property (nonatomic, weak) IBOutlet UIView *headingView;
@property (nonatomic, weak) IBOutlet UITableView *serviceTypesTable;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (nonatomic, weak) IBOutlet UIButton *addServiceBtn;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *addServiceBtnVerticalSpaceConstraint;
@property (nonatomic, weak) IBOutlet UITextView *bioTextView;
@property (strong, nonatomic) UILabel *profileLabel;
@property (nonatomic, weak) IBOutlet UILabel *noServicesAvailableLbl;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuBtn;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewXConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewYConstraint;

@end

@implementation UpdateProfileViewController
@synthesize servicesList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.stylistImageView.layer.borderWidth = 1;
    self.stylistImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //self.stylistImageView.layer.cornerRadius = self.stylistImageView.frame.size.width/2;
    self.stylistImageView.layer.cornerRadius = 45;
    self.stylistImageView.clipsToBounds = YES;
    //hide add service button by default
    self.addServiceBtn.hidden = YES;
    self.logoutBtn.hidden = YES;
    self.bioTextView.hidden = YES;
    //call stylist profile WS
    [self profileAPI];
    
    self.serviceTypesTable.layer.borderWidth = 1.0;
    self.serviceTypesTable.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //add gesture to view, to open the left menu
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self.leftMenuBtn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Profile API
-(void)profileAPI
{
    //Allocate WebviewController
    webVC = [[WebserviceViewController alloc] init];
    webVC.delegate = self;
    [self.serviceTypesTable setHidden:YES];
    
    //Show Activity Indicator
    [Utility showActivity:self];
    
    [webVC getStylistProfile];
}

#pragma mark - ViewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    sharedObj = [SingletonClass shareManager];
    
    if([sharedObj.productAdded isEqualToString:@"YES"])
    {
        [sharedObj setProductAdded:@"NO"];
        [self profileAPI];
    }
}

#pragma mark - Handle Response
- (void)receivedResponse:(id)response
{
    if([response isEqualToString:@"GetStylistProfile"])
    {
        [Utility removeActivityIndicator];
        [self parseResponse];
    }
    
    else if ([response isEqualToString:@"ProdutDeleted"])
    {
        [self profileAPI];
        [Utility removeActivityIndicator];
        UIAlertView *updateProfileAlert = [[UIAlertView alloc]initWithTitle:@"Product" message:@"Deleted successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [updateProfileAlert show];
    }
    
    else if ([response caseInsensitiveCompare:@"Successfully Updated"] == NSOrderedSame)
    {
        [Utility removeActivityIndicator];
        //save the password in userdefaults
        //And reset stylistPassword to empty, if it has been changed in changed password screen
        if ([stylistPassword length] > 0) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:stylistPassword forKey:@"Password"];
            stylistPassword = @"";
        }
        UIAlertView *updateProfileAlert = [[UIAlertView alloc]initWithTitle:@"Profile" message:@"Updated successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        updateProfileAlert.tag = 1;
        [updateProfileAlert show];
    }
}

#pragma mark AlertButtin Clicked
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {//after comlpetion of profile updation
        [self profileAPI];
        self.bioTextView.hidden = YES;
        self.leftMenuBtn.hidden = NO;
        //self.stylistImageView.frame = CGRectMake(42, 35, 70, 70);
        /*self.imageViewHeightConstraint.constant = 70;
        self.imageViewWidthConstraint.constant = 70;
        self.stylistImageView.layer.cornerRadius = 35;
        self.imageViewXConstraint.constant = 42;
        self.imageViewYConstraint.constant = 35;*/
        [self updateFields:self.saveProfileBtn.tag];
    }
}



#pragma mark - Stylist Profile Response
-(void)parseResponse
{
    if([[[StylistFlowModel sharedInstance] stylistProfileData]count] > 0)
    {
        stylistProfileDictionary = [NSMutableDictionary dictionaryWithDictionary:[[StylistFlowModel sharedInstance] stylistProfileData]];
        //NSLog(@"resp = %@", stylistProfileDictionary);
        self.nameFld.text = [[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"name"];
        self.emailFld.text = [[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"email"];
        
        if(![[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"experience"] isKindOfClass:[NSNull class]])
        {
            self.expFld.text = [NSString stringWithFormat:@"%@ years experience",[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"experience"]];
        }
        
        else
        {
            self.expFld.text = @"0 year of experience";
        }
        
        if(![[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"location"] isKindOfClass:[NSNull class]] && [[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"location"] length] > 0)
        {
            self.locationFld.text = [[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"location"];
        }
        
        else
        {
            self.locationFld.placeholder = @"Enter Location";
        }
        
        if(![[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"mobile_phone"] isKindOfClass:[NSNull class]] && [[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"mobile_phone"] length] > 0)
        {
            if([[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"mobile_phone"] length] == 12)
            {
                NSString *fullNumber = [[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"mobile_phone"];
                fullNumber = [fullNumber stringByReplacingOccurrencesOfString:@"+1" withString:@""];
                self.phoneNumFld.text = fullNumber;
            }
        }
        
        else
        {
            self.phoneNumFld.placeholder = @"Enter PhNo";
        }
        
        NSString *imageURLString = [[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"photo_url"];
        
        if([imageURLString rangeOfString:@"missing.png"].location != NSNotFound)
        {
            self.stylistImageView.image = [UIImage imageNamed:@"default _stylist_image.png"];
        }
        
        else
        {
            self.stylistImageView.imageURL = [NSURL URLWithString:imageURLString];
        }
        
        if(![[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"bio"] isKindOfClass:[NSNull class]] && [[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"bio"] length] > 0)
        {
            self.bioTextView.text = [[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"bio"];
            self.bioTextView.textColor = [UIColor blackColor];
        }
        
        else
        {
            self.bioTextView.text = @"About Me";
            self.bioTextView.textColor = [UIColor darkGrayColor];
        }
        
        servicesList = [[NSMutableArray alloc]init];
        servicesList = [[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"services"] mutableCopy];
        
        if(servicesList.count > 0)
        {
            if(servicesList.count > 3)
            {
                if(IS_iPhone4SOR5)
                {
                    self.tableHeightConstraint.constant = self.view.frame.size.width/2 - 10;
                    //self.addServiceBtnVerticalSpaceConstraint.constant = 20;
                }
                
                else if (IS_iPhone6 || IS_iPhone6Plus)
                {
                    self.tableHeightConstraint.constant = 300;
                    //self.addServiceBtnVerticalSpaceConstraint.constant = 150;
                }
            }
            
            else
            {
                self.tableHeightConstraint.constant = servicesList.count * 50;
                
                if(IS_iPhone4SOR5)
                {
                    //self.addServiceBtnVerticalSpaceConstraint.constant = 20;
                }
                
                else if (IS_iPhone6 || IS_iPhone6Plus)
                {
                    //self.addServiceBtnVerticalSpaceConstraint.constant = 150;
                }
            }
            
            self.noServicesAvailableLbl.hidden = YES;
            self.serviceTypesTable.hidden = NO;
            [self.serviceTypesTable reloadData];
        }
        
        else
        {
            self.noServicesAvailableLbl.hidden = NO;
            
            if(IS_iPhone4SOR5)
            {
                //self.addServiceBtnVerticalSpaceConstraint.constant = 60;
            }
            
            else if (IS_iPhone6)
            {
                //self.addServiceBtnVerticalSpaceConstraint.constant = self.view.frame.size.width/3;
            }
            
            self.serviceTypesTable.hidden = YES;
        }
    }
}

#pragma mark - Handle Error
- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:errorTitle message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return NO;
}

#pragma mark - Layout Subviews
- (void)viewDidLayoutSubviews
{
    
}

#pragma mark - changePhoto
-(void)changePhoto
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (popup.tag)
    {
        case 1:
        {
            switch (buttonIndex)
            {
                case 0:
                    [self openCamera];
                    break;
                case 1:
                    [self openGallery];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Open Camera
-(void)openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Camera not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:picker animated:YES completion:nil];
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

#pragma mark - Open Gallery
-(void)openGallery
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Camera not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate=self;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - imagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    chosenImage = editingInfo[UIImagePickerControllerOriginalImage];
    //[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(chosenImage)  forKey:@"savedImage"];
    self.stylistImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Textfield Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,-150,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    
    if([self.bioTextView.text isEqualToString:@"About Me"])
    {
        self.bioTextView.text = @"";
        self.bioTextView.textColor = [UIColor blackColor];
    }
    
    else
    {
        self.bioTextView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

/*-(void)textViewDidChange:(UITextView *)textView
{
    if(self.bioTextView.text.length == 0)
    {
        self.bioTextView.textColor = [UIColor darkGrayColor];
        self.bioTextView.text = @"About Me";
    }
}*/

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    if (![self.bioTextView hasText])
    {
        self.bioTextView.textColor = [UIColor darkGrayColor];
        self.bioTextView.text = @"About Me";
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)buttonActions:(UIButton *)sender {
    if (sender.tag == 1) {//change password
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ChangePasswordViewController *changePwdController = [storyBoard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
        changePwdController.delegate = self;
        [self presentViewController:changePwdController animated:YES completion:nil];
    }
    else if (sender.tag == 2) {//edit profile
        
        if(self.view.frame.size.height < 600)
        {
            self.bgScroll.scrollEnabled = YES;
            [self.bgScroll setContentSize:CGSizeMake(self.bgScroll.frame.size.width, self.view.frame.size.height+50)];
        }
        
        self.bioTextView.hidden = NO;
        self.addServiceBtnVerticalSpaceConstraint.constant = 116;
        /*self.stylistImageView.frame = CGRectMake(40, 10, 100, 100);
        self.imageViewHeightConstraint.constant = 100;
        self.imageViewWidthConstraint.constant = 100;
        self.imageViewXConstraint.constant = 40;
        self.imageViewYConstraint.constant = 10;
        self.stylistImageView.layer.cornerRadius = 50;*/
        //[self.stylistImageView updateConstraintsIfNeeded];
        self.leftMenuBtn.hidden = YES;
        [self updateFields:sender.tag];
    }
    else if (sender.tag == 3) {//save changes
        self.bgScroll.scrollEnabled = NO;
        [self.bioTextView resignFirstResponder];
        [self saveProfile];
    }
    else if (sender.tag == 4) {//logout
        //remove shared instances
        [StylistFlowModel removeSharedInstance];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if (sender.tag == 5) {//add services
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddServiceViewController *addService = [storyBoard instantiateViewControllerWithIdentifier:@"AddServiceViewControllerSB"];
        [self.navigationController presentViewController:addService animated:NO completion:nil];
    }
}

- (void)updateFields:(NSInteger)tag {
    //self.logoutBtn.hidden = tag == 2 ? YES : NO;
    self.addServiceBtn.hidden = tag == 2 ? NO : YES;
    self.changePwdBtn.enabled = tag == 2 ? YES : NO;
    
    self.stylistImageView.userInteractionEnabled = tag == 2 ? YES : NO;
    self.nameFld.userInteractionEnabled = tag == 2 ? YES : NO;
    self.emailFld.userInteractionEnabled = tag == 2 ? YES : NO;
    self.phoneNumFld.userInteractionEnabled = tag == 2 ? YES : NO;
    self.expFld.userInteractionEnabled = tag == 2 ? YES : NO;
    self.locationFld.userInteractionEnabled = tag == 2 ? YES : NO;
    
    if (tag == 3) {
        self.nameFld.borderStyle = UITextBorderStyleLine;
        self.emailFld.borderStyle = UITextBorderStyleLine;
        self.phoneNumFld.borderStyle = UITextBorderStyleLine;
        self.expFld.borderStyle = UITextBorderStyleLine;
        self.locationFld.borderStyle = UITextBorderStyleLine;
        
        self.nameFld.borderStyle = UITextBorderStyleNone;
        self.emailFld.borderStyle = UITextBorderStyleNone;
        self.phoneNumFld.borderStyle = UITextBorderStyleNone;
        self.expFld.borderStyle = UITextBorderStyleNone;
        self.locationFld.borderStyle = UITextBorderStyleNone;
    }
    else {
        self.nameFld.borderStyle = UITextBorderStyleBezel;
        self.emailFld.borderStyle = UITextBorderStyleBezel;
        self.phoneNumFld.borderStyle = UITextBorderStyleBezel;
        self.expFld.borderStyle = UITextBorderStyleBezel;
        self.locationFld.borderStyle = UITextBorderStyleBezel;
    }
    
    self.dotLbl.layer.borderWidth = tag == 2 ? 1 : 0;
    self.dotLbl.clipsToBounds = tag == 2 ? YES : NO;
    self.dotLbl.layer.cornerRadius = tag == 2 ? 3 : 0;
    
    self.changePwdBtn.layer.cornerRadius = tag == 2 ? 5 : 0;
    self.saveProfileBtn.layer.cornerRadius = tag == 2 ? 5 : 0;
    self.headingView.layer.cornerRadius = tag == 2 ? 3 : 0;
    
    self.serviceTypesTable.layer.borderWidth = tag == 2 ? 1.0f : 0;
    self.serviceTypesTable.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.serviceTypesTable.layer.cornerRadius = tag == 2 ? 5 : 0;
    
    if (tag == 2) {
        if (cameraIconImg == nil) {
            //Camera Icon
            cameraIconImg = [[UIImageView alloc]init];
            cameraIconImg.frame = CGRectMake(self.stylistImageView.frame.size.width-40, self.stylistImageView.frame.size.height-30, 25, 25);
            cameraIconImg.image = [UIImage imageNamed:@"update-picture-icon"];
            [self.stylistImageView addSubview:cameraIconImg];
            ///add tap gesture to profile imageview
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changePhoto)];
            tapGesture.delegate = self;
            tapGesture.numberOfTapsRequired = 1;
            tapGesture.numberOfTouchesRequired = 1;
            [self.stylistImageView addGestureRecognizer:tapGesture];
        }
        else {
            cameraIconImg.hidden = NO;
            self.stylistImageView.userInteractionEnabled = YES;
        }
    }
    else {
        cameraIconImg.hidden = YES;
        self.stylistImageView.userInteractionEnabled = NO;
    }
    
    //Disable Set Schedule and Appointments Tab
    [[[[self.tabBarController tabBar] items] objectAtIndex:0] setEnabled:tag == 2 ? NO : YES];
    [[[[self.tabBarController tabBar] items] objectAtIndex:1] setEnabled:tag == 2 ? NO : YES];
    
    if (tag == 2) {
        self.saveProfileBtn.tag = 3;
        [self.saveProfileBtn setTitle:@"Save Changes" forState:UIControlStateNormal];
    }
    else {
        self.saveProfileBtn.tag = 2;
        [self.saveProfileBtn setTitle:@"Edit Profile" forState:UIControlStateNormal];
    }
    [self.serviceTypesTable reloadData];
}

#pragma mark - Save Profile
-(void)saveProfile
{
    webVC = [[WebserviceViewController alloc] init];
    webVC.delegate = self;
    
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    
    NSData *dataOfStylistLicenceImage = UIImageJPEGRepresentation(chosenImage, 0.5F);
    NSString *base64StringOfStylistProfileImage = [dataOfStylistLicenceImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSMutableDictionary *profileDictionary = [[NSMutableDictionary alloc]init];
    NSMutableArray *pictureList= [[NSMutableArray alloc]init];
    
    if(base64StringOfStylistProfileImage)
    {
        [profileDictionary setObject:base64StringOfStylistProfileImage forKey:@"data"];
        [profileDictionary setObject:@"photo" forKey:@"file_name"];
        [pictureList addObject:profileDictionary];
    }
    
    [postDictionary setObject:[self.nameFld.text lowercaseString] forKey:@"name"];
    //[postDictionary setObject:@"20101980" forKey:@"dob"];
    if ([stylistPassword length] > 0)
        [postDictionary setObject:stylistPassword forKey:@"password"];
    
    if(self.bioTextView.text.length > 0 && ![self.bioTextView.text isEqualToString:@"About Me"])
    {
        [postDictionary setObject:self.bioTextView.text forKey:@"bio"];
    }
    
    [postDictionary setObject:self.emailFld.text forKey:@"email"];
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(userAccount.deviceToken.length > 0)
    {
        [postDictionary setObject:userAccount.deviceToken forKey:@"device_token"];
    }
    
    NSArray *arr = [self.expFld.text componentsSeparatedByString:@" "];
    
    [postDictionary setObject:[arr objectAtIndex:0] forKey:@"experience"];
    [postDictionary setObject:self.phoneNumFld.text forKey:@"mobile_phone"];
    [postDictionary setObject:pictureList forKey:@"pictures"];
    
    if(![[[stylistProfileDictionary objectForKey:@"partner"]objectForKey:@"location"] isEqualToString:self.locationFld.text])
    {
        NSMutableDictionary *locationDictionary = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *locDict = [[NSMutableDictionary alloc]init];
        [locDict setObject:self.locationFld.text forKey:@"address"];
        [locationDictionary setObject:locDict forKey:@"location"];
        [postDictionary setObject:locationDictionary forKey:@"partner"];
    }
    
    if (self.phoneNumFld.text.length != 10)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Invalid Phone" message:@"Please enter valid phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if (self.phoneNumFld.text.length == 10)
    {
        [Utility showActivity:self];
        
        //Calling webservice
        [webVC updateProfile:postDictionary];
    }
}

#pragma mark FetchStylistPassword delegate
- (void)getStylistPassword:(NSString *)passwordString {
    stylistPassword = passwordString;
}

#pragma mark - TableView Delegates and Datasources
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return servicesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *serviceTableCell = [tableView dequeueReusableCellWithIdentifier:@"updateServicesTableCell"];
    serviceTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *serviceLabel = (UILabel*) [serviceTableCell viewWithTag:1];
    UILabel *priceLabel = (UILabel*) [serviceTableCell viewWithTag:2];
    
    serviceLabel.text = [[servicesList objectAtIndex:indexPath.row]objectForKey:@"name"];
    priceLabel.text = [NSString stringWithFormat:@"$%@.00",[[servicesList objectAtIndex:indexPath.row] objectForKey:@"price"]];
    priceLabel.adjustsFontSizeToFitWidth = YES;
    
    UIButton *deleteServiceBtn = (UIButton *)[serviceTableCell.contentView viewWithTag:100];
    if (self.saveProfileBtn.tag == 3) {
        deleteServiceBtn.hidden = NO;
        [deleteServiceBtn addTarget:self action:@selector(deleteStylistService:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        deleteServiceBtn.hidden = YES;
    }
    
    return serviceTableCell;
}

-(void)deleteStylistService:(UIButton *)sender
{
    NSIndexPath *indexPath = [self getButtonIndexPath:sender];
    
    //Allocate WebviewController
    webVC = [[WebserviceViewController alloc] init];
    webVC.delegate = self;
    
    //Show Activity Indicator
    [Utility showActivity:self];
    
    //Get Previous Schedules
    [webVC deleteProduct:[[servicesList objectAtIndex:indexPath.row]objectForKey:@"product_id"]];
    
    [servicesList removeObjectAtIndex:indexPath.row];
    
    [self.serviceTypesTable beginUpdates];
    [self.serviceTypesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.serviceTypesTable endUpdates];
    [self.serviceTypesTable reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(NSIndexPath *)getButtonIndexPath:(UIButton *) button
{
    CGRect buttonFrame = [button convertRect:button.bounds toView:self.serviceTypesTable];
    return [self.serviceTypesTable indexPathForRowAtPoint:buttonFrame.origin];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.serviceTypesTable deselectRowAtIndexPath:indexPath animated:YES];
}

@end
