//
//  NewBookingRequestViewController.m
//  ParlorMe
//

#import "NewBookingRequestViewController.h"
#import "SingletonClass.h"
#import <LatoFont/UIFont+Lato.h>
#import "Constants.h"
#import "StylistAccount.h"
#import "AsyncImageView.h"

@interface NewBookingRequestViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    SingletonClass *sharedObj;
    NSDictionary *notificationDict;
    float totalAmount;
}

@property (nonatomic, weak) IBOutlet AsyncImageView *clientPicture;
@property (nonatomic, weak) IBOutlet UILabel *clientName;
@property (nonatomic, weak) IBOutlet UITableView *aTable;
@property (nonatomic, weak) IBOutlet UIButton *declineBtn;
@property (nonatomic, weak) IBOutlet UIButton *acceptBtn;
@property (nonatomic, weak) IBOutlet UIButton *dropDownBtn;
@property (nonatomic, weak) IBOutlet UIButton *showAndHideDetailsBtn;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *verticalSpaceConstraint;
@property (nonatomic, weak) IBOutlet UIView *horizontalLineLbl;

-(IBAction)hideAndShowDetailsAction:(UIButton *)sender;

@end

@implementation NewBookingRequestViewController

#pragma mark - ViewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.declineBtn.layer.cornerRadius = 5;
    self.acceptBtn.layer.cornerRadius = 5;
    
    sharedObj = [SingletonClass shareManager];
    
    [self.aTable setHidden:YES];
    [self.horizontalLineLbl setHidden:YES];
    
    self.verticalSpaceConstraint.constant = 20;
    
    [self.showAndHideDetailsBtn setBackgroundImage:[UIImage imageNamed:@"view-details-button"] forState:UIControlStateNormal];
    
    StylistAccount *stylistAccount = [StylistAccount sharedInstance];
    notificationDict = stylistAccount.stylistAppointmentNotificationDictionary;
    
    if(notificationDict != nil)
    {
        //Client Pic
        NSString *imageURLString = [[notificationDict objectForKey:@"appointment_details"]objectForKey:@"picture"];
        
        if([imageURLString rangeOfString:@"missing.png"].location != NSNotFound)
        {
            self.clientPicture.image = [UIImage imageNamed:@"default _stylist_image.png"];
        }
        
        else
        {
            self.clientPicture.imageURL = [NSURL URLWithString:imageURLString];
        }
        
        //Client Name
        self.clientName.text = [[notificationDict objectForKey:@"appointment_details"]objectForKey:@"name"];
        
        totalAmount = 0;
        
        for(int i=0; i< [[notificationDict objectForKey:@"services_list"] count]; i++)
        {
            totalAmount += [[[[notificationDict objectForKey:@"services_list"] objectAtIndex:i] objectForKey:@"price"]floatValue];
        }
        
        [self.aTable reloadData];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

#pragma mark - TableView Delegates and DataSources
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount = 0;
    
    if(section == 0 || section == 1 || section == 3)
    {
        rowsCount = 1;
    }
    
    else if (section == 2)
    {
        rowsCount = [[notificationDict objectForKey:@"services_list"]count];
    }
    
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    UILabel *lineLbl;
    
    if (indexPath.section == 0)
    {
        identifier = @"CellIdOne";
    }
    
    else if (indexPath.section == 1)
    {
        identifier = @"CellIdTwo";
    }
    
    UITableViewCell *cell = [self.aTable dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0)
    {
        UILabel *dateTimeLabel = (UILabel *)[cell viewWithTag:1];
        
        NSArray *startTimeArray = [[[notificationDict objectForKey:@"appointment_details"]objectForKey:@"date"] componentsSeparatedByString:@"T"];
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
        
        NSString *appointmentTime = [NSString stringWithFormat:@"@ %@",[[[notificationDict objectForKey:@"appointment_details"]objectForKey:@"from_time"] uppercaseString]];;
        dateTimeLabel.text = [NSString stringWithFormat:@"Date/Time: %@ %@ %@ %@", weekdayString, monthNameString, [dateToParse substringFromIndex:dateToParse.length - 2], appointmentTime];
        
        lineLbl = [[UILabel alloc]init];
        lineLbl.frame = CGRectMake(self.horizontalLineLbl.frame.origin.x+5, [self tableView:self.aTable heightForRowAtIndexPath:indexPath]-2, self.horizontalLineLbl.frame.size.width-10, 1);
        lineLbl.backgroundColor = [UIColor lightGrayColor];
        lineLbl.alpha = 0.8;
        [cell.contentView addSubview:lineLbl];
    }
    
    else if (indexPath.section == 1)
    {
        UILabel *locationLabel = (UILabel *)[cell viewWithTag:2];
        locationLabel.text = [NSString stringWithFormat:@"Address: %@",[[notificationDict objectForKey:@"appointment_details"]objectForKey:@"location"]];
        
        UIButton *accessoryBtn = (UIButton*) [cell viewWithTag:1];
        accessoryBtn.layer.cornerRadius = 8;
        
        lineLbl = [[UILabel alloc]init];
        lineLbl.frame = CGRectMake(self.horizontalLineLbl.frame.origin.x+5, [self tableView:self.aTable heightForRowAtIndexPath:indexPath]-2, self.horizontalLineLbl.frame.size.width-10, 1);
        lineLbl.backgroundColor = [UIColor lightGrayColor];
        lineLbl.alpha = 0.8;
        [cell.contentView addSubview:lineLbl];
    }
    
    else if (indexPath.section == 2)
    {
        UITableViewCell *selectedServiceCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdThree"];
        
        UILabel *categoryLabel = (UILabel *)[selectedServiceCell viewWithTag:500];
        categoryLabel.text = [NSString stringWithFormat:@"%@: %@",[[[notificationDict objectForKey:@"services_list"] objectAtIndex:indexPath.row] objectForKey:@"category"], [[[notificationDict objectForKey:@"services_list"] objectAtIndex:indexPath.row] objectForKey:@"service"]];
        
        UILabel *priceLabel = (UILabel *)[selectedServiceCell viewWithTag:501];
        priceLabel.text = [NSString stringWithFormat:@"$%@.00",[[[notificationDict objectForKey:@"services_list"] objectAtIndex:indexPath.row] objectForKey:@"price"]];
        
        return selectedServiceCell;
    }
    
    else if (indexPath.section == 3)
    {
        UITableViewCell *costServiceCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdFour"];
        
        UILabel *priceLabel = (UILabel *)[costServiceCell viewWithTag:1001];
    
        priceLabel.text = [NSString stringWithFormat:@"Total: $%.2f",totalAmount];
        
        return costServiceCell;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2)
    {
        return 25;
    }
    
    else if (indexPath.section == 3)
    {
        return 40;
    }
    
    return 0;
}

#pragma mark - Expand/Collapse Button Action
-(IBAction)hideAndShowDetailsAction:(UIButton *)sender
{
    if(sharedObj.dropDownBoolValue == NO)
    {
        [self.aTable setHidden:YES];
        [self.horizontalLineLbl setHidden:YES];
        
        [UIView animateWithDuration:5 animations:^{
            self.verticalSpaceConstraint.constant = 20;
        }];
        
        [self.showAndHideDetailsBtn setBackgroundImage:[UIImage imageNamed:@"view-details-button"] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideDetailsNotification" object:self];
    }
    
    else if(sharedObj.dropDownBoolValue == YES)
    {
        [self.aTable setHidden:NO];
        [self.horizontalLineLbl setHidden:NO];
        
        [UIView animateWithDuration:5 animations:^{
            self.verticalSpaceConstraint.constant = self.aTable.frame.origin.y + [[notificationDict objectForKey:@"services_list"]count]*20 + 60 + 5;
        }];
        
        [self.showAndHideDetailsBtn setBackgroundImage:[UIImage imageNamed:@"hide-details-button"] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowDetailsNotification" object:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
