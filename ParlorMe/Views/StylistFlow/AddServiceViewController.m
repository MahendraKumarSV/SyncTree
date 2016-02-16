//
//  AddServiceViewController.m
//  ParlorMe
//

#import "AddServiceViewController.h"
#import "SingletonClass.h"
#import "Constants.h"
#import "WebserviceViewController.h"
#import "Utility.h"

@interface AddServiceViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, WebserviceViewControllerDelegate>
{
    SingletonClass *sharedObj;
    BOOL tableBool;
    NSMutableArray *fetchServicesList;
    WebserviceViewController *webVC;
    NSString *serviceID;
    NSString *currentAPICalled;
}

@property (nonatomic, weak) IBOutlet UIButton *closeBtn;
@property (nonatomic, weak) IBOutlet UITextField *serviceNameFld;
@property (nonatomic, weak) IBOutlet UIButton *serviceListBtn;
@property (nonatomic, weak) IBOutlet UITableView *servicesListTable;
@property (nonatomic, weak) IBOutlet UITextField *costFld;
@property (nonatomic, weak) IBOutlet UIButton *addServiceBtn;

-(IBAction)servicesListBtnAction:(id)sender;
-(IBAction)addServiceBtnAction:(id)sender;

@end

@implementation AddServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.servicesListTable.hidden = YES;
    
    self.serviceListBtn.layer.borderWidth = 1.0;
    self.serviceListBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.serviceListBtn.layer.cornerRadius = 5;
    
    sharedObj = [SingletonClass shareManager];
    
    tableBool = NO;
    self.servicesListTable.layer.borderWidth = 1.0;
    self.servicesListTable.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //Allocate WebviewController
    webVC = [[WebserviceViewController alloc] init];
    webVC.delegate = self;
    [Utility showActivity:self];
    
    //fetch services list
    currentAPICalled = kFetchServices;
    [webVC getServices];
}

#pragma mark - Close Button Action
-(IBAction)closeBtnAction:(id)sender
{
    self.servicesListTable.hidden = YES;
    [sharedObj setProductAdded:@"NO"];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UITextfield Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Services List Button
-(IBAction)servicesListBtnAction:(id)sender;
{
    self.serviceNameFld.text = @"";
    self.costFld.text = @"";
    
    fetchServicesList = [[NSMutableArray alloc]initWithArray:sharedObj.fetchServicesFromResponse];
    
    if(tableBool == NO)
    {
        self.servicesListTable.hidden = NO;
        [self.servicesListTable reloadData];
        tableBool = YES;
    }
    
    else
    {
        self.servicesListTable.hidden = YES;
        tableBool = NO;
    }
}

#pragma mark - Table Delegates and Datasource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fetchServicesList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *servicesTableCellID = @"servicesListCell";
    
    UITableViewCell *servicesTableCell = [self.servicesListTable dequeueReusableCellWithIdentifier:servicesTableCellID];
    UILabel *serviceNameLabel = (UILabel *)[servicesTableCell viewWithTag:1];
    serviceNameLabel.text = [[fetchServicesList objectAtIndex:indexPath.row]objectForKey:@"name"];
    
    return servicesTableCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"selcted service: %@", [[fetchServicesList objectAtIndex:indexPath.row]objectForKey:@"name"]);
    self.serviceNameFld.text = [[fetchServicesList objectAtIndex:indexPath.row]objectForKey:@"name"];
    serviceID = [[fetchServicesList objectAtIndex:indexPath.row]objectForKey:@"id"];
    tableBool = NO;
    self.servicesListTable.hidden = YES;
}

-(NSIndexPath *)getButtonIndexPath:(UIButton *) btn
{
    CGRect btnFrame = [btn convertRect:btn.bounds toView:self.servicesListTable];
    return [self.servicesListTable indexPathForRowAtPoint:btnFrame.origin];
}

#pragma mark - Add New Service
-(IBAction)addServiceBtnAction:(id)sender
{
    if(self.serviceNameFld.text.length == 0)
    {
        [self failedWithError:@"Service Name" description:@"Service name is mandatory"];
    }
    
    else if (self.serviceNameFld.text.length > 0 && self.costFld.text.length == 0)
    {
        [self failedWithError:@"Service Price" description:@"Price is mandatory"];
    }
    
    else if(self.serviceNameFld.text.length >0 && self.costFld.text.length > 0)
    {
        static NSCharacterSet *charSet = nil;
        if(!charSet) {
            charSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        }
        
        NSRange location = [self.costFld.text rangeOfCharacterFromSet:charSet];
        
        if(location.location == NSNotFound)
        {
            [self.view endEditing:YES];
            //Show Activity Indicator
            [Utility showActivity:self];
            currentAPICalled = kAddProduct;
            //Get Previous Schedules
            [webVC addProduct:serviceID cost:self.costFld.text];
        }
        
        else
        {
            [self failedWithError:@"Invalid Price" description:@"Price should be numeric"];
        }
    }
}

#pragma mark - Handle Response
- (void)receivedResponse:(id)response
{
    [Utility removeActivityIndicator];
    
    if (![currentAPICalled isEqualToString:kFetchServices]) {
        if([response isEqualToString:@"NewProductAdded"])
        {
            [sharedObj setProductAdded:@"YES"];
            [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        }
        else if([response isEqualToString:@"already exists"])
        {
            [sharedObj setProductAdded:@"NO"];
            [self failedWithError:@"Add Service" description:@"Service Already Exists"];
        }
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
