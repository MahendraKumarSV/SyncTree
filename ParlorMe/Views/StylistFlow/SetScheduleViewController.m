//
//  SetScheduleViewController.m
//  ParlorMe
//

#import "SetScheduleViewController.h"
#import "RepeatDaysViewController.h"
#import "SingletonClass.h"
#import "Constants.h"
#import "WebserviceViewController.h"
#import "Utility.h"
#import <LatoFont/UIFont+Lato.h>
#import "StylistAccountParser.h"
#import "CoreDataModel.h"
#import "ClockInAndOut+CoreDataProperties.h"
#import "StylistAccount.h"
#import "StylistFlowModel.h"
#import "SWRevealViewController.h"

@interface SetScheduleViewController ()<UITabBarControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, WebserviceViewControllerDelegate, UITextFieldDelegate>
{
    NSMutableArray *datesWithDaysArray;
    NSMutableArray *formattedDatesWithDaysArray;
    NSMutableArray *repeatedDays;
    NSInteger selectedBtn;
    WebserviceViewController *webVC;
    NSString *selectedDate;
    NSInteger selectedDateTag;
    NSDictionary *getPartnerScheduleResponse;
    NSString *scheduleIdFromResponse;
    NSMutableArray *repeatedDaysArrayFromResponse;
    NSMutableDictionary *postDictionary;
    NSInteger daysDifference;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter1;
    NSDateFormatter *timeFormatter2;
    NSString *startTime;
    NSDate *currentDateTime;
    NSDate *startDateTime;
    NSString *currentTime;
    NSMutableArray *dateStringsFromResponse;
    NSMutableArray *singleDateObjectsFromResponse;
    NSMutableArray *onlyDatesArray;
    NSString *currentAPICalled;
}

@property (nonatomic, strong) NSString *chosenMonthAndDate;
@property (nonatomic, weak) IBOutlet UIButton *clockInBtn;
@property (nonatomic, weak) IBOutlet UILabel *clockInTextLabel;
@property (nonatomic, weak) IBOutlet UIButton *prevDatesBtn;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *nextDatesBtn;
@property (nonatomic, weak) IBOutlet UIButton *prevArrowBtnImg;
@property (nonatomic, weak) IBOutlet UIButton *nextArrowBtnImg;
@property (weak, nonatomic) IBOutlet UIScrollView *datesScroll;
@property (weak, nonatomic) IBOutlet UIView *startEndTimeView;
@property (weak, nonatomic) IBOutlet UITextField *startTimeField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeField;
@property (nonatomic, weak) IBOutlet UIButton *repeatedDaysBtn;
@property (nonatomic, weak) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *date_TopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuBtn;

-(IBAction)saveButtonAction:(id)sender;
-(IBAction)repeatDaysAction:(id)sender;
@end

@implementation SetScheduleViewController
@synthesize chosenMonthAndDate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Corner Radius
    self.clockInBtn.layer.cornerRadius = 5;
    self.saveBtn.layer.cornerRadius = 5;
    
    //Start/End Time View
    [self.startEndTimeView setHidden:YES];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"savedTag"];
    
    [self.leftMenuBtn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    //Disable the previous button
    self.prevDatesBtn.enabled = self.prevArrowBtnImg.enabled = NO;
    
    //Allocate WebviewController
    webVC = [[WebserviceViewController alloc] init];
    webVC.delegate = self;
    
    //set constraints for iphone5
    if(self.view.bounds.size.height <= IS_iPhone4SOR5) {
        self.date_TopConstraint.constant = self.date_TopConstraint.constant - 13.0;
    }
    
    //add gesture to view, to open the left menu
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //fetch schedules and partner availablity
    [Utility showActivity:self];
    
    UILabel *label = [self.bgView viewWithTag:100];
    label.hidden = YES;
    
    self.prevArrowBtnImg.hidden = YES;
    self.nextArrowBtnImg.hidden = YES;
    
    //Get Schedules
    currentAPICalled = kisPartnerAvailable;
    [webVC partnerAvailability];
}

#pragma mark - ViewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //hide navigation bar
    self.navigationController.navigationBarHidden = YES;
    //Get the stored days from NSUserDefaults and Show in Button
    [self storedRepeatedDays];
}

#pragma mark - List Of Two Weeks Dates
-(void)scrollViewDates
{
    //remove all subviews before adding new
    for (UIView *views in self.datesScroll.subviews) {
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
    
    //NSLog(@"dates: %@",dates);
    
    //adding dates with specified format to an array
    datesWithDaysArray = [[NSMutableArray alloc]init];
    formattedDatesWithDaysArray = [[NSMutableArray alloc]init];
    
    for(int j=0; j<dates.count; j++)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"MMMM/dd/yyyy/EEEE"];
        NSString *dateString = [df stringFromDate:[dates objectAtIndex:j]];
        [datesWithDaysArray addObject:dateString];
        
        [df setDateFormat:@"MM-dd-yyyy"];
        NSString *dateString1 = [df stringFromDate:[dates objectAtIndex:j]];
        [formattedDatesWithDaysArray addObject:dateString1];
    }
    
    //NSLog(@"datesWithDaysArray: %@",datesWithDaysArray);
    int tileXPos = 0;
    int highlightedLineXPos = 0;
    CGFloat monthLblFont = 0.0;
    CGFloat dateLblFont = 0.0;
    CGFloat dayLblFont = 0.0;
    CGFloat startTimeLblFont = 0.0;
    CGFloat endTimeLblFont = 0.0;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    //Different fonts sizes based on screen height
    if(screenHeight <= IS_iPhone4SOR5)
    {
        blockWidth = 65;
        monthLblFont = Font10;
        dateLblFont = Font22;
        dayLblFont = Font10;
        startTimeLblFont = endTimeLblFont = Font9;
    }
    
    else if (screenHeight == IS_iPhone6)
    {
        blockWidth = 79;
        monthLblFont = Font11;
        dateLblFont = Font23;
        dayLblFont = Font11;
        startTimeLblFont = endTimeLblFont = Font10;
    }
    
    else if (screenHeight == IS_iPhone6Plus)
    {
        blockWidth = 68;
        monthLblFont = Font10;
        dateLblFont = Font22;
        dayLblFont = Font10;
        startTimeLblFont = endTimeLblFont = Font9;
    }
    
    singleDateObjectsFromResponse = [[NSMutableArray alloc]init];
    onlyDatesArray = [[NSMutableArray alloc]init];
    
    dateStringsFromResponse = [[NSMutableArray alloc]init];
    
    if(getPartnerScheduleResponse.count > 0)
    {
        for(int i=0; i<getPartnerScheduleResponse.count; i++)
        {
            if([[[getPartnerScheduleResponse valueForKey:@"date"] objectAtIndex:i] count] > 1)
            {
                [dateStringsFromResponse addObject:[[[SingletonClass shareManager].getPartnerScheduleResponse objectForKey:@"partners_schedule"] objectAtIndex:i]];
            }
            
            else if ([[[getPartnerScheduleResponse valueForKey:@"date"] objectAtIndex:i] count] == 1)
            {
                [singleDateObjectsFromResponse addObject:[[[SingletonClass shareManager].getPartnerScheduleResponse objectForKey:@"partners_schedule"] objectAtIndex:i]];
            }
        }
    }
    
    for(int i=0; i<singleDateObjectsFromResponse.count; i++)
    {
        [onlyDatesArray addObjectsFromArray:[[singleDateObjectsFromResponse objectAtIndex:i]objectForKey:@"date"]];
    }
    
    for(int k=0; k<datesWithDaysArray.count; k++)
    {
        //Background Button
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        tile.frame = CGRectMake(tileXPos, 0, blockWidth, 90);
        tile.tag = k;
        [tile addTarget:self action:@selector(selectedDateAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Month Label
        UILabel *monthNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, blockWidth, 15)];
        monthNameLbl.textColor = [UIColor blackColor];
        monthNameLbl.textAlignment = NSTextAlignmentCenter;
        monthNameLbl.font = [UIFont fontWithName:@"Lato-Regular" size:monthLblFont];
        monthNameLbl.text = [[[datesWithDaysArray objectAtIndex:k]componentsSeparatedByString:@"/"]objectAtIndex:0];
        [tile addSubview:monthNameLbl];
        
        //Date Label
        UILabel *dateLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, blockWidth, 20)];
        dateLbl.textColor = [UIColor blackColor];
        dateLbl.textAlignment = NSTextAlignmentCenter;
        dateLbl.font = [UIFont fontWithName:@"Lato-Light" size:dateLblFont];
        dateLbl.text = [[[datesWithDaysArray objectAtIndex:k]componentsSeparatedByString:@"/"]objectAtIndex:1];
        [tile addSubview:dateLbl];
        
        //Day Label
        UILabel *dayLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, blockWidth, 15)];
        dayLbl.textColor = [UIColor blackColor];
        dayLbl.textAlignment = NSTextAlignmentCenter;
        dayLbl.font = [UIFont fontWithName:@"Lato-Regular" size:dayLblFont];
        dayLbl.text = [[[datesWithDaysArray objectAtIndex:k]componentsSeparatedByString:@"/"]objectAtIndex:3];
        [tile addSubview:dayLbl];
        
        //StartTime Label
        UILabel *startTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, blockWidth, 15)];
        startTimeLbl.textColor = [UIColor blackColor];
        startTimeLbl.textAlignment = NSTextAlignmentCenter;
        startTimeLbl.font = [UIFont fontWithName:@"Lato-Regular" size:startTimeLblFont];
        
        //EndTime Label
        UILabel *endTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 72, blockWidth, 15)];
        endTimeLbl.textColor = [UIColor blackColor];
        endTimeLbl.textAlignment = NSTextAlignmentCenter;
        endTimeLbl.font = [UIFont fontWithName:@"Lato-Regular" size:startTimeLblFont];
        
        //EndTime Label
        UILabel *noScheduleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 65, blockWidth, 15)];
        noScheduleLbl.textColor = [UIColor blackColor];
        noScheduleLbl.textAlignment = NSTextAlignmentCenter;
        noScheduleLbl.font = [UIFont fontWithName:@"Lato-Regular" size:startTimeLblFont];
        noScheduleLbl.text = @"no schedule";
        
        if(dateStringsFromResponse.count > 0)
        {
            for(int i=0; i<dateStringsFromResponse.count; i++)
            {
                if([[[dateStringsFromResponse objectAtIndex:i]valueForKey:@"date"] containsObject:[formattedDatesWithDaysArray objectAtIndex:k]])
                {
                    NSString *startTimeFromResponse = [[dateStringsFromResponse objectAtIndex:i]valueForKey:@"from_time"];
                    NSString *endTimeFromResponse = [[dateStringsFromResponse objectAtIndex:i]valueForKey:@"to_time"];
                    
                    NSArray *startTimeArray = [startTimeFromResponse componentsSeparatedByString:@" "];
                    NSString *startTime1 = [NSString stringWithFormat:@"%@ %@",[startTimeArray objectAtIndex:1], [startTimeArray objectAtIndex:2]];
                    
                    NSArray *endTimeArray = [endTimeFromResponse componentsSeparatedByString:@" "];
                    NSString *endTime = [NSString stringWithFormat:@"%@ %@",[endTimeArray objectAtIndex:1], [endTimeArray objectAtIndex:2]];
                    
                    //Assign the converted format timings to labels
                    startTimeLbl.text = startTime1;
                    endTimeLbl.text = endTime;
                    [tile addSubview:startTimeLbl];
                    [tile addSubview:endTimeLbl];
                }
            }
        }
        
        if(singleDateObjectsFromResponse.count > 0)
        {
            if([onlyDatesArray containsObject:[formattedDatesWithDaysArray objectAtIndex:k]])
            {
                [noScheduleLbl removeFromSuperview];
                
                NSInteger index = [onlyDatesArray indexOfObject:[formattedDatesWithDaysArray objectAtIndex:k]];
                
                NSString *startTimeFromResponse = [[singleDateObjectsFromResponse valueForKey:@"from_time"] objectAtIndex:index];
                NSString *endTimeFromResponse = [[singleDateObjectsFromResponse valueForKey:@"to_time"] objectAtIndex:index];
                
                NSArray *startTimeArray = [startTimeFromResponse componentsSeparatedByString:@" "];
                NSString *startTime1 = [NSString stringWithFormat:@"%@ %@",[startTimeArray objectAtIndex:1], [startTimeArray objectAtIndex:2]];
                
                NSArray *endTimeArray = [endTimeFromResponse componentsSeparatedByString:@" "];
                NSString *endTime = [NSString stringWithFormat:@"%@ %@",[endTimeArray objectAtIndex:1], [endTimeArray objectAtIndex:2]];
                
                //Assign the converted format timings to labels
                startTimeLbl.text = startTime1;
                endTimeLbl.text = endTime;
                [tile addSubview:startTimeLbl];
                [tile addSubview:endTimeLbl];
            }
        }
        
        if(startTimeLbl.text.length == 0 && endTimeLbl.text.length == 0)
        {
            [tile addSubview:noScheduleLbl];
        }
        
        //Highlighted Line Label
        UIImageView *dashedLine = [[UIImageView alloc]initWithFrame:CGRectMake(highlightedLineXPos, 85, blockWidth+2, 4)];
        dashedLine.tag = k;
        dashedLine.layer.zPosition = 100;
        
        NSString *tagString = [NSString stringWithFormat:@"%ld",(long)dashedLine.tag];
        
        if([tagString isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"savedTag"]])
        {
            [dashedLine setBackgroundColor:[UIColor darkGrayColor]];
        }
        
        else
        {
            dashedLine.backgroundColor = [UIColor clearColor];
        }
        
        [self.datesScroll addSubview:dashedLine];
        [self.datesScroll addSubview:tile];
        
        //Seperator Line
        UILabel *verticalSeparatorLine = [[UILabel alloc]init];
        verticalSeparatorLine.frame = CGRectMake(tileXPos-1, 0, 1, 100);
        verticalSeparatorLine.backgroundColor = [UIColor blackColor];
        verticalSeparatorLine.layer.zPosition = 100;
        [self.datesScroll addSubview:verticalSeparatorLine];
        
        //Changing x postion for next date
        tileXPos += blockWidth+2;
        highlightedLineXPos += blockWidth+2;
        
        //Setting the content size for dates
        [self.datesScroll setContentSize:CGSizeMake(datesWithDaysArray.count*(blockWidth+2), 90)];
    }
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
    else if (sender.tag == 2)
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

#pragma mark - Handle Date Selection
-(void)selectedDateAction:(UIButton *)sender
{
    [[SingletonClass shareManager].tempRepeatedDaysArray removeAllObjects];
    chosenMonthAndDate = @"";
    self.startTimeField.text = @"";
    self.endTimeField.text = @"";
    
    scheduleIdFromResponse = nil;
    
    for(UIView *aView in self.datesScroll.subviews)
    {
        if([aView isKindOfClass:[UIImageView class]])
        {
            //Set the default background color to all highlighted line labels
            //[aView setBackgroundColor:DashedLineRGBColor(231, 230, 221)];
            aView.backgroundColor = [UIColor clearColor];
            
            if(aView.tag == sender.tag)
            {
                //Set the custom background color to the selected date
                //[aView setBackgroundColor:DashedLineRGBColor(252.0, 52.0, 61.0)];
                [aView setBackgroundColor:[UIColor darkGrayColor]];
            }
        }
    }
    
    NSString *tagString = [NSString stringWithFormat:@"%ld",(long)sender.tag];
    [[NSUserDefaults standardUserDefaults]setObject:tagString forKey:@"savedTag"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self.startEndTimeView setHidden:NO];
    [self.startEndTimeView setFrame:CGRectMake(self.startEndTimeView.frame.origin.x, self.startEndTimeView.frame.origin.y, self.startEndTimeView.frame.size.width, self.saveBtn.frame.origin.y+self.saveBtn.frame.size.height+10)];
    //[self.backgroundScroll setContentSize:CGSizeMake(self.view.frame.size.width-20, 600)];
    
    //Store User Selected Date
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMMddyyyy"];
    
    NSString *initialDate = [NSString stringWithFormat:@"%@%@%@",[[[datesWithDaysArray objectAtIndex:sender.tag]componentsSeparatedByString:@"/"]objectAtIndex:0],[[[datesWithDaysArray objectAtIndex:sender.tag]componentsSeparatedByString:@"/"]objectAtIndex:1],[[[datesWithDaysArray objectAtIndex:sender.tag]componentsSeparatedByString:@"/"]objectAtIndex:2]];
    
    NSDate *date = [format dateFromString:initialDate];
    
    [format setDateFormat:@"MM-dd-yyyy"];
    
    selectedDate = [format stringFromDate:date];
    
    //Store Selected Date Tag
    selectedDateTag = sender.tag;
    
    repeatedDaysArrayFromResponse = [[NSMutableArray alloc]init];
    
    for(int i=0; i<getPartnerScheduleResponse.count; i++)
    {
        for(int j=0; j<dateStringsFromResponse.count; j++)
        {
            //check whether the response dictionary contains the selected date
            if([[[dateStringsFromResponse objectAtIndex:j]valueForKey:@"date"] containsObject:selectedDate])
            {                
                chosenMonthAndDate = selectedDate;
                
                NSString *startTimeFromResponse = [[dateStringsFromResponse objectAtIndex:j]valueForKey:@"from_time"];
                NSString *endTimeFromResponse = [[dateStringsFromResponse objectAtIndex:j]valueForKey:@"to_time"];
                
                NSArray *startTimeArray = [startTimeFromResponse componentsSeparatedByString:@" "];
                NSString *startTime1 = [NSString stringWithFormat:@"%@  %@",[startTimeArray objectAtIndex:1], [startTimeArray objectAtIndex:2]];
                
                NSArray *endTimeArray = [endTimeFromResponse componentsSeparatedByString:@" "];
                NSString *endTime = [NSString stringWithFormat:@"%@  %@",[endTimeArray objectAtIndex:1], [endTimeArray objectAtIndex:2]];
                
                //Assign the converted format timings to text fields
                self.startTimeField.text = startTime1;
                self.endTimeField.text = endTime;
                
                //Get Repeated Days from response
                if([[[dateStringsFromResponse valueForKey:@"repeat"] objectAtIndex:j] isEqualToString:@"weekly"])
                {
                    NSString * repeatDaysString = [[[dateStringsFromResponse valueForKey:@"days_of_week"] objectAtIndex:j] componentsJoinedByString:@""];
                    repeatDaysString = [repeatDaysString stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    
                    if(![repeatedDaysArrayFromResponse containsObject:repeatDaysString])
                    {
                        NSMutableArray *selectedRepeatedDays = [[NSMutableArray alloc]init];
                        NSString *appendedString;
                        
                        for(int i=0; i<[[[dateStringsFromResponse valueForKey:@"days_of_week"] objectAtIndex:j]count]; i++)
                        {
                            appendedString = [NSString stringWithFormat:@"Every %@",[[[[dateStringsFromResponse valueForKey:@"days_of_week"] objectAtIndex:j] objectAtIndex:i] capitalizedString]];
                            [selectedRepeatedDays addObject:appendedString];
                        }
                        
                        [SingletonClass shareManager].tempRepeatedDaysArray = [[NSMutableArray alloc]initWithArray:selectedRepeatedDays];
                        [repeatedDaysArrayFromResponse addObject:repeatDaysString];
                    }
                }
                
                
                scheduleIdFromResponse = [[dateStringsFromResponse valueForKey:@"schedule_id"] objectAtIndex:j];
            }
        }
        
        if([onlyDatesArray containsObject:selectedDate])
        {
            chosenMonthAndDate = selectedDate;
            
            NSInteger index = [onlyDatesArray indexOfObject:selectedDate];
            
            NSString *startTimeFromResponse = [[singleDateObjectsFromResponse valueForKey:@"from_time"] objectAtIndex:index];
            NSString *endTimeFromResponse = [[singleDateObjectsFromResponse valueForKey:@"to_time"] objectAtIndex:index];
            
            NSArray *startTimeArray = [startTimeFromResponse componentsSeparatedByString:@" "];
            NSString *startTime1 = [NSString stringWithFormat:@"%@  %@",[startTimeArray objectAtIndex:1], [startTimeArray objectAtIndex:2]];
            
            NSArray *endTimeArray = [endTimeFromResponse componentsSeparatedByString:@" "];
            NSString *endTime = [NSString stringWithFormat:@"%@  %@",[endTimeArray objectAtIndex:1], [endTimeArray objectAtIndex:2]];
            
            //Assign the converted format timings to text fields
            self.startTimeField.text = startTime1;
            self.endTimeField.text = endTime;
            
            //Get Repeated Days from response
            if(![[[singleDateObjectsFromResponse valueForKey:@"repeat"] objectAtIndex:index] isEqualToString:@"never"])
            {
                NSString * repeatDaysString = [[[singleDateObjectsFromResponse valueForKey:@"days_of_week"] objectAtIndex:index] componentsJoinedByString:@""];
                repeatDaysString = [repeatDaysString stringByReplacingOccurrencesOfString:@"(" withString:@""];
                
                if(![repeatedDaysArrayFromResponse containsObject:repeatDaysString])
                {
                    NSMutableArray *selectedRepeatedDays = [[NSMutableArray alloc]init];
                    NSString *appendedString;
                    
                    for(int i=0; i<[[[singleDateObjectsFromResponse valueForKey:@"days_of_week"] objectAtIndex:index]count]; i++)
                    {
                        appendedString = [NSString stringWithFormat:@"Every %@",[[[[singleDateObjectsFromResponse valueForKey:@"days_of_week"] objectAtIndex:index] objectAtIndex:i] capitalizedString]];
                        [selectedRepeatedDays addObject:appendedString];
                    }
                    
                    [SingletonClass shareManager].tempRepeatedDaysArray = [[NSMutableArray alloc]initWithArray:selectedRepeatedDays];
                    [repeatedDaysArrayFromResponse addObject:repeatDaysString];
                }
            }
            
            scheduleIdFromResponse = [[singleDateObjectsFromResponse valueForKey:@"schedule_id"] objectAtIndex:index];
        }
        
        else
        {
            self.chosenMonthAndDate = @"";
        }
    }

    //Get the stored days from NSUserDefaults and Show in Button
    [self storedRepeatedDays];
}

#pragma mark - List of Selected Days
-(void)storedRepeatedDays
{
    //////////////
    NSUserDefaults *chosenDate = [NSUserDefaults standardUserDefaults];
    [chosenDate setObject:self.chosenMonthAndDate forKey:@"chosenDate"];
    
    //Store the repeated days from response
    if(selectedDate != nil)
    {
        repeatedDays = [[NSMutableArray alloc]initWithArray:repeatedDaysArrayFromResponse];
    }
    
    //check for the stored userdefaults value if there is no repeated days from response
    if((repeatedDays.count == 0 || repeatedDays.count > 0) && [SingletonClass shareManager].tempRepeatedDaysArray.count > 0)
    {
        [repeatedDays removeAllObjects];
        repeatedDays = [[NSMutableArray alloc]initWithArray:[SingletonClass shareManager].tempRepeatedDaysArray];
    }
    
    //NSLog(@"repeatedDays: %@",repeatedDays);
    self.repeatedDaysBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    if(repeatedDays == nil || repeatedDays.count == 0)
    {
        self.repeatedDaysBtn.titleLabel.font = [UIFont latoLightFontOfSize:15];
        [self.repeatedDaysBtn setTitle:@"none" forState:UIControlStateNormal];
        [self.repeatedDaysBtn setTitle:@"none" forState:UIControlStateHighlighted];
    }
    
    else if(repeatedDays != nil && repeatedDays.count > 0 && [SingletonClass shareManager].tempRepeatedDaysArray.count > 0)
    {
        if(repeatedDays.count == 1)
        {
            self.repeatedDaysBtn.titleLabel.font = [UIFont latoLightFontOfSize:15];
            NSString *multipleDays = [[repeatedDays componentsJoinedByString:@","] stringByReplacingOccurrencesOfString:@"Every " withString:@""];
            multipleDays = [multipleDays stringByReplacingOccurrencesOfString:@"," withString:@"/"];
            [self.repeatedDaysBtn setTitle:multipleDays forState:UIControlStateNormal];
            [self.repeatedDaysBtn setTitle:multipleDays forState:UIControlStateHighlighted];
        }
        
        else if (repeatedDays.count >1)
        {
            self.repeatedDaysBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            
            //Actual Form (Monday/Tuesday)
            NSString *multipleDays = [[repeatedDays componentsJoinedByString:@","] stringByReplacingOccurrencesOfString:@"Every " withString:@""];
            multipleDays = [multipleDays stringByReplacingOccurrencesOfString:@"," withString:@"/"];
            [self.repeatedDaysBtn setTitle:multipleDays forState:UIControlStateNormal];
            [self.repeatedDaysBtn setTitle:multipleDays forState:UIControlStateHighlighted];
        }
    }
    
    if([SingletonClass shareManager].tempRepeatedDaysArray.count == 0)
    {
        self.repeatedDaysBtn.titleLabel.font = [UIFont latoLightFontOfSize:15];
        [self.repeatedDaysBtn setTitle:@"none" forState:UIControlStateNormal];
        [self.repeatedDaysBtn setTitle:@"none" forState:UIControlStateHighlighted];
    }
}

#pragma mark - Handle Selected Days Action
-(IBAction)repeatDaysAction:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RepeatDaysViewController *repeatDaysViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"RepeatDaysViewControllerSB"];
    [self presentViewController:repeatDaysViewController animated:NO completion:nil];
}

#pragma mark - Handle Clock In Action
-(IBAction)clockInAction:(id)sender
{
    currentAPICalled = kPartnerClockIn;
    [Utility showActivity:self];
    [webVC clockInPartner];
}

#pragma mark - Textfield Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0, -100, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    
    /*if(textField == self.startTimeField)
    {
        [self.backgroundScroll scrollRectToVisible:CGRectMake(self.backgroundScroll.frame.origin.x, 250, self.backgroundScroll.frame.size.width, self.backgroundScroll.frame.size.height+250) animated:YES];
    }
    
    else
    {
        [self.backgroundScroll scrollRectToVisible:CGRectMake(self.backgroundScroll.frame.origin.x, 300, self.backgroundScroll.frame.size.width, self.backgroundScroll.frame.size.height+300) animated:YES];
    }*/
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    
    /*if(textField == self.startTimeField)
    {
        [self.endTimeField becomeFirstResponder];
    }
    
    else
    {
        [self.backgroundScroll setContentSize:CGSizeMake(self.view.frame.size.width-20, 600)];
        [self.backgroundScroll scrollRectToVisible:CGRectMake(self.backgroundScroll.frame.origin.x, 0, self.backgroundScroll.frame.size.width, self.backgroundScroll.frame.size.height) animated:YES];
    }*/
}

#pragma mark - Save Button Action
-(IBAction)saveButtonAction:(id)sender
{
    [self.view endEditing:YES];
    
    postDictionary = [[NSMutableDictionary alloc]init];
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MMMM/dd/yyyy/EEEE"];
    NSDate *date = [format dateFromString:[datesWithDaysArray objectAtIndex:selectedDateTag]];
    
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSString *requiredFormat = [format stringFromDate:date];
    
    [postDictionary setObject:requiredFormat forKey:@"date"];
    [postDictionary setObject:[NSString stringWithFormat:@"%@ %@",requiredFormat, self.startTimeField.text]  forKey:@"from_time"];
    [postDictionary setObject:[NSString stringWithFormat:@"%@ %@",requiredFormat, self.endTimeField.text] forKey:@"to_time"];
    
    [self timeValidations];
}

#pragma mark - Days Difference

-(int)minutesSinceMidnight:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    return 60 * (int)[components hour] + (int)[components minute];
}

- (long)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2
{
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    daysDifference = components.day;
    return [components day]+1;
}

-(void)time1Formatters
{
    timeFormatter1 = [[NSDateFormatter alloc]init];
    
    //Time with hours and minutes
    if([self.startTimeField.text.lowercaseString rangeOfString:@":"].location != NSNotFound)
    {
        [timeFormatter1 setDateFormat:@"hh:mm a"];
    }
    
    //Time with only hours
    else
    {
        [timeFormatter1 setDateFormat:@"hh a"];
    }
    
    //Time with hours and minutes
    if([self.endTimeField.text.lowercaseString rangeOfString:@":"].location != NSNotFound)
    {
        [timeFormatter1 setDateFormat:@"hh:mm a"];
    }
    
    //Time with only hours
    else
    {
        [timeFormatter1 setDateFormat:@"hh a"];
    }
}

-(void)time2Formatters
{
    timeFormatter2 = [[NSDateFormatter alloc]init];
    
    //Time with hours and minutes
    if([self.startTimeField.text.lowercaseString rangeOfString:@":"].location != NSNotFound)
    {
        [timeFormatter2 setDateFormat:@"hh:mm a"];
    }
    
    //Time with only hours
    else
    {
        [timeFormatter2 setDateFormat:@"hh a"];
    }
    
    //Time with hours and minutes
    if([self.endTimeField.text.lowercaseString rangeOfString:@":"].location != NSNotFound)
    {
        [timeFormatter2 setDateFormat:@"hh:mm a"];
    }
    
    //Time with only hours
    else
    {
        [timeFormatter2 setDateFormat:@"hh a"];
    }
}

#pragma mark - Time Validations
-(void)timeValidations
{
    NSString *selectedStartTime = [[self.startTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]lowercaseString];
    NSString *selectedEndTime = [[self.endTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]lowercaseString];
    
    if(!selectedStartTime || [selectedStartTime length] == 0)
    {
        [self failedWithError:@"Start Time" description:@"Provide valid start time"];
        return;
    }
    else if (!selectedEndTime || [selectedEndTime length] == 0)
    {
        [self failedWithError:@"End Time" description:@"Provide valid end time"];
        return;
    }
    else if ([selectedStartTime rangeOfString:@":"].location == NSNotFound)
    {
        [self failedWithError:@"Start Time" description:@"Start time format is invalid"];
        return;
    }
    else if ([selectedEndTime rangeOfString:@":"].location == NSNotFound)
    {
        [self failedWithError:@"End Time" description:@"End time format is invalid"];
        return;
    }
    else if (([selectedStartTime rangeOfString:@"am"].location == NSNotFound) && ([selectedStartTime rangeOfString:@"pm"].location == NSNotFound))
    {
        [self failedWithError:@"Start Time" description:@"Start time format is invalid"];
        return;
    }
    else if (([selectedEndTime rangeOfString:@"am"].location == NSNotFound) && ([selectedEndTime rangeOfString:@"pm"].location == NSNotFound))
    {
        [self failedWithError:@"End Time" description:@"End time format is invalid"];
        return;
    }
    else
    {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"MM-dd-yyyy"];
        
        NSDate *today = [NSDate date];
        NSString *currentDateString = [df stringFromDate:today];
        
        NSDate *userSelectedDate = [df dateFromString:selectedDate];
        NSDate *currentDate = [df dateFromString:currentDateString];
        
        [self daysBetween:currentDate and:userSelectedDate];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        //Time with hours and minutes
        if([self.startTimeField.text.lowercaseString rangeOfString:@":"].location != NSNotFound)
        {
            [dateFormatter setDateFormat:@"hh:mm a"];
        }
        
        //Time with only hours
        else
        {
            [dateFormatter setDateFormat:@"hh a"];
        }
        
        //Time with hours and minutes
        if([self.endTimeField.text.lowercaseString rangeOfString:@":"].location != NSNotFound)
        {
            [dateFormatter setDateFormat:@"hh:mm a"];
        }
        
        //Time with only hours
        else
        {
            [dateFormatter setDateFormat:@"hh a"];
        }
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        //[timeFormatter1 setDateFormat:@"hh:mm:ss a"];
        //timeFormatter2 = [[NSDateFormatter alloc]init];
        
        if(daysDifference == 0)
        {
            currentTime = [dateFormatter stringFromDate:[NSDate date]];
            //NSLog(@"currentTime: %@",currentTime);
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"hh:mma"];
            
            NSDate *startTimeDate = [formatter dateFromString:selectedStartTime];
            NSDate *endTimeDate = [formatter dateFromString:selectedEndTime];
            NSString *currentTimeString = [formatter stringFromDate:[NSDate date]];
            NSDate *currentTimeDate = [formatter dateFromString:currentTimeString];
            
            int startTimer  = [self minutesSinceMidnight:startTimeDate];
            int endTimer = [self minutesSinceMidnight:endTimeDate];
            int currentTimer = [self minutesSinceMidnight:currentTimeDate];
            
            
            if(( startTimer < currentTimer) || (endTimer < currentTimer))
            {
                [self failedWithError:@"Improper Timings" description:@" Start time and End time both should be greater than Current time"];
                return;
            }
            
            [self compareStartTime:startTimer withEndTime:endTimer];
            
            
            /*
             [self time1Formatters];
             [self time2Formatters];
             
             [self timeComparision1];
             */
        }
        
        else
        {
            
            //Time with hours and minutes
            /* if([self.startTimeField.text rangeOfString:@":"].location != NSNotFound)
             {
             [timeFormatter2 setDateFormat:@"hh:mm a"];
             }
             
             //Time with only hours
             else
             {
             [timeFormatter2 setDateFormat:@"hh a"];
             }  //prev--
             
             [self time1Formatters];
             [self time2Formatters];
             
             NSDate *startDate = [timeFormatter2 dateFromString:self.startTimeField.text];
             startTime = [dateFormatter stringFromDate:startDate];
             //NSLog(@"startTime: %@",startTime);
             
             startDateTime = [timeFormatter1 dateFromString:startTime];
             
             [self timeComparision2];
             */
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"hh:mma"];
            
            NSDate *startTimeDate = [formatter dateFromString:selectedStartTime];
            NSDate *endTimeDate = [formatter dateFromString:selectedEndTime];
            
            int startTimer  = [self minutesSinceMidnight:startTimeDate];
            int endTimer = [self minutesSinceMidnight:endTimeDate];
            [self compareStartTime:startTimer withEndTime:endTimer];
            
        }
    }
}
// Test
#pragma mark - Current Date Time and start time difference

-(void)compareStartTime:(int)startTimer withEndTime:(int)endTimer
{
    if((endTimer - startTimer) >= 1)
    {
        //Show Activity Indicator
        [Utility showActivity:self];
        
        //Set schedule for first time
        if(scheduleIdFromResponse.length == 0 || [scheduleIdFromResponse isEqualToString:@""])
        {
            //NSLog(@"New Schedule");
            [self setNewSchedule];
        }
        
        //Update the existing schedule
        else if(scheduleIdFromResponse.length > 0)
        {
            //NSLog(@"Update Schedule: %@", scheduleIdFromResponse);
            [self updateSchedule];
        }
        
    }
    else
    {
        [self failedWithError:@"Improper Timings" description:@"End time should be greater than Start time and Maximum difference should be 1 hour"];
        return;
    }
    
}

-(void)timeComparision1
{
    NSDate *startDate = [timeFormatter2 dateFromString:self.startTimeField.text];
    
    startTime = [dateFormatter stringFromDate:startDate];
    
    currentDateTime = [timeFormatter1 dateFromString:currentTime];
    startDateTime = [timeFormatter1 dateFromString:startTime];
    
    //Time with hours and minutes
    /*if([self.startTimeField.text rangeOfString:@":"].location != NSNotFound)
     {
     [timeFormatter2 setDateFormat:@"hh:mm a"];
     }
     
     //Time with only hours
     else
     {
     [timeFormatter2 setDateFormat:@"hh a"];
     }*/
    
    //NSLog(@"startTime: %@",startTime);
    
    NSComparisonResult startTimeResult = [currentDateTime compare:startDateTime];
    
    NSDate *endDate = [timeFormatter2 dateFromString:self.endTimeField.text];
    NSString *endTime = [dateFormatter stringFromDate:endDate];
    NSDate *endDateTime = [timeFormatter1 dateFromString:endTime];
    NSComparisonResult endTimeResult = [startDateTime compare:endDateTime];
    
    if(startTimeResult == NSOrderedDescending)
    {
        //NSLog(@"current time is greater than start time");
        [self failedWithError:@"Improper Timings" description:@"Start time should be greater than Current time"];
        return;
    }
    
    else if (endTimeResult == NSOrderedDescending)
    {
        [self failedWithError:@"Improper Timings" description:@"End time should be greater than Current time"];
        return;
    }
    
    else if(startTimeResult == NSOrderedAscending)
    {
        //NSLog(@"start time is greater than curent time");
    }
    
    [self timeComparision2];
}

#pragma mark - Start time and End time difference
-(void)timeComparision2
{
    //Time with hours and minutes
    if([self.endTimeField.text rangeOfString:@":"].location != NSNotFound)
    {
        [timeFormatter2 setDateFormat:@"hh:mm a"];
    }
    
    //Time with only hours
    else
    {
        [timeFormatter2 setDateFormat:@"hh a"];
    }
    
    NSDate *endDate = [timeFormatter2 dateFromString:self.endTimeField.text];
    
    NSString *endTime = [dateFormatter stringFromDate:endDate];
    //NSLog(@"endTime: %@",endTime);
    
    NSDate *endDateTime = [timeFormatter1 dateFromString:endTime];
    
    NSComparisonResult endTimeResult = [startDateTime compare:endDateTime];
    
    if(endTimeResult == NSOrderedDescending)
    {
        //NSLog(@"start time is greater than end time");
        [self failedWithError:@"Improper Timings" description:@"End time should be greater than Start time"];
        return;
    }
    
    else if(endTimeResult == NSOrderedAscending)
    {
        //NSLog(@"end time is greater than start time");
        
        //Show Activity Indicator
        [Utility showActivity:self];
        
        //Set schedule for first time
        if(scheduleIdFromResponse.length == 0 || [scheduleIdFromResponse isEqualToString:@""])
        {
            //NSLog(@"New Schedule");
            [self setNewSchedule];
        }
        
        //Update the existing schedule
        else if(scheduleIdFromResponse.length > 0)
        {
            //NSLog(@"Update Schedule: %@", scheduleIdFromResponse);
            [self updateSchedule];
        }
    }
}

#pragma mark - New Schedule
-(void)setNewSchedule
{
    if([self.repeatedDaysBtn.titleLabel.text isEqualToString:@"none"])
    {
        [postDictionary setObject:@"never" forKey:@"repeats"];
        currentAPICalled = kSetPartnerSchedule;
        [webVC setSchedule:postDictionary];
    }
    
    else
    {
        NSString *repeatDays = self.repeatedDaysBtn.titleLabel.text;
        repeatDays = [repeatDays stringByReplacingOccurrencesOfString:@"/" withString:@","];
        [postDictionary setObject:@"weekly" forKey:@"repeats"];
        [postDictionary setObject:repeatDays.lowercaseString forKey:@"days_of_week"];
        currentAPICalled = kSetPartnerSchedule;
        [webVC setSchedule:postDictionary];
    }
    
    //NSLog(@"set postDictionary: %@",postDictionary);
}

#pragma mark - Update Schedule
-(void)updateSchedule
{
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    [postDictionary setObject:stylistAC.userId forKey:@"partner_id"];
    
    if([self.repeatedDaysBtn.titleLabel.text isEqualToString:@"none"])
    {
        [postDictionary setObject:@"never" forKey:@"repeats"];
        currentAPICalled = kUpdatePartnerSchedule;
        [webVC updateSchedule:postDictionary andScheduleId:scheduleIdFromResponse];
    }
    
    else
    {
        NSString *repeatDays = self.repeatedDaysBtn.titleLabel.text;
        repeatDays = [repeatDays stringByReplacingOccurrencesOfString:@"/" withString:@","];
        [postDictionary setObject:@"weekly" forKey:@"repeats"];
        [postDictionary setObject:repeatDays.lowercaseString forKey:@"days_of_week"];
        currentAPICalled = kUpdatePartnerSchedule;
        [webVC updateSchedule:postDictionary andScheduleId:scheduleIdFromResponse];
    }
    
    //NSLog(@"update postDictionary: %@",postDictionary);
}

#pragma mark - Handle Response
- (void)receivedResponse:(id)response
{
    if([currentAPICalled isEqualToString:kisPartnerAvailable])
    {
        if([response isEqualToString:@"true"]) {
            self.clockInTextLabel.text = @"Clock Out";
        }
        else {
            self.clockInTextLabel.text = @"Clock In";
        }
        [[StylistFlowModel sharedInstance]setPartnerAvailabilityString:self.clockInTextLabel.text];
        
        //Get Schedules
        currentAPICalled = kGetPartnerSchedule;
        [webVC getSchedule];
    }
    
    else if([currentAPICalled isEqualToString:kGetPartnerSchedule] && [response isEqualToString:@"GetPartnerSchedule"])
    {
        getPartnerScheduleResponse = [[SingletonClass shareManager].getPartnerScheduleResponse objectForKey:@"partners_schedule"];
        //List of dates in a Scrollview (strats from current date)
        self.prevArrowBtnImg.hidden = NO;
        self.nextArrowBtnImg.hidden = NO;
        UILabel *label = [self.bgView viewWithTag:100];
        label.hidden = NO;
        
        [self scrollViewDates];
        [Utility removeActivityIndicator];
    }

    else if ([currentAPICalled isEqualToString:kSetPartnerSchedule] && [response isEqualToString:@"SetPartnerSchedule"])
    {
        [self failedWithError:@"Success" description:@"Schedule Saved"];
        
        //Start/End Time View
        [self.startEndTimeView setHidden:YES];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"savedTag"];
        
        //Get Schedules
        currentAPICalled = kGetPartnerSchedule;
        [webVC getSchedule];
    }
    
    else if ([currentAPICalled isEqualToString:kUpdatePartnerSchedule] && ([response isEqualToString:@"UpdatePartnerSchedule"] || [SingletonClass shareManager].updateScheduleStatusCode == 200))
    {
        [self failedWithError:@"Success" description:@"Schedule Updated"];
        
        //Start/End Time View
        [self.startEndTimeView setHidden:YES];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"savedTag"];
        
        //Get Schedules
        currentAPICalled = kGetPartnerSchedule;
        [webVC getSchedule];
    }
    
    else if([currentAPICalled isEqualToString:kPartnerClockIn] && [response isEqualToString:@"true"])
    {
        [Utility removeActivityIndicator];
        self.clockInTextLabel.text = @"Clock Out";
        [[StylistFlowModel sharedInstance]setPartnerAvailabilityString:self.clockInTextLabel.text];
    }
    
    else if ([currentAPICalled isEqualToString:kPartnerClockIn] && [response isEqualToString:@"false"])
    {
        [Utility removeActivityIndicator];
        self.clockInTextLabel.text = @"Clock In";
        [[StylistFlowModel sharedInstance]setPartnerAvailabilityString:self.clockInTextLabel.text];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
