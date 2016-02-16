//
//  DetailsViewController.m
//  ParlorMe

#import "DetailsViewController.h"
#import "StylistAccount.h"
#import "UserAccount.h"
#import "StylistDetails.h"
#import "WebserviceViewController.h"
#import "Utility.h"
#import "Constants.h"
#import "AddressViewController.h"
#import "JoinParlorViewController.h"
#import "AddressCustomTableViewCell.h"
#import "CoreDataModel.h"
#import "SettingsViewController.h"
#import "StylistInfoViewController.h"
#import "StylistDetails.h"
#import "StylistTimeSlotTableViewCell.h"
#import "SingletonClass.h"
#import "PaymentViewController.h"

#define kBookAppointmentAlert 250

@interface DetailsViewController ()<WebserviceViewControllerDelegate,SaveAddressDelegate,UIAlertViewDelegate,RegsiterUserDelegate,SetSelectedStylistDelegate>
{
    UISwipeGestureRecognizer * swiperight;
    UISwipeGestureRecognizer * swipeleft;
    BOOL isexpanded;
    NSMutableArray *subCategoryList;
    NSDictionary *selectedServices;
    StylistDetails *selectedStylist;
    float totalAmount;
    NSMutableArray *datesWithDaysArray;
    NSArray *timeList;
    BOOL isDateSelected;
    BOOL isTimeSelected;
    BOOL isBookFutureApppointmentButtonSelected;
    BOOL isSendStylistButtonSelected;
    BOOL isAddressSelected;
    int selectedDateButtonTag;
    int selectedAddressButtonTag;
    NSString *selectedTime;
    NSMutableDictionary *priceDictionary;
    NSMutableDictionary *categoryDictionary;
    NSString *currentAPICalled;
    NSMutableArray *addressList;
    BOOL iswebServiceFailed;
    NSArray *selectedAddress;
    NSString *selectedAddressId;
    NSString *selectedStylistName;
    NSString *selectedDate;
    BOOL isnewAddressAdded;
    NSArray *datesArray;
    NSString *selectedStylistId;
}
@property (weak, nonatomic) IBOutlet UITableView *detailsTableView;

@end

@implementation DetailsViewController

#pragma mark-view life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // to check if table is expanded or not
    isexpanded = NO;
    subCategoryList = [[NSMutableArray alloc]init];
    selectedServices = [[NSDictionary alloc]init];
    selectedStylist = [[StylistDetails alloc]init];
    addressList = [[NSMutableArray alloc]init];
    totalAmount = 0;
    isBookFutureApppointmentButtonSelected = NO;
    isSendStylistButtonSelected = NO;
    selectedDateButtonTag = 0;
    selectedAddressButtonTag = 0;
    selectedTime = nil;
    isDateSelected = NO;
    isTimeSelected = NO;
    isAddressSelected = NO;
    currentAPICalled = @" ";
    iswebServiceFailed = NO;
    selectedAddress = [[NSArray alloc]init];
    selectedStylistName = @"";
    isnewAddressAdded = NO;
    selectedDate = @"";
    datesArray = [[NSArray alloc]init];
    timeList = [[NSArray alloc]init];
    
    for(int counter = 0; counter < 2; counter++)
    {
        UIButton *bottomBarButton = (UIButton*)[self.view viewWithTag:(9090 + counter)];
        bottomBarButton.layer.borderColor = [[UIColor blackColor]CGColor];
        bottomBarButton.layer.borderWidth = 2.0f;
    }
    
    // adding swipe left gesture
    swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.detailsTableView addGestureRecognizer:swipeleft];
    
    // adding swipe right gesture
    swiperight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.detailsTableView addGestureRecognizer:swiperight];
    
    [self getSavedAddress];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[SingletonClass shareManager]showBackBtn:self];
    self.navigationItem.title = @"Select Time";
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    selectedServices = userAccount.selectedServicesList;
    subCategoryList = [NSMutableArray arrayWithArray:userAccount.selectedServicesList.allKeys]; //[NSMutableArray arrayWithArray:userAccount.selectedsubCategoryList];
    selectedStylistName = userAccount.selectedStylistName;
    
    StylistDetails *stylistObj = [StylistDetails sharedInstance];
    selectedStylist = stylistObj.selectedStylist;
    priceDictionary = [NSMutableDictionary dictionaryWithDictionary:stylistObj.stylistServicePriceDict];
    categoryDictionary = [NSMutableDictionary dictionaryWithDictionary:stylistObj.stylistCategoryPriceDict];
    
    if([userAccount.userId isEqualToString:@"Guest"])
    {
        addressList = nil;//[NSMutableArray arrayWithObjects:nil, nil];
    }
    else if (iswebServiceFailed && currentAPICalled == kGetAddressList)
    {
        [self getSavedAddress];
    }
    
    [self getUserData];
    
    if(!userAccount.appointmentId)
    {
        isSendStylistButtonSelected = NO;
        isBookFutureApppointmentButtonSelected = NO;
        isDateSelected = NO;
        isTimeSelected = NO;
    }
    
    [self.detailsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Show Registration Required Alert

- (void)showRegisterUserAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Registration Required." message:@"Kindly register, in-order to book an appointment" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    alert.tag = kBookAppointmentAlert;
    alert.delegate = self;
    [alert show];
}

#pragma mark - Get Address List

- (void)getSavedAddress
{
    if(isnewAddressAdded)
    {
        isAddressSelected = NO;
    }
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(![userAccount.userId isEqualToString:@"Guest"])
    {
        [Utility showActivity:self];
        WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
        webserviceViewController.delegate = self;
        currentAPICalled = kGetAddressList;
        [webserviceViewController getAddressList];
    }
}

// get newly saved Address
- (void)getNewlySavedAddress
{
    isnewAddressAdded = YES;
    [self getSavedAddress];
}

#pragma mark - Check if Appointment Time Selected

- (BOOL)checkIfAppointmentTimeSelected
{
    // to check if any service selected
    if(!isTimeSelected)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Appointment time not selected." message:@"Kindly select either send stylist now or book a future appointment to set the appointment time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        UserAccount *userAccount = [UserAccount sharedInstance];
        userAccount.selectedAddressId = selectedAddressId;
    }
    
    return isTimeSelected;
}

#pragma mark - Get User Data from Database

- (void)getUserData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(!userAccount.userId)
    {
        return;
    }
    
    NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    if(userRecords.count>0)
    {
        User *currentUser = [userRecords objectAtIndex:0];
        //NSLog(@"currentUser: %@",[userRecords objectAtIndex:0]);
        
        userAccount.selectedStylistName = currentUser.selectedStylistName;
        selectedStylistName = currentUser.selectedStylistName;
        selectedStylistId = currentUser.selectedStylistTag;
        
        if([currentUser.isAddressSelected isEqualToString:@"Yes"] && !isnewAddressAdded)
        {
            isAddressSelected = YES;
            selectedAddressButtonTag = [currentUser.selectedAddressTag intValue];
            
            Address *selectedUserAddress = currentUser.slectedAddress;
            
            if(selectedUserAddress)
            {
                NSMutableArray *userAddressArray = [[NSMutableArray alloc]init];
                [userAddressArray insertObject:selectedUserAddress.name atIndex:0];
                [userAddressArray insertObject:selectedUserAddress.line1 atIndex:1];
                [userAddressArray insertObject:selectedUserAddress.city atIndex:2];
                [userAddressArray insertObject:selectedUserAddress.zipcode atIndex:3];
                
                selectedAddress = [NSArray arrayWithArray:userAddressArray];
                userAccount.selectedUserAddress = selectedAddress;
                userAccount.selectedAddressId = currentUser.selectedAddressId;
                selectedAddressId = userAccount.selectedAddressId;
            }
            else
            {
                isAddressSelected = NO;
                selectedAddressButtonTag = 0;
            }
        }
        else
        {
            isAddressSelected = NO;
            selectedAddressButtonTag = 0;
        }
    }
}

#pragma mark - Save User Data in Database

- (void)saveUserData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(!userAccount.userId)
    {
        return;
    }
    
    NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    NSArray *addressRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Address" andPredicate:[NSPredicate predicateWithFormat:@"currentUser == %@",[userRecords objectAtIndex:0]] andSortDescriptor:nil forContext:nil];
    
    if(addressRecords.count>0)
    {
        [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[addressRecords objectAtIndex:0] withContext:nil];
    }
    
    if(userRecords.count == 1)
    {
        if(isAddressSelected)
        {
            Address *selectedUserAddress = (Address *)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"Address" forContext:nil];
            [selectedUserAddress setName:[selectedAddress objectAtIndex:0]];
            [selectedUserAddress setLine1:[selectedAddress objectAtIndex:1]];
            [selectedUserAddress setCity:[selectedAddress objectAtIndex:2]];
            [selectedUserAddress setZipcode:[selectedAddress objectAtIndex:3]];
            [selectedUserAddress setCurrentUser:[userRecords objectAtIndex:0]];
            
            [[userRecords objectAtIndex:0]setSelectedAddressId:selectedAddressId];
            [[userRecords objectAtIndex:0]setSlectedAddress:selectedUserAddress];
            [[userRecords objectAtIndex:0]setIsAddressSelected:@"Yes"];
            [[userRecords objectAtIndex:0]setSelectedAddressTag:[NSString stringWithFormat:@"%d", selectedAddressButtonTag]];
        }
        else
        {
            [[userRecords objectAtIndex:0]setIsAddressSelected:@"No"];
        }
        
        if(selectedDate)
            [[userRecords objectAtIndex:0]setSelectedDate:selectedDate];
        
        if(selectedTime)
            [[userRecords objectAtIndex:0]setSelectedTime:selectedTime];
        
        if(userAccount.appointmentId)
            [[userRecords objectAtIndex:0]setAppointmentID:userAccount.appointmentId];
        
        [[CoreDataModel sharedCoreDataModel]saveContext];
    }
}

#pragma mark-Swipe Gesture Methods

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if(![self checkIfAppointmentTimeSelected])
        return;
    
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PaymentViewController *paymentView = [aStoryboard instantiateViewControllerWithIdentifier:@"PaymentStoryView"];
    [self.navigationController pushViewController:paymentView animated:YES];
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-Delete Guest User Data

- (void)deleteGuestUser
{
    NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",@"Guest"] andSortDescriptor:nil forContext:nil];
    
    if( [firstLoad count] > 0 )
    {
        [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:0] withContext:nil];
    }
    [[CoreDataModel sharedCoreDataModel]saveContext];
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

#pragma mark - Show next 14 Dates in Scrollview Related Methods

-(void)scrollViewDates:(UIScrollView *)datesScrollView
{
    for (UIView *view in datesScrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    int days = 14; // 14 dates for now
    NSDate *start = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    NSMutableArray* dates = [NSMutableArray arrayWithObject:start];
    
    for (int i = 1; i < days; i++)
    {
        [offset setDay:i];
        NSDate *next = [calendar dateByAddingComponents:offset toDate:start options:0];
        [dates addObject:next];
    }
    
    datesArray = [NSArray arrayWithArray:dates];
    
    datesWithDaysArray = [[NSMutableArray alloc]init];
    
    for(int j=0; j<dates.count; j++)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"MMMM/dd/EEEE"];
        NSString *dateString = [df stringFromDate:[dates objectAtIndex:j]];
        [datesWithDaysArray addObject:dateString];
    }
    
    int tileXPos = 0;
    
    CGFloat buttonWidth = (self.view.frame.size.width - 70)/5;
    CGFloat buttonHeight = datesScrollView.frame.size.height;
    
    for(int k=0; k<datesWithDaysArray.count; k++)
    {
        //Background Button
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        tile.frame = CGRectMake(tileXPos, 5, buttonWidth, buttonHeight-5);
        tile.backgroundColor = [UIColor clearColor];
        
        tile.tag = k+1;
        [tile setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tile setTitle:[[[datesWithDaysArray objectAtIndex:k]componentsSeparatedByString:@"/"]objectAtIndex:1] forState:UIControlStateNormal];
        [tile addTarget:self action:@selector(selectedDateAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Month Label
        UILabel *monthNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(3, 5, buttonWidth-6, 16)];
        monthNameLbl.textColor = [UIColor blackColor];
        monthNameLbl.textAlignment = NSTextAlignmentCenter;
        monthNameLbl.font = [UIFont latoFontOfSize:8.0];
        monthNameLbl.text = [[[datesWithDaysArray objectAtIndex:k]componentsSeparatedByString:@"/"]objectAtIndex:0];
        [tile addSubview:monthNameLbl];
        
        //Day Label
        UILabel *dayLbl = [[UILabel alloc]initWithFrame:CGRectMake(3, 65, buttonWidth-6, 16)];
        dayLbl.textColor = [UIColor blackColor];
        dayLbl.textAlignment = NSTextAlignmentCenter;
        dayLbl.font = [UIFont latoFontOfSize:8.0];
        dayLbl.text = [[[datesWithDaysArray objectAtIndex:k]componentsSeparatedByString:@"/"]objectAtIndex:2];
        [tile addSubview:dayLbl];
        
        if(self.view.frame.size.width==320)
        {
            monthNameLbl.font = [UIFont latoFontOfSize:8.0];
            dayLbl.font = [UIFont latoFontOfSize:8.0];
        }
        else if(self.view.frame.size.width>320 && self.view.frame.size.width<1024)
        {
            monthNameLbl.font = [UIFont latoFontOfSize:10.0];
            dayLbl.font = [UIFont latoFontOfSize:10.0];
        }
        else
        {
            monthNameLbl.font = [UIFont latoFontOfSize:20.0];
            dayLbl.font = [UIFont latoFontOfSize:20.0];
        }
        
        if(tile.tag == selectedDateButtonTag)
        {
            [tile setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
        }
        else
        {
            [tile setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
        }
        
        tileXPos += buttonWidth;
        [datesScrollView addSubview:tile];
        [datesScrollView setContentSize:CGSizeMake(datesWithDaysArray.count*buttonWidth, buttonHeight)];
    }
}

#pragma mark- Date Selected Action

- (void)selectedDateAction:(UIButton *)sender
{
    if(selectedDateButtonTag != sender.tag)
    {
        selectedDateButtonTag = (int) sender.tag;
        isDateSelected = YES;
        isTimeSelected = NO;
        selectedTime = nil;
        
        [self.detailsTableView reloadData];
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        dateFormater.dateFormat = @"dd/MM/yyyy";
        NSString *dateString  = [dateFormater stringFromDate:[datesArray objectAtIndex:selectedDateButtonTag-1]];
        
        selectedDate = dateString;
        
        [Utility showActivity:self];
        WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
        webserviceViewController.delegate = self;
        currentAPICalled = kGetTimeSlots;
        [webserviceViewController getTimeSlotsForPartnerId:selectedStylistId andForDate:selectedDate];
    }
}

#pragma mark- Address Not Selected Alert

- (void)showAddressNoSelectedAlert
{
    if(!isAddressSelected)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Address Required." message:@"Kindly select any address, in-order to book an appointment" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark- Book Future Appointment Button Action

- (void)bookFutureAppointmentButtonTapped:(UIButton *)sender
{
    if(!isAddressSelected)
    {
        [self showAddressNoSelectedAlert];
        return;
    }
    
    if(isBookFutureApppointmentButtonSelected)
    {
        return;
    }
    else
    {
        isSendStylistButtonSelected = NO;
        isDateSelected = NO;
        selectedDateButtonTag = 0;
        isBookFutureApppointmentButtonSelected = YES;
    }
    
    [self.detailsTableView reloadData];
}

#pragma mark- Send Stylist Button Action

- (void)sendStylistButtonTapped:(UIButton *)sender
{
    if(!isAddressSelected)
    {
        [self showAddressNoSelectedAlert];
        return;
    }
    
    isSendStylistButtonSelected = YES;
    isBookFutureApppointmentButtonSelected = NO;
    isDateSelected = NO;
    selectedDateButtonTag = 0;
    //[self.detailsTableView reloadData];
    
    [Utility showActivity:self];
    WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
    webserviceViewController.delegate = self;
    currentAPICalled = kSendStylist;
    
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"dd/MM/yyyy HH:MM"];
    NSString *strDate = [format stringFromDate:today];
    
    //Forming Json Object
    [postDictionary setObject:selectedStylistId forKey:@"partner_id"];
    [postDictionary setObject:strDate forKey:@"date"];
    
    //Calling webservice
    [webserviceViewController sendStylist:postDictionary];
}

#pragma mark - UITableView Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(isexpanded)
    {
        if(isDateSelected)
        {
            return 13;
        }
        
        else if (isBookFutureApppointmentButtonSelected)
        {
            return 10;
        }
        
        else
        {
            return 9;
        }
    }
    
    else
    {
        if(isDateSelected)
        {
            return 9;
        }
        
        else if (isBookFutureApppointmentButtonSelected)
        {
            return 6;
        }
        
        else
        {
            return 5;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isexpanded)
    {
        if(section == 3)
            return subCategoryList.count;
        else if (section == 11)
        {
            if ([timeList count] == 0)
                return 0;
            
            else if(([timeList count] > 3) && ([timeList count] % 3 != 0))
                return [timeList count] / 3 + 1; // Only one row should be returned if % is 1 or 2
            
            else if(([timeList count]>3) && ([timeList count] % 3 == 0))
                return [timeList count] / 3;  //No row should be retuned if % is equal to 0
            
            else
                return 1;
        }
        
        else if ((section == 6) && addressList.count>0)
            return ((addressList.count/2) + (addressList.count%2));
        else if ((section == 6) && addressList.count<=0)
            return 1;
        else
            return 1;
    }
    
    else
    {
        if(section == 7)
        {
            if ([timeList count] == 0)
                return 0;
            
            else if(([timeList count] > 3) && ([timeList count] % 3 != 0))
                return [timeList count] / 3 + 1; // Only one row should be returned if % is 1 or 2
            
            else if(([timeList count]>3) && ([timeList count] % 3 == 0))
                return [timeList count] / 3;  //No row should be retuned if % is equal to 0
            
            else
                return 1;
        }
        
        else if ((section == 2) && addressList.count>0)
            return ((addressList.count/2) + (addressList.count%2));
        else if ((section == 2) && addressList.count<=0)
            return 1;
        else
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isexpanded)
    {
        if(indexPath.section == 0)
        {
            UITableViewCell *appointmentStatusViewCell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentStatusView"];
            return appointmentStatusViewCell;
        }
        else if (indexPath.section == 1)
        {
            UITableViewCell *addressLabelViewCell = [tableView dequeueReusableCellWithIdentifier:@"AddressLabelView"];
            
            UILabel *primaryAddressNameLabel = (UILabel *) [addressLabelViewCell viewWithTag:950];
            UILabel *fullAddressLabel = (UILabel *) [addressLabelViewCell viewWithTag:951];
            
            if(isAddressSelected)
            {
                primaryAddressNameLabel.hidden = NO;
                fullAddressLabel.hidden = NO;
                primaryAddressNameLabel.text = [selectedAddress objectAtIndex:0];
                fullAddressLabel.text = [NSString stringWithFormat:@"%@, %@, %@",[selectedAddress objectAtIndex:1],[selectedAddress objectAtIndex:2],[selectedAddress objectAtIndex:3]];
            }
            else
            {
                primaryAddressNameLabel.hidden = YES;
                fullAddressLabel.hidden = YES;
            }
            
            return addressLabelViewCell;
        }
        
        else if (indexPath.section == 2)
        {
            UITableViewCell *stylistViewCell = [tableView dequeueReusableCellWithIdentifier:@"StylistView"];
            
            UILabel *stylistAddressNameLabel = (UILabel *) [stylistViewCell viewWithTag:850];
            stylistAddressNameLabel.text = selectedStylistName;//selectedStylist.stylistName;
            
            return stylistViewCell;
        }
        
        else if (indexPath.section == 3)
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
            
            categoryLbl.text = [NSString stringWithFormat:@"%@: %@",[selectedServices objectForKey:[subCategoryList objectAtIndex:indexPath.row]],[subCategoryList objectAtIndex:indexPath.row]];
            priceLbl.text = [NSString stringWithFormat:@"$%@",[priceDictionary valueForKey:[subCategoryList objectAtIndex:indexPath.row]]];
            
            return selectedServiceCell;
        }
        
        else if (indexPath.section == 4)
        {
            UITableViewCell *addServiceViewCell = [tableView dequeueReusableCellWithIdentifier:@"AddServiceView"];
            
            UILabel *amountLbl = (UILabel *)[addServiceViewCell viewWithTag:650];
            UIButton *addServiceButton = (UIButton *)[addServiceViewCell viewWithTag:430];
            
            addServiceButton.layer.borderColor = [[UIColor blackColor]CGColor];
            addServiceButton.layer.borderWidth = 1.0f;
            [addServiceButton addTarget:self action:@selector(goToSelectedStylistProfile) forControlEvents:UIControlEventTouchUpInside];
            
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
        
        else if (indexPath.section == 5)
        {
            UITableViewCell *detailButtonViewCell = [tableView dequeueReusableCellWithIdentifier:@"DetailButtonView"];
            
            // adding action and image to detail button
            UIButton *detailButton = (UIButton *)[detailButtonViewCell viewWithTag:777];
            [detailButton setTitle:@"Tap to Hide Details" forState:UIControlStateNormal];
            [detailButton setImage:[UIImage imageNamed:@"arrow-up-icon"] forState:UIControlStateNormal];
            [detailButton addTarget:self action:@selector(expandCollapseTable) forControlEvents:UIControlEventTouchUpInside];
            
            return detailButtonViewCell;
        }
        
        else if (indexPath.section == 6)
        {
            AddressCustomTableViewCell *addressTableCell = [tableView dequeueReusableCellWithIdentifier:@"AddressView"];
            NSDictionary *primaryAddress, *secondaryAddress;
            
            if(addressList.count>0)
            {
                if(addressList.count/((indexPath.row + 1)*2) >= 1)
                {
                    primaryAddress = [addressList objectAtIndex:indexPath.row*2];
                    secondaryAddress = [addressList objectAtIndex:(indexPath.row*2)+1];
                    
                    [addressTableCell.primaryAddressButton setTitle:[self getPrimaryAddress:primaryAddress] forState:UIControlStateNormal];
                    [addressTableCell.secondaryAddressButton setTitle:[self getSecondaryAddress:secondaryAddress] forState:UIControlStateNormal];
                    [addressTableCell.secondaryAddressButton setUserInteractionEnabled:YES];
                }
                else
                {
                    primaryAddress = [addressList objectAtIndex:indexPath.row*2];
                    
                    [addressTableCell.primaryAddressButton setTitle:[self getPrimaryAddress:primaryAddress] forState:UIControlStateNormal];
                    [addressTableCell.secondaryAddressButton setTitle:@" " forState:UIControlStateNormal];
                    [addressTableCell.secondaryAddressButton setUserInteractionEnabled:NO];
                }
                
                [addressTableCell.primaryAddressButton setHidden:NO];
                [addressTableCell.secondaryAddressButton setHidden:NO];
                [addressTableCell.noAddressMsgLabel setHidden:YES];
            }
            else
            {
                [addressTableCell.primaryAddressButton setHidden:YES];
                [addressTableCell.secondaryAddressButton setHidden:YES];
                [addressTableCell.noAddressMsgLabel setHidden:NO];
            }
            
            addressTableCell.primaryAddressButton.tag = indexPath.row + 1000;
            addressTableCell.secondaryAddressButton.tag = indexPath.row + 2000;
            [addressTableCell.primaryAddressButton addTarget:self action:@selector(selectAddress:) forControlEvents:UIControlEventTouchUpInside];
            [addressTableCell.secondaryAddressButton addTarget:self action:@selector(selectAddress:) forControlEvents:UIControlEventTouchUpInside];
            
            if(selectedAddressButtonTag == addressTableCell.primaryAddressButton.tag)
            {
                [addressTableCell.primaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
                [addressTableCell.secondaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
                
            }
            else if(selectedAddressButtonTag == addressTableCell.secondaryAddressButton.tag)
            {
                [addressTableCell.primaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
                [addressTableCell.secondaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
            }
            else
            {
                [addressTableCell.primaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
                [addressTableCell.secondaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
            }
            
            return addressTableCell;
        }
        
        else if (indexPath.section == 7)
        {
            UITableViewCell *addAdressButtonCell = [tableView dequeueReusableCellWithIdentifier:@"AddAdressButtonView"];
            
            UIButton *addNewAddressButton = (UIButton *)[addAdressButtonCell viewWithTag:651];
            addNewAddressButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
            addNewAddressButton.layer.borderWidth = 1.0f;
            addNewAddressButton.layer.cornerRadius = 3.0f;
            [addNewAddressButton addTarget:self action:@selector(addAdress:) forControlEvents:UIControlEventTouchUpInside];
            
            return addAdressButtonCell;
        }
        
        else if (indexPath.section == 8)
        {
            UITableViewCell *dateTimeCell = [tableView dequeueReusableCellWithIdentifier:@"DateTimeView"];
            
            UIButton *sendStylistButton = (UIButton *)[dateTimeCell viewWithTag:601];
            sendStylistButton.layer.borderColor = [[UIColor lightGrayColor]CGColor];
            sendStylistButton.layer.borderWidth = 1.0f;
            [sendStylistButton addTarget:self action:@selector(sendStylistButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            if(isSendStylistButtonSelected)
            {
                [sendStylistButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
            }
            
            else
            {
                [sendStylistButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
            }
            
            UIButton *bookFutureAppointmentButton = (UIButton *)[dateTimeCell viewWithTag:602];
            bookFutureAppointmentButton.layer.borderColor = [[UIColor lightGrayColor]CGColor];
            bookFutureAppointmentButton.layer.borderWidth = 1.0f;
            [bookFutureAppointmentButton addTarget:self action:@selector(bookFutureAppointmentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            if(isBookFutureApppointmentButtonSelected)
            {
                [bookFutureAppointmentButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
            }
            
            else
            {
                [bookFutureAppointmentButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
            }
            
            return dateTimeCell;
        }
        
        else if (indexPath.section == 9)
        {
            UITableViewCell *selectDateCell = [tableView dequeueReusableCellWithIdentifier:@"selectDateView"];
            
            UIScrollView *datesScrollView = (UIScrollView *)[selectDateCell viewWithTag:650];
            [self scrollViewDates:datesScrollView];
            
            return selectDateCell;
        }
        
        else if (indexPath.section == 10)
        {
            UITableViewCell *selectTimeCell = [tableView dequeueReusableCellWithIdentifier:@"selectTimeView"];
            UILabel *selectTimeLabel = (UILabel*) [selectTimeCell viewWithTag:511];
            
            if(isDateSelected && (timeList.count <= 0))
            {
                if(self.view.frame.size.width == 320)
                {
                    [selectTimeLabel setFont:[UIFont latoFontOfSize:13]];
                }
                
                else
                {
                    [selectTimeLabel setFont:[UIFont latoFontOfSize:16]];
                }
                
                selectTimeLabel.text = @"Stylist schedule does not exists for this day.";
            }
            
            else
            {
                selectTimeLabel.font = [UIFont systemFontOfSize:17];
                selectTimeLabel.text = @"Select Time:";
            }
            
            return selectTimeCell;
        }
        
        else if (indexPath.section == 11)
        {
            StylistTimeSlotTableViewCell *bookTimeCell = [tableView dequeueReusableCellWithIdentifier:@"bookTimeView"];
            
            // Adding actions to time buttons
            [bookTimeCell.timeSlotButton1 addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [bookTimeCell.timeSlotButton2 addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [bookTimeCell.timeSlotButton3 addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            // Adding tags to time buttons
            bookTimeCell.timeSlotButton1.tag = (1 + indexPath.section) * 100 + 1;
            bookTimeCell.timeSlotButton2.tag = (1 + indexPath.section) * 100 + 2;
            bookTimeCell.timeSlotButton3.tag = (1 + indexPath.section) * 100 + 3;
            
            // if All 3 buttons contains some text
            if ([timeList count] / ((indexPath.row + 1) * 3) >= 1)
            {
                [bookTimeCell.timeSlotButton1 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3)]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton2 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3) + 1]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton3 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3) + 2]] forState:UIControlStateNormal];
            }
            
            // if only 2 buttons contains some text
            else if ([timeList count] % 3 == 2)
            {
                [bookTimeCell.timeSlotButton1 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3)]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton2 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3) + 1]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton3 setTitle:@" " forState:UIControlStateNormal];
            }
            
            // if only 1 button contains some text
            else
            {
                [bookTimeCell.timeSlotButton1 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3)]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton2 setTitle:@" " forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton3 setTitle:@" " forState:UIControlStateNormal];
            }
            
            StylistDetails *stylistDetailsObj = [StylistDetails sharedInstance];
            
            if([bookTimeCell.timeSlotButton1.titleLabel.text isEqualToString:selectedTime])
            {
                [bookTimeCell.timeSlotButton1 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderSelected"] forState:UIControlStateNormal];
            }
            
            else if([stylistDetailsObj.bookedTimeSlots containsObject:bookTimeCell.timeSlotButton1.titleLabel.text])
            {
                [bookTimeCell.timeSlotButton1 setBackgroundImage:[UIImage imageNamed:@"booked_slot_Img"] forState:UIControlStateNormal];
            }
            
            else
            {
                [bookTimeCell.timeSlotButton1 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderUnselected"] forState:UIControlStateNormal];
            }
            
            if([bookTimeCell.timeSlotButton2.titleLabel.text isEqualToString:selectedTime])
            {
                [bookTimeCell.timeSlotButton2 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderSelected"] forState:UIControlStateNormal];
            }
            
            else if([stylistDetailsObj.bookedTimeSlots containsObject:bookTimeCell.timeSlotButton2.titleLabel.text])
            {
                [bookTimeCell.timeSlotButton2 setBackgroundImage:[UIImage imageNamed:@"booked_slot_Img"] forState:UIControlStateNormal];
            }
            
            else
            {
                [bookTimeCell.timeSlotButton2 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderUnselected"] forState:UIControlStateNormal];
            }
            
            if([bookTimeCell.timeSlotButton3.titleLabel.text isEqualToString:selectedTime])
            {
                [bookTimeCell.timeSlotButton3 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderSelected"] forState:UIControlStateNormal];
            }
            
            else if([stylistDetailsObj.bookedTimeSlots containsObject:bookTimeCell.timeSlotButton3.titleLabel.text])
            {
                [bookTimeCell.timeSlotButton3 setBackgroundImage:[UIImage imageNamed:@"booked_slot_Img"] forState:UIControlStateNormal];
            }
            
            else
            {
                [bookTimeCell.timeSlotButton3 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderUnselected"] forState:UIControlStateNormal];
            }
            
            return bookTimeCell;
        }
        else
        {
            UITableViewCell *footerCell = [tableView dequeueReusableCellWithIdentifier:@"FooterView"];
            return footerCell;
        }
    }
    
    else
    {
        if(indexPath.section == 0)
        {
            UITableViewCell *appointmentStatusViewCell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentStatusView"];
            return appointmentStatusViewCell;
        }
        
        else if (indexPath.section==1)
        {
            UITableViewCell *detailButtonViewCell = [tableView dequeueReusableCellWithIdentifier:@"DetailButtonView"];
            
            UIButton *detailButton = (UIButton *)[detailButtonViewCell viewWithTag:777];
            [detailButton setTitle:@"Tap to View Details" forState:UIControlStateNormal];
            [detailButton setImage:[UIImage imageNamed:@"arrow-down-icon"] forState:UIControlStateNormal];
            [detailButton addTarget:self action:@selector(expandCollapseTable) forControlEvents:UIControlEventTouchUpInside];
            
            return detailButtonViewCell;
        }
        
        else if (indexPath.section == 2)
        {
            AddressCustomTableViewCell *addressTableCell = [tableView dequeueReusableCellWithIdentifier:@"AddressView"];
            NSDictionary *primaryAddress, *secondaryAddress;
            
            if(addressList.count>0)
            {
                if(addressList.count/((indexPath.row + 1)*2) >= 1)
                {
                    primaryAddress = [addressList objectAtIndex:indexPath.row*2];
                    secondaryAddress = [addressList objectAtIndex:(indexPath.row*2)+1];
                    
                    [addressTableCell.primaryAddressButton setTitle:[self getPrimaryAddress:primaryAddress] forState:UIControlStateNormal];
                    [addressTableCell.secondaryAddressButton setTitle:[self getPrimaryAddress:secondaryAddress]  forState:UIControlStateNormal];
                }
            
                else
                {
                    primaryAddress = [addressList objectAtIndex:indexPath.row*2];
                    
                    [addressTableCell.primaryAddressButton setTitle:[self getPrimaryAddress:primaryAddress]  forState:UIControlStateNormal];
                    [addressTableCell.secondaryAddressButton setTitle:@" " forState:UIControlStateNormal];
                }
                
                [addressTableCell.primaryAddressButton setHidden:NO];
                [addressTableCell.secondaryAddressButton setHidden:NO];
                [addressTableCell.noAddressMsgLabel setHidden:YES];
            }
            
            else
            {
                [addressTableCell.primaryAddressButton setHidden:YES];
                [addressTableCell.secondaryAddressButton setHidden:YES];
                [addressTableCell.noAddressMsgLabel setHidden:NO];
            }
            
            addressTableCell.primaryAddressButton.tag = indexPath.row + 1000;
            addressTableCell.secondaryAddressButton.tag = indexPath.row + 2000;
            [addressTableCell.primaryAddressButton addTarget:self action:@selector(selectAddress:) forControlEvents:UIControlEventTouchUpInside];
            [addressTableCell.secondaryAddressButton addTarget:self action:@selector(selectAddress:) forControlEvents:UIControlEventTouchUpInside];
            
            if(selectedAddressButtonTag == addressTableCell.primaryAddressButton.tag)
            {
                [addressTableCell.primaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
                [addressTableCell.secondaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
            }
            
            else if(selectedAddressButtonTag == addressTableCell.secondaryAddressButton.tag)
            {
                [addressTableCell.primaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
                [addressTableCell.secondaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
            }
            
            else
            {
                [addressTableCell.primaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
                [addressTableCell.secondaryAddressButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
            }
            
            return addressTableCell;
        }
        
        else if (indexPath.section == 3)
        {
            UITableViewCell *addAdressButtonCell = [tableView dequeueReusableCellWithIdentifier:@"AddAdressButtonView"];
            
            UIButton *addNewAddressButton = (UIButton *)[addAdressButtonCell viewWithTag:651];
            //addNewAddressButton.layer.borderColor = [[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
            addNewAddressButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
            addNewAddressButton.layer.borderWidth = 1.0f;
            addNewAddressButton.layer.cornerRadius = 3.0f;
            [addNewAddressButton addTarget:self action:@selector(addAdress:) forControlEvents:UIControlEventTouchUpInside];
            
            return addAdressButtonCell;
        }
        
        else if (indexPath.section == 4)
        {
            UITableViewCell *dateTimeCell = [tableView dequeueReusableCellWithIdentifier:@"DateTimeView"];
            
            UIButton *sendStylistButton = (UIButton *)[dateTimeCell viewWithTag:601];
            sendStylistButton.layer.borderColor = [[UIColor lightGrayColor]CGColor];
            sendStylistButton.layer.borderWidth = 1.0f;
            [sendStylistButton addTarget:self action:@selector(sendStylistButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            if(isSendStylistButtonSelected)
            {
                [sendStylistButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
            }
            
            else
            {
                [sendStylistButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
            }
            
            UIButton *bookFutureAppointmentButton = (UIButton *)[dateTimeCell viewWithTag:602];
            bookFutureAppointmentButton.layer.borderColor = [[UIColor lightGrayColor]CGColor];
            bookFutureAppointmentButton.layer.borderWidth = 1.0f;
            [bookFutureAppointmentButton addTarget:self action:@selector(bookFutureAppointmentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            if(isBookFutureApppointmentButtonSelected)
            {
                [bookFutureAppointmentButton setBackgroundImage:[UIImage imageNamed:@"date_selected_grey_bg"] forState:UIControlStateNormal];
            }
            
            else
            {
                [bookFutureAppointmentButton setBackgroundImage:[UIImage imageNamed:@"date_unselected"] forState:UIControlStateNormal];
            }
            
            return dateTimeCell;
        }
        
        else if (indexPath.section == 5)
        {
            UITableViewCell *selectDateCell = [tableView dequeueReusableCellWithIdentifier:@"selectDateView"];
            
            UIScrollView *datesScrollView = (UIScrollView *)[selectDateCell viewWithTag:650];
            [self scrollViewDates:datesScrollView];
           
            return selectDateCell;
        }
        
        else if (indexPath.section == 6)
        {
            UITableViewCell *selectTimeCell = [tableView dequeueReusableCellWithIdentifier:@"selectTimeView"];
            UILabel *selectTimeLabel = (UILabel*) [selectTimeCell viewWithTag:511];
            
            if(isDateSelected && (timeList.count <= 0))
            {
                if(self.view.frame.size.width == 320)
                {
                    [selectTimeLabel setFont:[UIFont latoFontOfSize:13]];
                }
                
                else
                {
                    [selectTimeLabel setFont:[UIFont latoFontOfSize:16]];
                }
                
                selectTimeLabel.text = @"Stylist schedule does not exists for this day.";
            }
            
            else
            {
                [selectTimeLabel setFont:[UIFont latoFontOfSize:17]];
                selectTimeLabel.text = @"Select Time:";
            }
            
            return selectTimeCell;
        }
        
        else if (indexPath.section == 7)
        {
            StylistTimeSlotTableViewCell *bookTimeCell = [tableView dequeueReusableCellWithIdentifier:@"bookTimeView"];
            
            // Adding actions to time buttons
            [bookTimeCell.timeSlotButton1 addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [bookTimeCell.timeSlotButton2 addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [bookTimeCell.timeSlotButton3 addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            // Adding tags to time buttons
            bookTimeCell.timeSlotButton1.tag = (1 + indexPath.section) * 100 + 1;
            bookTimeCell.timeSlotButton2.tag = (1 + indexPath.section) * 100 + 2;
            bookTimeCell.timeSlotButton3.tag = (1 + indexPath.section) * 100 + 3;
            
            // if All 3 buttons contains some text
            if ([timeList count] / ((indexPath.row + 1) * 3) >= 1)
            {
                [bookTimeCell.timeSlotButton1 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3)]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton2 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3) + 1]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton3 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3) + 2]] forState:UIControlStateNormal];
            }
            
            // if only 2 buttons contains some text
            else if ([timeList count] % 3 == 2)
            {
                [bookTimeCell.timeSlotButton1 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3)]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton2 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3) + 1]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton3 setTitle:@" " forState:UIControlStateNormal];
            }
            
            // if only 1 button contains some text
            else
            {
                [bookTimeCell.timeSlotButton1 setTitle:[self getTime:[timeList objectAtIndex:(indexPath.row * 3)]] forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton2 setTitle:@" " forState:UIControlStateNormal];
                [bookTimeCell.timeSlotButton3 setTitle:@" " forState:UIControlStateNormal];
            }
            
            StylistDetails *stylistDetailsObj = [StylistDetails sharedInstance];
            
            if([bookTimeCell.timeSlotButton1.titleLabel.text isEqualToString:selectedTime])
            {
                [bookTimeCell.timeSlotButton1 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderSelected"] forState:UIControlStateNormal];
            }
            
            else if([stylistDetailsObj.bookedTimeSlots containsObject:bookTimeCell.timeSlotButton1.titleLabel.text])
            {
                [bookTimeCell.timeSlotButton1 setBackgroundImage:[UIImage imageNamed:@"booked_slot_Img"] forState:UIControlStateNormal];
            }
            
            else
            {
                [bookTimeCell.timeSlotButton1 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderUnselected"] forState:UIControlStateNormal];
            }
            
            if([bookTimeCell.timeSlotButton2.titleLabel.text isEqualToString:selectedTime])
            {
                [bookTimeCell.timeSlotButton2 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderSelected"] forState:UIControlStateNormal];
            }
            
            else if([stylistDetailsObj.bookedTimeSlots containsObject:bookTimeCell.timeSlotButton2.titleLabel.text])
            {
                [bookTimeCell.timeSlotButton2 setBackgroundImage:[UIImage imageNamed:@"booked_slot_Img"] forState:UIControlStateNormal];
            }
            
            else
            {
                [bookTimeCell.timeSlotButton2 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderUnselected"] forState:UIControlStateNormal];
            }
            
            if([bookTimeCell.timeSlotButton3.titleLabel.text isEqualToString:selectedTime])
            {
                [bookTimeCell.timeSlotButton3 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderSelected"] forState:UIControlStateNormal];
            }
            
            else if([stylistDetailsObj.bookedTimeSlots containsObject:bookTimeCell.timeSlotButton3.titleLabel.text])
            {
                [bookTimeCell.timeSlotButton3 setBackgroundImage:[UIImage imageNamed:@"booked_slot_Img"] forState:UIControlStateNormal];
            }
            
            else
            {
                [bookTimeCell.timeSlotButton3 setBackgroundImage:[UIImage imageNamed:@"timeButtonBorderUnselected"] forState:UIControlStateNormal];
            }
            
            return bookTimeCell;
        }
        
        else
        {
            UITableViewCell *footerCell = [tableView dequeueReusableCellWithIdentifier:@"FooterView"];
            return footerCell;
        }
    }
}

// providing height to different sections when the table is expanded and when the table is collapsed
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(isexpanded)
    {
        if(indexPath.section == 0)
        {
            return 40;
        }
        
        else if(indexPath.section == 1)
        {
            return 32;
        }
        
        else if(indexPath.section == 2)
        {
            return 32;
        }
        
        else if(indexPath.section == 3)
        {
            return 25;
        }
        
        else if(indexPath.section == 4)
        {
            return 32;
        }
        
        else if(indexPath.section == 5)
        {
            return 60;
        }
        
        else if(indexPath.section == 6)
        {
            return 90;
        }
        
        else if(indexPath.section == 7)
        {
            return 110;
        }
        
        else if(indexPath.section == 8)
        {
            return 70;
        }
        
        else if(indexPath.section == 9)
        {
            return 120;
        }
        
        else if(indexPath.section == 10)
        {
            return 27;
        }
        
        else if(indexPath.section == 11)
        {
            return 44;
        }
        
        else
        {
            return 10;
        }
    }
    
    else
    {
        if(indexPath.section == 0)
        {
            return 40;
        }
        
        else if(indexPath.section == 1)
        {
            return 60;
        }
        
        else if(indexPath.section == 2)
        {
            return 90;
        }
        
        else if(indexPath.section == 3)
        {
            return 106;
        }
        
        else if(indexPath.section == 4)
        {
            return 70;
        }
        
        else if(indexPath.section == 5)
        {
            return 120;
        }
        
        else if(indexPath.section == 6)
        {
            return 27;
        }
        
        else if(indexPath.section == 7)
        {
            return 44;
        }
        
        else
        {
            return 10;
        }
    }
}

#pragma mark - Get Secondary Address String

- (NSString *)getSecondaryAddress:(NSDictionary *)secondaryAddress
{
    NSString *secondaryAddressString;
    NSString *lineTwoSecondaryAddress = [[secondaryAddress valueForKey:@"line_2"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(!lineTwoSecondaryAddress || [lineTwoSecondaryAddress length] == 0)
    {
        secondaryAddressString = [NSString stringWithFormat:@"%@\n%@\n%@, %@ %@",[secondaryAddress valueForKey:@"name"],[secondaryAddress valueForKey:@"line_1"],[secondaryAddress valueForKey:@"city"],[secondaryAddress valueForKey:@"state"],[secondaryAddress valueForKey:@"zip_code"]];
    }
    
    else
    {
        secondaryAddressString = [NSString stringWithFormat:@"%@\n%@,%@\n%@, %@ %@",[secondaryAddress valueForKey:@"name"],[secondaryAddress valueForKey:@"line_1"],[secondaryAddress valueForKey:@"line_2"],[secondaryAddress valueForKey:@"city"],[secondaryAddress valueForKey:@"state"],[secondaryAddress valueForKey:@"zip_code"]];
    }
    
    return secondaryAddressString;
}

#pragma mark - Get Primary Address String

- (NSString *)getPrimaryAddress:(NSDictionary *)primaryAddress
{
    NSString *primaryAddressString;
    NSString *lineTwoPrimaryAddress = [[primaryAddress valueForKey:@"line_2"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //NSLog(@"%@",lineTwoPrimaryAddress);
    
    if(!lineTwoPrimaryAddress || [lineTwoPrimaryAddress length] == 0)
    {
        primaryAddressString = [NSString stringWithFormat:@"%@\n%@\n%@, %@ %@",[primaryAddress valueForKey:@"name"],[primaryAddress valueForKey:@"line_1"],[primaryAddress valueForKey:@"city"],[primaryAddress valueForKey:@"state"],[primaryAddress valueForKey:@"zip_code"]];
    }
    
    else
    {
        primaryAddressString = [NSString stringWithFormat:@"%@\n%@,%@\n%@, %@ %@",[primaryAddress valueForKey:@"name"],[primaryAddress valueForKey:@"line_1"],[primaryAddress valueForKey:@"line_2"],[primaryAddress valueForKey:@"city"],[primaryAddress valueForKey:@"state"],[primaryAddress valueForKey:@"zip_code"]];
    }
    
    return primaryAddressString;
}

#pragma mark - Get Time String Format

- (NSString *)getTime:(NSString *)time
{
    return time;
}

#pragma mark - Tap to show/hide button action

- (void)expandCollapseTable
{
    if(isexpanded)
    {
        isexpanded = NO;
    }
    
    else
    {
        isexpanded = YES;
    }
    
    [self.detailsTableView reloadData];
}


#pragma mark- Time Button Selected Action

-(void)timeButtonTapped: (UIButton*)sender
{
    //  int tag = (int)sender.tag;
    StylistDetails *stylistDetailsObj = [StylistDetails sharedInstance];
    
    // Call webservice to Book Appointment
    
    if([stylistDetailsObj.bookedTimeSlots containsObject:sender.titleLabel.text])
    {
        return;
    }
    
    else if((![sender.titleLabel.text isEqualToString:@" "]) && (![sender.titleLabel.text isEqualToString:selectedTime]))
    {
        selectedTime = sender.titleLabel.text;
        isTimeSelected = YES;
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        dateFormater.dateFormat = @"dd/MM/yyyy";
        
        NSString *todayDateString = [dateFormater stringFromDate:[NSDate date]];
        
        if([selectedDate isEqualToString:todayDateString])
        {
            NSDate *today = [NSDate date];
            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            [format setDateFormat:@"hh:mma"];
            NSString *currentTime = [format stringFromDate:today];
            NSString *currentTimeInLowerCase = currentTime.lowercaseString;
            
            NSDate *date1= [format dateFromString:selectedTime];
            NSDate *date2 = [format dateFromString:currentTimeInLowerCase];
            
            NSComparisonResult startTimeResult = [date1 compare:date2];
            
            if(startTimeResult == NSOrderedAscending)
            {
                //NSLog(@"current time is greater than start time");
                isDateSelected = YES;
                isTimeSelected = NO;
                selectedTime = nil;
                [self failedWithError:nil description:@"Appointment time should be greater than Current time"];
                return;
            }
            
            else
            {
                [Utility showActivity:self];
                WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
                webserviceViewController.delegate = self;
                currentAPICalled = kBookAppointment;
                
                NSMutableDictionary *appointmentDictionary = [[NSMutableDictionary alloc]init];
                NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"hh:mma"];
                
                NSDate *startTimeDate = [formatter dateFromString:sender.titleLabel.text];
                NSDate *newTimeDate = [startTimeDate dateByAddingTimeInterval:60*60];
                
                [appointmentDictionary setObject:selectedStylistId forKey:@"partner_id"];
                [appointmentDictionary setObject:selectedDate forKey:@"date"];
                [appointmentDictionary setObject:[NSString stringWithFormat:@"%@ %@", selectedDate, sender.titleLabel.text] forKey:@"from_time"];
                [appointmentDictionary setObject:[NSString stringWithFormat:@"%@ %@", selectedDate, [[formatter stringFromDate:newTimeDate]lowercaseString]] forKey:@"to_time"];
                
                //Forming Json Object
                [postDictionary setObject:appointmentDictionary forKey:@"appointment"];
                
                //Calling webservice
                [webserviceViewController bookAppointment:postDictionary];
            }
        }
        
        if(![selectedDate isEqualToString:todayDateString])
        {
            [Utility showActivity:self];
            WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
            webserviceViewController.delegate = self;
            currentAPICalled = kBookAppointment;
            
            NSMutableDictionary *appointmentDictionary = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"hh:mma"];
            
            NSDate *startTimeDate = [formatter dateFromString:sender.titleLabel.text];
            NSDate *newTimeDate = [startTimeDate dateByAddingTimeInterval:60*60];
            
            [appointmentDictionary setObject:selectedStylistId forKey:@"partner_id"];
            [appointmentDictionary setObject:selectedDate forKey:@"date"];
            [appointmentDictionary setObject:[NSString stringWithFormat:@"%@ %@", selectedDate, sender.titleLabel.text] forKey:@"from_time"];
            [appointmentDictionary setObject:[NSString stringWithFormat:@"%@ %@", selectedDate, [[formatter stringFromDate:newTimeDate]lowercaseString]] forKey:@"to_time"];
            
            //Forming Json Object
            [postDictionary setObject:appointmentDictionary forKey:@"appointment"];
            
            //Calling webservice
            [webserviceViewController bookAppointment:postDictionary];
        }
    }
}

#pragma mark- Select Address method

- (void)selectAddress:(UIButton *)sender
{
    NSString *address = [sender.titleLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(address.length<= 0)
        return;
    
    int currentTag = (int) sender.tag;
    
    if(selectedAddressButtonTag != currentTag && sender.titleLabel.text.length>0)
    
    isAddressSelected = YES;
    selectedAddressButtonTag = currentTag;
    NSArray *addressArray = [sender.titleLabel.text componentsSeparatedByString:@"\n"];
    NSArray *stateAndZipcodeArray = [[addressArray objectAtIndex:2] componentsSeparatedByString:@","];
    
    NSMutableArray *createSelectedAddressarray = [[NSMutableArray alloc]init];
    [createSelectedAddressarray insertObject:[addressArray objectAtIndex:0] atIndex:0];
    [createSelectedAddressarray insertObject:[addressArray objectAtIndex:1] atIndex:1];
    [createSelectedAddressarray insertObject:[stateAndZipcodeArray objectAtIndex:0] atIndex:2];
    [createSelectedAddressarray insertObject:[stateAndZipcodeArray objectAtIndex:1] atIndex:3];
    
    selectedAddress = [NSArray arrayWithArray:createSelectedAddressarray];
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    userAccount.selectedUserAddress = selectedAddress;
    
    if(currentTag < 2000)
    {
        selectedAddressId = [[addressList objectAtIndex:(currentTag % 1000)*2]valueForKey:@"id"];
    }
    
    else
    {
        selectedAddressId = [[addressList objectAtIndex:((currentTag % 2000)*2 + 1)]valueForKey:@"id"];
    }
    userAccount.selectedAddressId = selectedAddressId;
    
    [self saveUserData];
    [self.detailsTableView reloadData];
}

#pragma mark - Add Address for Registered User

- (void)addAddressForRegisteredUser
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddressViewController *addressViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"AddressSB"];
    addressViewController.delegate = self;
    [self presentViewController:addressViewController animated:YES completion:nil];
}

#pragma mark - Modify price Data if new services is added via Add Service Button

- (void)modifyPriceData
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
            NSMutableDictionary *servicesSelected = [[NSMutableDictionary alloc]init];
            [priceDictionary removeAllObjects];
            [categoryDictionary removeAllObjects];
            [subCategoryList removeAllObjects];
            
            NSMutableArray *productIds = [[NSMutableArray alloc]init];
            
            NSArray *serviceSelectedByUser = currentUser.selectedServices.allObjects;
            
            for(Services *selectedServicesObj in serviceSelectedByUser)
            {
                [priceDictionary  setValue:selectedServicesObj.price forKey:selectedServicesObj.name];
                [categoryDictionary  setValue:selectedServicesObj.categoryName forKey:selectedServicesObj.name];
                [productIds  addObject:selectedServicesObj.productId];
                [subCategoryList addObject:selectedServicesObj.name];
                [servicesSelected setValue:selectedServicesObj.categoryName forKey:selectedServicesObj.name];
            }
            
            userAccount.selectedServicesList = servicesSelected;
            userAccount.selectedsubCategoryList = subCategoryList;
            stylistObj.stylistCategoryPriceDict = categoryDictionary;
            stylistObj.stylistServicePriceDict = priceDictionary;
            userAccount.selectedStylistName = currentUser.selectedStylistName;
        }
    }
}

#pragma mark - New service selected via Add Service Button

- (void)addtionalServiceSelected
{
    [self modifyPriceData];
}

#pragma mark - Add Service Button Action

- (void)goToSelectedStylistProfile
{
    StylistDetails *stylist = [StylistDetails sharedInstance];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StylistInfoViewController *stylistInfoViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistInfoSB"];
    stylistInfoViewController.stylistId = stylist.selectedStylist.stylistId;
    stylistInfoViewController.delegate = self;
    stylistInfoViewController.stylistAC = stylist.selectedStylist;
    [self presentViewController:stylistInfoViewController animated:YES completion:nil];
}

#pragma mark - Add New Address Button Action

- (void)addAdress:(UIButton*)sender
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if([userAccount.userId isEqualToString:@"Guest"])
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        JoinParlorViewController *joinParlorViewController = [storyBoard instantiateViewControllerWithIdentifier:@"JoinParlorSB"];
        joinParlorViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:joinParlorViewController];
        [self presentViewController:navController animated:YES completion:nil];
    }
    
    else
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddressViewController *addressViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"AddressSB"];
        addressViewController.delegate = self;
        [self presentViewController:addressViewController animated:YES completion:nil];
    }
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kBookAppointmentAlert)
    {
        
    }
    
    else if(alertView.tag == 66)
    {
        if(![self checkIfAppointmentTimeSelected])
            return;
        
        UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        PaymentViewController *paymentView = [aStoryboard instantiateViewControllerWithIdentifier:@"PaymentStoryView"];
        [self.navigationController pushViewController:paymentView animated:YES];
    }
    
    else if(alertView.tag == 77)
    {
        if(![self checkIfAppointmentTimeSelected])
            return;
        
        UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        PaymentViewController *paymentView = [aStoryboard instantiateViewControllerWithIdentifier:@"PaymentStoryView"];
        [self.navigationController pushViewController:paymentView animated:YES];
    }
}

#pragma mark- Webservice Delegates

- (void)receivedResponse:(id)response
{
    iswebServiceFailed = NO;
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"] && [currentAPICalled isEqualToString:kGetAddressList]) // check for response while calling Get Address List API
    {
        UserAccount *userAccount = [UserAccount sharedInstance];
        
        addressList = [NSMutableArray arrayWithArray:userAccount.userAddressList];
        
        if(!isAddressSelected && addressList.count > 0)
        {
            isAddressSelected = YES;
            NSDictionary *primaryAddress, *secondaryAddress;
            NSArray *addressArray;
            
            if(addressList.count%2==0)
            {
                selectedAddressId = [[addressList objectAtIndex:(addressList.count-1)]valueForKey:@"id"];
                selectedAddressButtonTag = (int)(addressList.count-1)/2 + 2000;
                secondaryAddress = [addressList objectAtIndex:addressList.count-1];
                addressArray = [[self getSecondaryAddress:secondaryAddress]componentsSeparatedByString:@"\n"];
                
            }
            
            else
            {
                primaryAddress = [addressList objectAtIndex:addressList.count-1];
                addressArray = [[self getPrimaryAddress:primaryAddress]componentsSeparatedByString:@"\n"];
                selectedAddressId = [[addressList objectAtIndex:(addressList.count-1)]valueForKey:@"id"];
                selectedAddressButtonTag = (int)(addressList.count-1)/2 + 1000;
            }
            
            NSArray *stateAndZipcodeArray = [[addressArray objectAtIndex:2] componentsSeparatedByString:@","];
            
            NSMutableArray *createSelectedAddressarray = [[NSMutableArray alloc]init];
            [createSelectedAddressarray insertObject:[addressArray objectAtIndex:0] atIndex:0];
            [createSelectedAddressarray insertObject:[addressArray objectAtIndex:1] atIndex:1];
            [createSelectedAddressarray insertObject:[stateAndZipcodeArray objectAtIndex:0] atIndex:2];
            [createSelectedAddressarray insertObject:[stateAndZipcodeArray objectAtIndex:1] atIndex:3];
            
            selectedAddress = [NSArray arrayWithArray:createSelectedAddressarray];
            
            UserAccount *userAccount = [UserAccount sharedInstance];
            userAccount.selectedUserAddress = selectedAddress;
            userAccount.selectedAddressId = selectedAddressId;
            [self saveUserData];
            isnewAddressAdded = NO;
        }
        
        [self.detailsTableView reloadData];
    }
    
    else if ([response isEqualToString:@"Yes"] && [currentAPICalled isEqualToString:kGetTimeSlots]) // check for response while calling Get Time Slot API
    {
        //NSLog(@"parse Times");
        StylistDetails *stylistAccountObj = [StylistDetails sharedInstance];
        //NSLog(@"%@", stylistAccountObj.availableTimeSlots);
        timeList = [NSArray arrayWithArray:stylistAccountObj.availableTimeSlots];
        [self.detailsTableView reloadData];
    }
    
    else if ([response isEqualToString:@"Yes"] && [currentAPICalled isEqualToString:kBookAppointment]) // check for response while calling Book Appointment API
    {
        //NSLog(@"parse Book Appointment Time Response");
        UserAccount *userAccount = [UserAccount sharedInstance];
        if(userAccount.appointmentId)
        {
            userAccount.fromTime = selectedTime;
            userAccount.selectedDate = selectedDate;
            [self saveUserData];
            if(![self checkIfAppointmentTimeSelected])
                return;
            
            UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            PaymentViewController *paymentView = [aStoryboard instantiateViewControllerWithIdentifier:@"PaymentStoryView"];
            [self.navigationController pushViewController:paymentView animated:YES];
        }
        
        else
        {
            [Utility showActivity:self];
            // StylistDetails *stylistDetailsObj = [StylistDetails sharedInstance];
            WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
            webserviceViewController.delegate = self;
            currentAPICalled = kGetAppointmentID;
            
            NSMutableDictionary *appointmentDictionary = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
            
            [appointmentDictionary setObject:selectedStylistId forKey:@"partner_id"];
            [appointmentDictionary setObject:selectedDate forKey:@"date"];
            [appointmentDictionary setObject:[NSString stringWithFormat:@"%@ %@",selectedDate,selectedTime] forKey:@"from_time"];
            
            //Forming Json Object
            [postDictionary setObject:appointmentDictionary forKey:@"appointment"];
            
            //Calling webservice
            [webserviceViewController getAppointmentID:postDictionary];
        }
    }
    
    else if ([response isEqualToString:@"Yes"] && [currentAPICalled isEqualToString:kGetAppointmentID]) // check for response while calling Get Appointment ID API
    {
        //NSLog(@"parse Get Appointment ID Response");
        
        UserAccount *userAccount = [UserAccount sharedInstance];
        if(userAccount.appointmentId)
        {
            userAccount.fromTime = selectedTime;
            userAccount.selectedDate = selectedDate;
            [self saveUserData];
            if(![self checkIfAppointmentTimeSelected])
                return;
            
            UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            PaymentViewController *paymentView = [aStoryboard instantiateViewControllerWithIdentifier:@"PaymentStoryView"];
            [self.navigationController pushViewController:paymentView animated:YES];
        }
    }
    
    else if ([response isEqualToString:@"Yes"] && [currentAPICalled isEqualToString:kSendStylist])
    {
        UserAccount *userAccount = [UserAccount sharedInstance];
        if(userAccount.appointmentId)
        {
            selectedDate = userAccount.selectedDate;
            selectedTime = userAccount.fromTime;
            isTimeSelected = YES;
            [self saveUserData];
            if(![self checkIfAppointmentTimeSelected])
                return;
            
            UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            PaymentViewController *paymentView = [aStoryboard instantiateViewControllerWithIdentifier:@"PaymentStoryView"];
            [self.navigationController pushViewController:paymentView animated:YES];
        }
    }
    
    else if ([currentAPICalled isEqualToString:kSendStylist]) // check for any error while calling Send Stylist API
    {
        //NSLog(@"parse Send Stylist Response failure");
        UserAccount *userAccount = [UserAccount sharedInstance];
        
        userAccount.appointmentId = nil;
        isTimeSelected = NO;
        [self.detailsTableView reloadData];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Stylist is not available at this time." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if ([currentAPICalled isEqualToString:kGetAppointmentID]) // check for any error while calling Get Appointment ID API
    {
        //NSLog(@"parse Get Appointment ID Response failure");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to book Slot." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if ([currentAPICalled isEqualToString:kBookAppointment])  // check for any error while calling Book Appointment API
    {
        isTimeSelected = NO;
        [self.detailsTableView reloadData];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to book Schedule." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if ([currentAPICalled isEqualToString:kGetTimeSlots])  // check for any error while calling Get Time Slot API
    {
        StylistDetails *stylistAccountObj = [StylistDetails sharedInstance];
        //NSLog(@"%@", stylistAccountObj.availableTimeSlots);
        timeList = [NSArray arrayWithArray:stylistAccountObj.availableTimeSlots];
        [self.detailsTableView reloadData];
    }
    
    else if ([currentAPICalled isEqualToString:kGetAddressList])  // check for any error while calling Get Address List API
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to fetch Address List." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    iswebServiceFailed = YES;
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to process Request." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
