//
//  FavouritiesViewController.m
//  ParlorMe
//

#import "FavouritiesViewController.h"
#import "CoreDataModel.h"
#import "SWRevealViewController.h"
#import "FavouritesTableViewCell.h"
#import "Favourities+CoreDataProperties.h"
#import "StylistInfoViewController.h"
#import "UserAccount.h"
#import "StylistDetails.h"
#import "SingletonClass.h"
#import "DetailsViewController.h"

@interface FavouritiesViewController ()<SetSelectedStylistDelegate, UIAlertViewDelegate>
{
    NSMutableArray *favouritesStylistData;
    NSMutableDictionary *priceDictionary;
    NSMutableDictionary *productIdDict;
    NSMutableDictionary *categoryDictionary;
    StylistDetails *stylistDetailObj;
    NSMutableArray *stylistList;
    NSMutableArray *stylistResponse;
    NSArray *selectedServices;
    NSString *selectedStylistName;
    NSString *selectedStylistId;
    NSMutableArray *subCategoryList;
    NSString *selectedStylistID;
}

@property (weak, nonatomic) IBOutlet UITableView *favouritesTableView;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuBtn;
@property (weak, nonatomic) IBOutlet UILabel *favoritesListLabel;

@end

@implementation FavouritiesViewController

#pragma mark - View Life Cycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self.leftMenuBtn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    stylistDetailObj = [[StylistDetails alloc]init];
    subCategoryList = [[NSMutableArray alloc]init];
    priceDictionary = [[NSMutableDictionary alloc]init];
    productIdDict = [[NSMutableDictionary alloc]init];
    categoryDictionary = [[NSMutableDictionary alloc]init];
    
    [self arrayData];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Fetch Data from CoreData Object
-(void)arrayData
{
    NSMutableArray *favouritesDataArray = [NSMutableArray arrayWithObject:[[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Favourities" andPredicate:nil andSortDescriptor:nil forContext:nil]];
    
    if([[favouritesDataArray objectAtIndex:0]count] > 0)
    {
        stylistList = [[NSMutableArray alloc]init];
        self.favoritesListLabel.hidden = YES;
        self.favouritesTableView.hidden = NO;
        
        stylistResponse = [[NSMutableArray alloc]init];
        favouritesStylistData = [[NSMutableArray alloc]init];
        
        favouritesStylistData = [[favouritesDataArray objectAtIndex:0] valueForKey:@"stylistInfo"];
        stylistResponse = [[favouritesDataArray objectAtIndex:0] valueForKey:@"stylistInfo"];
        
        if(stylistResponse.count > 0)
        {
            for(int i = 0; i < [stylistResponse count]; i++)
            {
                StylistDetails *stylistInfoDetails = [[StylistDetails alloc]init];
                stylistInfoDetails.stylistName = [[stylistResponse objectAtIndex:i]objectForKey:@"name"];
                stylistInfoDetails.stylistId = [[stylistResponse objectAtIndex:i]objectForKey:@"id"];
                stylistInfoDetails.stylistExpereince = [[stylistResponse objectAtIndex:i]objectForKey:@"experience"];
                stylistInfoDetails.stylistBio = [[stylistResponse objectAtIndex:i]objectForKey:@"bio"];
                
                if(!stylistInfoDetails.stylistExpereince || [stylistInfoDetails.stylistExpereince isEqual:[NSNull null]])
                    stylistInfoDetails.stylistExpereince = @"0";
                
                stylistInfoDetails.stylistLocation = [[stylistResponse objectAtIndex:i]objectForKey:@"location"];
                stylistInfoDetails.stylistRatings = [[stylistResponse objectAtIndex:i]objectForKey:@"rating"];
                stylistInfoDetails.stylistFees = [[stylistResponse objectAtIndex:i]objectForKey:@"avg_price"];
                stylistInfoDetails.stylistBio = [[stylistResponse objectAtIndex:i]objectForKey:@"bio"];
                stylistInfoDetails.image = [[stylistResponse objectAtIndex:i]objectForKey:@"photo_url"];
                stylistInfoDetails.stylistPricingList= [[stylistResponse objectAtIndex:i] objectForKey:@"services"];
                
                if(stylistInfoDetails.stylistFees.intValue < 50)
                {
                    stylistInfoDetails.stylistFees = @"1";
                }
                
                else if([stylistInfoDetails.stylistFees intValue] >= 50 && [stylistInfoDetails.stylistFees intValue] < 100)
                {
                    stylistInfoDetails.stylistFees = @"2";
                }
                
                else
                {
                    stylistInfoDetails.stylistFees = @"3";
                }
                
                [stylistList addObject:stylistInfoDetails];
            }
        }
        
        [self.favouritesTableView reloadData];
    }
    
    else if ([[favouritesDataArray objectAtIndex:0]count] == 0)
    {
        self.favoritesListLabel.hidden = NO;
        self.favouritesTableView.hidden = YES;
    }
}

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [favouritesStylistData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavouritesTableViewCell *favouritesListViewCell = [tableView dequeueReusableCellWithIdentifier:@"FavouritesCell"];
    
    favouritesListViewCell.gotoStylistProfileButton.tag = 1000+indexPath.row;
    [favouritesListViewCell.gotoStylistProfileButton addTarget:self action:@selector(goToStylistProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    StylistDetails *stylistDetailsObj;
    stylistDetailsObj = [stylistList objectAtIndex:indexPath.row];
    
    favouritesListViewCell.stylistName.text = stylistDetailsObj.stylistName;
    favouritesListViewCell.stylistLocation.text = stylistDetailsObj.stylistLocation;

    [favouritesListViewCell.stylistImage setImage:[UIImage imageNamed:@"default _stylist_image.png"]];//[UIImage imageNamed:stylistDetailsObj.image];
    favouritesListViewCell.stylistExperience.text = [NSString stringWithFormat:@"%@ years experience",stylistDetailsObj.stylistExpereince];
    
    if(favouritesListViewCell)
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:favouritesListViewCell.stylistImage];
    
    NSURL *url = [NSURL URLWithString:stylistDetailsObj.image]; // working for URL @"http://pngimg.com/upload/rose_PNG637.png"
    favouritesListViewCell.stylistImage.imageURL = url;
    
    for(int i = 1000; i < 1005; i++)
    {
        // assigning image to rating button
        UIImageView *ratingStarImageView = (UIImageView *)[favouritesListViewCell viewWithTag:i];
        if([stylistDetailsObj.stylistRatings intValue] >= ratingStarImageView.tag)
        {
            [ratingStarImageView setImage:[UIImage imageNamed:@"black-star-rating-filled-small.png"]];
        }
        else
        {
            [ratingStarImageView setImage:[UIImage imageNamed:@"black-star-rating-empty-small.png"]];
        }
    }
    
    NSArray *firstLoad = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Favourities" andPredicate:nil andSortDescriptor:nil forContext:nil];
    
    if ([firstLoad count]>0)
    {
        for (int i=0; i<[firstLoad count]; i++)
        {
            if ([[[firstLoad objectAtIndex:i]valueForKey:@"stylistId"] isEqualToString:stylistDetailsObj.stylistId])
            {
                [favouritesListViewCell.favoritiesImage setBackgroundImage:[UIImage imageNamed:@"FilledHeart.png"] forState:UIControlStateNormal];
                [favouritesListViewCell.favoritiesTransBtn addTarget:self action:@selector(deleteFromFavourites:) forControlEvents:UIControlEventTouchUpInside];
                [favouritesListViewCell.favoritiesTransBtn setTag:indexPath.row];
            }
        }
    }
    
    return favouritesListViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - Go To Stylist Profile button action

// display profile of any stylist
- (void)goToStylistProfile:(UIButton*)sender
{
    /*if(isStylistSelected)
     return;*/
    
    int tag = (int) sender.tag-1000;
    NSString *stylistId = @"";
    
    StylistDetails *stylistDetailsObj;
    stylistDetailsObj = [stylistList objectAtIndex:tag];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StylistInfoViewController *stylistInfoViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistInfoSB"];
    
    stylistId = [[stylistList objectAtIndex:tag]stylistId];
    stylistInfoViewController.stylistAC = [stylistList objectAtIndex:tag];
    
    NSMutableArray *stylistServicesList = [NSMutableArray arrayWithObject:[[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Favourities" andPredicate:[NSPredicate predicateWithFormat:@"stylistId == %@ AND isFavourite == %@",stylistId, @"YES"] andSortDescriptor:nil forContext:nil]];
    
    if([[stylistServicesList objectAtIndex:0]count] > 0)
    {
        selectedServices = [[stylistServicesList objectAtIndex:0]valueForKey:@"selectedServices"];
        UserAccount *userAccount = [UserAccount sharedInstance];
        userAccount.selectedServicesList = [selectedServices objectAtIndex:0];
    }
    
    stylistInfoViewController.stylistId = stylistId;
    stylistInfoViewController.delegate = self;
    [self presentViewController:stylistInfoViewController animated:YES completion:nil];
}

#pragma mark - Selected Stylist Profile
- (void)stylistSelected:(StylistDetails *)selectedStylist
{
    selectedStylistId = selectedStylist.stylistId;
    
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
        [[userRecords objectAtIndex:0]setSelectedStylistName:selectedStylistName];
        [[userRecords objectAtIndex:0]setIsStlistSelected:@"Yes"];
        [[userRecords objectAtIndex:0]setSelectedStylistTag:selectedStylistId];
        [[userRecords objectAtIndex:0]setIsStlistSelected:@"No"];
        
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

- (void)addtionalServiceSelected
{
}

#pragma mark - Delete Favourites
-(void)deleteFromFavourites:(UIButton *)sender
{
    StylistDetails *stylistDetailsObj;
    stylistDetailsObj = [stylistList objectAtIndex:sender.tag];
    
    selectedStylistID = stylistDetailsObj.stylistId;
    
    UIAlertView *removeFavouriteAlert = [[UIAlertView alloc]initWithTitle:@"Remove Stylist" message:@"Are you sure you want to remove stylist from favourite" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
    [removeFavouriteAlert show];
}

#pragma mark - UIAlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Favourities" andPredicate:[NSPredicate predicateWithFormat:@"stylistId == %@", selectedStylistID] andSortDescriptor:nil forContext:nil];
        
        if([firstLoad count] > 0)
        {
            [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:0]  withContext:nil];
            [[CoreDataModel sharedCoreDataModel]saveContext];
        }
        
        [self arrayData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
