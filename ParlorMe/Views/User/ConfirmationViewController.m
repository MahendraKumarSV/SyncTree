//
//  ConfirmationViewController.m
//  ParlorMe
//

#import "ConfirmationViewController.h"
#import "Utility.h"
#import "StylistDetails.h"
#import "UserAccount.h"
#import "SettingsViewController.h"
#import "WebserviceViewController.h"
#import "Constants.h"
#import "CoreDataModel.h"
#import "SingletonClass.h"

#define kBookNewAppointmentAlert 250

@interface ConfirmationViewController ()<WebserviceViewControllerDelegate>
{
    UISwipeGestureRecognizer * swiperight;
    UISwipeGestureRecognizer * swipeleft;
    BOOL isexpanded;
    NSMutableArray *subCategoryList;
    NSDictionary *selectedServices;
    StylistDetails *selectedStylist;
    float totalAmount;
    NSDictionary *priceDictionary;
    NSDictionary *categoryDictionary;
    NSArray *selectedAddress;
    NSString *selectedStylistName;
    NSString *selectedDateTime;
}
@property (weak, nonatomic) IBOutlet UITableView *confirmationTableView;

- (IBAction)bookNewAppointmentButtonTapped:(id)sender;

@end

@implementation ConfirmationViewController

#pragma mark-view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isexpanded=NO;
    self.navigationController.navigationBarHidden = true;
    
    subCategoryList = [[NSMutableArray alloc]init];
    selectedServices = [[NSDictionary alloc]init];
    selectedStylist = [[StylistDetails alloc]init];
    selectedAddress = [[NSArray alloc]init];
    selectedStylistName = @"";
    
    for(int counter = 0; counter < 2; counter++)
    {
        UIButton *bottomBarButton = (UIButton*)[self.view viewWithTag:(9090 + counter)];
        bottomBarButton.layer.borderColor = [[UIColor blackColor]CGColor];
        bottomBarButton.layer.borderWidth = 2.0f;
    }
    
    swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.confirmationTableView addGestureRecognizer:swipeleft];
    
    swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.confirmationTableView addGestureRecognizer:swiperight];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    selectedServices = userAccount.selectedServicesList;
    subCategoryList = [NSMutableArray arrayWithArray:userAccount.selectedsubCategoryList];
    selectedAddress = userAccount.selectedUserAddress;
    selectedStylistName = userAccount.selectedStylistName;
    
    StylistDetails *stylistObj = [StylistDetails sharedInstance];
    selectedStylist = stylistObj.selectedStylist;
    priceDictionary = stylistObj.stylistServicePriceDict;
    categoryDictionary = stylistObj.stylistCategoryPriceDict;
    
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
    
    //[self.confirmationTableView setBackgroundColor:DashedLineRGBColor(229.0, 199.0, 194.0)];
    [self.confirmationTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Swipe Gesture Methods

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Book New Appointment Button Action

- (IBAction)bookNewAppointmentButtonTapped:(id)sender
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
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark - UITableView Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(isexpanded)
        return 6;
    else
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if((section==3) && (isexpanded))
        return subCategoryList.count;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        UITableViewCell *appointmentStatusViewCell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentStatusView"];
        
        UILabel *appointmentLabel=(UILabel *)[appointmentStatusViewCell viewWithTag:750];
        if(isexpanded)
        {
            appointmentLabel.text=@"Appointment Details";
        }
        else
        {
            appointmentLabel.text=@"Appointment Booked.";
            
        }
        
        return appointmentStatusViewCell;
    }
    
    else if (indexPath.section==1)
    {
        if(isexpanded)
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
        
        else
        {
            UITableViewCell *messageViewCell = [tableView dequeueReusableCellWithIdentifier:@"MessageView"];
            
            UIButton *detailButton=(UIButton *)[messageViewCell viewWithTag:777];
            [detailButton setTitle:@"Tap to View Details" forState:UIControlStateNormal];
            [detailButton setImage:[UIImage imageNamed:@"arrow-down-icon"] forState:UIControlStateNormal];
            [detailButton addTarget:self action:@selector(expandCollapseTable) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *cancelButton=(UIButton *)[messageViewCell viewWithTag:700];
            [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            
            return messageViewCell;
            
        }
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
    
    else
    {
        UITableViewCell *messageViewCell = [tableView dequeueReusableCellWithIdentifier:@"MessageView"];
        
        UIButton *detailButton=(UIButton *)[messageViewCell viewWithTag:777];
        [detailButton setTitle:@"Tap to Hide Details" forState:UIControlStateNormal];
        [detailButton setImage:[UIImage imageNamed:@"arrow-up-icon"] forState:UIControlStateNormal];
        [detailButton addTarget:self action:@selector(expandCollapseTable) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton=(UIButton *)[messageViewCell viewWithTag:700];
        [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        return messageViewCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0)
    {
        return 40;
    }
    
    else if(indexPath.section==1)
    {
        
        if(isexpanded)
        {
            return 64;
        }
        else
        {
            return 202;
        }
        
        
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
    
    else
    {
        return 202;
    }
}

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
    
    [self.confirmationTableView reloadData];
}

#pragma mark Cancel Button Action

- (void)cancelButtonTapped
{
    [Utility showActivity:self];
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
    webserviceViewController.delegate = self;
    
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    
    //Forming Json Object
    [postDictionary setObject:userAccount.userId forKey:@"client_id"];
    [postDictionary setObject:userAccount.appointmentId forKey:@"appointment_id"];
    
    //Calling webservice
    [webserviceViewController cancelUserAppointment:postDictionary];
}

#pragma mark- AlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 11211 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:000-000-0000"]]];
    }
    else if(alertView.tag == kBookNewAppointmentAlert && buttonIndex == 1)
    {
        [self deletePreviousData];
        [self.tabBarController setSelectedIndex:0];
    }
}

#pragma mark- Save User Data in Database

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
        [[userRecords objectAtIndex:0]setIsPaymentDone:@"No"];
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
        
        [self saveUserData];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Appointment Cancelled." message:@"Money will be refunded in 24 hours" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to Cancel Appointment, Try in some time." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

// Check if web-service failed
- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to Cancel Appointment, Try in some time." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}


@end
