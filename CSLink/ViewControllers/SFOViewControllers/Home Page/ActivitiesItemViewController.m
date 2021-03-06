//
//  ActivitiesItemViewController.m
//  CSLink
//
//  Created by adamlucas on 5/28/17.
//  Copyright © 2017 eTech. All rights reserved.
//

#import "ActivitiesItemViewController.h"
#import "BaseViewController.h"
#import "ItemTableViewCell.h"
#import "TeacherUser.h"
#import "TeacherConstant.h"

@interface ActivitiesItemViewController ()

@end

@implementation ActivitiesItemViewController
{
    NSMutableArray *arrStudent;
    TeacherUser *userObj;
    UITextField *searchTextField;
    NSMutableArray *arrFilterStud;
    NSMutableArray *arrFilterStudSearch;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[BaseViewController setNavigationBack:self title:[GeneralUtil getLocalizedText:@"TITLE_ACTIVITIES"] titleColor:TEXT_COLOR_LIGHT_CYNA WithSel:@selector(onTouchedBack:)];
	
	[BaseViewController setBackGroud:self];
	userObj = [[TeacherUser alloc] init];
    arrFilterStud = [[NSMutableArray alloc] init];
    arrFilterStudSearch = [[NSMutableArray alloc] init];
    
    searchTextField = [self.searchBar valueForKey:@"_searchField"];
    searchTextField.tag = 8;
    searchTextField.placeholder = [GeneralUtil getLocalizedText:@"TXT_PLC_SEARCH"];
    [BaseViewController getRoundRectTextField:searchTextField withIcon:@"searchIcon.png"];
    searchTextField.font = FONT_16_LIGHT;
    
    [searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
	self.activitiesTableView.delegate = self;
	self.activitiesTableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getStudentList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTouchedBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidChange:(UITextField*)textField
{
	[self updateSearchArray:textField.text];
}

//update seach method where the textfield acts as seach bar
-(void)updateSearchArray:(NSString *)searchTextString
{
    [arrFilterStud removeAllObjects];
    if (searchTextString.length != 0) {
        
        for ( NSDictionary* item in arrFilterStudSearch ) {
            if ([[[item objectForKey:@"student_name"] lowercaseString] rangeOfString:[searchTextString lowercaseString]].location != NSNotFound) {
                [arrFilterStud addObject:item];
            }
        }
    }else{
        arrFilterStud = [arrFilterStudSearch mutableCopy];
    }
    
    [self.activitiesTableView reloadData];
}

#pragma UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//return self.notificationArray.count;
	return arrFilterStud.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (IS_IPAD) {
		return 85;
	}
	else {
		return 70;
	}
	
	return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	
	static NSString *simpleTableIdentifier = @"ItemTableViewCell";
	ItemTableViewCell *cell = (ItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	
	if (cell == nil) {
		NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"ItemTableViewCell" owner:self options:nil];
		cell=[nib objectAtIndex:0];
		cell.backgroundColor = [UIColor clearColor];
		
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	//
	//	NSDictionary *dicStudantDetail = [arrStudant objectAtIndex:indexPath.row];
	//
	//	cell.lblStudantName.text = [dicStudantDetail valueForKey:@"name"];
	//	cell.lblClassName.text = [NSString stringWithFormat:@"%@ %@",[GeneralUtil getLocalizedText:@"LBL_CLS_NAME_TITLE"],[dicStudantDetail valueForKey:@"class_name"]];
	//
	
	//[cell.profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",UPLOAD_URL,[dicStudantDetail valueForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"profile.png"]];
	
	[cell setItemType:ACTIVITIES];
    NSDictionary* oneStudent = [arrFilterStud objectAtIndex:indexPath.row];
    [cell.nameLabel setText:[oneStudent valueForKey:@"student_name"]];
    [cell.classLabel setText:[NSString stringWithFormat:@"(%@)", [oneStudent valueForKey:@"class_name"]]];
    [cell.detailLabel setText:[oneStudent valueForKey:@"activity_name"]];
    
	[BaseViewController setRoudRectImage:cell.profileImageView];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//	[txfSearchField resignFirstResponder];
	//
	//	NSDictionary *dicStudantDetail = [arrStudant objectAtIndex:indexPath.row];
	//
	//	StudantDetailViewController *custompopup = [[StudantDetailViewController alloc] initWithNibName:@"StudantDetailViewController" bundle:nil andDate:dicStudantDetail];
	//	custompopup.delegate = self;
	//	[self presentPopupViewController:custompopup animationType:MJPopupViewAnimationFade];
}
-(void)getStudentList {
    
    [userObj getStudentsInActivity:[GeneralUtil getUserPreference:key_teacherId] :^(NSObject *resObj) {
        
        [GeneralUtil hideProgress];
        
        NSDictionary *dicRes = (NSDictionary *)resObj;
        
        if (dicRes != nil) {
            
            arrStudent = [[NSMutableArray alloc] init];
            NSMutableArray *arrData = (NSMutableArray *)[dicRes valueForKey:@"students"];
            for(NSDictionary* one in arrData)
            {
                if ([one valueForKey:@"sfo_status"] != [NSNull null])
                    [arrStudent addObject:(NSMutableArray*)one];
                
            }
            [arrFilterStudSearch removeAllObjects];
            [arrFilterStud removeAllObjects];

            [arrFilterStudSearch addObjectsFromArray:arrStudent];
            [arrFilterStud addObjectsFromArray:arrFilterStudSearch];
            
            [self.activitiesTableView  reloadData];
        }
        else {
            NSLog(@"Request Fail...");
        }
    }];
}

@end
