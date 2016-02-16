//
//  StylistInfoViewController.m
//  ParlorMe
//

#import "StylistInfoViewController.h"
#import "Utility.h"
#import "WebserviceViewController.h"
#import "StylistDetails.h"
#import "StylistViewController.h"
#import "AsyncImageView.h"
#import "UserAccount.h"
#import "CoreDataModel.h"

@interface StylistInfoViewController ()<WebserviceViewControllerDelegate>
{
    NSArray *lhsList;
    NSArray *rhsList;
    NSArray *selectedServices;
}

@property (weak, nonatomic) IBOutlet UITableView *servicesTable;

@end

@implementation StylistInfoViewController
@synthesize stylistId,stylistAC;

#pragma mark - View LifeCycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // to hide nabigation bar
    self.navigationController.navigationBarHidden = true;
    
    lhsList=[NSArray arrayWithObjects:@"SERVICES:",@"Blowout",@"Hair Cut",@"Hair Color",@"MakeUpApplication",@"Manicure",@"Pedicure",@"xx", nil];
    rhsList=[NSArray arrayWithObjects:@"prices starting at:",@"$30.00",@"$75.00",@"$100.00",@"$50.00",@"$30.00",@"$35.00",@"$$", nil];
    selectedServices = [[NSArray alloc]init];
    
    //NSLog(@"stylistPricingList: %@",stylistAC.stylistPricingList);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UserAccount *userAccount = [UserAccount sharedInstance];
    selectedServices = userAccount.selectedServicesList.allKeys;
    [self.servicesTable reloadData];
}

#pragma mark - Close Button Action

- (void)closeButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==1)
    {
        //  NSLog(@"%lu",(unsigned long)stylistAC.stylistPricingList.allKeys.count);
        return (stylistAC.stylistPricingList.count + 1);
    }
    
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderView"];
        headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *closeBtn=(UIButton*)[headerCell viewWithTag:901];
        [closeBtn addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        AsyncImageView *stylistImageView=(AsyncImageView *)[headerCell viewWithTag:501];
        stylistImageView.layer.cornerRadius = 30;
        stylistImageView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
        stylistImageView.layer.borderWidth = 1.0f;
        stylistImageView.clipsToBounds = YES;
        stylistImageView.image=[UIImage imageNamed:@"default _stylist_image.png"];
        
        UITextView *bioInfo = (UITextView *)[self.view viewWithTag:2000];
        bioInfo.hidden = YES;
        
        UITextView *bioTextView = [[UITextView alloc]initWithFrame:CGRectMake(8, 111, self.view.frame.size.width-20, 139)];
        bioTextView.backgroundColor = [UIColor lightTextColor];
        bioTextView.editable = NO;
        bioTextView.selectable = NO;
        bioTextView.font = [UIFont systemFontOfSize:16];
        
        if(![stylistAC.stylistBio isKindOfClass:[NSNull class]] && stylistAC.stylistBio.length > 0)
        {
            bioTextView.textColor = [UIColor blackColor];
            bioTextView.text = stylistAC.stylistBio;
        }
        
        else
        {
            bioTextView.textColor = [UIColor darkGrayColor];
            bioTextView.text = @"Stylist Bio Here";
        }
        
        [headerCell.contentView addSubview:bioTextView];
                
        NSURL *url = [NSURL URLWithString:stylistAC.image];
        stylistImageView.imageURL = url;
        
        UIImageView *dotImageView = (UIImageView *)[headerCell viewWithTag:555];
        dotImageView.layer.cornerRadius = dotImageView.frame.size.width/2;
        dotImageView.layer.borderColor = [[UIColor blackColor]CGColor];
        dotImageView.layer.borderWidth = 1.0f;
        dotImageView.clipsToBounds = YES;
        
        UILabel *nameLabel = (UILabel *)[headerCell viewWithTag:700];
        nameLabel.text = stylistAC.stylistName;
        
        UILabel *experienceLabel = (UILabel *)[headerCell viewWithTag:701];
        
        if(stylistAC.stylistExpereince > 0)
        {
            if(stylistAC.stylistExpereince.integerValue < 2)
            {
                experienceLabel.text = [NSString stringWithFormat:@"%@ year experience",stylistAC.stylistExpereince];
            }
            
            else
            {
                experienceLabel.text = [NSString stringWithFormat:@"%@ years experience",stylistAC.stylistExpereince];
            }
        }
        
        UILabel *addressLabel = (UILabel *)[headerCell viewWithTag:702];
        addressLabel.text = stylistAC.stylistLocation;
        
        return headerCell;
    }
    
    else if (indexPath.section==1)
    {
        UITableViewCell *serviceTableCell = [tableView dequeueReusableCellWithIdentifier:@"seviceTabelCell"];
        serviceTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *bgView = (UIView*) [serviceTableCell viewWithTag:401];
        UILabel *lhsLabel = (UILabel*) [serviceTableCell viewWithTag:301];
        UILabel *rhsLabel = (UILabel*) [serviceTableCell viewWithTag:302];
        
        if(indexPath.row==0)
        {
            lhsLabel.text=[lhsList objectAtIndex:indexPath.row];
            rhsLabel.text=[rhsList objectAtIndex:indexPath.row];
        }
        
        else
        {
            NSString *serviceAmount = [NSString stringWithFormat:@"$%@",[[[stylistAC.stylistPricingList  objectAtIndex:indexPath.row-1]objectForKey:@"price"]stringValue]];
            // NSArray *servicesList = [stylistAC.stylistPricingList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            lhsLabel.text=[[stylistAC.stylistPricingList  objectAtIndex:indexPath.row-1]objectForKey:@"name"];
            rhsLabel.text=serviceAmount;
        }
        
        if(indexPath.row == 0 || [selectedServices containsObject:lhsLabel.text])
        {
            bgView.backgroundColor=[UIColor colorWithRed:67/255.0f green:66/255.0f blue:65/255.0f alpha:1];
            lhsLabel.textColor=[UIColor whiteColor];
            rhsLabel.textColor=[UIColor whiteColor];
        }
        
        else
        {
            bgView.backgroundColor=[UIColor whiteColor];
            lhsLabel.textColor=[UIColor blackColor];
            rhsLabel.textColor=[UIColor blackColor];
        }
        
        return serviceTableCell;
    }
    
    else
    {
        UITableViewCell *footerCell = [tableView dequeueReusableCellWithIdentifier:@"FooterCell"];
        footerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *selectStylistButton=(UIButton *)[footerCell viewWithTag:530];
        
        selectStylistButton.layer.cornerRadius=3.0f;
        selectStylistButton.layer.borderWidth=1.0f;
        selectStylistButton.layer.borderColor=[[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
        [selectStylistButton addTarget:self action:@selector(stylistSelected) forControlEvents:UIControlEventTouchUpInside];
        
        for(int i=1;i<=5;i++)
        {
            // assigning image to rating button
            UIButton *ratingStarButton = (UIButton *)[footerCell viewWithTag:i];
            if([stylistAC.stylistRatings intValue] >= ratingStarButton.tag)
            {
                [ratingStarButton setImage:[UIImage imageNamed:@"black-star-rating-filled.png"] forState:UIControlStateNormal];
            }
            else
            {
                [ratingStarButton setImage:[UIImage imageNamed:@"black-star-rating-empty.png"] forState:UIControlStateNormal];
            }
        }
        
        return footerCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        return 304;
    }
    
    else if(indexPath.section==1)
    {
        return 40;
    }
    
    else
    {
        return 160;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(indexPath.section!=1)
    {
        return;
    }
    
    else if (!userAccount.selectedStylistName)
    {
        return;
    }
    
    else
    {
        UITableViewCell *serviceTableCell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *lhsLabel = (UILabel*) [serviceTableCell viewWithTag:301];
        UILabel *rhsLabel = (UILabel*) [serviceTableCell viewWithTag:302];
        UIView *bgView = (UIView*) [serviceTableCell viewWithTag:401];
        
        if(indexPath.row > 0 && [selectedServices containsObject:lhsLabel.text] && [_delegate respondsToSelector:@selector(addtionalServiceSelected)])
        {
            [_delegate addtionalServiceSelected];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        else if (indexPath.row > 0 && ![selectedServices containsObject:lhsLabel.text] && [_delegate respondsToSelector:@selector(addtionalServiceSelected)])
        {
            lhsLabel.textColor=[UIColor whiteColor];
            rhsLabel.textColor=[UIColor whiteColor];
            bgView.backgroundColor=[UIColor colorWithRed:67/255.0f green:66/255.0f blue:65/255.0f alpha:1];
            [self saveUserData:indexPath];
            [_delegate addtionalServiceSelected];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Stylist selected Action

- (void)stylistSelected
{
    if ([_delegate respondsToSelector:@selector(stylistSelected:)])
    {
        [_delegate stylistSelected:stylistAC];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Save User data in database

- (void)saveUserData:(NSIndexPath*)indexPath
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    NSMutableArray *servicesArray;
    NSMutableArray *mainCategoryArray;
    
    if(!userAccount.userId)
    {
        return;
    }
    
    NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    if(userRecords.count == 1)
    {
        User *userObj = [userRecords objectAtIndex:0];
        servicesArray = [NSMutableArray arrayWithArray:userObj.selectedServices.allObjects];
        mainCategoryArray = [NSMutableArray arrayWithArray:userObj.selectedCategories.allObjects];
        
        NSArray *selectedServiceRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Services" andPredicate:[NSPredicate predicateWithFormat:@"currentUser == %@",[userRecords objectAtIndex:0]] andSortDescriptor:nil forContext:nil];
        [servicesArray addObjectsFromArray:selectedServiceRecords];
        
        Services *selectedService = (Services *)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"Services" forContext:nil];
        [selectedService setName:[[stylistAC.stylistPricingList  objectAtIndex:indexPath.row-1]objectForKey:@"name"]];
        [selectedService setCategoryName:[[stylistAC.stylistPricingList  objectAtIndex:indexPath.row-1]objectForKey:@"category_name"]];
        [selectedService setPrice:[NSString stringWithFormat:@"%@",[[stylistAC.stylistPricingList  objectAtIndex:indexPath.row-1]objectForKey:@"price"]]];
        [selectedService setProductId:[[stylistAC.stylistPricingList  objectAtIndex:indexPath.row-1]objectForKey:@"product_id"]];
        [servicesArray addObject:selectedService];
        
        if(![mainCategoryArray containsObject:[[stylistAC.stylistPricingList  objectAtIndex:indexPath.row-1]objectForKey:@"category_name"]])
        {
            MainCategories *mainCategoryObj = (MainCategories *)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"MainCategories" forContext:nil];
            [mainCategoryObj setName:[[stylistAC.stylistPricingList  objectAtIndex:indexPath.row-1]objectForKey:@"category_name"]];
            [mainCategoryArray addObject:mainCategoryObj];
        }
        
        [[userRecords objectAtIndex:0]setSelectedCategories:[NSSet setWithArray:mainCategoryArray]];
        [[userRecords objectAtIndex:0]setSelectedServices:[NSSet setWithArray:servicesArray]];

        [[CoreDataModel sharedCoreDataModel]saveContext];
    }
}

#pragma mark - Webservice delegates

- (void)receivedResponse:(id)response
{
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"])
    {
        if(stylistAC)
        {
            StylistDetails *stylistObj = [StylistDetails sharedInstance];
            
            for(StylistDetails *object in stylistObj.stylistList)
            {
                if(object.stylistId == stylistId )
                {
                    stylistAC = object;
                }
            }
            
            [self.servicesTable reloadData];
        }
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to process Request." message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to process Request." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
