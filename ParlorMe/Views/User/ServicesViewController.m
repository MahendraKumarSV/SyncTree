//
//  ServicesViewController.m
//  ParlorMe
//

#import "ServicesViewController.h"

#import "PopoverViewController.h"
#import "WebserviceViewController.h"
#import "Utility.h"
#import "UserAccount.h"
#import "ServicesCustomTableViewCell.h"
#import "AsyncImageView.h"
#import "CoreDataModel.h"
#import "Constants.h"
#import "SingletonClass.h"
#import "SWRevealViewController.h"
#import "StylistViewController.h"
#import "StylistAccount.h"
#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ExpandedCategory : NSObject
@property (nonatomic, retain) NSString *selectedCategory;
@property (nonatomic, assign) NSInteger selectedRowCount;
@end

@implementation ExpandedCategory

- (instancetype)init {
    _selectedRowCount = 1;
    _selectedCategory = @"";
    return self;
}

@end

@interface ServicesViewController () <UITableViewDataSource, UITableViewDelegate,UITabBarControllerDelegate, UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate,PopOverDelegate,WebserviceViewControllerDelegate,CLLocationManagerDelegate>
{
    UISwipeGestureRecognizer * swipeleft;
    CGFloat  buttonWidth;
    UIView* coverView;
    int selectedItem;
    BOOL isSectionSelected;
    CGRect popoverFrame;
    NSArray *imagesArray;
    BOOL isPaymentDone;
    NSDictionary *selectedServices;
    NSArray *categoryList;
    NSMutableArray *subCategoryList;
    CLLocationManager *locationManager;
    CLLocation *location;
    NSString *currentAPI;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@property (weak, nonatomic) IBOutlet UITableView *tblviewOptions;

@property (strong, nonatomic) NSMutableArray *expandedSectionsArray;
@property (strong, nonatomic) NSMutableArray *expandedSubCategoryArray;
@property (strong, nonatomic) NSMutableDictionary *expandedSubCategoryDict;
@property (strong, nonatomic) NSMutableArray *categoriesArray;
@property (strong, nonatomic) NSMutableArray *subcategoriesArray;
@property (nonatomic, retain) PopoverViewController *popOverViewController;
@property (nonatomic, retain) UIPopoverController *displayPopoverCntrlr;
@property (weak, nonatomic) IBOutlet UITextField *addressTxtField;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuBtn;

- (IBAction)showPopOver:(UITabBarItem*)sender;
- (IBAction)dismissPopOver;

@end

@implementation ServicesViewController

#pragma mark-view life cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Sections Array which will keep track of expanded and collapsed section
    self.expandedSectionsArray = nil;
    _expandedSectionsArray = [[NSMutableArray alloc] init];
    self.categoriesArray = nil;
    _categoriesArray = [[NSMutableArray alloc] init];
    self.subcategoriesArray = nil;
    _subcategoriesArray = [[NSMutableArray alloc] init];
    self.expandedSubCategoryArray = nil;
    _expandedSubCategoryArray = [[NSMutableArray alloc]init];
    self.expandedSubCategoryDict = nil;
    _expandedSubCategoryDict = [[NSMutableDictionary alloc]init];
    imagesArray = [[NSArray alloc]init];
    // To change placeholder text color to lightgray
    [self.addressTxtField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    isPaymentDone = NO;
    selectedItem = 0;
    isSectionSelected = NO;
    
    for(int counter = 0; counter < 2; counter++)
    {
        UIButton *bottomBarButton = (UIButton*)[self.view viewWithTag:(9090 + counter)];
        bottomBarButton.layer.borderColor = [[UIColor blackColor]CGColor];
        bottomBarButton.layer.borderWidth = 2.0f;
    }
        
    self.addressTxtField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LocationCategoryImage"]];
    self.addressTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.addressTxtField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIView *usernamePaddingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 25)];
    usernamePaddingView.backgroundColor = [UIColor clearColor];
    self.addressTxtField.leftView = usernamePaddingView;
    self.addressTxtField.leftViewMode = UITextFieldViewModeAlways;
    
    //set picode to nil and fetch new from current location
    UserAccount *userAccount = [UserAccount sharedInstance];
    userAccount.userLocationPincode = nil;
    
    if(![Constants isWifiAvailable])
    {
        [self showNetworkError];
    }
    
    else
    {
        [Utility showActivity:self];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        geocoder = [[CLGeocoder alloc] init];
        
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [locationManager performSelector:@selector(requestAlwaysAuthorization) withObject:NULL];
        }
        
        [locationManager startUpdatingLocation];
    }
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    [self.leftMenuBtn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    //add gesture to view
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // adding swipe left gesture
    swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tblviewOptions addGestureRecognizer:swipeleft];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self getUserData];
    
    if(isPaymentDone)
        [self.tabBarController setSelectedIndex:2];
}

#pragma mark - Show Network error

- (void)showNetworkError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NetworkErrMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - CLLocation Manager delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    location = newLocation;
    
    [locationManager stopUpdatingLocation];
    if (location != nil)
    {
        [self getPincodeFromAddress];
    }
    else
        [self getCategoryAndServiceNames];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
    [self getCategoryAndServiceNames];
}

#pragma mark - get Pin code from Address

-(void)getPincodeFromAddress
{
    [locationManager stopUpdatingLocation];
    
    //UserAccount *userAccount = [UserAccount sharedInstance];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        // NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            self.addressTxtField.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                         placemark.subThoroughfare.length > 0 ? placemark.subThoroughfare : @"", placemark.thoroughfare > 0 ? placemark.thoroughfare : @"",
                                         placemark.postalCode.length > 0 ? placemark.postalCode : @"", placemark.locality.length > 0 ? placemark.locality : @"",
                                         placemark.administrativeArea.length > 0 ? placemark.administrativeArea : @"",
                                         placemark.country.length > 0 ? placemark.country : @""];
//            userAccount.userLocationPincode = placemark.postalCode;
        }
        
        else
        {
            //NSLog(@"%@", error.debugDescription);
        }
    }];
    
    [self getCategoryAndServiceNames];
}

- (void)getPincodeFromTypedAddress:(NSString *)address {
    [geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error == nil && [placemarks count] > 0) {
            UserAccount *userAccount = [UserAccount sharedInstance];
            placemark = [placemarks lastObject];
            self.addressTxtField.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                         placemark.subThoroughfare.length > 0 ? placemark.subThoroughfare : @"", placemark.thoroughfare > 0 ? placemark.thoroughfare : @"",
                                         placemark.postalCode.length > 0 ? placemark.postalCode : @"", placemark.locality.length > 0 ? placemark.locality : @"",
                                         placemark.administrativeArea.length > 0 ? placemark.administrativeArea : @"",
                                         placemark.country.length > 0 ? placemark.country : @""];
            userAccount.userLocationPincode = placemark.postalCode;
        }
        
        else
        {
            self.addressTxtField.text = @"";
            //NSLog(@"%@", error.debugDescription);
        }
    }];
}

#pragma mark - check if user exists as guest user

- (void)checkIfGuestUser
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",@"Guest"] andSortDescriptor:nil forContext:nil];
    if( [firstLoad count] == 0)
    {
        [self createGuestUser];
    }
    else
    {
        userAccount.userId = @"Guest";
    }
}

#pragma mark - create guest user

- (void)createGuestUser
{
    User *newUser = (User*)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"User" forContext:nil];
    newUser.userId = @"Guest";
    newUser.password = @"Guest";
    newUser.name = @"Guest";
    newUser.email = @"Guest";
    
    UserAccount *userAccount = [UserAccount sharedInstance];
    userAccount.userId = newUser.userId;
    
    [[CoreDataModel sharedCoreDataModel]saveContext];
}

#pragma mark - delete guest user

- (void)deleteGuestUser
{
    NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@", @"Guest"] andSortDescriptor:nil forContext:nil];
    
    if( [firstLoad count] > 0 )
    {
        [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:0] withContext:nil];
    }
    [[CoreDataModel sharedCoreDataModel]saveContext];
}

#pragma mark - check if some service is selected

- (void)getCategoryAndServiceNames
{
    WebserviceViewController *webserviceViewController = [[WebserviceViewController alloc] init];
    webserviceViewController.delegate = self;
    [webserviceViewController getCategoryNames];
}

#pragma mark - get user data from data base

- (void)getUserData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(!userAccount.userId)
    {
        return;
    }
    
    NSArray *userRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@",userAccount.userId] andSortDescriptor:nil forContext:nil];
    
    if(userRecords.count>0)
    {
        User *currentUser = [userRecords objectAtIndex:0];
        NSArray *serviceSelectedByUser = currentUser.selectedServices.allObjects;
        
        NSArray *mainCategoryList = currentUser.selectedCategories.allObjects;
        
        if(serviceSelectedByUser.count>0)
        {
            [_expandedSubCategoryArray removeAllObjects];
            [_expandedSubCategoryDict removeAllObjects];
            
            for(Services *selectedServiceObj in serviceSelectedByUser)
            {
                [_expandedSubCategoryArray addObject:selectedServiceObj.name];
                [_expandedSubCategoryDict setValue:selectedServiceObj.categoryName forKey:selectedServiceObj.name];
            }
        }
        
        else
        {
            [_expandedSubCategoryArray removeAllObjects];
            [_expandedSubCategoryDict removeAllObjects];
        }
        
        if([currentUser.isPaymentDone isEqualToString:@"Yes"])
            isPaymentDone = YES;
        else
            isPaymentDone = NO;
        
        if(mainCategoryList.count>0)
        {
            [_expandedSectionsArray removeAllObjects];
            for(MainCategories *selectedCategoryObj in mainCategoryList)
            {
                ExpandedCategory *expCategoryObj = [[ExpandedCategory alloc] init];
                expCategoryObj.selectedCategory = selectedCategoryObj.name;
                NSArray *tempSelectedCategoryArray = [_expandedSectionsArray valueForKey:@"selectedCategory"];
                if (![tempSelectedCategoryArray containsObject:selectedCategoryObj.name]) {
                    [_expandedSectionsArray addObject:expCategoryObj];
                }
            }
        }
        
        else
        {
            [_expandedSectionsArray removeAllObjects];
        }
        
        [self.tblviewOptions reloadData];
    }
}

#pragma mark - check if some service is selected

- (BOOL)checkIfServicesSelected
{
    BOOL isServiceSelected = NO;
    
    // to check if any service selected
    if(self.expandedSubCategoryDict.count <= 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Select Service" message:@"Please select at least one service to move to the next screen" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else
    {
        isServiceSelected = YES;
    }
    
    return isServiceSelected;
}

#pragma mark Save user data in data

- (void)saveUserData
{
    UserAccount *userAccount = [UserAccount sharedInstance];
    NSMutableArray *servicesArray = [[NSMutableArray alloc]init];
    NSMutableArray *mainCategoryArray = [[NSMutableArray alloc]init];
    
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
            if([_expandedSubCategoryArray containsObject:selectedService.name])
            {
                
            }
            else
            {
                [[CoreDataModel sharedCoreDataModel]deleteEntityObject:selectedService withContext:nil];
            }
        }
    }
    
    if(userRecords.count == 1)
    {
        if(servicesRecords.count!=_expandedSubCategoryArray.count)
        {
            [[userRecords objectAtIndex:0]setIsStlistSelected:@"No"];
        }
        
        for(NSString *selectedServiceObj in _expandedSubCategoryArray)
        {
            NSArray *selectedServiceRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Services" andPredicate:[NSPredicate predicateWithFormat:@"name == %@ && categoryName == %@ && currentUser == %@ ",selectedServiceObj,[_expandedSubCategoryDict valueForKey:selectedServiceObj],[userRecords objectAtIndex:0]] andSortDescriptor:nil forContext:nil];
            
            if(selectedServiceRecords.count == 1)
            {
                [servicesArray addObject:[selectedServiceRecords objectAtIndex:0]];
            }
            
            else
            {
                Services *selectedService = (Services *)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"Services" forContext:nil];
                [selectedService setName:selectedServiceObj];
                [selectedService setCategoryName:[_expandedSubCategoryDict valueForKey:selectedServiceObj]];
                [selectedService setCurrentUser:[userRecords objectAtIndex:0]];
                [servicesArray addObject:selectedService];
            }
        }
        
        for(ExpandedCategory *categoryObj in _expandedSectionsArray)
        {
            MainCategories *selectedMainCategories = (MainCategories *)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"MainCategories" forContext:nil];
            [selectedMainCategories setName:categoryObj.selectedCategory];
            
            [mainCategoryArray addObject:selectedMainCategories];
        }
        
        [[userRecords objectAtIndex:0]setSelectedCategories:[NSSet setWithArray:mainCategoryArray]];
        [[userRecords objectAtIndex:0]setSelectedServices:[NSSet setWithArray:servicesArray]];
        [[CoreDataModel sharedCoreDataModel]saveContext];
    }
}

#pragma mark-Swipe Gesture Methods

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
   [self findStylistForSelectedServices];
}

#pragma mark FindStylistForSelectedService
- (void)findStylistForSelectedServices
{
    // to check if any service selected
    BOOL isServiceSelected = [self checkIfServicesSelected];
    
    if(isServiceSelected)
    {
        UserAccount *userAccount = [UserAccount sharedInstance];
        //check for user exists, else create a guest user
        if ([[userAccount.userId stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0) {
            [self checkIfGuestUser];
        }
        userAccount.selectedServicesList = self.expandedSubCategoryDict;
        //NSLog(@"selectedServicesList: %@",userAccount.selectedServicesList);
        [self saveUserData];
        
        UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        StylistViewController *stylistView = [aStoryboard instantiateViewControllerWithIdentifier:@"StylistStoryView"];
        [self.navigationController pushViewController:stylistView animated:NO];
    }
}

#pragma mark - TableView Datasources

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_categoriesArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_expandedSectionsArray count] > 0)
    {
        NSArray *sectionarray = [_expandedSectionsArray valueForKey:@"selectedCategory"];
        if ([sectionarray containsObject:[_categoriesArray objectAtIndex:section]])
        {
            if ([[_subcategoriesArray objectAtIndex:section]count] == 0)
                return 0;
            
            else
            {
                for (ExpandedCategory *categoryObj in _expandedSectionsArray)
                {
                    if ([categoryObj.selectedCategory caseInsensitiveCompare:[_categoriesArray objectAtIndex:section]] == NSOrderedSame) {
                        return categoryObj.selectedRowCount;
                    }
                }
            }
        }
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (ExpandedCategory *categoryObj in _expandedSectionsArray)
    {
        if ([categoryObj.selectedCategory caseInsensitiveCompare:[_categoriesArray objectAtIndex:indexPath.section]] == NSOrderedSame && (categoryObj.selectedRowCount - 1) == indexPath.row)
        {
            return 120;
        }
    }
    
    return 60.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServicesCustomTableViewCell *subcategoryCell = [tableView dequeueReusableCellWithIdentifier:@"OptionsSubCategoryCell"];
    
    NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
    
    if ((numberOfRows - 1) == indexPath.row)
    {
        subcategoryCell.findBtn.tag = indexPath.section;
        subcategoryCell.servicesBtn.tag = indexPath.section;
        subcategoryCell.findBtn.hidden = NO;
        CGRect frame = subcategoryCell.findBtn.frame;
        frame.size.height = 0.0f;
        subcategoryCell.findBtn.frame =frame;
        
        subcategoryCell.servicesBtn.hidden = NO;
        CGRect frame1 = subcategoryCell.servicesBtn.frame;
        frame1.size.height = 0.0f;
        subcategoryCell.servicesBtn.frame =frame1;
        
        [subcategoryCell.findBtn addTarget:self action:@selector(findStylistForSelectedServices) forControlEvents:UIControlEventTouchUpInside];
        [subcategoryCell.servicesBtn addTarget:self action:@selector(addServiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if(subcategoryCell.findBtn.tag == 1)
        {
            [subcategoryCell.findBtn setTitle:@"Find A Makeup Artist" forState:UIControlStateNormal];
        }
        
        else
        {
            [subcategoryCell.findBtn setTitle:@"Find A Stylist" forState:UIControlStateNormal];
        }
        
        for (ExpandedCategory *categoryObj in _expandedSectionsArray)
        {
            if ([categoryObj.selectedCategory caseInsensitiveCompare:[_categoriesArray objectAtIndex:indexPath.section]] == NSOrderedSame)
            {
                //check for all services displayed and disable more service button
                NSInteger subCategoriesCount = [[_subcategoriesArray objectAtIndex:indexPath.section] count];
                NSInteger actualRows = subCategoriesCount / 4;
                if ((subCategoriesCount % 4) > 0)
                    actualRows++;
                if (actualRows == categoryObj.selectedRowCount)
                {
                    subcategoryCell.servicesBtn.enabled = NO;
                    [subcategoryCell.servicesBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                }
                
                else
                {
                    subcategoryCell.servicesBtn.enabled = YES;
                    [subcategoryCell.servicesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                
                break;
            }
        }
    }
    
    else
    {
        subcategoryCell.findBtn.hidden = YES;
        subcategoryCell.servicesBtn.hidden = YES;
    }

    // Adding actions to subcategory buttons
    [subcategoryCell.subCategoryBtn1 addTarget:self action:@selector(btnSubCategoryClicked:) forControlEvents:UIControlEventTouchUpInside];
    [subcategoryCell.subCategoryBtn2 addTarget:self action:@selector(btnSubCategoryClicked:) forControlEvents:UIControlEventTouchUpInside];
    [subcategoryCell.subCategoryBtn3 addTarget:self action:@selector(btnSubCategoryClicked:) forControlEvents:UIControlEventTouchUpInside];
    [subcategoryCell.subCategoryBtn4 addTarget:self action:@selector(btnSubCategoryClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // Adding tags to subcategory buttons
    subcategoryCell.subCategoryBtn1.tag = (1 + indexPath.section) * 100 + 1;
    subcategoryCell.subCategoryBtn2.tag = (1 + indexPath.section) * 100 + 2;
    subcategoryCell.subCategoryBtn3.tag = (1 + indexPath.section) * 100 + 3;
    subcategoryCell.subCategoryBtn4.tag = (1 + indexPath.section) * 100 + 4;
    
    subcategoryCell.subCategoryLbl1.tag = (1 + indexPath.section) * 100 + 1;
    subcategoryCell.subCategoryLbl2.tag = (1 + indexPath.section) * 100 + 2;
    subcategoryCell.subCategoryLbl3.tag = (1 + indexPath.section) * 100 + 3;
    subcategoryCell.subCategoryLbl4.tag = (1 + indexPath.section) * 100 + 4;
    
    subcategoryCell.checkCategoryBtn1.tag = (1 + indexPath.section) * 100 + 1;
    subcategoryCell.checkCategoryBtn2.tag = (1 + indexPath.section) * 100 + 2;
    subcategoryCell.checkCategoryBtn3.tag = (1 + indexPath.section) * 100 + 3;
    subcategoryCell.checkCategoryBtn4.tag = (1 + indexPath.section) * 100 + 4;
    
    subcategoryCell.subCategoryBtn1.hidden = NO;
    subcategoryCell.subCategoryBtn2.hidden = NO;
    subcategoryCell.subCategoryBtn3.hidden = NO;
    subcategoryCell.subCategoryBtn4.hidden = NO;
    
    subcategoryCell.subCategoryLbl1.hidden = NO;
    subcategoryCell.subCategoryLbl2.hidden = NO;
    subcategoryCell.subCategoryLbl3.hidden = NO;
    subcategoryCell.subCategoryLbl4.hidden = NO;
    
    subcategoryCell.checkCategoryBtn1.hidden = NO;
    subcategoryCell.checkCategoryBtn2.hidden = NO;
    subcategoryCell.checkCategoryBtn3.hidden = NO;
    subcategoryCell.checkCategoryBtn4.hidden = NO;
    
    // if All 4 buttons contains some text
    if ([[_subcategoriesArray objectAtIndex:indexPath.section] count] / ((indexPath.row + 1) * 4) >= 1)
    {
        subcategoryCell.subCategoryLbl1.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4)];
        subcategoryCell.subCategoryLbl2.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4) + 1];
        subcategoryCell.subCategoryLbl3.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4) + 2];
        subcategoryCell.subCategoryLbl4.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4) + 3];
    }
    // if only 3 buttons contains some text
    else if ([[_subcategoriesArray objectAtIndex:indexPath.section] count] % 4 == 3)
    {
        subcategoryCell.subCategoryLbl1.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4)];
        subcategoryCell.subCategoryLbl2.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4) + 1];
        subcategoryCell.subCategoryLbl3.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4) + 2];
        subcategoryCell.subCategoryLbl4.text = @" ";
        
        subcategoryCell.checkCategoryBtn4.hidden = YES;
        subcategoryCell.subCategoryLbl4.hidden = YES;
        subcategoryCell.subCategoryBtn4.hidden = YES;
    }
    // if only 2 buttons contains some text
    else if ([[_subcategoriesArray objectAtIndex:indexPath.section] count] % 4 == 2)
    {
        subcategoryCell.subCategoryLbl1.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4)];
        subcategoryCell.subCategoryLbl2.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4) + 1];
        subcategoryCell.subCategoryLbl3.text = @" ";
        subcategoryCell.subCategoryLbl4.text = @" ";
        
        subcategoryCell.checkCategoryBtn3.hidden = YES;
        subcategoryCell.subCategoryLbl3.hidden = YES;
        subcategoryCell.subCategoryBtn3.hidden = YES;
        
        subcategoryCell.checkCategoryBtn4.hidden = YES;
        subcategoryCell.subCategoryLbl4.hidden = YES;
        subcategoryCell.subCategoryBtn4.hidden = YES;
    }
    // if only 1 button contains some text
    else
    {
        subcategoryCell.subCategoryLbl1.text = [[_subcategoriesArray objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row * 4)];
        subcategoryCell.subCategoryLbl2.text = @" ";
        subcategoryCell.subCategoryLbl3.text = @" ";
        subcategoryCell.subCategoryLbl4.text = @" ";
        
        subcategoryCell.checkCategoryBtn2.hidden = YES;
        subcategoryCell.subCategoryLbl2.hidden = YES;
        subcategoryCell.subCategoryBtn2.hidden = YES;
        
        subcategoryCell.checkCategoryBtn3.hidden = YES;
        subcategoryCell.subCategoryLbl3.hidden = YES;
        subcategoryCell.subCategoryBtn3.hidden = YES;
        
        subcategoryCell.checkCategoryBtn4.hidden = YES;
        subcategoryCell.subCategoryLbl4.hidden = YES;
        subcategoryCell.subCategoryBtn4.hidden = YES;
    }
    
    // Applying highlighted images if buttons are selected else applying plain images
    if(([_expandedSubCategoryArray containsObject:subcategoryCell.subCategoryLbl1.text])&&(subcategoryCell.subCategoryLbl1.text.length>0))
    {
        [subcategoryCell.checkCategoryBtn1 setBackgroundImage:[UIImage imageNamed:@"CheckServicesImage"] forState:UIControlStateNormal];
    }
    
    else
    {
        [subcategoryCell.checkCategoryBtn1 setBackgroundImage:[UIImage imageNamed:@"UnCheckServicesImage"] forState:UIControlStateNormal];
    }
    
    if(([_expandedSubCategoryArray containsObject:subcategoryCell.subCategoryLbl2.text])&&(subcategoryCell.subCategoryLbl2.text.length>0))
    {
        [subcategoryCell.checkCategoryBtn2 setBackgroundImage:[UIImage imageNamed:@"CheckServicesImage"] forState:UIControlStateNormal];
    }
    
    else
    {
        [subcategoryCell.checkCategoryBtn2 setBackgroundImage:[UIImage imageNamed:@"UnCheckServicesImage"] forState:UIControlStateNormal];
    }
    
    if(([_expandedSubCategoryArray containsObject:subcategoryCell.subCategoryLbl3.text])&&(subcategoryCell.subCategoryLbl3.text.length>0))
    {
        [subcategoryCell.checkCategoryBtn3 setBackgroundImage:[UIImage imageNamed:@"CheckServicesImage"] forState:UIControlStateNormal];
    }
    
    else
    {
        [subcategoryCell.checkCategoryBtn3 setBackgroundImage:[UIImage imageNamed:@"UnCheckServicesImage"] forState:UIControlStateNormal];
    }
    
    if(([_expandedSubCategoryArray containsObject:subcategoryCell.subCategoryLbl4.text])&&(subcategoryCell.subCategoryLbl4.text.length>0))
    {
        [subcategoryCell.checkCategoryBtn4 setBackgroundImage:[UIImage imageNamed:@"CheckServicesImage"] forState:UIControlStateNormal];
    }
    
    else
    {
        [subcategoryCell.checkCategoryBtn4 setBackgroundImage:[UIImage imageNamed:@"UnCheckServicesImage"] forState:UIControlStateNormal];
    }
    
    return subcategoryCell;
}

#pragma mark - tableview delegates

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 120.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"OptionsCategoryCell"];
    
    UIImageView *imageView = [headerCell viewWithTag:2];
    if (section == 0)
    {
        imageView.image = [UIImage imageNamed:@"HairCategoryImage"];
    }
    
    else if (section == 1)
    {
        imageView.image = [UIImage imageNamed:@"MakeUpCategoryImage"];
    }
    
    else if (section == 2)
    {
        imageView.image = [UIImage imageNamed:@"NailsCategoryImage"];
    }
    
    else
    {
        imageView.image = [UIImage imageNamed:@"MenCategoryImage"];
    }
    
    UIButton *categoryBtn = (UIButton*) [headerCell viewWithTag:101];
    UILabel *subCategoryCountLbl = (UILabel*) [headerCell viewWithTag:102];
    UIImageView *expandImgView = (UIImageView*) [headerCell viewWithTag:103];
    UILabel *bottomLineLbl = (UILabel*) [headerCell viewWithTag:104];
    
    if ([[self.expandedSectionsArray valueForKey:@"selectedCategory"] containsObject:[_categoriesArray objectAtIndex:section]])
    {
        expandImgView.hidden = YES;
        bottomLineLbl.backgroundColor = [UIColor grayColor];
    }
    
    else
    {
        expandImgView.hidden = NO;
        //bottomLineLbl.backgroundColor = DashedLineRGBColor(220.0, 168.0, 170.0);
    }
    
    if ([[_subcategoriesArray objectAtIndex:section] count] == 0)
        subCategoryCountLbl.text = @"SERVICES NOT AVAILABLE IN YOUR AREA";
    else
        subCategoryCountLbl.text = [NSString stringWithFormat:@"%lu AVAILABLE SERVICES IN YOUR AREA", (unsigned long)[[_subcategoriesArray objectAtIndex:section] count]];

    categoryBtn.tag = section;
    [categoryBtn addTarget:self action:@selector(btnCategoryClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return headerCell.contentView;
}

- (void)addServiceButtonClicked:(UIButton *)sender
{
    for (ExpandedCategory *categoryObj in _expandedSectionsArray)
    {
        if ([categoryObj.selectedCategory caseInsensitiveCompare:[_categoriesArray objectAtIndex:sender.tag]] == NSOrderedSame)
        {
            categoryObj.selectedRowCount = categoryObj.selectedRowCount + 1;
            break;
        }
    }

    [_tblviewOptions beginUpdates];
    [_tblviewOptions reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tblviewOptions endUpdates];
}

#pragma mark TextField Delegates
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //call service, to bring location based services
    [self getPincodeFromTypedAddress:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark- expand/collapse table methods

-(void)btnSubCategoryClicked: (UIButton*)sender
{
    int tag = (int)sender.tag;
    NSString *categoryName = [_categoriesArray objectAtIndex:(tag/100)-1];
    ServicesCustomTableViewCell *cell = (ServicesCustomTableViewCell *)sender.superview.superview;
    
    UILabel *servicesLbl;
    UIButton *checkBtn;
    if (cell.subCategoryLbl1.tag == tag)
    {
        servicesLbl = cell.subCategoryLbl1;
        checkBtn = cell.checkCategoryBtn1;
    }
    
    else if (cell.subCategoryLbl2.tag == tag)
    {
        servicesLbl = cell.subCategoryLbl2;
        checkBtn = cell.checkCategoryBtn2;
    }
    
    else if (cell.subCategoryLbl3.tag == tag)
    {
        servicesLbl = cell.subCategoryLbl3;
        checkBtn = cell.checkCategoryBtn3;
    }
    
    else
    {
        servicesLbl = cell.subCategoryLbl4;
        checkBtn = cell.checkCategoryBtn4;
    }
    
    // Adding selected service to expanded array and removing unselected service from the expanded array
    if((![servicesLbl.text isEqualToString:@" "])&&([_expandedSubCategoryArray containsObject:servicesLbl.text]))
    {
        [_expandedSubCategoryArray removeObject:servicesLbl.text];
        [_expandedSubCategoryDict removeObjectForKey:servicesLbl.text];
        [checkBtn setBackgroundImage:[UIImage imageNamed:@"UnCheckServicesImage"] forState:UIControlStateNormal];
    }
    
    else if(![servicesLbl.text isEqualToString:@" "])
    {
        [_expandedSubCategoryArray addObject:servicesLbl.text];
        [_expandedSubCategoryDict setValue:categoryName forKey:servicesLbl.text];
        [checkBtn setBackgroundImage:[UIImage imageNamed:@"CheckServicesImage"] forState:UIControlStateNormal];
    }
}

-(void)btnCategoryClicked: (UIButton*)sender
{
    // Checking if category contains any services
    if([[_subcategoriesArray objectAtIndex:sender.tag]count] <= 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Services Present" message:@"Currently there are no services to show in this category" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    // Adding selected category to expanded array and removing unselected category from the expanded array
    if ([[_expandedSectionsArray valueForKey:@"selectedCategory"] containsObject:[_categoriesArray objectAtIndex:sender.tag]])
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selectedCategory == %@", [_categoriesArray objectAtIndex:sender.tag]];
        NSArray *filteredArray = [_expandedSectionsArray filteredArrayUsingPredicate:predicate];
        [_expandedSectionsArray removeObjectsInArray:filteredArray];
    }
    
    else
    {
        //NSIndexPath *indexPath = [self.tblviewOptions indexPathForCell:cell];
        
        ExpandedCategory *expCategoryObj = [[ExpandedCategory alloc] init];
        expCategoryObj.selectedCategory = [_categoriesArray objectAtIndex:sender.tag];
        [_expandedSectionsArray addObject:expCategoryObj];
    }
    
    [_tblviewOptions beginUpdates];
    [_tblviewOptions reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tblviewOptions endUpdates];
}

#pragma mark - Other Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-popover realted methods

// To show popover ( iOS >= 8 )
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"popover"])
    {
        PopoverViewController *pooverViewController= [segue destinationViewController];
        pooverViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        pooverViewController.popoverPresentationController.delegate = self;
        pooverViewController.preferredContentSize = CGSizeMake(300, 124);
        [pooverViewController.goBtn addTarget:self action:@selector(dismissPopOver) forControlEvents:UIControlEventTouchUpInside];
        pooverViewController.popoverPresentationController.sourceRect = popoverFrame;
        pooverViewController.popoverPresentationController.sourceView = self.view;
        pooverViewController.delegate = self;
    }
}

// To show popover ( iOS < 8 )
- (IBAction)showPopOver:(UITabBarItem*)sender
{
    if(! self.popOverViewController)
    {
        self.popOverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverSB"];
        self.popOverViewController.preferredContentSize = CGSizeMake(300,124);
    }
    
    if( !self.displayPopoverCntrlr)
    {
        self.displayPopoverCntrlr = [[UIPopoverController alloc]
                                     initWithContentViewController:self.popOverViewController];
        
        [self.displayPopoverCntrlr setDelegate:self];
    }
    
    [self.popOverViewController.goBtn addTarget:self action:@selector(dismissPopOver) forControlEvents:UIControlEventTouchUpInside];
    self.popOverViewController.preferredContentSize = CGSizeMake(300,124);
    [self.displayPopoverCntrlr presentPopoverFromRect:popoverFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

// To dismiss popover ( iOS >= 8 )
- (IBAction)dismissPopOver
{
    [self.displayPopoverCntrlr dismissPopoverAnimated:YES];
    [coverView removeFromSuperview];
    [self.tabBarController setSelectedIndex:selectedItem];
}

// To dismiss popover ( iOS < 8 )
- (void)dismissPopOverView
{
    [self dismissPopOver];
}

// To check if popover dismissed ( iOS < 8 )
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [coverView removeFromSuperview];
    [self.tabBarController setSelectedIndex:selectedItem];
}

// To give popover feel for iOS >= 8
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

// To check if popover dismissed ( iOS >= 8 )
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    [coverView removeFromSuperview];
    [self.tabBarController setSelectedIndex:selectedItem];
}

#pragma mark - Webservice delegates

- (void)receivedResponse:(id)response
{
    [Utility removeActivityIndicator];
    
    if([response isEqualToString:@"Yes"])
    {
        [_categoriesArray removeAllObjects];
        [_subcategoriesArray removeAllObjects];
        UserAccount *userAC =  [UserAccount sharedInstance];
        [_categoriesArray addObjectsFromArray:userAC.categoryList];
        [_subcategoriesArray addObjectsFromArray:userAC.subCategoryList];
        imagesArray = [NSArray arrayWithArray:userAC.cateroryImages];
        [self.tblviewOptions reloadData];
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Unable to process Request" message:response delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription
{
    
    [_categoriesArray removeAllObjects];
    [_subcategoriesArray removeAllObjects];
    imagesArray = nil;
    
    [self.tblviewOptions reloadData];
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:errorTitle message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Display/dismiss your alert
        [Utility removeActivityIndicator];
        [alert show];
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertTitle isEqualToString:@"Session Expired"])
    {
        //remove user details from local and DB
        NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:nil andSortDescriptor:nil forContext:nil];
        if([firstLoad count] > 0) {
            [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:0] withContext:nil];
        }
        
        [[CoreDataModel sharedCoreDataModel]saveContext];
        [UserAccount removeSharedInstance];
        [StylistAccount removeSharedInstance];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        
        LoginViewController *lvc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginSB"];
        [navController setViewControllers: @[lvc] animated: NO];
        [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
    }
}

@end
