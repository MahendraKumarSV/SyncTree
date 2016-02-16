//
//  AddCreditCardViewController.m
//  ParlorMe

#import "AddCreditCardViewController.h"

#import "WebserviceViewController.h"
#import "Utility.h"
#import "WebserviceViewController.h"
#import "UserAccount.h"

@interface AddCreditCardViewController ()<WebserviceViewControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer* tapGesture;
    BOOL isNonceRelatedError;
}
@property (weak, nonatomic) IBOutlet UITextField *cardNameTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *expirationDateTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *billingZipCodeTxtFld;
@property (weak, nonatomic) IBOutlet UIButton *saveCreditCardButton;
@property (nonatomic, strong) Braintree *braintree;

- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)saveCreditCardButtonTapped:(id)sender;
- (IBAction)next:(id)sender;

@end

@implementation AddCreditCardViewController

#pragma mark-view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clientToken = @"";
    isNonceRelatedError = NO;
    
    // to add bottom layer to all text fields
    [self ChangeTextfieldBorder:self.cardNameTxtFld];
    [self ChangeTextfieldBorder:self.cardNumberTxtFld];
    [self ChangeTextfieldBorder:self.expirationDateTxtFld];
    [self ChangeTextfieldBorder:self.billingZipCodeTxtFld];
    
    // to change UI of saveCredit Button
    self.saveCreditCardButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
    self.saveCreditCardButton.layer.borderWidth=1.0f;
    self.saveCreditCardButton.layer.cornerRadius=3.0f;
    
    // Adding Tap gesture to hide keyboard on single tap
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark- Tap Gesture

-(IBAction)tapped
{
    [self.view endEditing:YES];
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

#pragma mark- close button action

- (IBAction)closeButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- save credit card button action

- (IBAction)saveCreditCardButtonTapped:(id)sender
{
    [self tapped];
    
    BOOL isAllInfoFilled = YES;
    NSString *cardNumberPattern = @"[0-9]{16}";
    NSPredicate *cardNumberPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cardNumberPattern];
    
    NSString *expiryDatePattern = @"[0-9]{2}/[0-9]{4}";
    NSPredicate *expiryDatePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expiryDatePattern];
    
    NSString *billingZipCodePattern = @"[0-9]{5}";
    NSPredicate *billingZipCodePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", billingZipCodePattern];
    
    
    NSString *cardNumber = [_cardNumberTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *expiryDate = [_expirationDateTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *billingZipCode = [_billingZipCodeTxtFld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *expiryMonthYearArray = [expiryDate componentsSeparatedByString:@"/"];
    
    for (int counter = 0; counter < 4; counter++)
    {
        UITextField *currentTextfield = (UITextField *)[self.view viewWithTag:601+counter];
        
        NSString *info = [currentTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(!info || [info length] == 0)
        {
            isAllInfoFilled = NO;
            break;
        }
        else
        {
            isAllInfoFilled = YES;
        }
    }
    
    // check for validations
    if(isAllInfoFilled)
    {
        if (![cardNumberPred evaluateWithObject:cardNumber])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Number" message:@"Please provide valid card number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if(![expiryDatePred evaluateWithObject:expiryDate]|| expiryMonthYearArray.count <= 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Expiry Date" message:@"Please provide valid expiry date" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if ([[expiryMonthYearArray objectAtIndex:0]integerValue] > 12 || [[expiryMonthYearArray objectAtIndex:0]integerValue] <= 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Expiry Month" message:@"Please provide valid expiry month" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if ([[expiryMonthYearArray objectAtIndex:1]integerValue] < 2015)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Expiry Year" message:@"Please provide valid expiry year" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if(![billingZipCodePred evaluateWithObject:billingZipCode])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Billing Zip Code" message:@"Please provide valid billing zip code" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            [Utility showActivity:self];
            //NSLog(@"%@",self.clientToken);
            
            UserAccount *userAccount = [UserAccount sharedInstance];
            
            self.braintree = [Braintree braintreeWithClientToken:userAccount.clientToken];
            NSArray *expirationMonthYearArray = [_expirationDateTxtFld.text componentsSeparatedByString:@"/"];
            
            BTClientCardRequest *request = [BTClientCardRequest new];
            request.number = _cardNumberTxtFld.text;
            
            request.expirationMonth = [expirationMonthYearArray objectAtIndex:0];
            request.expirationYear = [expirationMonthYearArray objectAtIndex:1];
            
            //NSString *creditCardNonce;
            
            [self.braintree tokenizeCard:request completion:^(NSString *nonce, NSError *error)
             {
                 // Communicate the nonce to your server, or handle error
                 //NSLog(@"I am here %@",nonce);
                 
                 if(error)
                 {
                     isNonceRelatedError = YES;
                 }
                 else if (nonce)
                 {
                     WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
                     webserviceViewController.delegate = self;
                     isNonceRelatedError = NO;
                     // currentAPICalled = kGetAddressList;
                     [webserviceViewController saveCreditCard:nonce];
                 }
                 
             }];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information Required." message:@"Please provide all required details" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    if(isNonceRelatedError)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed." message:@"Not able to proceed with this card" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - textfield delegates

// to move textfields up/down when Keyboard shows/hides
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //    if(textField.tag == 605)
    //    {
    //        [self.scrollViewSlider setContentOffset:CGPointMake(0, 100)];
    //    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //    if(textField.tag == 605)
    //    {
    //        [self.scrollViewSlider setContentOffset:CGPointMake(0, 0)];
    //    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if(newLength > 20 && textField.tag == 601)
    {
        return NO;
    }
    else if(newLength > 16 && textField.tag == 602)
    {
        return NO;
    }
    else if(newLength > 7 && textField.tag == 603)
    {
        return NO;
    }
    else if(newLength > 5 && textField.tag == 604)
    {
        return NO;
    }
    else
    {
        return YES;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - Other Methods

// to bring focus to next text field
- (IBAction)next:(id)sender
{
    UITextField *currentTextfield=(UITextField *)sender;
    
    UITextView *newResponder=(UITextView*)[self.view viewWithTag:currentTextfield.tag+1];
    [newResponder becomeFirstResponder];
}

#pragma mark-webservice delegates

- (void)receivedResponse:(id)response
{
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"])
    {
        if([_delegate respondsToSelector:@selector(getSavedCreditCards)])
        {
            [_delegate getSavedCreditCards];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to add card." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to add card." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
