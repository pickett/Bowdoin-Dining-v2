//
//  HoursViewController.m
//  Bowdoin Dining
//
//  Created by Ben Johnson on 8/5/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "HoursViewController.h"
#import "ScheduleDecider.h"
#import "MealSchedule.h"
#import "UICustomTableView.h"

@implementation HoursViewController

@synthesize hoursScheduler, hourSelector, openNowArray, theTableView;

#pragma mark -
#pragma mark View lifecycle

// Required to initialize Hours View Controller
-(id)initWithScheduleDecider:(ScheduleDecider*)decider{

	localScheduler = decider;
	
	return self;
		
}

- (void)viewDidLoad {
    [super viewDidLoad];
		
	self.title = @"Dining Hours";
			
	[self.navigationController setNavigationBarHidden:YES animated:YES];

	theTableView.separatorColor = [UIColor lightGrayColor];
    
}

- (void)viewDidAppear:(BOOL)animated{

	[hourSelector setTitle:[localScheduler currentlySelectedHoursDescription]
				  forState:UIControlStateNormal];
}

- (IBAction)hourSelectorDidChange{
	
	[localScheduler changeDisplayedHourInformation];
	
	[theTableView reloadData];
	
	if ([hourSelector.titleLabel.text isEqualToString:@"Today"]) {
		[hourSelector setTitle:@"Now" forState:UIControlStateNormal];
		
	} else {
		[hourSelector setTitle:@"Today" forState:UIControlStateNormal];
	}

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return [localScheduler returnNumberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [localScheduler returnNumberOfRows:section];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 30.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { 
	UIView* customView = [[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)]autorelease];
	customView.backgroundColor = [UIColor clearColor];
	
	UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:18];
	headerLabel.frame = CGRectMake(10, -5.0, 320.0, 44.0);
	headerLabel.textAlignment = UITextAlignmentLeft;
	headerLabel.text = [localScheduler returnSectionTitleForSection:section];	
	
	[customView addSubview:headerLabel];

	return customView;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{	
	
	return 30.0;

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

	cell.backgroundColor = [UIColor whiteColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.backgroundColor = [UIColor clearColor];

	cell.textLabel.text = [[localScheduler returnDictionaryAtIndex:indexPath] objectForKey:@"meal"];
    [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]]; 
	[cell.textLabel setTextColor:[UIColor blackColor]];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	
	cell.detailTextLabel.text = [[localScheduler returnDictionaryAtIndex:indexPath] objectForKey:@"hours"];	
	
	
	// A simple check to change "Closes at..." notifications to blue color.
	if ([cell.detailTextLabel.text rangeOfString:@"Closes"].location != NSNotFound){
		[cell.detailTextLabel setTextColor:[UIColor blueColor]];
	} else {
		[cell.detailTextLabel setTextColor:[UIColor grayColor]];
	}

    return cell;
}

- (IBAction)backButtonSelected{
	
	[self.navigationController popViewControllerAnimated:YES];
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

