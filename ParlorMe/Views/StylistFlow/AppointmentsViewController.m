//
//  AppointmentViewController.m
//  ParlorMe
//

#import "AppointmentsViewController.h"
#import "NewBookingRequestViewController.h"
#import "AppointmentDetailViewController.h"
#import "SingletonClass.h"
#import "Constants.h"
#import <LatoFont/UIFont+Lato.h>
#import "CoreDataModel.h"
#import "ClockInAndOut+CoreDataProperties.h"
#import "WebserviceViewController.h"
#import "Utility.h"
#import "StylistFlowModel.h"
#import "StylistAccount.h"
#import "SWRevealViewController.h"

@interface AppointmentsViewController ()<UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NSURLConnectionDataDelegate, WebserviceViewControllerDelegate>
{
    NSMutableArray *datesWithDaysArray;
    NSMutableArray *datesWithDaysArray2;
    NSMutableArray *countsArray;
    NSArray *timeLapsArray;
    NSMutableArray *appointmentTimesArray;
    NSMutableArray *cellHeightsArray;
    NewBookingRequestViewController *bookingRequestViewController;
    SingletonClass *sharedObj;
    NSInteger xpos;
    NSInteger width;
    NSInteger selectedBtn;
    NSString *currentAPICalled;
    WebserviceViewController *webVC;
    NSMutableArray *appointmentsListDictionary;
    UILabel *noAppointmentsLabel;
    UILabel *initialShownLabel;
}

@property (weak, nonatomic) IBOutlet UIScrollView *datesScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *bgScroll;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UITableView *appointmentsTable;
@property (nonatomic, weak) IBOutlet UILabel *bottomLbl;
@property (nonatomic, weak) IBOutlet UIButton *clockInBtn;
@property (nonatomic, weak) IBOutlet UILabel *clockInTextLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topSpaceViewConstraint;
@property (nonatomic, weak) IBOutlet UIButton *prevArrowBtnImg;
@property (nonatomic, weak) IBOutlet UIButton *nextArrowBtnImg;
@property (nonatomic, weak) IBOutlet UIButton *prevDatesBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextDatesBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuBtn;

-(IBAction)clockInBtnAction:(id)sender;

@end

@implementation AppointmentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Disable the previous button
    self.prevDatesBtn.enabled = self.prevArrowBtnImg.enabled = NO;
    
    timeLapsArray = [[NSArray alloc]initWithObjects:@"8:00AM",@"9:00AM", @"10:00AM", @"11:00AM", @"12:00PM", @"1:00PM", @"2:00PM", @"3:00PM", @"4:00PM", @"5:00PM", @"6:00PM", @"7:00PM", @"8:00PM", @"9:00PM",@"10:00PM", nil];
    //appointmentTimesArray = [[NSMutableArray alloc]initWithObjects:@"12:30PM", @"3:30PM", @"6:30PM", nil];
    
    self.clockInBtn.layer.cornerRadius = 5;
    
    xpos = self.view.frame.origin.x;
    width = self.view.frame.size.width;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"ShowDetailsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"HideDetailsNotification" object:nil];
    
    [self.appointmentsTable setHidden:YES];
    
    //Allocate WebviewController
    webVC = [[WebserviceViewController alloc] init];
    webVC.delegate = self;
    
    initialShownLabel = [[UILabel alloc]init];
    initialShownLabel.frame = CGRectMake(0, self.view.frame.size.height/2-30, self.view.frame.size.width, 30);
    initialShownLabel.text = @"Select a date to see available appointments";
    initialShownLabel.textAlignment = NSTextAlignmentCenter;
    initialShownLabel.layer.zPosition = 100;
    initialShownLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15];
    initialShownLabel.hidden = NO;
    [self.bgScroll addSubview:initialShownLabel];
    
    noAppointmentsLabel = [[UILabel alloc]init];
    noAppointmentsLabel.frame = CGRectMake(0, self.view.frame.size.height/2-30, self.view.frame.size.width, 30);
    noAppointmentsLabel.text = @"No Appointments scheduled for this date";
    noAppointmentsLabel.textAlignment = NSTextAlignmentCenter;
    noAppointmentsLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15];
    noAppointmentsLabel.layer.zPosition = 100;
    
    //add gesture to view, to open the left menu
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [Utility showActivity:self];
    
    UILabel *label = [self.view viewWithTag:100];
    label.hidden = YES;
    self.prevArrowBtnImg.hidden = YES;
    self.nextArrowBtnImg.hidden = YES;
    
    currentAPICalled = kPartnerAppointmentsCount;
    [webVC getAppointmentsCount];
    
    [self.leftMenuBtn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - ViewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //hide navigation bar
    self.navigationController.navigationBarHidden = YES;
    
    if([SingletonClass shareManager].appoinmentNotification == YES)
    {
        StylistAccount *stylistAccount = [StylistAccount sharedInstance];
        NSDictionary *notificationDict = stylistAccount.stylistAppointmentNotificationDictionary;
        
        self.topSpaceViewConstraint.constant = 205+40+40+25 + [[notificationDict objectForKey:@"services_list"] count]*20;
        
        [_bgScroll updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
        [_bgScroll layoutIfNeeded];
    }
    
    self.clockInTextLabel.text = [[StylistFlowModel sharedInstance]partnerAvailabilityString];
}

#pragma mark - ViewDidAppear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    if(sharedObj.appoinmentNotification == YES)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideDetailsNotification" object:self];
    }
    
    else
    {
        //Replacement of content size
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 70, 0.0);
        self.bgScroll.contentInset = contentInsets;
    }
}

#pragma mark - Handle NSNotification
- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"HideDetailsNotification"])
    {
        //Move scrollview postion to top
        [self.bgScroll setContentOffset:CGPointZero animated:NO];
        [sharedObj setDropDownBoolValue:YES];
        
        [bookingRequestViewController.view removeFromSuperview];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        bookingRequestViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"NewBookingRequestViewControllerSB"];
        bookingRequestViewController.view.frame = CGRectMake(0, 0, bookingRequestViewController.view.frame.size.width, 160);
        [self.bgScroll addSubview:bookingRequestViewController.view];
        
        self.topSpaceViewConstraint.constant = bookingRequestViewController.view.frame.size.height;
        //sharedObj.appoinmentNotification = NO;
    }
    
    if([[notification name] isEqualToString:@"ShowDetailsNotification"])
    {
        //Move scrollview postion to top
        [self.bgScroll setContentOffset:CGPointZero animated:NO];
        
        [sharedObj setDropDownBoolValue:NO];
        
        StylistAccount *stylistAccount = [StylistAccount sharedInstance];
        NSDictionary *notificationDict = stylistAccount.stylistAppointmentNotificationDictionary;
        
        bookingRequestViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 205+40+40+25 + [[notificationDict objectForKey:@"services_list"] count]*20);
        
        self.topSpaceViewConstraint.constant = bookingRequestViewController.view.frame.size.height;
        //sharedObj.appoinmentNotification = NO;
    }
}

#pragma mark - ViewWillDisappear
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //To move scrollview postion to top
    [self.bgScroll setContentOffset:CGPointZero animated:NO];
    [bookingRequestViewController.view removeFromSuperview];
    //sharedObj.appoinmentNotification = NO;
    self.topSpaceViewConstraint.constant = 0;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"HideDetailsNotification" object:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ShowDetailsNotification" object:self];
}

#pragma mark - Max Cell Height Index Values
-(void)maxCellHeightIndexValues
{
    cellHeightsArray = [[NSMutableArray alloc]init];
    
    for(int h=0; h<appointmentTimesArray.count; h++)
    {
        for(int i=0; i<timeLapsArray.count; i++)
        {
            if(i <= timeLapsArray.count-2)
            {
                NSString *startTimeString = [timeLapsArray objectAtIndex:i];
                NSString *endTimeString = [timeLapsArray objectAtIndex:i+1];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"h:mma"];
                
                NSString *nowTimeString = [appointmentTimesArray objectAtIndex:h];
                
                int startTime = [self minutesSinceMidnight:[formatter dateFromString:startTimeString]];
                int endTime = [self minutesSinceMidnight:[formatter dateFromString:endTimeString]];
                int nowTime = [self minutesSinceMidnight:[formatter dateFromString:nowTimeString]];
                
                if (startTime <= nowTime && nowTime <= endTime)
                {
                    //NSLog(@"Appointment time %@ is in between %@ and %@ so dynamic cell height index value is %d",[appointmentTimesArray objectAtIndex:h], [timeLapsArray objectAtIndex:i], [timeLapsArray objectAtIndex:i+1], i);
                    NSString *indexString = [NSString stringWithFormat:@"%d",i];
                    
                    if(![cellHeightsArray containsObject:indexString])
                    {
                        [cellHeightsArray addObject:indexString];
                    }
                }
                
                else
                {
                    //NSLog(@"Time is not in between");
                }
            }
        }
    }
    
    //NSLog(@"cellHeightsArray: %@",cellHeightsArray);
}

-(int)minutesSinceMidnight:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    return 60 * (int)[components hour] + (int)[components minute];
}

#pragma mark - List Of Two Weeks Dates
-(void)scrollViewDates
{
    //remove all subviews before adding new
    for (UIView *views in self.datesScroll.subviews)
    {
        [views removeFromSuperview];
    }
    
    self.datesScroll.layer.borderWidth = 1;
    self.datesScroll.layer.borderColor = [UIColor blackColor].CGColor;
    
    //14 days from today
    int days = 14;
    int blockWidth = 0;
    
    NSDate *start = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    NSMutableArray* dates = [NSMutableArray arrayWithObject:start];
    
    //adding dates with default format to an array
    for (int i = 1; i < days; i++)
    {
        [offset setDay:i];
        NSDate *next = [calendar dateByAddingComponents:offset toDate:start options:0];
        [dates addObject:next];
    }
    
    //adding dates to an array with specified format
    datesWithDaysArray = [[NSMutableArray alloc]init];
    datesWithDaysArray2 = [[NSMutableArray alloc]init];
    countsArray = [[NSMutableArray alloc]init];
    
    for(int j=0; j<dates.count; j++)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"MMMM/dd/yyyy/EEEE"];
        NSString *dateString = [df stringFromDate:[dates objectAtIndex:j]];
        [datesWithDaysArray addObject:dateString];
        
        NSDateFormatter *df2 = [[NSDateFormatter alloc]init];
        [df2 setDateFormat:@"yyyy/M/d"];
        NSString *dateString2 = [df2 stringFromDate:[dates objectAtIndex:j]];
        [datesWithDaysArray2 addObject:dateString2];
        
        [countsArray insertObject:@"0" atIndex:j];
    }
    
    int tileXPos = 0;
    CGFloat appointmentsLblFont = 0.0;
    int highlightedLineXPos = 0;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    //Different fonts sizes based on screen height
    if(screenHeight <= IS_iPhone4SOR5)
    {
        blockWidth = 65;
        appointmentsLblFont = Font8;
    }
    
    else if (screenHeight == IS_iPhone6)
    {
        blockWidth = 79;
        appointmentsLblFont = Font10;
    }
    
    else if (screenHeight == IS_iPhone6Plus)
    {
        blockWidth = 68;
        appointmentsLblFont = Font9;
    }
    
    StylistAccount *stylistAccount = [StylistAccount sharedInstance];
    
    if(stylistAccount.stylistAppointmentDatesArray.count > 0)
    {
        for(int i=0; i<stylistAccount.stylistAppointmentDatesArray.count; i++)
        {
            for(int j=0; j<datesWithDaysArray2.count; j++)
            {
                if([[datesWithDaysArray2 objectAtIndex:j] isEqualToString:[stylistAccount.stylistAppointmentDatesArray objectAtIndex:i]])
                {
                    [countsArray replaceObjectAtIndex:j withObject:[stylistAccount.stylistAppointmentCountArray objectAtIndex:i]];
                }
             }
        }
    }
    
    for(int k=0; k<datesWithDaysArray.count; k++)
    {
        //Background Button
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        tile.frame = CGRectMake(tileXPos, 0, blockWidth, 90);
        tile.tag = k;
        [tile addTarget:self action:@selector(selectedDateAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //Line Label
        UILabel *aLine = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, datesWithDaysArray.count*68, 1)];
        aLine.backgroundColor = [UIColor blackColor];
        [tile addSubview:aLine];
        
        //Appointments Label
        UILabel *appointmentsLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, blockWidth, 15)];
        appointmentsLbl.textColor = [UIColor blackColor];
        appointmentsLbl.textAlignment = NSTextAlignmentLeft;
        appointmentsLbl.font = [UIFont latoFontOfSize:appointmentsLblFont];
        appointmentsLbl.backgroundColor = [UIColor clearColor];
        //appointmentsLbl.text = @"0 appointments";
        
        if(countsArray.count > 0)
        {
            appointmentsLbl.text = [NSString stringWithFormat:@"%@ appointments",[countsArray objectAtIndex:k]];
        }
        
        [tile addSubview:appointmentsLbl];
        
        //Month Label
        UILabel *monthNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, blockWidth, 15)];
        monthNameLbl.textColor = [UIColor blackColor];
        monthNameLbl.textAlignment = NSTextAlignmentCenter;
        monthNameLbl.font = [UIFont latoFontOfSize:10.0];
        monthNameLbl.text = [[[datesWithDaysArray objectAtIndex:k]componentsSeparatedByString:@"/"]objectAtIndex:0];
        [tile addSubview:monthNameLbl];
        
        //Date Label
        UILabel *dateLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 45, blockWidth, 18)];
        dateLbl.textColor = [UIColor blackColor];
        dateLbl.textAlignment = NSTextAlignmentCenter;
        dateLbl.font = [UIFont fontWithName:@"Lato-Light" size:22.0];
        dateLbl.text = [[[datesWithDaysArray objectAtIndex:k]componentsSeparatedByString:@"/"]objectAtIndex:1];
        [tile addSubview:dateLbl];
        
        //Day Label
        UILabel *dayLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 69, blockWidth, 15)];
        dayLbl.textColor = [UIColor blackColor];
        dayLbl.textAlignment = NSTextAlignmentCenter;
        dayLbl.font = [UIFont latoFontOfSize:10.0];
        dayLbl.text = [[[datesWithDaysArray objectAtIndex:k]componentsSeparatedByString:@"/"]objectAtIndex:3];
        [tile addSubview:dayLbl];
        
        [self.datesScroll addSubview:tile];
        
        //Highlighted Line Label
        UIImageView *dashedLine = [[UIImageView alloc]initWithFrame:CGRectMake(highlightedLineXPos, 85, blockWidth+2, 4)];
        //dashedLine.backgroundColor = DashedLineRGBColor(231, 230, 221);
        dashedLine.backgroundColor = [UIColor clearColor];
        dashedLine.tag = k;
        dashedLine.layer.zPosition = 100;
        [self.datesScroll addSubview:dashedLine];
        
        //Seperator Line
        UILabel *verticalSeparatorLine = [[UILabel alloc]init];
        verticalSeparatorLine.frame = CGRectMake(tileXPos-1, 0, 1, 200);
        verticalSeparatorLine.backgroundColor = [UIColor blackColor];
        verticalSeparatorLine.layer.zPosition = 100;
        [self.datesScroll addSubview:verticalSeparatorLine];
        
        tileXPos += blockWidth+2;
        highlightedLineXPos += blockWidth+2;
        
        [self.datesScroll setContentSize:CGSizeMake(datesWithDaysArray.count*(blockWidth+2), 90)];
    }
}

#pragma mark - Handle Date Selection
-(void)selectedDateAction:(UIButton *)sender
{
    [self.appointmentsTable setContentOffset:CGPointZero animated:YES];
    for(UIView *aView in self.datesScroll.subviews)
    {
        if([aView isKindOfClass:[UIImageView class]])
        {
            //[aView setBackgroundColor:DashedLineRGBColor(231, 230, 221)];
            aView.backgroundColor = [UIColor clearColor];
            
            if(aView.tag == sender.tag)
            {
                //[aView setBackgroundColor:DashedLineRGBColor(252.0, 52.0, 61.0)];
                [aView setBackgroundColor:[UIColor darkGrayColor]];
            }
        }
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMMM/dd/yyyy/EEEE"];
    
    NSDate *date = [format dateFromString:[datesWithDaysArray objectAtIndex:sender.tag]];
    [format setDateFormat:@"dd/MM/yyyy"];
    NSString *selectedDate = [format stringFromDate:date];
    
    [Utility showActivity:self];
    currentAPICalled = kPartnerAppointmentsList;
    [webVC getPartnerAppointmentsListsFromDate:selectedDate];
}

#pragma mark - Next/Prev Dates Action
-(IBAction)buttonsAction:(UIButton *)sender
{
    //Previous Dates Button
    if(sender.tag == 1)
    {
        selectedBtn = 1;
        
        if(self.datesScroll.contentOffset.x > 0)
        {
            [self.datesScroll setContentOffset:CGPointMake(self.datesScroll.contentOffset.x - self.datesScroll.bounds.size.width, 0) animated:YES];
            self.prevDatesBtn.enabled = self.prevArrowBtnImg.enabled = self.nextDatesBtn.enabled = self.nextArrowBtnImg.enabled = YES;
        }
    }
    
    //Next Dates Button
    else if(sender.tag == 2)
    {
        selectedBtn = 2;
        
        //If scrollview position not reached to maximum coordinates (content size)
        if(self.datesScroll.contentOffset.x >= 0)
        {
            [self.datesScroll setContentOffset:CGPointMake(self.datesScroll.contentOffset.x + self.datesScroll.bounds.size.width, 0) animated:YES];
            self.prevDatesBtn.enabled = self.prevArrowBtnImg.enabled = self.nextDatesBtn.enabled = self.nextArrowBtnImg.enabled = YES;
        }
        
        //Disable the next button if scrollview offset position reacehs to maximum coordinates (content size)
        if(self.datesScroll.contentOffset.x + self.datesScroll.bounds.size.width == self.datesScroll.contentSize.width)
        {
            self.nextDatesBtn.enabled = self.nextArrowBtnImg.enabled = NO;
            self.prevDatesBtn.enabled = self.prevArrowBtnImg.enabled = YES;
        }
    }
}

#pragma mark - ScrollView Delegate Methods
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
    CGFloat contentOffset = self.datesScroll.contentOffset.x + self.datesScroll.bounds.size.width;
    
    if(selectedBtn == 1)
    {
        //Setting the offset postion to initial coordinates
        if(contentOffset < self.datesScroll.bounds.size.width)
        {
            [self.datesScroll setContentOffset:CGPointMake(0, 0) animated:NO];
            self.nextDatesBtn.enabled = self.nextArrowBtnImg.enabled = YES;
            self.prevDatesBtn.enabled = self.prevArrowBtnImg.enabled = NO;
        }
        
        if(self.datesScroll.contentOffset.x == 0.0)
        {
            self.prevDatesBtn.enabled = self.prevArrowBtnImg.enabled = NO;
            self.nextDatesBtn.enabled = self.nextArrowBtnImg.enabled = YES;
        }
    }
    
    else if(selectedBtn == 2)
    {
        //Setting the offset position to maximum coordinates (content size)
        if(contentOffset >= self.datesScroll.contentSize.width)
        {
            [self.datesScroll setContentOffset:CGPointMake(self.datesScroll.contentSize.width - self.datesScroll.bounds.size.width, 0) animated:NO];
            self.nextDatesBtn.enabled = self.nextArrowBtnImg.enabled = NO;
            self.prevDatesBtn.enabled = self.prevArrowBtnImg.enabled = YES;
        }
    }
}

#pragma mark - TableView Delegates and DataSources
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return timeLapsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"timeLapsTableCell";
    UITableViewCell *timeLapsTableCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *timeLapsLbl;
    UILabel *verticalSeparatorLine;
    UILabel *appointmentTimeLbl;
    UILabel *dashLineLbl;
    
    UIView *appointmentDetailsView;
    UIButton *buttonForAppointmentDetail;
    UILabel *categoriesLbl;
    UILabel *clientNameLbl;
    UILabel *locationLbl;
    
    if (timeLapsTableCell == nil)
    {
        timeLapsTableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        timeLapsTableCell.backgroundColor = [UIColor clearColor];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor clearColor];
        [timeLapsTableCell setSelectedBackgroundView:bgColorView];
        
        //Working hours (hourly times)
        timeLapsLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 12)];
        timeLapsLbl.tag = 1001;
        [timeLapsLbl setFont:[UIFont latoFontOfSize:10]];
        timeLapsLbl.backgroundColor = [UIColor clearColor];
        timeLapsLbl.textColor = [UIColor blackColor];
        [timeLapsTableCell.contentView addSubview:timeLapsLbl];
        
        verticalSeparatorLine = [[UILabel alloc]init];
        verticalSeparatorLine.frame = CGRectMake((timeLapsLbl.frame.origin.x + timeLapsLbl.frame.size.width + 1), 0, 1, timeLapsTableCell.frame.size.height);
        verticalSeparatorLine.backgroundColor = [UIColor blackColor];
        verticalSeparatorLine.layer.zPosition = 100;
        [timeLapsTableCell.contentView addSubview:verticalSeparatorLine];
        
        if ([cellHeightsArray containsObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row]])
        {
            long indexValue = [cellHeightsArray indexOfObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
            //set frame for "verticalSeparatorLine"
            verticalSeparatorLine.frame = CGRectMake(41, 0, 1, [[[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"AppointmentViewHeight"] floatValue] + 5.0);
            
            //Appointment Info View
            appointmentDetailsView = [[UIView alloc]init];
            appointmentDetailsView.frame = CGRectMake(61, 2.5, (self.view.frame.size.width - 90.0), [[[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"AppointmentViewHeight"] floatValue]);
            appointmentDetailsView.tag = 1004;
            appointmentDetailsView.layer.borderWidth = 1.0;
            appointmentDetailsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [timeLapsTableCell.contentView addSubview:appointmentDetailsView];
            
            //Appointment time Label
            appointmentTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(27.0, 0.0, 30.0, 30.0)];
            appointmentTimeLbl.center = CGPointMake(verticalSeparatorLine.frame.origin.x, (appointmentDetailsView.frame.origin.y + appointmentDetailsView.frame.size.height) / 2.0);
            appointmentTimeLbl.tag = 1002;
            [timeLapsTableCell.contentView addSubview:appointmentTimeLbl];
            
            //Dashed Line (-)
            dashLineLbl = [[UILabel alloc]initWithFrame:CGRectMake(55, (appointmentDetailsView.frame.origin.y + appointmentDetailsView.frame.size.height) / 2.0, 6, 2.5)];
            dashLineLbl.tag = 1003;
            [timeLapsTableCell.contentView addSubview:dashLineLbl];
            
            //Hair Info Label
            categoriesLbl = [[UILabel alloc]init];
            categoriesLbl.frame = CGRectMake(5, 2.5, (appointmentDetailsView.frame.size.width - 10.0), (appointmentDetailsView.frame.size.height - 42.5));
            categoriesLbl.tag = 1005;
            categoriesLbl.numberOfLines = 0;
            [appointmentDetailsView addSubview:categoriesLbl];
            
            //Client Name Label
            clientNameLbl = [[UILabel alloc]init];
            clientNameLbl.frame = CGRectMake(categoriesLbl.frame.origin.x, (categoriesLbl.frame.origin.y + categoriesLbl.frame.size.height), appointmentDetailsView.frame.size.width - 10.0, 15);
            clientNameLbl.tag = 1007;
            [appointmentDetailsView addSubview:clientNameLbl];
            clientNameLbl.backgroundColor = [UIColor clearColor];
            
            //Location Label
            locationLbl = [[UILabel alloc]init];
            locationLbl.frame = CGRectMake(clientNameLbl.frame.origin.x, (clientNameLbl.frame.origin.y + clientNameLbl.frame.size.height), clientNameLbl.frame.size.width, 15);
            locationLbl.tag = 1008;
            [appointmentDetailsView addSubview:locationLbl];
            locationLbl.backgroundColor = [UIColor clearColor];
            
            //Transparent Button on top of each view
            buttonForAppointmentDetail = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonForAppointmentDetail.frame = appointmentDetailsView.frame;
            buttonForAppointmentDetail.backgroundColor = [UIColor clearColor];
            [buttonForAppointmentDetail addTarget:self action:@selector(appointmentDetail:) forControlEvents:UIControlEventTouchUpInside];
            buttonForAppointmentDetail.tag = indexPath.row;
            [timeLapsTableCell.contentView addSubview:buttonForAppointmentDetail];
        }
    }
    
    timeLapsLbl = (UILabel *)[timeLapsTableCell.contentView viewWithTag:1001];
    timeLapsLbl.text = [[timeLapsArray objectAtIndex:indexPath.row]lowercaseString];
    
    appointmentTimeLbl = (UILabel *)[timeLapsTableCell.contentView viewWithTag:1002];
    appointmentTimeLbl.numberOfLines = 2;
    appointmentTimeLbl.textAlignment = NSTextAlignmentCenter;
    [appointmentTimeLbl setFont:[UIFont latoFontOfSize:8]];
    appointmentTimeLbl.backgroundColor = [UIColor blackColor];
    appointmentTimeLbl.clipsToBounds = YES;
    appointmentTimeLbl.layer.cornerRadius = 15;
    appointmentTimeLbl.textColor = [UIColor whiteColor];
    appointmentTimeLbl.layer.zPosition = 100;
    
    dashLineLbl = (UILabel *)[timeLapsTableCell.contentView viewWithTag:1003];
    dashLineLbl.backgroundColor = [UIColor blackColor];
    
    appointmentDetailsView = (UIView *)[timeLapsTableCell.contentView viewWithTag:1004];
    appointmentDetailsView.alpha = 1;
    
    if ([cellHeightsArray containsObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row]])
    {
        long indexValue = [cellHeightsArray indexOfObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        
        categoriesLbl = (UILabel *)[timeLapsTableCell.contentView viewWithTag:1005];
        categoriesLbl.font = [UIFont latoFontOfSize:12];
        categoriesLbl.textColor = [UIColor blackColor];
        
        clientNameLbl = (UILabel *)[timeLapsTableCell.contentView viewWithTag:1007];
        clientNameLbl.font = [UIFont latoFontOfSize:12];
        clientNameLbl.textColor = [UIColor blackColor];
        clientNameLbl.text = nil;
        
        locationLbl = (UILabel *)[timeLapsTableCell.contentView viewWithTag:1008];
        locationLbl.font = [UIFont latoFontOfSize:10];
        locationLbl.textColor = [UIColor blackColor];
        locationLbl.text = nil;
        
        buttonForAppointmentDetail = (UIButton *)[timeLapsTableCell.contentView viewWithTag:1009];
        
        NSArray *serviceListArray = [[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"services_list"];
        if([serviceListArray count] > 0)
        {
            NSMutableString *categoriesString = [NSMutableString stringWithString:@""];
            NSSet *categoriesSet = [NSSet setWithArray:[serviceListArray valueForKey:@"category"]];
            for (NSString *category in categoriesSet) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
                NSArray *filteredCategoryArray = [serviceListArray filteredArrayUsingPredicate:predicate];
                
                if (categoriesString.length == 0)
                {
                    [categoriesString appendFormat:@"%@:%@", category, [[filteredCategoryArray valueForKey:@"service"] componentsJoinedByString:@", "]];
                }
                
                else
                {
                    [categoriesString appendFormat:@"\n%@:%@", category, [[filteredCategoryArray valueForKey:@"service"] componentsJoinedByString:@", "]];
                }
            }
            
            categoriesLbl.attributedText = [self boldAndLightText:categoriesString forSubString:[NSArray arrayWithArray:categoriesSet.allObjects]];
        }
        
        if([[[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"client"] length] > 0)
        {
            clientNameLbl.attributedText = [self boldAndLightText:[NSString stringWithFormat:@"CLIENT:%@", [[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"client"]] forSubString:[NSArray arrayWithObject:@"CLIENT"]];
        }
        
        if([[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"location"] && [[[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"location"] length] > 0)
        {
            locationLbl.attributedText = [self boldAndLightText:[NSString stringWithFormat:@"LOCATION: %@",[[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"location"]] forSubString:[NSArray arrayWithObject:@"LOCATION"]];
        }
        
        NSString *subString1 = [[appointmentTimesArray objectAtIndex:indexValue]substringToIndex:[[appointmentTimesArray objectAtIndex:indexValue]length] - 2];
        NSString *subString2 = [[appointmentTimesArray objectAtIndex:indexValue]substringFromIndex:[[appointmentTimesArray objectAtIndex:indexValue]length] - 2];
        
        appointmentTimeLbl.text = [NSString stringWithFormat:@"%@\n%@",subString1,subString2.uppercaseString];
        appointmentTimeLbl.text = [appointmentTimeLbl.text stringByReplacingOccurrencesOfString:@":30" withString:@":00"];
    }

    return timeLapsTableCell;
}

- (NSAttributedString *)boldAndLightText:(NSString *)desiredString forSubString:(NSArray *)subStringArray
{
    UIFont *font1 = [UIFont fontWithName:@"Lato-Bold" size:12];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];

    UIFont *font2 = [UIFont fontWithName:@"Lato-Regular" size:12];
    NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:desiredString attributes:arialDict2];
    
    for (NSString *subString in subStringArray)
    {
        [attributedString setAttributes:arialDict range:[desiredString rangeOfString:subString]];
    }
    return attributedString;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellHeightsArray containsObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row]])
    {
        float cellHeight = 0.0;
        //get index value
        long indexValue = [cellHeightsArray indexOfObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        float defaultHeight = 40.0;//height of both clientname & location
        CGSize maximumLabelSize = CGSizeMake((self.view.frame.size.width - 70), FLT_MAX);
        //combine all services with related category as "comma separated" and different categories by "\n" newline character
        NSArray *serviceListArray = [[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"services_list"];
        
        if ([serviceListArray count] > 0)
        {
            NSMutableString *categoriesString = [NSMutableString stringWithString:@""];
            NSSet *categoriesSet = [NSSet setWithArray:[serviceListArray valueForKey:@"category"]];
            for (NSString *category in categoriesSet)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
                NSArray *filteredCategoryArray = [serviceListArray filteredArrayUsingPredicate:predicate];
                if (categoriesString.length == 0)
                {
                    [categoriesString appendFormat:@"%@:%@", category, [[filteredCategoryArray valueForKey:@"service"] componentsJoinedByString:@", "]];
                }
                
                else
                {
                    [categoriesString appendFormat:@"\n%@:%@", category, [[filteredCategoryArray valueForKey:@"service"] componentsJoinedByString:@", "]];
                }
            }
            
            CGRect appointmentDetailViewRect = [categoriesString boundingRectWithSize:maximumLabelSize
                                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                                           attributes:@{NSFontAttributeName:[UIFont latoFontOfSize:12]}
                                                                              context:nil];
            cellHeight = (appointmentDetailViewRect.size.height + defaultHeight);
        }
        
        //update the height using "height" key
        NSMutableDictionary *dict = [appointmentsListDictionary objectAtIndex:indexValue];
        [dict setValue:[NSNumber numberWithFloat:(cellHeight + 5)] forKey:@"AppointmentViewHeight"];
        return cellHeight + 8.0;
    }
    
    return 30;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.appointmentsTable deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Handle Response
- (void)receivedResponse:(id)response
{
    if([currentAPICalled isEqualToString:kPartnerAppointmentsList])
    {
        appointmentsListDictionary = [[NSMutableArray alloc]init];
        appointmentsListDictionary = [[[StylistFlowModel sharedInstance]appointmentsList] objectForKey:@"appointments_list"];
        
        appointmentTimesArray = [[NSMutableArray alloc]init];
        
        for(int i=0; i<[appointmentsListDictionary count]; i++)
        {
            NSString *toTime = [[appointmentsListDictionary objectAtIndex:i]objectForKey:@"from_time"];
            
            NSArray *startTimeArray = [toTime componentsSeparatedByString:@"T"];
            NSString *toTimeFirstParse = [NSString stringWithFormat:@"%@",[startTimeArray objectAtIndex:1]];
            toTimeFirstParse = [toTimeFirstParse substringToIndex:5];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm";
            
            NSDate *date = [dateFormatter dateFromString:toTimeFirstParse];
            dateFormatter.dateFormat = @"h:mma";
            NSString *pmamDateString = [dateFormatter stringFromDate:date];
            
            if([pmamDateString rangeOfString:@":00"].location != NSNotFound)
            {
                pmamDateString = [pmamDateString stringByReplacingOccurrencesOfString:@":00" withString:@":30"];
            }
            
            [appointmentTimesArray addObject:pmamDateString];
        }
        
        if(appointmentsListDictionary.count > 0)
        {
            initialShownLabel.hidden = YES;
            noAppointmentsLabel.hidden = YES;
            [self maxCellHeightIndexValues];
            [self.appointmentsTable setHidden:NO];
            [self.appointmentsTable reloadData];
        }
        
        else
        {
            initialShownLabel.hidden = YES;
            noAppointmentsLabel.hidden = NO;
            [self.bgScroll addSubview:noAppointmentsLabel];
            [self.appointmentsTable setHidden:YES];
        }
        
        [Utility removeActivityIndicator];
    }
    
    else if([currentAPICalled isEqualToString:kPartnerClockIn] && [response isEqualToString:@"true"])
    {
        self.clockInTextLabel.text = @"Clock Out";
        [[StylistFlowModel sharedInstance]setPartnerAvailabilityString:self.clockInTextLabel.text];
        [Utility removeActivityIndicator];
    }
    
    else if ([currentAPICalled isEqualToString:kPartnerClockIn] && [response isEqualToString:@"false"])
    {
        self.clockInTextLabel.text = @"Clock In";
        [[StylistFlowModel sharedInstance]setPartnerAvailabilityString:self.clockInTextLabel.text];
        [Utility removeActivityIndicator];
    }
    
    else if ([currentAPICalled isEqualToString:kisPartnerAvailable])
    {
        NSString *availability;
        if([response isEqualToString:@"true"])
        {
            availability = @"Clock Out";
            self.clockInTextLabel.text = @"Clock Out";
        }
        
        else
        {
            availability = @"Clock In";
            self.clockInTextLabel.text = @"Clock In";
        }
        
        [[StylistFlowModel sharedInstance]setPartnerAvailabilityString:availability];
        
        self.prevArrowBtnImg.hidden = NO;
        self.nextArrowBtnImg.hidden = NO;
        UILabel *label = [self.view viewWithTag:100];
        label.hidden = NO;
        
        [self scrollViewDates];
        [Utility removeActivityIndicator];
    }
    
    else if ([currentAPICalled isEqualToString:kPartnerAppointmentsCount])
    {
        currentAPICalled = kisPartnerAvailable;
        [webVC partnerAvailability];
    }
}

#pragma mark - Handle Error
- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:errorTitle message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.appointmentsTable setHidden:YES];
        [Utility removeActivityIndicator];
        // Display/dismiss your alert
        [alert show];
    });
}

#pragma mark - Clock Button Action
-(IBAction)clockInBtnAction:(id)sender
{
    currentAPICalled = kPartnerClockIn;
    [Utility showActivity:self];
    [webVC clockInPartner];
}

#pragma mark - Move to Appointment Detail Screen
-(void)appointmentDetail:(UIButton *)selectedIndexpath
{
    if([cellHeightsArray containsObject:[NSString stringWithFormat:@"%ld", (long)selectedIndexpath.tag]]) {
        long indexValue = [cellHeightsArray indexOfObject:[NSString stringWithFormat:@"%ld", (long)selectedIndexpath.tag]];
        [[StylistFlowModel sharedInstance]setAppointmentID:[[appointmentsListDictionary objectAtIndex:indexValue] objectForKey:@"appointment_id"]];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AppointmentDetailViewController *appointmentDetailsViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"AppointmentDetailViewControllerSB"];
        appointmentDetailsViewController.appointmentInfoArray = [[NSMutableArray alloc]init];
        appointmentDetailsViewController.appointmentInfoArray = [appointmentsListDictionary objectAtIndex:indexValue];
        [self presentViewController:appointmentDetailsViewController animated:NO completion:nil];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
