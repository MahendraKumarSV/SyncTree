//
//  StylistSignUpViewController.m
//  ParlorMe
//

#import "StylistSignUpTwoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "StylistSignUpThreeViewController.h"
#import "StylistSignUpOneViewController.h"
#import "SingletonClass.h"

@interface StylistSignUpTwoViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,StylistSignUpThreeViewControllerDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    NSArray *placeholderList;
    long tag;
    UITapGestureRecognizer *tapGesture;
}
@property (weak, nonatomic) IBOutlet UIView *licensesView;
@property (weak, nonatomic) IBOutlet UITextField *txtfldSSNFront;
@property (weak, nonatomic) IBOutlet UITextField *txtfldSSNMiddle;
@property (weak, nonatomic) IBOutlet UITextField *txtfldSSNLast;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewSlider;
@property (weak, nonatomic) IBOutlet UIButton *basicInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *licenseBtn;
@property (weak, nonatomic) IBOutlet UIButton *stylistLicenseBtn;
@property (weak, nonatomic) IBOutlet UIButton *driversLicenseBtn;
@property (weak, nonatomic) IBOutlet UITextField *txtfldZipCode;

- (IBAction)continueLicenseViewButtonTapped:(id)sender;
- (IBAction)stylistLicenseButtonTapped:(UIButton*)sender;
- (IBAction)driversLicenseButtonTapped:(UIButton*)sender;
- (IBAction)basicInfoButtonTapped:(id)sender;
- (IBAction)licenseButtonTapped:(id)sender;
- (IBAction)submitTopButtonTapped:(id)sender;
- (IBAction)next:(UITextField*)sender;

@end

@implementation StylistSignUpTwoViewController
@synthesize basicInfoList,stylistLicensephoto,stylistDriverLicensephoto,ssnFront,ssnLast,ssnMiddle,zipCode;

#pragma mark-view life cycle method

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self ChangeTextfieldBorder:_txtfldSSNFront];
    [self ChangeTextfieldBorder:_txtfldSSNMiddle];
    [self ChangeTextfieldBorder:_txtfldSSNLast];
    [self ChangeTextfieldBorder:_txtfldZipCode];
    
    self.stylistLicenseBtn.layer.borderColor = [[UIColor blackColor]CGColor];
    self.stylistLicenseBtn.layer.borderWidth = 1.0f;
    
    self.driversLicenseBtn.layer.borderColor = [[UIColor blackColor]CGColor];
    self.driversLicenseBtn.layer.borderWidth = 1.0f;
    
    [_txtfldSSNFront setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtfldSSNMiddle setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtfldSSNLast setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    placeholderList = [[NSArray alloc]initWithObjects:@"fullname",@"email address",@"password",@"birthday",@"mobile phone#", nil];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.basicInfoBtn setImage:[UIImage imageNamed:@"step-complete"] forState:UIControlStateNormal];
    [self.scrollViewSlider scrollRectToVisible:CGRectMake(0, 0, 1, 1)
                                      animated:NO];
    
    if(self.stylistLicensephoto != [UIImage imageNamed:@""])
        [self.stylistLicenseBtn setImage:self.stylistLicensephoto forState:UIControlStateNormal];
    else
        [self.stylistLicenseBtn setImage:[UIImage imageNamed:@"add-photo-button.png"] forState:UIControlStateNormal];
    
    if(self.stylistDriverLicensephoto != [UIImage imageNamed:@""])
        [self.driversLicenseBtn setImage:self.stylistDriverLicensephoto forState:UIControlStateNormal];
    else
        [self.driversLicenseBtn setImage:[UIImage imageNamed:@"add-photo-button.png"] forState:UIControlStateNormal];
    
    _txtfldSSNFront.text = self.ssnFront;
    _txtfldSSNMiddle.text = self.ssnMiddle;
    _txtfldSSNLast.text = self.ssnLast;
    _txtfldZipCode.text = self.zipCode;
    
    [[SingletonClass shareManager]showBackBtn:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if([_delegate respondsToSelector:@selector(changeImage:andImage:)])
    {
        [_delegate changeImage:self.stylistLicensephoto andImage:self.stylistDriverLicensephoto];
        [_delegate changeSSN:_txtfldSSNFront.text andSSNMiddle:_txtfldSSNMiddle.text andSSNLast:_txtfldSSNLast.text andZipCode:_txtfldZipCode.text];
    }
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
    
    [self.stylistLicenseBtn setImage:self.stylistLicensephoto forState:UIControlStateNormal];
    [self.driversLicenseBtn setImage:self.stylistDriverLicensephoto forState:UIControlStateNormal];
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

#pragma mark- Continue Button Tapped

- (IBAction)continueLicenseViewButtonTapped:(id)sender
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
    
    for(int i = 0; i < 4; i++)
    {
        UITextField *basicInfoTextField = (UITextField *)[self.licensesView viewWithTag:981+i];
        NSString *infoText = [basicInfoTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(!infoText || [infoText length] == 0)
        {
            isAllInfoFilled = NO;
            break;
        }
        
    }
    
    if(isAllInfoFilled)
    {
        if (![zipCodePred evaluateWithObject:_txtfldZipCode.text])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Zip Code" message:@"Please provide valid zip code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else if (![ssnFrontPred evaluateWithObject:_txtfldSSNFront.text])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SSN" message:@"Please provide valid SSN number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else if (![ssnMiddlePred evaluateWithObject:_txtfldSSNMiddle.text])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SSN" message:@"Please provide valid SSN number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else if (![ssnLastPred evaluateWithObject:_txtfldSSNLast.text])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SSN" message:@"Please provide valid SSN number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else
        {
            self.ssnFront = _txtfldSSNFront.text;
            self.ssnMiddle = _txtfldSSNMiddle.text;
            self.ssnLast = _txtfldSSNLast.text;
            self.zipCode = _txtfldZipCode.text;
            
            [self.licenseBtn setAlpha:1.0];
            [self.licenseBtn setBackgroundColor:[UIColor clearColor]];
            [self.licenseBtn setImage:[UIImage imageNamed:@"step-complete"] forState:UIControlStateNormal];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            StylistSignUpThreeViewController *stylistSignUpThreeViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistSignUp3SB"];
            stylistSignUpThreeViewController.basicInfoList = basicInfoList;
            stylistSignUpThreeViewController.stylistDriverLicensephoto = self.stylistDriverLicensephoto;
            stylistSignUpThreeViewController.stylistLicensephoto = self.stylistLicensephoto;
            stylistSignUpThreeViewController.ssnFront = self.ssnFront;
            stylistSignUpThreeViewController.ssnMiddle = self.ssnMiddle;
            stylistSignUpThreeViewController.ssnLast = self.ssnLast;
            stylistSignUpThreeViewController.zipCode = self.zipCode;
            stylistSignUpThreeViewController.delegate = self;
            [self.navigationController pushViewController:stylistSignUpThreeViewController animated:YES];
        }
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information Required." message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark- Add Stylist License Image button Tapped

- (IBAction)stylistLicenseButtonTapped:(UIButton*)sender
{
    [self.view endEditing:YES];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select from gallery", @"Take a new picture", nil];
    tag = sender.tag;
    [sheet showInView:self.view];
}

#pragma mark- Add Driver License Image button Tapped

- (IBAction)driversLicenseButtonTapped:(UIButton*)sender
{
    [self.view endEditing:YES];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select from gallery", @"Take a new picture", nil];
    tag = sender.tag;
    [sheet showInView:self.view];
}

#pragma mark - Basic Info button Tapped

- (IBAction)basicInfoButtonTapped:(id)sender
{
    for (id viewController in [self.navigationController viewControllers])
    {
        if ([viewController isKindOfClass:[StylistSignUpOneViewController class]])
        {
            self.delegate = viewController;
            [viewController changeImage:self.stylistLicensephoto andImage:self.stylistDriverLicensephoto];
            [viewController changeSSN:_txtfldSSNFront.text andSSNMiddle:_txtfldSSNMiddle.text andSSNLast:_txtfldSSNLast.text andZipCode:_txtfldZipCode.text];
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
    //[self continueLicenseViewButtonTapped:sender];
}

- (IBAction)next:(UITextField*)sender
{
    UITextField *nextTextfield = (UITextField *)[self.view viewWithTag:sender.tag+1];
    [nextTextfield becomeFirstResponder];
    
    if(sender.tag == 984)
    {
        [self continueLicenseViewButtonTapped:sender];
    }
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
    
    if(tag == 670)
    {
        self.stylistLicensephoto = photo;
        [self.stylistLicenseBtn setImage:photo forState:UIControlStateNormal];
    }
    
    else if(tag == 671)
    {
        self.stylistDriverLicensephoto = photo;
        [self.driversLicenseBtn setImage:photo forState:UIControlStateNormal];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - textfield delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[self animateTextField: textField up: YES];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(textField.tag == 981 || textField.tag == 984)
    {
        [self.scrollViewSlider setContentOffset:CGPointMake(0, 200)];
    }
    
    //[self.scrollViewSlider setContentOffset:CGPointMake(0, 200)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if(textField.tag == 984)
    {
        //[self animateTextField: textField up: NO];
        [self.scrollViewSlider setContentOffset:CGPointMake(0, 0)];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 300; // tweak as needed
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
    
    if(newLength > 3 && textField.tag == 981)
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

@end
