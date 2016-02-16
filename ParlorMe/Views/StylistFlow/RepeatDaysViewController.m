//
//  RepeatDaysViewController.m
//  ParlorMe
//

#import "RepeatDaysViewController.h"
#import <LatoFont/UIFont+Lato.h>
#import "Constants.h"
#import "SingletonClass.h"

@interface RepeatDaysViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *weekNamesArray;
    NSMutableArray *checkmarkArray;
    SingletonClass *sharedObj;
}

@property (nonatomic, weak) IBOutlet UITableView *weekNamesTable;
@property (nonatomic) BOOL isChecked;

@end

@implementation RepeatDaysViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = true;
    
    weekNamesArray = [NSMutableArray arrayWithObjects:@"Every Monday",@"Every Tuesday",@"Every Wednesday",@"Every Thursday",@"Every Friday",@"Every Saturday",@"Every Sunday", nil];
    sharedObj = [SingletonClass shareManager];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(sharedObj.tempRepeatedDaysArray != nil)
    {
        //Chosen week names
        checkmarkArray = [[NSMutableArray alloc]initWithArray:sharedObj.tempRepeatedDaysArray];
    }
    
    else
    {
        //Not yet chosen week names
        checkmarkArray = [[NSMutableArray alloc]init];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [sharedObj.tempRepeatedDaysArray removeAllObjects];
    sharedObj.tempRepeatedDaysArray = [[NSMutableArray alloc]initWithArray:checkmarkArray];
}

#pragma mark - Goto Previous Screen
-(IBAction)goBack:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - TableView Delegates and DataSources
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return weekNamesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"weekNamesTableCell";
    UITableViewCell *weekNamesTableCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *lineLbl;
    
    if (weekNamesTableCell == nil)
    {
        weekNamesTableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        weekNamesTableCell.backgroundColor = [UIColor clearColor];
        weekNamesTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for(int i = 0; i <= weekNamesArray.count; i++)
    {
        lineLbl = [[UILabel alloc]init];
        lineLbl.frame = CGRectMake(0, 41, self.view.frame.size.width, 2);
        lineLbl.backgroundColor = [UIColor lightGrayColor];
        lineLbl.alpha = 0.8;
        [weekNamesTableCell.contentView addSubview:lineLbl];
    }
    
    // Show checkmark(s)(if checked) for week name(s) for the selected date
    if (checkmarkArray != nil)
    {
        NSIndexPath *selectedIndexPath = [weekNamesArray objectAtIndex:indexPath.row];
        
        if([checkmarkArray containsObject:selectedIndexPath])
        {
            weekNamesTableCell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-repeat-day-icon small.png"]];
        }
    }
    
    // No checkmark
    else
    {
        weekNamesTableCell.accessoryView = nil;
    }
    
    weekNamesTableCell.textLabel.text = [weekNamesArray objectAtIndex:indexPath.row];
    return weekNamesTableCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.weekNamesTable deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.weekNamesTable cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-repeat-day-icon small.png"]];
    
    NSIndexPath *selectedIndexPath = [weekNamesArray objectAtIndex:indexPath.row];
    
    // Set checkmark for selected week names
    if(![checkmarkArray containsObject:selectedIndexPath])
    {
        [checkmarkArray addObject:selectedIndexPath];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-repeat-day-icon small.png"]];
    }
    
    // Remove checkmark if it is selected
    else if([checkmarkArray containsObject:selectedIndexPath])
    {
        [checkmarkArray removeObject:selectedIndexPath];
        cell.accessoryView = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
