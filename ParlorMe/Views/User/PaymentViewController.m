//
//  PaymentViewController.m
//  ParlorMe
//

@import PassKit;

#import "PaymentViewController.h"
#import <Braintree/Braintree.h>

#import "WebserviceViewController.h"
#import "Utility.h"
#import "StylistDetails.h"
#import "UserAccount.h"
#import "Constants.h"
#import "CreditCardCustomTableViewCell.h"
#import "AddCreditCardViewController.h"
#import "StylistDetails.h"
#import "CoreDataModel.h"
#import "SettingsViewController.h"
#import "SingletonClass.h"
#import "ConfirmationViewController.h"

@interface PaymentViewController ()<WebserviceViewControllerDelegate,SaveCreditCardDelegate,PKPaymentAuthorizationViewControllerDelegate>
{
    UISwipeGestureRecognizer * swiperight;
    UISwipeGestureRecognizer * swipeleft;
    BOOL isexpanded;
    NSMutableArray *subCategoryList;
    NSMutableDictionary *selectedServices;
    StylistDetails *selectedStylist;
    float totalAmount;
    NSMutableDictionary *priceDictionary;
    NSMutableDictionary *categoryDictionary;
    NSArray *selectedAddress;
    NSString *currentAPICalled;
    NSArray *userCreditCardList;
    int selectedCreditCardButtonTag;
    BOOL isCreditCardSelected;
    BOOL iswebServiceFailed;
    BOOL isOrderComplete;
    NSMutableArray *productIds;
    NSString *selectedStylistName;
    NSString *selectedDateTime;
}
@property (nonatomic, strong) Braintree *braintree;
@property (weak, nonatomic) IBOutlet UITableView *paymentTableView;

@end

@implementation PaymentViewController

#pragma mark-view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // to check if table is expanded or not
    isexpanded=NO;
    totalAmount = 0;
    subCategoryList = [[NSMutableArray alloc]init];
    selectedServices = [[NSMutableDictionary alloc]init];
    selectedStylist = [[StylistDetails alloc]init];
    selectedAddress = [[NSArray alloc]init];
    currentAPICalled = @"";
    userCreditCardList = [[NSArray alloc]init];
    selectedCreditCardButtonTag = 0;
    isCreditCardSelected = NO;
    iswebServiceFailed = NO;
    isOrderComplete = NO;
    productIds = [[NSMutableArray alloc]init];
    selectedStylistName = @"";
    
    for(int counter = 0; counter < 2; counter++)
    {
        UIButton *bottomBarButton = (UIButton*)[self.view viewWithTag:(9090 + counter)];
        bottomBarButton.layer.borderColor = [[UIColor blackColor]CGColor];
        bottomBarButton.layer.borderWidth = 2.0f;
    }
    
    // adding swipe left gesture
    swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.paymentTableView addGestureRecognizer:swipeleft];
    
    // adding swipe right gesture
    swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.paymentTableView addGestureRecognizer:swiperight];
    
    [self getClientToken];
    [self getSavedCreditCards];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[SingletonClass shareManager]showBackBtn:self];
    
    self.navigationItem.title = @"Payment";
    
    if (iswebServiceFailed && currentAPICalled == kGetClientToken)
    {
        [self getClientToken];
    }
    else if (iswebServiceFailed && currentAPICalled == kGetCreditCardList)
    {
        [self getSavedCreditCards];
    }
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    selectedServices = [NSMutableDictionary dictionaryWithDictionary:userAccount.selectedServicesList];
    subCategoryList = [NSMutableArray arrayWithArray:userAccount.selectedsubCategoryList];
    selectedAddress = userAccount.selectedUserAddress;
    selectedStylistName = userAccount.selectedStylistName;
    
    StylistDetails *stylistObj = [StylistDetails sharedInstance];
    selectedStylist = stylistObj.selectedStylist;
    priceDictionary =  [NSMutableDictionary dictionaryWithDictionary:stylistObj.stylistServicePriceDict];
    categoryDictionary = [NSMutableDictionary dictionaryWithDictionary:stylistObj.stylistCategoryPriceDict];
    
    [self getUserData];
    
    if(userAccount.fromTime)
    {
        NSString *dateString = userAccount.selectedDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *date = [dateFormatter dateFromString:dateString];
        // converting into our required date format
        [dateFormatter setDateFormat:@"EEEE MMMM dd"];
        NSString *reqDateString = [dateFormatter stringFromDate:date];
        
        NSString *reqTimeString = [[userAccount.fromTime uppercaseString] stringByReplacingOccurrencesOfString:@"AM" withString:@" AM"];
        reqTimeString = [[reqTimeString uppercaseString] stringByReplacingOccurrencesOfString:@"PM" withString:@" PM"];
        
        selectedDateTime = [NSString stringWithFormat:@"%@ @ %@", reqDateString, reqTimeString];
    }
    else
    {
        selectedDateTime = @"";
    }
    
    [self.paymentTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Apple Pay related methods

- (UIButton *)applePayButton
{
    UIButton *button;
    
    if ([PKPaymentButton class])
    { // Available in iOS 8.3+
        button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
    }
    
    [button addTarget:self action:@selector(tappedApplePay) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (PKPaymentRequest *)paymentRequest
{
    // Check device can make Apple Pay
    if ([PKPaymentAuthorizationViewController canMakePayments])
    {
        //NSLog(@"Can Make Payments");
    }
    
    else
    {
        //NSLog(@"Can't Make payments");
        return nil;
    }
    
    //-----------/----------/----------/----------/----------
    
    // Payment cards what we can accept
    NSArray *paymentNetworks = [NSArray arrayWithObjects:PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkAmex, nil];
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:paymentNetworks])
    {
        //NSLog(@"Can Make payment with Visa, Mastercard");
    }
    else
    {
        //NSLog(@"Card is not supporting");
        return nil;
    }
    
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = @"merchant.2k6yjgx755pgkx7g";
    paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.countryCode = @"US"; // e.g. US
    paymentRequest.currencyCode = @"USD"; // e.g. USD
    
    NSMutableArray *paymentSummaryItems = [[NSMutableArray alloc]init];
    
    [paymentSummaryItems removeAllObjects];
    
    for(NSString *item in subCategoryList)
    {
        float priceValue = [[priceDictionary objectForKey:item]floatValue];
        
        PKPaymentSummaryItem *summaryItem = [PKPaymentSummaryItem summaryItemWithLabel:item amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.02f", priceValue]]];
        [paymentSummaryItems addObject:summaryItem];
    }
    
    PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.02f",[self getTotalAmount]]]];
    [paymentSummaryItems addObject:total];
    paymentRequest.paymentSummaryItems = paymentSummaryItems;
    
    return paymentRequest;
}

- (void)tappedApplePay
{
    if(isOrderComplete)
    {
        [self showOrderPlacedAlert];
        return;
    }
    
    PKPaymentRequest *paymentRequest = [self paymentRequest];
    PKPaymentAuthorizationViewController *paymentAuthorizationViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    paymentAuthorizationViewController.delegate = self;
    if(paymentAuthorizationViewController)
        [self presentViewController:paymentAuthorizationViewController animated:YES completion:nil];
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Apple Pay." message:@"Payments cannot be made using this device" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    // NSLog(@"%@",self.braintree);
    if(!self.braintree)
    {   UserAccount *userAccount = [UserAccount sharedInstance];
        self.braintree = [Braintree braintreeWithClientToken:userAccount.clientToken];
    }
    
    // Tokenize the Apple Pay payment
    [self.braintree tokenizeApplePayPayment:payment
                                 completion:^(NSString *nonce, NSError *error)
     {
         if (error)
         {
             // Received an error from Braintree.
             // Indicate failure via the completion callback.
             isOrderComplete = NO;
             completion(PKPaymentAuthorizationStatusFailure);
             return;
         }
         else
         {
             [self completePaymentUsingApplePay:nonce];
             completion(PKPaymentAuthorizationStatusSuccess);
         }
         
         //[NSException raise:@"Not yet implemented" format:@"Send nonce (%@) to your server", nonce];
         
         // On success, send nonce to your server for processing.
         // If applicable, address information is accessible in payment.
         // Then indicate success or failure via the completion callback, e.g.
         //
         //
     }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- get total amount of selected services

- (float)getTotalAmount
{
    totalAmount = 0;
    
    for(id item in subCategoryList)
    {
        totalAmount += [[priceDictionary valueForKey:item]floatValue];
    }
    
    return totalAmount;
}

#pragma mark- get list of saved credit card

- (void)getSavedCreditCards
{
    [Utility showActivity:self];
    WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
    webserviceViewController.delegate = self;
    currentAPICalled = kGetCreditCardList;
    [webserviceViewController getCreditCardList];
}

#pragma mark- get Client token

- (void)getClientToken
{
    [Utility showActivity:self];
    WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
    webserviceViewController.delegate = self;
    currentAPICalled = kGetClientToken;
    [webserviceViewController getClientToken];
}

#pragma mark- get user data from data base

- (void)getUserData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    StylistDetails *stylistObj = [StylistDetails sharedInstance];
    
    if(!userAccount.userId)
    {
        return;
    }
    
    NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    if(userRecords.count>0)
    {
        User *currentUser = [userRecords objectAtIndex:0];
        
        if(currentUser.selectedServices.allObjects.count>0)
        {
            [priceDictionary removeAllObjects];
            [categoryDictionary removeAllObjects];
            [productIds removeAllObjects];
            [subCategoryList removeAllObjects];
            [selectedServices removeAllObjects];
            
            NSArray *serviceSelectedByUser = currentUser.selectedServices.allObjects;
            
            for(Services *selectedServicesObj in serviceSelectedByUser)
            {
                [priceDictionary  setValue:selectedServicesObj.price forKey:selectedServicesObj.name];
                [categoryDictionary  setValue:selectedServicesObj.categoryName forKey:selectedServicesObj.name];
                [productIds  addObject:selectedServicesObj.productId];
                [subCategoryList addObject:selectedServicesObj.name];
                [selectedServices setValue:selectedServicesObj.categoryName forKey:selectedServicesObj.name];
            }
            userAccount.selectedServicesList = selectedServices;
            userAccount.selectedsubCategoryList = subCategoryList;
            stylistObj.stylistCategoryPriceDict = categoryDictionary;
            stylistObj.stylistServicePriceDict = priceDictionary;
            userAccount.selectedStylistName = currentUser.selectedStylistName;
            selectedStylistName = currentUser.selectedStylistName;
        }
        
        if([currentUser.isAddressSelected isEqualToString:@"Yes"])
        {
            Address *selectedUserAddress = currentUser.slectedAddress;
            
            NSMutableArray *userAddressArray = [[NSMutableArray alloc]init];
            [userAddressArray insertObject:selectedUserAddress.name atIndex:0];
            [userAddressArray insertObject:selectedUserAddress.line1 atIndex:1];
            [userAddressArray insertObject:selectedUserAddress.city atIndex:2];
            [userAddressArray insertObject:selectedUserAddress.zipcode atIndex:3];
            
            selectedAddress = [NSArray arrayWithArray:userAddressArray];
            userAccount.selectedUserAddress = selectedAddress;
            userAccount.selectedAddressId = currentUser.selectedAddressId;
        }
        
        if([currentUser.isCreditCardSelected isEqualToString:@"Yes"])
        {
            isCreditCardSelected = YES;
            selectedCreditCardButtonTag = [currentUser.selectedCreditCardTag intValue];
        }
        
        else
        {
            isCreditCardSelected = NO;
            selectedCreditCardButtonTag = 0;
        }
        
        if([currentUser.isPaymentDone isEqualToString:@"Yes"])
        {
            isOrderComplete = YES;
            userAccount.appointmentId = currentUser.appointmentID;
            userAccount.selectedDate = currentUser.selectedDate;
            userAccount.fromTime = currentUser.selectedTime;
        }
        
        else
        {
            isOrderComplete = NO;
        }
    }
}

#pragma mark- save user data in data base

- (void)saveUserData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(!userAccount.userId)
    {
        return;
    }
    
    NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    if(userRecords.count == 1)
    {
        if(isCreditCardSelected)
        {
            //  [[userRecords objectAtIndex:0]setSelectedAddressId:selectedAddress];
            [[userRecords objectAtIndex:0]setIsCreditCardSelected:@"Yes"];
            [[userRecords objectAtIndex:0]setSelectedCreditCardTag:[NSString stringWithFormat:@"%d", selectedCreditCardButtonTag]];
        }
        
        else
        {
            [[userRecords objectAtIndex:0]setIsCreditCardSelected:@"No"];
        }
        
        if(isOrderComplete)
        {
            [[userRecords objectAtIndex:0]setIsPaymentDone:@"Yes"];
        }
        
        else
        {
            [[userRecords objectAtIndex:0]setIsPaymentDone:@"No"];
        }
        
        [[CoreDataModel sharedCoreDataModel]saveContext];
    }
}

#pragma mark- show alert if payment not done

- (BOOL)checkIfOrderCompleted
{
    // to check if any service selected
    if(!isOrderComplete)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Complete Order." message:@"Kindly pay and complete your order to move to next screen" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    return isOrderComplete;
}

#pragma mark- show alert if payment already done

- (void)showOrderPlacedAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Order is Placed." message:@"Your order has been placed, you cannot make any changes now, Kindly check the next screen for details" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark-Swipe Gesture Methods

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if(![self checkIfOrderCompleted])
        return;
    
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ConfirmationViewController *confirmationView = [aStoryboard instantiateViewControllerWithIdentifier:@"ConfirmationStoryView"];
    [self.navigationController pushViewController:confirmationView animated:YES];
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if(isOrderComplete)
    {
        [self showOrderPlacedAlert];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(isexpanded)
    {
        if(isCreditCardSelected)
            return 10;
        else
            return 9;
    }
    
    else
    {
        if(isCreditCardSelected)
            return 6;
        else
            return 5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isexpanded)
    {
        if(section==3)
            return subCategoryList.count;
        else if ((section == 7) && userCreditCardList.count > 0)
            return userCreditCardList.count;
        else if ((section == 7) && userCreditCardList.count <= 0)
            return 1;
        else
            return 1;
    }
    
    else
    {
        if ((section == 3) && userCreditCardList.count > 0)
            return userCreditCardList.count;
        else if ((section == 3) && userCreditCardList.count <= 0)
            return 1;
        else
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isexpanded)
    {
        if(indexPath.section==0)
        {
            UITableViewCell *appointmentStatusViewCell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentStatusView"];
            return appointmentStatusViewCell;
        }
        
        else if (indexPath.section==1)
        {
            UITableViewCell *addressViewCell = [tableView dequeueReusableCellWithIdentifier:@"AddressView"];
            
            UILabel *primaryAddressNameLabel = (UILabel *) [addressViewCell viewWithTag:950];
            UILabel *fullAddressLabel = (UILabel *) [addressViewCell viewWithTag:951];
            
            primaryAddressNameLabel.text = [selectedAddress objectAtIndex:0];
            fullAddressLabel.text = [NSString stringWithFormat:@"%@, %@, %@",[selectedAddress objectAtIndex:1],[selectedAddress objectAtIndex:2],[selectedAddress objectAtIndex:3]];
            
            UILabel *dateTimeLabel = (UILabel *) [addressViewCell viewWithTag:220];
            dateTimeLabel.text = selectedDateTime;
            
            return addressViewCell;
        }
        
        else if (indexPath.section==2)
        {
            UITableViewCell *stylistViewCell = [tableView dequeueReusableCellWithIdentifier:@"StylistView"];
            
            UILabel *stylistAddressNameLabel = (UILabel *) [stylistViewCell viewWithTag:850];
            stylistAddressNameLabel.text = selectedStylistName;//selectedStylist.stylistName;
            
            return stylistViewCell;
        }
        
        else if (indexPath.section==3)
        {
            UITableViewCell *selectedServiceCell = [tableView dequeueReusableCellWithIdentifier:@"SelectedServiceCell"];
            
            UILabel *categoryLbl = (UILabel *)[selectedServiceCell viewWithTag:750];
            UILabel *priceLbl = (UILabel *)[selectedServiceCell viewWithTag:751];
            
            if(self.view.frame.size.width == 320)
            {
                [categoryLbl setFont:[UIFont latoFontOfSize:13]];
            }
            else
            {
                [categoryLbl setFont:[UIFont latoFontOfSize:14]];
            }
            
            categoryLbl.text = [ NSString stringWithFormat:@"%@: %@",[selectedServices objectForKey:[subCategoryList objectAtIndex:indexPath.row]],[subCategoryList objectAtIndex:indexPath.row]];
            priceLbl.text = [NSString stringWithFormat:@"$%@",[priceDictionary valueForKey:[subCategoryList objectAtIndex:indexPath.row]]];
            
            return selectedServiceCell;
        }
        
        else if (indexPath.section==4)
        {
            UITableViewCell *addServiceViewCell = [tableView dequeueReusableCellWithIdentifier:@"AddServiceView"];
            
            UILabel *amountLbl = (UILabel *)[addServiceViewCell viewWithTag:650];
            
            if(self.view.frame.size.width == 320)
            {
                [amountLbl setFont:[UIFont latoFontOfSize:13]];
            }
            
            else
            {
                [amountLbl setFont:[UIFont latoFontOfSize:14]];
            }
            
            amountLbl.text = [NSString stringWithFormat:@"$ %.02f",[self getTotalAmount]];
            
            return addServiceViewCell;
        }
        
        else if (indexPath.section==5)
        {
            UITableViewCell *detailButtonViewCell = [tableView dequeueReusableCellWithIdentifier:@"DetailButtonView"];
            
            UIButton *detailButton=(UIButton *)[detailButtonViewCell viewWithTag:777];
            [detailButton setTitle:@"Tap to Hide Details" forState:UIControlStateNormal];
            [detailButton setImage:[UIImage imageNamed:@"arrow-up-icon"] forState:UIControlStateNormal];
            [detailButton addTarget:self action:@selector(expandCollapseTable) forControlEvents:UIControlEventTouchUpInside];
            
            return detailButtonViewCell;
        }
        
        else if (indexPath.section==6)
        {
            UITableViewCell *applePayViewCell = [tableView dequeueReusableCellWithIdentifier:@"ApplePayView"];
            
            UIButton *payButton=(UIButton *)[applePayViewCell viewWithTag:651];
            payButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
            payButton.layer.borderWidth=1.0f;
            payButton.layer.cornerRadius=3.0f;
            
            [payButton addTarget:self action:@selector(tappedApplePay) forControlEvents:UIControlEventTouchUpInside];
            return applePayViewCell;
        }
        
        else if (indexPath.section==7)
        {
            CreditCardCustomTableViewCell *creditViewCell = [tableView dequeueReusableCellWithIdentifier:@"CreditView"];
            NSDictionary *creditCardDict;
            
            if(userCreditCardList.count>0)
            {
                creditCardDict = [userCreditCardList objectAtIndex:indexPath.row];
                
                [creditViewCell.noCreditCardMessageLabel setHidden:YES];
                [creditViewCell.savedCreditCardButton setHidden:NO];
            }
            
            else
            {
                [creditViewCell.noCreditCardMessageLabel setHidden:NO];
                [creditViewCell.savedCreditCardButton setHidden:YES];
            }
            
            creditViewCell.savedCreditCardButton.tag = indexPath.row + 1000;
            [creditViewCell.savedCreditCardButton addTarget:self action:@selector(selectCreditCard:) forControlEvents:UIControlEventTouchUpInside];
            
            if(selectedCreditCardButtonTag == creditViewCell.savedCreditCardButton.tag)
            {
                [creditViewCell.savedCreditCardButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
            }
            
            else
            {
                [creditViewCell.savedCreditCardButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
            }
            
            return creditViewCell;
        }
        
        else if (indexPath.section==8)
        {
            UITableViewCell *addCreditCardViewCell = [tableView dequeueReusableCellWithIdentifier:@"AddCreditCardView"];
            
            UIButton *addNewCreditCardButton=(UIButton *)[addCreditCardViewCell viewWithTag:751];
            addNewCreditCardButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
            addNewCreditCardButton.layer.borderWidth=1.0f;
            addNewCreditCardButton.layer.cornerRadius=3.0f;
            
            [addNewCreditCardButton addTarget:self action:@selector(addCreditCardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            return addCreditCardViewCell;
        }
        
        else
        {
            UITableViewCell *completeOrderViewCell = [tableView dequeueReusableCellWithIdentifier:@"CompleteOrderView"];
            
            UIButton *completeOrderButton=(UIButton *)[completeOrderViewCell viewWithTag:851];
            completeOrderButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
            completeOrderButton.layer.borderWidth=1.0f;
            completeOrderButton.layer.cornerRadius=3.0f;
            
            [completeOrderButton addTarget:self action:@selector(completeOrder) forControlEvents:UIControlEventTouchUpInside];
            
            return completeOrderViewCell;
        }
    }
    
    // if table is not expanded
    else
    {
        if(indexPath.section==0)
        {
            UITableViewCell *appointmentStatusViewCell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentStatusView"];
            return appointmentStatusViewCell;
        }
        
        else if (indexPath.section==1)
        {
            UITableViewCell *detailButtonViewCell = [tableView dequeueReusableCellWithIdentifier:@"DetailButtonView"];
            
            UIButton *detailButton=(UIButton *)[detailButtonViewCell viewWithTag:777];
            [detailButton setTitle:@"Tap to View Details" forState:UIControlStateNormal];
            [detailButton setImage:[UIImage imageNamed:@"arrow-down-icon"] forState:UIControlStateNormal];
            [detailButton addTarget:self action:@selector(expandCollapseTable) forControlEvents:UIControlEventTouchUpInside];
            
            return detailButtonViewCell;
        }
        
        else if (indexPath.section==2)
        {
            UITableViewCell *applePayViewCell = [tableView dequeueReusableCellWithIdentifier:@"ApplePayView"];
            
            UIButton *payButton=(UIButton *)[applePayViewCell viewWithTag:651];
            payButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
            payButton.layer.borderWidth=1.0f;
            payButton.layer.cornerRadius=3.0f;
            
            [payButton addTarget:self action:@selector(tappedApplePay) forControlEvents:UIControlEventTouchUpInside];
            return applePayViewCell;
        }
        
        else if (indexPath.section==3)
        {
            CreditCardCustomTableViewCell *creditViewCell = [tableView dequeueReusableCellWithIdentifier:@"CreditView"];
            NSDictionary *creditCardDict;
            
            if(userCreditCardList.count>0)
            {
                creditCardDict = [userCreditCardList objectAtIndex:indexPath.row];
                
                [creditViewCell.savedCreditCardButton setTitle:[self getCreditCardInfo:creditCardDict] forState:UIControlStateNormal];
                [creditViewCell.noCreditCardMessageLabel setHidden:YES];
                [creditViewCell.savedCreditCardButton setHidden:NO];
            }
            
            else
            {
                [creditViewCell.noCreditCardMessageLabel setHidden:NO];
                [creditViewCell.savedCreditCardButton setHidden:YES];
            }
            
            creditViewCell.savedCreditCardButton.tag = indexPath.row + 1000;
            [creditViewCell.savedCreditCardButton addTarget:self action:@selector(selectCreditCard:) forControlEvents:UIControlEventTouchUpInside];
            
            if(selectedCreditCardButtonTag == creditViewCell.savedCreditCardButton.tag)
            {
                [creditViewCell.savedCreditCardButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
            }
            
            else
            {
                [creditViewCell.savedCreditCardButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
            }
            
            return creditViewCell;
        }
        
        else if (indexPath.section==4)
        {
            UITableViewCell *addCreditCardViewCell = [tableView dequeueReusableCellWithIdentifier:@"AddCreditCardView"];
            
            UIButton *addNewCreditCardButton=(UIButton *)[addCreditCardViewCell viewWithTag:751];
            addNewCreditCardButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
            addNewCreditCardButton.layer.borderWidth=1.0f;
            addNewCreditCardButton.layer.cornerRadius=3.0f;
            
            [addNewCreditCardButton addTarget:self action:@selector(addCreditCardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            return addCreditCardViewCell;
        }
        
        else
        {
            UITableViewCell *completeOrderViewCell = [tableView dequeueReusableCellWithIdentifier:@"CompleteOrderView"];
            
            UIButton *completeOrderButton=(UIButton *)[completeOrderViewCell viewWithTag:851];
            completeOrderButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
            completeOrderButton.layer.borderWidth=1.0f;
            completeOrderButton.layer.cornerRadius=3.0f;
            
            [completeOrderButton addTarget:self action:@selector(completeOrder) forControlEvents:UIControlEventTouchUpInside];
            
            return completeOrderViewCell;
        }
    }
}

// providing height to different sections when the table is expanded and when the table is collapsed
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isexpanded)
    {
        if(indexPath.section==0)
        {
            return 40;
        }
        
        else if(indexPath.section==1)
        {
            return 64;
        }
        
        else if(indexPath.section==2)
        {
            return 32;
        }
        
        else if(indexPath.section==3)
        {
            return 25;
        }
        
        else if(indexPath.section==4)
        {
            return 32;
        }
        
        else if(indexPath.section==5)
        {
            return 30;
        }
        
        else if(indexPath.section==6)
        {
            return 229;
        }
        
        else if(indexPath.section==7)
        {
            return 100;
        }
        
        else if(indexPath.section==8)
        {
            return 45;
        }
        
        else
        {
            return 150;
        }
    }
    
    else
    {
        if(indexPath.section==0)
        {
            return 40;
        }
        
        else if(indexPath.section==1)
        {
            return 30;
        }
        
        else if(indexPath.section==2)
        {
            return 229;
        }
        
        else if(indexPath.section==3)
        {
            return 100;
        }
        
        else if(indexPath.section==4)
        {
            return 45;
        }
        
        else
        {
            return 150;
        }
    }
}

#pragma mark- Complete Order Button Action ( using credit card )

- (void)completeOrder
{
    if(isOrderComplete)
    {
        [self showOrderPlacedAlert];
        return;
    }
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSMutableArray *productIdList = [[NSMutableArray alloc]init];
    productIdList = [NSMutableArray arrayWithArray:productIds];
    
    int tag = selectedCreditCardButtonTag%1000;
    NSDictionary *selectedCreditCard = [userCreditCardList objectAtIndex:tag];
    
    // converting array into string seperated by comma
    NSString *productIdListString = [[productIdList valueForKey:@"description"] componentsJoinedByString:@","];
    
    // show activity indicator
    [Utility showActivity:self];
    
    //  [self getClientToken];
    WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
    webserviceViewController.delegate = self;
    
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    
    [userDictionary setObject:userAccount.clientToken forKey:@"client_token"];
    [userDictionary setObject:userAccount.selectedAddressId forKey:@"address_id"];
    [userDictionary setObject:productIdListString forKey:@"product_ids"];
    [userDictionary setObject:[selectedCreditCard valueForKey:@"token"] forKey:@"payment_method_token"];
    [userDictionary setObject:userAccount.appointmentId forKey:@"appointment_id"];
    
    //Forming Json Object
    [postDictionary setObject:userDictionary forKey:@"transaction"];
    
    currentAPICalled = kMakePayment;
    
    //Calling webservice
    [webserviceViewController makePayment:postDictionary];
}

#pragma mark- Complete Payment using Appple Pay

// using this method we are passing the information to server side for apple pay users
- (void)completePaymentUsingApplePay:(NSString*)nonce
{
    if(isOrderComplete)
    {
        [self showOrderPlacedAlert];
        return;
    }
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSMutableArray *productIdList = [[NSMutableArray alloc]init];
    productIdList = [NSMutableArray arrayWithArray:productIds];
    
    // converting array into string seperated by comma
    NSString *productIdListString = [[productIdList valueForKey:@"description"] componentsJoinedByString:@","];
    [Utility showActivity:self];
    
    //  [self getClientToken];
    WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
    webserviceViewController.delegate = self;
    
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    
    [userDictionary setObject:userAccount.clientToken forKey:@"client_token"];
    [userDictionary setObject:userAccount.selectedAddressId forKey:@"address_id"];
    [userDictionary setObject:productIdListString forKey:@"product_ids"];
    [userDictionary setObject:nonce forKey:@"payment_method_nonce"];
    [userDictionary setObject:userAccount.appointmentId forKey:@"appointment_id"];
    
    //Forming Json Object
    [postDictionary setObject:userDictionary forKey:@"transaction"];
    
    currentAPICalled = kMakeApplePayPayment;
    
    //Calling webservice
    [webserviceViewController makePayment:postDictionary];
}

#pragma mark - Credit card related methods

// Call this method to add new credit card
- (void)addCreditCardButtonTapped:(UIButton*)sender
{
    if(isOrderComplete)
    {
        [self showOrderPlacedAlert];
        return;
    }
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddCreditCardViewController *addCreditCardViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"AddCreditCardSB"];
    addCreditCardViewController.delegate = self;
    addCreditCardViewController.clientToken = [NSString stringWithString:userAccount.clientToken];
    
    [self presentViewController:addCreditCardViewController animated:YES completion:nil];
}

// Call this method to get/display inforrmation of credit card
- (NSString *)getCreditCardInfo:(NSDictionary *)creditCardDict
{
    NSString *creditCardInfoString;
    
    creditCardInfoString = [NSString stringWithFormat:@"\t\t%@\nXXXX XXXX XXXX %@\n\t expires:%@",[creditCardDict valueForKey:@"card_type"],[creditCardDict valueForKey:@"last_4"],[creditCardDict valueForKey:@"expiration_date"]];
    
    return creditCardInfoString;
}

// Call this method to select any credit card
- (void)selectCreditCard:(UIButton*)sender
{
    if(isOrderComplete)
    {
        [self showOrderPlacedAlert];
        return;
    }
    
    int currentTag = (int) sender.tag;
    if(selectedCreditCardButtonTag == currentTag && sender.titleLabel.text.length>0)
    {
        selectedCreditCardButtonTag = 0;
        isCreditCardSelected = NO;
    }
    else if(selectedCreditCardButtonTag != currentTag && sender.titleLabel.text.length>0)
    {
        selectedCreditCardButtonTag = currentTag;
        isCreditCardSelected = YES;
    }
    
    [self saveUserData];
    [self.paymentTableView reloadData];
}

#pragma mark - Tap to show/hide button action

- (void) expandCollapseTable
{
    if(isexpanded)
    {
        isexpanded=NO;
        
    }
    else
    {
        isexpanded=YES;
    }
    
    [self.paymentTableView reloadData];
}


#pragma mark - Webservice delegates

- (void)receivedResponse:(id)response
{
    iswebServiceFailed = NO;
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"])
    {
        UserAccount *userAccount = [UserAccount sharedInstance];
        
        if([currentAPICalled isEqualToString:kGetClientToken])
            self.braintree = [Braintree braintreeWithClientToken:userAccount.clientToken];
        else if([currentAPICalled isEqualToString:kGetCreditCardList])
            userCreditCardList = [NSMutableArray arrayWithArray:userAccount.userCreditCardList];
        else if([currentAPICalled isEqualToString:kMakePayment])
        {
            isOrderComplete = YES;
            [self saveUserData];
            if(![self checkIfOrderCompleted])
                return;
            
            UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            ConfirmationViewController *confirmationView = [aStoryboard instantiateViewControllerWithIdentifier:@"ConfirmationStoryView"];
            [self.navigationController pushViewController:confirmationView animated:YES];
            
            NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
            [[userRecords objectAtIndex:0]setSelectedDate:nil];
            [[userRecords objectAtIndex:0]setSelectedTime:nil];
            [[userRecords objectAtIndex:0]setIsStlistSelected:@"No"];
            [[userRecords objectAtIndex:0]setIsServicesSelected:@"No"];
            [[userRecords objectAtIndex:0]setIsCreditCardSelected:@"No"];
            [[userRecords objectAtIndex:0]setSelectedStylistTag:nil];
            [[userRecords objectAtIndex:0]setSelectedStylistName:nil];
            [[userRecords objectAtIndex:0]setSelectedCreditCardTag:nil];
            [[userRecords objectAtIndex:0]setSelectedCategories:nil];
            [[userRecords objectAtIndex:0]setSelectedServices:nil];
            [[CoreDataModel sharedCoreDataModel]saveContext];
        }
        else if([currentAPICalled isEqualToString:kMakeApplePayPayment])
        {
            isOrderComplete = YES;
            [self saveUserData];
            if(![self checkIfOrderCompleted])
                return;
            
            UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            ConfirmationViewController *confirmationView = [aStoryboard instantiateViewControllerWithIdentifier:@"ConfirmationStoryView"];
            [self.navigationController pushViewController:confirmationView animated:YES];
        }
        [self.paymentTableView reloadData];
    }
    else
    {
        isOrderComplete = NO;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to process request." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    isOrderComplete = NO;
    iswebServiceFailed = YES;
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to process request." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
