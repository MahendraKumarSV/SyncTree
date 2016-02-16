//
//  StylistViewController.m
//  ParlorMe
//

#import "StylistViewController.h"
#import <LatoFont/UIFont+Lato.h>
#import "StylistInfoViewController.h"
#import "UserAccount.h"
#import "StylistAccount.h"
#import "Utility.h"
#import "StylistDetails.h"
#import "StylistDetailsTableViewCell.h"
#import "StylistDetails.h"
#import "WebserviceViewController.h"
#import "AsyncImageView.h"
#import "CoreDataModel.h"
#import "SettingsViewController.h"
#import "SingletonClass.h"
#import "Constants.h"
#import "DetailsViewController.h"
#import "Favourities+CoreDataProperties.h"

@interface StylistViewController ()<WebserviceViewControllerDelegate, SetSelectedStylistDelegate>
{
    UISwipeGestureRecognizer * swiperight;
    UISwipeGestureRecognizer * swipeleft;
    BOOL isexpanded;
    NSDictionary *selectedServices;
    NSArray *categoryList;
    NSMutableArray *subCategoryList;
    NSMutableArray *stylistList;
    NSMutableArray *filteredStylistArray;
    BOOL isSearching;
    BOOL isStylistSelected;
    long selectedButtonTag;
    NSString *selectedStylistId;
    StylistDetails *stylistDetailObj;
    float totalAmount;
    NSMutableDictionary *priceDictionary;
    NSMutableDictionary *productIdDict;
    NSMutableDictionary *categoryDictionary;
    BOOL isWebServiceFailed;
    NSString *selectedStylistName;
}

@property (weak, nonatomic) IBOutlet UITableView *stylistTableView;
@property (nonatomic, weak) IBOutlet UILabel *noStylistsAvailableLbl;

@end

@implementation StylistViewController

#pragma mark - view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // to check if table is expanded or not
    isexpanded = NO;
    isWebServiceFailed = NO;
    
    // adding swipe left gesture
    swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.stylistTableView addGestureRecognizer:swipeleft];
    
    // adding swipe right gesture
    swiperight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.stylistTableView addGestureRecognizer:swiperight];
    
    stylistDetailObj = [[StylistDetails alloc]init];
    subCategoryList = [[NSMutableArray alloc]init];
    stylistList = [[NSMutableArray alloc]init];
    filteredStylistArray = [[NSMutableArray alloc]init];
    priceDictionary = [[NSMutableDictionary alloc]init];
    productIdDict = [[NSMutableDictionary alloc]init];
    categoryDictionary = [[NSMutableDictionary alloc]init];
    selectedButtonTag = 0;
    isSearching = NO;
    isStylistSelected = NO;
    selectedStylistId = @"";
    totalAmount = 0;
    selectedStylistName = @"";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = [UIImage imageNamed:@"backArrow"];
    [btn setImage:btnImg forState:UIControlStateNormal];
    
    btn.frame = CGRectMake(-20, 0, 30, 22);
    [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    for(int counter = 0; counter < 2; counter++)
    {
        UIButton *bottomBarButton = (UIButton*)[self.view viewWithTag:(9090 + counter)];
        bottomBarButton.layer.borderColor = [[UIColor blackColor]CGColor];
        bottomBarButton.layer.borderWidth = 2.0f;
    }
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.noStylistsAvailableLbl.hidden = YES;
    
    self.navigationItem.title = @"Select Stylist";
    [[SingletonClass shareManager]showBackBtn:self];
    
    // to get a list of selected services
    UserAccount *userAccount = [UserAccount sharedInstance];
    selectedServices = userAccount.selectedServicesList;
    
    NSArray *mainCategoryList = [[NSArray alloc]initWithArray:selectedServices.allKeys];
    NSArray *sortedCategoryList = [mainCategoryList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedSubCategory = [subCategoryList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    // to group services as per their category and sorting them alphabetically
    if(![sortedCategoryList isEqualToArray: sortedSubCategory] || isWebServiceFailed)
    {
        categoryList = selectedServices.allValues;
        NSSet *categoryset = [NSSet setWithArray:categoryList];
        [subCategoryList removeAllObjects];
        
        NSArray *sortedCategoryList = [categoryset.allObjects sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        for(id categoryName in sortedCategoryList)
        {
            [subCategoryList addObjectsFromArray:[[selectedServices allKeysForObject:categoryName ] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        }
        
        isStylistSelected = NO;
        isSearching = NO;
        selectedButtonTag = 0;
        totalAmount = 0;
        userAccount.selectedsubCategoryList = [[NSArray alloc]initWithArray:subCategoryList];
    }
    
    // calling webservice to get list of Stylists
    [Utility showActivity:self];
    WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
    webserviceViewController.delegate = self;
    [webserviceViewController getStylistList];
    
    [self getUserData];
    
    [self.stylistTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - to get user data from data base
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
        
        if([currentUser.isStlistSelected isEqualToString:@"Yes"])
        {
            isStylistSelected = YES;
            selectedStylistId = currentUser.selectedStylistTag;
            selectedStylistName = currentUser.selectedStylistName;
            userAccount.selectedStylistName = selectedStylistName;
        }
        
        else
        {
            userAccount.selectedStylistName = nil;
        }
        
        if(currentUser.selectedServices.allObjects.count>0)
        {
            [priceDictionary removeAllObjects];
            [categoryDictionary removeAllObjects];
            [productIdDict removeAllObjects];
            
            NSArray *serviceSelectedByUser = currentUser.selectedServices.allObjects;
            
            for(Services *selectedServicesObj in serviceSelectedByUser)
            {
                [priceDictionary  setValue:selectedServicesObj.price forKey:selectedServicesObj.name];
                [categoryDictionary  setValue:selectedServicesObj.categoryName forKey:selectedServicesObj.name];
                [productIdDict  setValue:selectedServicesObj.productId forKey:selectedServicesObj.name];
                
                if(!selectedServicesObj.price)
                {
                    isStylistSelected = NO;
                    break;
                }
            }
            
            if(!isStylistSelected)
            {
                [[userRecords objectAtIndex:0]setIsStlistSelected:@"No"];
                [[CoreDataModel sharedCoreDataModel]saveContext];
            }
        }
    }
}

#pragma mark - to modify user data in data base

// if any additional service has been added, add the same service in data base
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

#pragma mark - Additional service selected Method

//if client/user added any new service then modify data and move to Details page
- (void)addtionalServiceSelected
{
    [self modifyPriceData];
    if(![self checkIfStylistSelected])
        return;
    [self setPriceDict];
    //move to details screen
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DetailsViewController *detailView = [aStoryboard instantiateViewControllerWithIdentifier:@"DetailsStoryView"];
    [self.navigationController pushViewController:detailView animated:YES];
}

#pragma mark - to save user data in data base

- (void)saveUserData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(!userAccount.userId)
    {
        return;
    }
    
    NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    NSArray *servicesRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Services" andPredicate:[NSPredicate predicateWithFormat:@"currentUser == %@",[userRecords objectAtIndex:0]] andSortDescriptor:nil forContext:nil];
    
    if(servicesRecords.count>0)
    {
        for(Services *selectedService in servicesRecords)
        {
            if([subCategoryList containsObject:selectedService.name])
            {
                [selectedService setPrice:[NSString stringWithFormat:@"%@",[priceDictionary valueForKey:selectedService.name]]];
                [selectedService setProductId:[NSString stringWithFormat:@"%@",[productIdDict valueForKey:selectedService.name]]];
                [selectedService setCategoryName:[NSString stringWithFormat:@"%@",[categoryDictionary valueForKey:selectedService.name]]];
            }
        }
    }
    
    if(userRecords.count == 1)
    {
        if(isStylistSelected)
        {
            [[userRecords objectAtIndex:0]setSelectedStylistName:selectedStylistName];
            [[userRecords objectAtIndex:0]setIsStlistSelected:@"Yes"];
            [[userRecords objectAtIndex:0]setSelectedStylistTag:selectedStylistId];
        }
        else
        {
            [[userRecords objectAtIndex:0]setIsStlistSelected:@"No"];
        }
        
        [[CoreDataModel sharedCoreDataModel]saveContext];
    }
}

#pragma mark - set price category dictionary for later use

- (void)setPriceDict
{
    StylistDetails *stylistDetails = [StylistDetails sharedInstance];
    stylistDetails.stylistCategoryPriceDict = categoryDictionary;
    stylistDetails.stylistServicePriceDict = priceDictionary;
    stylistDetails.productIdDict = productIdDict;
}

#pragma mark - check if any stylist is selected

- (BOOL)checkIfStylistSelected
{
    // to check if any service selected
    if(!isStylistSelected)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Select Stylist." message:@"Select one stylist to move to next Screen" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    return isStylistSelected;
}

#pragma mark-Swipe Gesture Methods

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if(![self checkIfStylistSelected])
        return;
    [self setPriceDict];
    
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DetailsViewController *detailView = [aStoryboard instantiateViewControllerWithIdentifier:@"DetailsStoryView"];
    [self.navigationController pushViewController:detailView animated:YES];
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self setPriceDict];
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(isexpanded)
        return 6;
    else
        return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isexpanded)
    {
        if(section == 1)
            return subCategoryList.count;
        else if((section == 5) && isSearching)
            return filteredStylistArray.count;
        else if (section == 5)
            return stylistList.count;
        else if ((section == 0) && (isStylistSelected))
            return 2;
        else
            return 1;
    }
    else
    {
        if((section == 3) && isSearching)
            return filteredStylistArray.count;
        else if (section == 3)
            return stylistList.count;
        else
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isexpanded)
    {
        if(indexPath.section == 0)
        {
            UITableViewCell *appointmentStatusViewCell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentStatusView"];
            
            UILabel *lineLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:766];
            UILabel *appointmentLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:750];
            UILabel *stylistLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:701];
            UILabel *stylistNameLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:702];
            UILabel *stylistProfileLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:703];
            
            lineLbl.hidden = NO;
            
            if(indexPath.row == 0)
            {
                appointmentLbl.hidden = NO;
                stylistLbl.hidden = YES;
                stylistNameLbl.hidden = YES;
                stylistProfileLbl.hidden = YES;
            }
            
            else
            {
                appointmentLbl.hidden = YES;
                stylistLbl.hidden = NO;
                stylistNameLbl.hidden = NO;
                stylistNameLbl.text = selectedStylistName;
                stylistProfileLbl.hidden = NO;
            }
            
            return appointmentStatusViewCell;
        }
        
        else if(indexPath.section == 1)
        {
            UITableViewCell *selectedServiceCell = [tableView dequeueReusableCellWithIdentifier:@"SelectedServiceCell"];
            
            UILabel *categoryLbl = (UILabel *)[selectedServiceCell viewWithTag:901];
            UILabel *priceLbl = (UILabel *)[selectedServiceCell viewWithTag:931];
            
            if(self.view.frame.size.width == 320)
            {
                [categoryLbl setFont:[UIFont latoFontOfSize:13]];
            }
            else
            {
                [categoryLbl setFont:[UIFont latoFontOfSize:14]];
            }
            
            categoryLbl.text = [ NSString stringWithFormat:@"%@: %@",[selectedServices objectForKey:[subCategoryList objectAtIndex:indexPath.row]],[subCategoryList objectAtIndex:indexPath.row]];
            
            if(isStylistSelected)
            {
                priceLbl.hidden = NO;
                priceLbl.text = [NSString stringWithFormat:@"$%@",[priceDictionary valueForKey:[subCategoryList objectAtIndex:indexPath.row]]];
            }
            else
            {
                priceLbl.hidden = YES;
            }
            
            return selectedServiceCell;
        }
        
        else if(indexPath.section == 2)
        {
            UITableViewCell *addServiceViewCell = [tableView dequeueReusableCellWithIdentifier:@"AddServiceView"];
            
            UILabel *totalLbl = (UILabel *)[addServiceViewCell viewWithTag:831];
            UILabel *amountLbl = (UILabel *)[addServiceViewCell viewWithTag:832];
            UILabel *lineLbl = (UILabel *)[addServiceViewCell viewWithTag:833];
            UILabel *chooseStylistLbl = (UILabel *)[addServiceViewCell viewWithTag:930];
            UIButton *addServiceButton = (UIButton *)[addServiceViewCell viewWithTag:430];
            
            addServiceButton.layer.borderColor = [[UIColor blackColor]CGColor];
            addServiceButton.layer.borderWidth = 1.0f;
            [addServiceButton addTarget:self action:@selector(goToSelectedStylistProfile) forControlEvents:UIControlEventTouchUpInside];
            
            if(isStylistSelected)
                addServiceButton.hidden = NO;
            else
                addServiceButton.hidden = YES;
            
            if(self.view.frame.size.width == 320)
            {
                [amountLbl setFont:[UIFont latoFontOfSize:13]];
            }
            else
            {
                [amountLbl setFont:[UIFont latoFontOfSize:14]];
            }
            
            if(isStylistSelected)
            {
                amountLbl.text = [NSString stringWithFormat:@"$ %.02f", [self getTotalAmount]];
                totalLbl.hidden = NO;
                amountLbl.hidden = NO;
                chooseStylistLbl.hidden = YES;
                lineLbl.hidden = NO;
            }
            else
            {
                totalLbl.hidden = YES;
                amountLbl.hidden = YES;
                chooseStylistLbl.hidden = NO;
                lineLbl.hidden = YES;
            }
            
            return addServiceViewCell;
        }
        
        else if (indexPath.section == 3)
        {
            UITableViewCell *detailButtonViewCell = [tableView dequeueReusableCellWithIdentifier:@"DetailButtonView"];
            
            // adding action and image to detail button
            UIButton *detailButton = (UIButton *)[detailButtonViewCell viewWithTag:777];
            [detailButton setTitle:@"Tap to Hide Details" forState:UIControlStateNormal];
            [detailButton setImage:[UIImage imageNamed:@"arrow-up-icon"] forState:UIControlStateNormal];
            [detailButton addTarget:self action:@selector(expandCollapseTable) forControlEvents:UIControlEventTouchUpInside];
            
            return detailButtonViewCell;
        }
        
        else if(indexPath.section == 4)
        {
            UITableViewCell *selectStylistViewCell = [tableView dequeueReusableCellWithIdentifier:@"SelectStylistView"];
            
            for(int i = 0; i < 3; i++)
            {
                // providing border to dollar button
                UIButton *searchStylistBtn = (UIButton*)[selectStylistViewCell viewWithTag:336+i];
                if(selectedButtonTag != searchStylistBtn.tag)
                {
                    searchStylistBtn.layer.borderWidth = 1.0f;
                    searchStylistBtn.layer.cornerRadius = 3.0f;
                    searchStylistBtn.layer.borderColor = [[UIColor blackColor]CGColor];
                    [searchStylistBtn setBackgroundColor: [UIColor clearColor]];
                    [searchStylistBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                else
                {
                    searchStylistBtn.layer.borderWidth = 1.0f;
                    searchStylistBtn.layer.cornerRadius = 3.0f;
                    searchStylistBtn.layer.borderColor = [[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
                    [searchStylistBtn setBackgroundColor:DashedLineRGBColor(252, 51, 61)];
                    [searchStylistBtn setTitleColor:DashedLineRGBColor(227, 225, 216) forState:UIControlStateNormal];
                }
                
                [searchStylistBtn addTarget:self action:@selector(searchStylistButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            return selectStylistViewCell;
        }
        
        else
        {
            StylistDetailsTableViewCell *stylistListViewCell = [tableView dequeueReusableCellWithIdentifier:@"StylistListView"];
            StylistDetails *stylistDetailsObj;
            
            if(isSearching)
            {
                stylistDetailsObj = [filteredStylistArray objectAtIndex:indexPath.row];
            }
            
            else
            {
                stylistDetailsObj = [stylistList objectAtIndex:indexPath.row];
            }
                        
            // providing action and tag to profile button
            stylistListViewCell.gotoStylistProfileButton.tag = 1000+indexPath.row;
            [stylistListViewCell.gotoStylistProfileButton addTarget:self action:@selector(goToStylistProfile:) forControlEvents:UIControlEventTouchUpInside];
            
            //assigning Data
            stylistListViewCell.stylistName.text = stylistDetailsObj.stylistName;
            stylistListViewCell.stylistLocation.text = stylistDetailsObj.stylistLocation;
            
            NSArray *firstLoad = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Favourities" andPredicate:[NSPredicate predicateWithFormat:@"stylistId==%@",stylistDetailsObj.stylistId] andSortDescriptor:nil forContext:nil];
            
            if ([firstLoad count]>0)
            {
                for (int i=0; i<[firstLoad count]; i++)
                {
                    if ([[[firstLoad objectAtIndex:i]valueForKey:@"stylistId"] isEqualToString:stylistDetailsObj.stylistId])
                    {
                        [stylistListViewCell.favoritiesImage setBackgroundImage:[UIImage imageNamed:@"FilledHeart.png"] forState:UIControlStateNormal];
                        [stylistListViewCell.favoritiesTransBtn addTarget:self action:@selector(addToFavourites:) forControlEvents:UIControlEventTouchUpInside];
                        [stylistListViewCell.favoritiesImage setTag:indexPath.row];
                    }
                }
            }
            
            else if([firstLoad count] == 0)
            {
                [stylistListViewCell.favoritiesImage setBackgroundImage:[UIImage imageNamed:@"EmptyHeart.png"] forState:UIControlStateNormal];
                [stylistListViewCell.favoritiesTransBtn addTarget:self action:@selector(addToFavourites:) forControlEvents:UIControlEventTouchUpInside];
                [stylistListViewCell.favoritiesTransBtn setTag:indexPath.row];
            }
            
            [stylistListViewCell.stylistImage setImage:[UIImage imageNamed:@"default _stylist_image.png"]];//[UIImage imageNamed:stylistDetailsObj.image];
            stylistListViewCell.stylistExperience.text = [NSString stringWithFormat:@"%@ years experience",stylistDetailsObj.stylistExpereince];
            
            if(stylistListViewCell)
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:stylistListViewCell.stylistImage];
            
            NSURL *url = [NSURL URLWithString:stylistDetailsObj.image]; // working for URL @"http://pngimg.com/upload/rose_PNG637.png"
            stylistListViewCell.stylistImage.imageURL = url;
            
            for(int i = 1000; i < 1005; i++)
            {
                // assigning image to rating button
                UIImageView *ratingStarImageView = (UIImageView *)[stylistListViewCell viewWithTag:i];
                if([stylistDetailsObj.stylistRatings intValue] >= ratingStarImageView.tag)
                {
                    [ratingStarImageView setImage:[UIImage imageNamed:@"black-star-rating-filled-small.png"]];
                }
                else
                {
                    [ratingStarImageView setImage:[UIImage imageNamed:@"black-star-rating-empty-small.png"]];
                }
            }
            
            // setting text for Dollar button
            switch ([stylistDetailsObj.stylistFees intValue])
            {
                case 1:
                    [stylistListViewCell.stylistFees setTitle:@"$"  forState:UIControlStateNormal];
                    break;
                case 2:
                    [stylistListViewCell.stylistFees setTitle:@"$$"  forState:UIControlStateNormal];
                    break;
                case 3:
                    [stylistListViewCell.stylistFees setTitle:@"$$$"  forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
            
            if(isStylistSelected && [stylistDetailsObj.stylistId isEqualToString:selectedStylistId])
            {
                StylistDetails *stylist = [StylistDetails sharedInstance];
                stylist.selectedStylist = stylistDetailsObj;
                
                // to give selected effect/feel, changing border color to red
                stylistListViewCell.layer.borderColor = [[UIColor darkGrayColor]CGColor];
                stylistListViewCell.layer.borderWidth = 2.0f;
                stylistListViewCell.contentView.alpha = 1.0f;
            }
            else if(isStylistSelected)
            {
                stylistListViewCell.layer.borderColor = [[UIColor clearColor]CGColor];
                stylistListViewCell.layer.borderWidth = 2.0f;
                //stylistListViewCell.contentView.alpha = 0.5f;
            }
            else
            {
                stylistListViewCell.layer.borderColor = [[UIColor clearColor]CGColor];
                stylistListViewCell.layer.borderWidth = 2.0f;
                stylistListViewCell.contentView.alpha = 1.0f;
            }
            
            return stylistListViewCell;
        }
    }
    
    else
    {
        if(indexPath.section == 0)
        {
            UITableViewCell *appointmentStatusViewCell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentStatusView"];
            
            UILabel *lineLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:766];
            UILabel *appointmentLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:750];
            UILabel *stylistLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:701];
            UILabel *stylistNameLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:702];
            UILabel *stylistProfileLbl = (UILabel *)[appointmentStatusViewCell viewWithTag:703];
            
            lineLbl.hidden = YES;
            
            if(indexPath.row == 0)
            {
                appointmentLbl.hidden = NO;
                stylistLbl.hidden = YES;
                stylistNameLbl.hidden = YES;
                stylistProfileLbl.hidden = YES;
            }
            
            return appointmentStatusViewCell;
        }
        
        else if (indexPath.section == 1)
        {
            UITableViewCell *detailButtonViewCell = [tableView dequeueReusableCellWithIdentifier:@"DetailButtonView"];
            
            // adding action and image to detail button
            UIButton *detailButton = (UIButton *)[detailButtonViewCell viewWithTag:777];
            [detailButton setTitle:@"Tap to View Details" forState:UIControlStateNormal];
            [detailButton setImage:[UIImage imageNamed:@"arrow-down-icon"] forState:UIControlStateNormal];
            [detailButton addTarget:self action:@selector(expandCollapseTable) forControlEvents:UIControlEventTouchUpInside];
            
            return detailButtonViewCell;
        }
        
        else if(indexPath.section == 2)
        {
            UITableViewCell *selectStylistViewCell = [tableView dequeueReusableCellWithIdentifier:@"SelectStylistView"];
            
            for(int i = 0; i < 3 ; i++)
            {
                // providing border to dollar button
                UIButton *searchStylistBtn = (UIButton*)[selectStylistViewCell viewWithTag:336+i];
                if(selectedButtonTag != searchStylistBtn.tag)
                {
                    searchStylistBtn.layer.borderWidth = 1.0f;
                    searchStylistBtn.layer.cornerRadius = 3.0f;
                    searchStylistBtn.layer.borderColor = [[UIColor blackColor]CGColor];
                    [searchStylistBtn setBackgroundColor: [UIColor clearColor]];
                    [searchStylistBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                else
                {
                    searchStylistBtn.layer.borderWidth = 1.0f;
                    searchStylistBtn.layer.cornerRadius = 3.0f;
                    searchStylistBtn.layer.borderColor = [[UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]CGColor];
                    [searchStylistBtn setBackgroundColor: [UIColor colorWithRed:252/255.0f green:51/255.0f blue:61/255.0f alpha:1]];
                    [searchStylistBtn setTitleColor:[UIColor colorWithRed:227/255.0f green:225/255.0f blue:216/255.0f alpha:1] forState:UIControlStateNormal];
                }
                
                [searchStylistBtn addTarget:self action:@selector(searchStylistButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            return selectStylistViewCell;
        }
        
        else
        {
            StylistDetailsTableViewCell *stylistListViewCell = [tableView dequeueReusableCellWithIdentifier:@"StylistListView"];
            StylistDetails *stylistDetailsObj;
            
            if(isSearching)
            {
                stylistDetailsObj = [filteredStylistArray objectAtIndex:indexPath.row];
            }
            
            else
            {
                stylistDetailsObj = [stylistList objectAtIndex:indexPath.row];
            }
            
            // providing action and tag to profile button
            stylistListViewCell.gotoStylistProfileButton.tag = 1000+indexPath.row;
            [stylistListViewCell.gotoStylistProfileButton addTarget:self action:@selector(goToStylistProfile:) forControlEvents:UIControlEventTouchUpInside];
            
            //assigning Data
            stylistListViewCell.stylistName.text = stylistDetailsObj.stylistName;
            stylistListViewCell.stylistLocation.text = stylistDetailsObj.stylistLocation;
            
            NSArray *firstLoad = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Favourities" andPredicate:[NSPredicate predicateWithFormat:@"stylistId==%@",stylistDetailsObj.stylistId] andSortDescriptor:nil forContext:nil];
            
            if ([firstLoad count]>0)
            {
                for (int i=0; i<[firstLoad count]; i++)
                {
                    if ([[[firstLoad objectAtIndex:i]valueForKey:@"stylistId"] isEqualToString:stylistDetailsObj.stylistId])
                    {
                        [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:i]  withContext:nil];
                        [[CoreDataModel sharedCoreDataModel]saveContext];
                        
                        [stylistListViewCell.favoritiesImage setBackgroundImage:[UIImage imageNamed:@"FilledHeart.png"] forState:UIControlStateNormal];
                        [stylistListViewCell.favoritiesTransBtn addTarget:self action:@selector(addToFavourites:) forControlEvents:UIControlEventTouchUpInside];
                        [stylistListViewCell.favoritiesImage setTag:indexPath.row];
                        
                        Favourities *favourities = (Favourities*)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"Favourities" forContext:nil];
                        favourities.stylistId = stylistDetailsObj.stylistId;
                        favourities.selectedServices = selectedServices;
                        
                        NSMutableArray *responseArray = [[NSMutableArray alloc]init];
                        [responseArray addObject:[[SingletonClass shareManager]stylistList]];
                        
                        for(int i=0; i<[[responseArray objectAtIndex:0] count]; i++)
                        {
                            if([[[[responseArray objectAtIndex:0]valueForKey:@"id"] objectAtIndex:i] isEqualToString:stylistDetailsObj.stylistId])
                            {
                                favourities.stylistInfo = [[responseArray objectAtIndex:0] objectAtIndex:i];
                            }
                        }
                        
                        [[CoreDataModel sharedCoreDataModel]saveContext];
                    }
                }
            }
            
            else if([firstLoad count]==0)
            {
                [stylistListViewCell.favoritiesImage setBackgroundImage:[UIImage imageNamed:@"EmptyHeart.png"] forState:UIControlStateNormal];
                [stylistListViewCell.favoritiesTransBtn addTarget:self action:@selector(addToFavourites:) forControlEvents:UIControlEventTouchUpInside];
                [stylistListViewCell.favoritiesImage setTag:indexPath.row];
            }
            
            [stylistListViewCell.stylistImage setImage:[UIImage imageNamed:@"default _stylist_image.png"]];//[UIImage imageNamed:stylistDetailsObj.image];
            stylistListViewCell.stylistExperience.text = [NSString stringWithFormat:@"%@ years experience",stylistDetailsObj.stylistExpereince];
            
            if(stylistListViewCell)
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:stylistListViewCell.stylistImage];
            
            NSURL *url = [NSURL URLWithString:stylistDetailsObj.image]; // working for URL @"http://pngimg.com/upload/rose_PNG637.png"
            stylistListViewCell.stylistImage.imageURL = url;
            
            for(int i = 1000; i < 1005; i++)
            {
                // assigning image to rating button
                UIImageView *ratingStarImageView = (UIImageView *)[stylistListViewCell viewWithTag:i];
                if([stylistDetailsObj.stylistRatings intValue] >= ratingStarImageView.tag)
                {
                    [ratingStarImageView setImage:[UIImage imageNamed:@"black-star-rating-filled-small.png"]];
                }
                else
                {
                    [ratingStarImageView setImage:[UIImage imageNamed:@"black-star-rating-empty-small.png"]];
                }
            }
            
            // setting text for Dollar button
            switch ([stylistDetailsObj.stylistFees intValue])
            {
                case 1:
                    [stylistListViewCell.stylistFees setTitle:@"$"  forState:UIControlStateNormal];
                    break;
                case 2:
                    [stylistListViewCell.stylistFees setTitle:@"$$"  forState:UIControlStateNormal];
                    break;
                case 3:
                    [stylistListViewCell.stylistFees setTitle:@"$$$"  forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
            
            if(isStylistSelected && [stylistDetailsObj.stylistId isEqualToString:selectedStylistId])
            {
                StylistDetails *stylist = [StylistDetails sharedInstance];
                stylist.selectedStylist = stylistDetailsObj;
                
                stylistListViewCell.layer.borderColor = [[UIColor darkGrayColor]CGColor];
                stylistListViewCell.layer.borderWidth = 2.0f;
                stylistListViewCell.contentView.alpha = 1.0f;
            }
            
            else if(isStylistSelected)
            {
                stylistListViewCell.layer.borderColor = [[UIColor clearColor]CGColor];
                stylistListViewCell.layer.borderWidth = 2.0f;
            }
            
            else
            {
                stylistListViewCell.layer.borderColor = [[UIColor clearColor]CGColor];
                stylistListViewCell.layer.borderWidth = 2.0f;
                stylistListViewCell.contentView.alpha = 1.0f;
            }
            
            return stylistListViewCell;
        }
    }
}

-(void)addToFavourites:(UIButton *)sender
{
    StylistDetails *stylistDetailsObj;
    
    CGPoint center= sender.center;
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.stylistTableView];
    NSIndexPath *indexPath = [self.stylistTableView indexPathForRowAtPoint:rootViewPoint];
    
    StylistDetailsTableViewCell *cell = [self.stylistTableView cellForRowAtIndexPath:indexPath];
    
    if(isSearching)
    {
        stylistDetailsObj = [filteredStylistArray objectAtIndex:indexPath.row];
    }
    
    else
    {
        stylistDetailsObj = [stylistList objectAtIndex:indexPath.row];
    }
    
    if ([[cell.favoritiesImage backgroundImageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"EmptyHeart.png"]])
    {
        Favourities *favourities = (Favourities*)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"Favourities" forContext:nil];
        favourities.stylistId = stylistDetailsObj.stylistId;
        NSMutableArray *selectedStylistObj = [[NSMutableArray alloc]init];
        [selectedStylistObj addObject:[[[StylistDetails sharedInstance]stylistResponseObj] objectAtIndex:sender.tag]];
        favourities.selectedServices = selectedServices;
        NSMutableArray *responseArray = [[NSMutableArray alloc]init];
        [responseArray addObject:[[SingletonClass shareManager]stylistList]];
        
        for(int i=0; i<[[responseArray objectAtIndex:0] count]; i++)
        {
            if([[[[responseArray objectAtIndex:0]valueForKey:@"id"] objectAtIndex:i] isEqualToString:stylistDetailsObj.stylistId])
            {
                favourities.stylistInfo = [[responseArray objectAtIndex:0] objectAtIndex:i];
            }
        }
        
        favourities.isFavourite = @"YES";
        [[CoreDataModel sharedCoreDataModel]saveContext];
        [cell.favoritiesImage setBackgroundImage:[UIImage imageNamed:@"FilledHeart.png"] forState:UIControlStateNormal];
        
    }
    
    else
    {
        [cell.favoritiesImage setBackgroundImage:[UIImage imageNamed:@"EmptyHeart.png"] forState:UIControlStateNormal];
        
        NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Favourities" andPredicate:[NSPredicate predicateWithFormat:@"stylistId==%@",stylistDetailsObj.stylistId] andSortDescriptor:nil forContext:nil];
        
        if([firstLoad count] > 0)
        {
            [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:0]  withContext:nil];
            [[CoreDataModel sharedCoreDataModel]saveContext];
        }
    }
}

// providing height to different sections when the table is expanded and when the table is collapsed
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isexpanded)
    {
        if(indexPath.section == 0)
        {
            return 40;
        }
        
        else if(indexPath.section == 1)
        {
            return 25;
        }
        
        else if(indexPath.section == 2)
        {
            return 32;
        }
        
        else if(indexPath.section == 3)
        {
            return 30;
        }
        
        else if(indexPath.section == 4)
        {
            return 76;
        }
        
        else
        {
            return 100;
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
            return 30;
        }
        
        else if(indexPath.section == 2)
        {
            return 76;
        }
        
        else
        {
            return 100;
        }
    }
}

#pragma mark - Tap to show/hide button action

- (void) expandCollapseTable
{
    if(isexpanded)
    {
        isexpanded = NO;
    }
    else
    {
        isexpanded = YES;
    }
    
    [self.stylistTableView reloadData];
}

#pragma mark - Stylist Selected Action

- (void)stylistSelected:(StylistDetails *)selectedStylist
{
    selectedStylistId = selectedStylist.stylistId;
    isStylistSelected = YES;
    
    StylistDetails *stylist = [StylistDetails sharedInstance];
    stylistDetailObj = selectedStylist;
    stylist.selectedStylist = selectedStylist;
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    userAccount.selectedStylistName = selectedStylist.stylistName;
    selectedStylistName = selectedStylist.stylistName;
    
    for(NSDictionary *serviceDict in selectedStylist.stylistPricingList)
    {
        if([serviceDict valueForKey:@"name"])
        {
            [priceDictionary setValue:[serviceDict valueForKey:@"price"] forKey:[serviceDict valueForKey:@"name"]];
            [categoryDictionary setValue:[serviceDict valueForKey:@"category_name"] forKey:[serviceDict valueForKey:@"name"]];
            [productIdDict setValue:[serviceDict valueForKey:@"product_id"] forKey:[serviceDict valueForKey:@"name"]];
        }
    }
    
    [self saveUserData];
    [self.stylistTableView reloadData];
    //
    if(![self checkIfStylistSelected])
        return;
    [self setPriceDict];
    
    NSArray *firstLoad = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Favourities" andPredicate:[NSPredicate predicateWithFormat:@"stylistId==%@",@"services"] andSortDescriptor:nil forContext:nil];
    
    if([firstLoad count] > 0)
    {
        [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:0] withContext:nil];
        [[CoreDataModel sharedCoreDataModel]saveContext];
    }
    
    //move to details screen
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DetailsViewController *detailView = [aStoryboard instantiateViewControllerWithIdentifier:@"DetailsStoryView"];
    [self.navigationController pushViewController:detailView animated:YES];
}

#pragma mark - searchStylist Bbtton action

- (void)searchStylistButtonTapped:(UIButton*)sender
{
    if(sender.tag == selectedButtonTag)
    {
        isSearching = NO;
        selectedButtonTag = 0;
    }
    else
    {
        [filteredStylistArray removeAllObjects];
        isSearching = YES;
        selectedButtonTag = sender.tag;
        for(StylistDetails *stylistDetailsObj in stylistList)
        {
            if( [stylistDetailsObj.stylistFees intValue] == sender.titleLabel.text.length )
                [filteredStylistArray addObject:stylistDetailsObj];
        }
    }
    
    [self.stylistTableView reloadData];
}

#pragma mark - go to Selected stylist profile

// stylist is already selected, display selected stylist profile
- (void)goToSelectedStylistProfile
{
    if(isStylistSelected)
    {
        StylistDetails *stylist = [StylistDetails sharedInstance];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StylistInfoViewController *stylistInfoViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistInfoSB"];
        stylistInfoViewController.stylistId = selectedStylistId;
        stylistInfoViewController.delegate = self;
        stylistInfoViewController.stylistAC = stylist.selectedStylist;
        [self presentViewController:stylistInfoViewController animated:YES completion:nil];
    }
}

#pragma mark - Go To Stylist Profile button action

// display profile of any stylist
- (void)goToStylistProfile:(UIButton*)sender
{
    /*if(isStylistSelected)
        return;*/
    
    int tag = (int) sender.tag-1000;
    NSString *stylistId = @"";
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StylistInfoViewController *stylistInfoViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistInfoSB"];
    
    if(isSearching)
    {
        stylistId = [[filteredStylistArray objectAtIndex:tag]stylistId];
        stylistInfoViewController.stylistAC = [filteredStylistArray objectAtIndex:tag];
    }
    else
    {
        stylistId = [[stylistList objectAtIndex:tag]stylistId];
        stylistInfoViewController.stylistAC = [stylistList objectAtIndex:tag];
    }
        
    stylistInfoViewController.stylistId = stylistId;
    stylistInfoViewController.delegate = self;
    [self presentViewController:stylistInfoViewController animated:YES completion:nil];
}

#pragma mark - Webservice delegates

- (void)receivedResponse:(id)response
{
    isWebServiceFailed = NO;
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"])
    {
        StylistDetails *stylistAC = [StylistDetails sharedInstance];
        UserAccount *userAccount = [UserAccount sharedInstance];
        stylistList = [NSMutableArray arrayWithArray:stylistAC.stylistList];
        
        if(stylistList.count<=0)
        {
            NSArray *userRecords= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
            
            if(userRecords.count>0)
            {
                isStylistSelected = NO;
                [[userRecords objectAtIndex:0]setIsStlistSelected:@"No"];
                [[CoreDataModel sharedCoreDataModel]saveContext];
            }
            
            self.stylistTableView.hidden = YES;
            self.noStylistsAvailableLbl.hidden = NO;
        }
        
        else if (stylistList.count > 0)
        {
            self.stylistTableView.hidden = NO;
            self.noStylistsAvailableLbl.hidden = YES;
            [self.stylistTableView reloadData];
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
    isWebServiceFailed = YES;
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Unable to process Request." message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

@end
