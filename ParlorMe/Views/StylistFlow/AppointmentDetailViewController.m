//
//  AppointmentDetailViewController.m
//  ParlorMe
//

#import "AppointmentDetailViewController.h"
#import "ScheduleViewController.h"
#import "SingletonClass.h"
#import <LatoFont/UIFont+Lato.h>
#import "Constants.h"
#import "StylistFlowModel.h"
#import "WebserviceViewController.h"
#import "Utility.h"
#import "StylistAccount.h"
#import "AsyncImageView.h"

@interface AppointmentDetailViewController ()<WebserviceViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    SingletonClass *sharedObject;
    WebserviceViewController *webVC;
    NSString *currentAPICalled;
    float totalAmount;
}

@property (nonatomic, weak) IBOutlet UIScrollView *backgroundScroll;
@property (nonatomic, weak) IBOutlet UIButton *cancelAppointmentBtn;
@property (nonatomic, weak) IBOutlet UIButton *statusUpdateBtn;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLbl;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UITableView *appointmentInfoTable;

@end

@implementation AppointmentDetailViewController
@synthesize appointmentInfoArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cancelAppointmentBtn.layer.cornerRadius = 5;
    self.statusUpdateBtn.layer.cornerRadius = 5;
    
    webVC = [[WebserviceViewController alloc] init];
    webVC.delegate = self;
    
    NSArray *startTimeArray = [[appointmentInfoArray valueForKey:@"from_time"] componentsSeparatedByString:@"T"];
    NSString *dateToParse = [NSString stringWithFormat:@"%@",[startTimeArray objectAtIndex:0]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date = [dateFormatter dateFromString:dateToParse];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSCalendar* calender = [NSCalendar currentCalendar];
    NSDateComponents* component = [calender components:NSWeekdayCalendarUnit | NSMonthCalendarUnit fromDate:date];
    
    NSInteger weekDay = [component weekday];
    NSString *weekdayString = [[formatter weekdaySymbols] objectAtIndex:weekDay - 1];
    
    NSInteger monthName = [component month];
    NSString *monthNameString = [[formatter monthSymbols] objectAtIndex:monthName - 1];
    
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *fromDateTime = [dateFormatter dateFromString:[[startTimeArray objectAtIndex:1] substringToIndex:5]];
    
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *pmamDateString = [dateFormatter stringFromDate:fromDateTime];
    
    NSString *appointmentTime = [NSString stringWithFormat:@"@ %@",pmamDateString];
    
    self.dateTimeLabel.text = [NSString stringWithFormat:@"Date/Time: %@ %@ %@ %@", weekdayString, monthNameString, [dateToParse substringFromIndex:dateToParse.length - 2], appointmentTime];
    
    totalAmount = 0;
    
    for(int i=0; i< [[appointmentInfoArray valueForKey:@"services_list"]count]; i++)
    {
        totalAmount += [[[[appointmentInfoArray valueForKey:@"services_list"] objectAtIndex:i] objectForKey:@"price"]floatValue];
    }
    
    [self.appointmentInfoTable reloadData];
}

-(IBAction)cancelAppointmentAction:(id)sender
{
    currentAPICalled = kPartnerCancelAppointment;
    [Utility showActivity:self];
    
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    
    //Forming Json Object
    [postDictionary setObject:stylistAC.userId forKey:@"partner_id"];
    [postDictionary setObject:[[StylistFlowModel sharedInstance] appointmentID] forKey:@"appointment_id"];
    
    [webVC partnerCancelAppointment:postDictionary];
}

-(IBAction)sendStatusUpdateAction:(id)sender
{
    currentAPICalled = kPartnerConfirmAppointment;
    [Utility showActivity:self];
    
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    
    //Forming Json Object
    [postDictionary setObject:stylistAC.userId forKey:@"partner_id"];
    [postDictionary setObject:[[StylistFlowModel sharedInstance] appointmentID] forKey:@"appointment_id"];
    
    [webVC partnerConfirmAppointment:postDictionary];
}

- (void)receivedResponse:(id)response
{
    if([currentAPICalled isEqualToString:kPartnerCancelAppointment] || [currentAPICalled isEqualToString:kPartnerConfirmAppointment])
    {
        webVC = [[WebserviceViewController alloc] init];
        webVC.delegate = self;
        currentAPICalled = kPartnerAppointmentsCount;
        [webVC getAppointmentsCount];
    }
    
    else if([currentAPICalled isEqualToString:kPartnerAppointmentsCount] && [response isEqualToString:@"CountExists"])
    {
        [Utility removeActivityIndicator];
        [self goBackToView];
    }
}

-(void)failedWithError:(NSString *)errorTitle description:(NSString *)errorDescription
{
    [Utility removeActivityIndicator];
}

#pragma mark - UITableView Delegate and Datasource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount = 0;
    
    if(section == 1)
    {
        rowsCount = [[appointmentInfoArray valueForKey:@"services_list"]count];
    }
    
    else
    {
        rowsCount = 1;
    }
    
    return rowsCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 90;
    }
    
    else if(indexPath.section == 1)
    {
        return 35;
    }
    
    else if (indexPath.section == 2)
    {
        return 40;
    }
    
    else if (indexPath.section == 3)
    {
        return 40;
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    UILabel *lineLbl1;
    UILabel *lineLbl2;
    UILabel *lineLbl3;
    
    if (indexPath.section == 0)
    {
        identifier = @"ClientInfoCell";
    }
    
    else if (indexPath.section == 1)
    {
        identifier = @"ServicesListCell";
    }
    
    else if (indexPath.section == 2)
    {
        identifier = @"TotalAmountCell";
    }
    
    else if (indexPath.section == 3)
    {
        identifier = @"LocationCell";
    }
    
    UITableViewCell *cell = [self.appointmentInfoTable dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.section == 0)
    {
        AsyncImageView *clientPic = (AsyncImageView *)[cell viewWithTag:1];
        UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *clientAgeLabel = (UILabel *)[cell viewWithTag:3];
        
        clientPic.backgroundColor = [UIColor whiteColor];
        
        NSString *imageURLString = [appointmentInfoArray valueForKey:@"photo"];
        
        if([imageURLString rangeOfString:@"missing.png"].location != NSNotFound || [imageURLString rangeOfString:@"error.png"].location != NSNotFound)
        {
            clientPic.image = [UIImage imageNamed:@"default _stylist_image.png"];
        }
        
        else
        {
            clientPic.imageURL = [NSURL URLWithString:imageURLString];
        }
        
        clientNameLabel.text = [appointmentInfoArray valueForKey:@"client"];
        
        NSNumber *ageNumber = [appointmentInfoArray valueForKey:@"age"];
        NSString *ageNumberInString = [ageNumber stringValue];
        
        clientAgeLabel.text = ageNumberInString;
        
        lineLbl1 = [[UILabel alloc]init];
        lineLbl1.frame = CGRectMake(0, [self tableView:self.appointmentInfoTable heightForRowAtIndexPath:indexPath]-2, self.view.frame.size.width+5, 0.5);
        lineLbl1.backgroundColor = [UIColor blackColor];
        lineLbl1.alpha = 0.8;
        [cell.contentView addSubview:lineLbl1];
    }
    
    if(indexPath.section == 1)
    {
        UILabel *categoryNameLabel = (UILabel *)[cell viewWithTag:100];
        categoryNameLabel.text = [NSString stringWithFormat:@"%@:%@",[[[appointmentInfoArray valueForKey:@"services_list"] objectAtIndex:indexPath.row] objectForKey:@"category"], [[[appointmentInfoArray valueForKey:@"services_list"] objectAtIndex:indexPath.row] objectForKey:@"service"]];
        
        NSArray *subStrings = [categoryNameLabel.text componentsSeparatedByString:@":"];
        
        UIFont *font1 = [UIFont fontWithName:@"Lato-Bold" size:15];
        NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
        NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",[subStrings objectAtIndex:0]] attributes:arialDict];
        
        UIFont *font2 = [UIFont fontWithName:@"Lato-Regular" size:15];
        NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
        NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:[subStrings objectAtIndex:1] attributes:arialDict2];
        
        [aAttrString1 appendAttributedString:aAttrString2];
        categoryNameLabel.attributedText = aAttrString1;
        
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:200];
        priceLabel.text = [NSString stringWithFormat:@"$%@.00",[[[appointmentInfoArray valueForKey:@"services_list"] objectAtIndex:indexPath.row] objectForKey:@"price"]];
    }
    
    if(indexPath.section == 2)
    {
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:300];
        priceLabel.text = [NSString stringWithFormat:@"Total: $%.2f",totalAmount];
        
        NSArray *subStrings = [priceLabel.text componentsSeparatedByString:@":"];
        
        UIFont *font1 = [UIFont fontWithName:@"Lato-Bold" size:15];
        NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
        NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",[subStrings objectAtIndex:0]] attributes:arialDict];
        
        UIFont *font2 = [UIFont fontWithName:@"Lato-Light" size:15];
        NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
        NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:[subStrings objectAtIndex:1] attributes:arialDict2];
        
        [aAttrString1 appendAttributedString:aAttrString2];
        priceLabel.attributedText = aAttrString1;
        
        lineLbl2 = [[UILabel alloc]init];
        lineLbl2.frame = CGRectMake(0, [self tableView:self.appointmentInfoTable heightForRowAtIndexPath:indexPath]-2, self.view.frame.size.width+5, 0.5);
        lineLbl2.backgroundColor = [UIColor blackColor];
        lineLbl2.alpha = 0.8;
        [cell.contentView addSubview:lineLbl2];
    }
    
    if(indexPath.section == 3)
    {
        UILabel *locationLabel = (UILabel *)[cell viewWithTag:400];
        locationLabel.text = [appointmentInfoArray valueForKey:@"location"];
        
        lineLbl3 = [[UILabel alloc]init];
        lineLbl3.frame = CGRectMake(0, [self tableView:self.appointmentInfoTable heightForRowAtIndexPath:indexPath]-2, self.view.frame.size.width+5, 0.5);
        lineLbl3.backgroundColor = [UIColor blackColor];
        lineLbl3.alpha = 0.8;
        [cell.contentView addSubview:lineLbl3];
    }
    
    return cell;
}

#pragma mark - Close Screen
-(IBAction)closeBtnAction:(UIButton *)sender
{
    [self goBackToView];
}

-(void)goBackToView
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ScheduleViewController *scheduleViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"ScheduleViewControllerSB"];
    scheduleViewController.updatedProfile = @"NO";
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
