//
//  RootViewController.m
//  The RootViewController directs the entirety of the application. It is the orchestrator of the application
//  DiningTableViewTest
//
//  Created by Ben Johnson on 7/8/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "PolarPoints.h"
#import "CustomTableViewCell.h"
#import "UICustomTableView.h"
#import "DiningParser.h"
#import "DownloadManager.h"
#import "WristWatch.h"
#import "ScheduleDecider.h"
#import "HoursViewController.h"
#import "NavigationBarController.h"
#import "CSGoldController.h"
#import "HallNavigationBar.h"
#import "MealNavigationBar.h"


@implementation RootViewController

@synthesize customTableView, hallScrollView, mealScrollView, alternateScroller, selectedIndexPath, dayDeciderBar;

#pragma mark -
#pragma mark View lifecycle

// Defining Tags used in Implementation
#define hallScroller 1
#define mealScroller 2

// Responsible for setting up the look of Bowdoin Dining
- (void)viewDidLoad {

	[super viewDidLoad];
	
	// Creating the View
	[self.navigationController setNavigationBarHidden:YES animated: NO];
	self.title = @"Main";
     
	// Table View Initiliazation - sets data source and delegate
	customTableView.delegate = self;
	customTableView.dataSource = self;
	customTableView.separatorColor = [UIColor clearColor];
		
    // Meal Decider decides what meal to display
    WristWatch *localWatch = [[WristWatch alloc]init];
	localMealDecider = localWatch;

	// Register for Notifications
    [self registerNotifications];
	
	// Check for New Meal Information
	[self setupMealData];
       
    // Grill View
    [alternateScroller addSubview:grillView];
    [alternateScroller setContentSize:CGSizeMake(320, 600)];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}


// Method to deal with application resumes from multi-tasking or backgrounding.
- (void)becomeActive:(NSNotification *)notification {
    
	NSLog(@"Becoming Active");
	
}


// Handles Downloading or Processing of Already Downloaded Menus
- (void)setupMealData{

	// Initializes the Download Manager to Deal with Meal Data
	DownloadManager *manager = [[DownloadManager alloc] init];
    [manager initializeDownloads];
	
}

//Registering Notifications
- (void)registerNotifications{
    
    // Menu Download Completion
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadCompleted)
												 name:@"Download Completed" object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNoMealNotification)
												 name:@"No Meal Displayed" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(becomeActive:)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
    
}

- (void)showNoMealNotification{
	
	NSLog(@"NO MEAL");
	
}

- (void)setNavigationBarsWithArray:(NSMutableArray*)scheduleArray{
    
    NavigationBarController *navBarController = [[NavigationBarController alloc] initWithScheduleArray:scheduleArray];

    
    // Establishes the navigation bars at the top of the page
	// Top Scroll Bar for Meals
	[mealScrollView setContentSize:CGSizeMake(320 * [navBarController.scheduleArray count], 44)];

	[mealScrollView setTag:mealScroller];
	[mealScrollView setDelegate:self];
	[mealScrollView setOpaque:NO];
	[mealScrollView setShowsHorizontalScrollIndicator:NO];

	MealNavigationBar *navBar = [[MealNavigationBar alloc] initWithArray:scheduleArray];
	
	[mealScrollView addSubview:navBar];
	[mealScrollView setBackgroundColor:[UIColor blackColor]];
	[mealScrollView setPagingEnabled:YES];

    
    
	hallNavBar = [[HallNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 960, 44)];
	hallNavBar.timeToDisplay = @"DEFAULT";
    // Second Scroll Bar for Meals
    [hallScrollView setContentSize:CGSizeMake(960, 44)];

	[hallScrollView setOpaque:NO];

	[hallScrollView setShowsHorizontalScrollIndicator:NO];
	[hallScrollView setTag:hallScroller];
	[hallScrollView setDelegate:self];
	
	[hallScrollView addSubview:hallNavBar];
	[hallScrollView setBackgroundColor:[UIColor whiteColor]];
	[hallScrollView setPagingEnabled:YES];
    
    
}

// Activated when Menus have Downloaded
- (void)downloadCompleted{
    NSLog(@"Download Completed");
    
    // Initializes the Schedule Decider which determines the array of meals
	// that will be displayed
    
	ScheduleDecider *scheduler = [[ScheduleDecider alloc] init];
	[scheduler processArrays];
	
	localScheduler = scheduler;
	
	
    [self setNavigationBarsWithArray:[scheduler returnNavBarArray]]; 
	
	NSLog(@"Reloading Data for Hall:%d, Meal:%d,", currentHallPage, currentMealPage);
    [customTableView reloadData];
    
}

    #define thorne		0
    #define moulton		1

// Logic for deciding the current Menu to display
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	// Filters out UITableView Scroll Events which inherits from UIScrollView
	if ([scrollView isKindOfClass:[UITableView class]]) {
	
		return;
	}
	
	
	
	// Decides the current page of the Hall scroller.	
	CGFloat hallPageWidth = hallScrollView.frame.size.width;
	int hallPage = floor((hallScrollView.contentOffset.x - hallPageWidth / 2) / hallPageWidth) + 1;

	
	CGFloat mealPageWidth = hallScrollView.frame.size.width;
	int mealPage = floor((mealScrollView.contentOffset.x - mealPageWidth / 2) / mealPageWidth) + 1;
	

	
	
    // Decides how to animate and when to animate by comparing the currentPage to the page
    // that should come into view.
	
	if ((currentHallPage != hallPage || currentMealPage != mealPage) && hallPage != 2) {
		
        if (navigationBarsAnimatedOut){
            
            [self animateNavigationBars];
            NSLog(@"Reloading Data for Hall:%d, Meal:%d,", currentHallPage, currentMealPage);
			[customTableView reloadData];
            
            currentHallPage = hallPage;
            currentMealPage = mealPage;
            return;
            
        }
        
		 [UIView beginAnimations:nil context:nil];
		 [UIView setAnimationDuration:0.2];
		 [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
		 [UIView setAnimationDelegate:self]; 
		 [UIView setAnimationDidStopSelector:@selector(tableViewAnimationDone:finished:context:)];
		 customTableView.alpha = 0.0;
		 [UIView commitAnimations];
		 
		 
		currentHallPage = hallPage;
		currentMealPage = mealPage;
        
        
	} else if (currentHallPage != hallPage && hallPage == 2){
        
        
        [self animateNavigationBars];
     
        currentHallPage = hallPage;

    }		
	
}

- (void)animateNavigationBars{
        
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    [UIView setAnimationDelegate:self]; 
   
    // Constants for Navigation Bar Animation
    CGFloat mealScrollWidth = mealScrollView.frame.size.width;
    CGFloat mealScrollHeight = mealScrollView.frame.size.height;
    CGFloat mealScrollOriginY = mealScrollView.frame.origin.y;

    
    CGFloat hallScrollWidth = hallScrollView.frame.size.width;
    CGFloat hallScrollHeight = hallScrollView.frame.size.height;


    CGFloat fillerBarWidth = topFillerBar.frame.size.width;
    CGFloat fillerBarHeight = topFillerBar.frame.size.height;
    CGFloat fillerBarOriginY = topFillerBar.frame.origin.y;
    
    CGFloat altScrollerHeight = alternateScroller.frame.size.height;
    CGFloat altScrollerWidth = alternateScroller.frame.size.width;
    
    
    if (navigationBarsAnimatedOut){
        
        [UIView setAnimationDidStopSelector:@selector(navigationAnimationOut:finished:context:)];

        mealScrollView.frame = CGRectMake(0, 0, mealScrollWidth, mealScrollHeight);
        topFillerBar.frame = CGRectMake(0 , -1, fillerBarWidth, fillerBarHeight);
        hallScrollView.frame = CGRectMake(0 , mealScrollHeight, hallScrollWidth, hallScrollHeight);
        alternateScroller.frame = CGRectMake(0, mealScrollHeight + hallScrollHeight, altScrollerWidth, altScrollerHeight);
               
        
        navigationBarsAnimatedOut = NO;
        [customTableView setAlpha:1.0];
        [alternateScroller setAlpha:0.0];
        [dayDeciderBar setAlpha:0.0];
        
        
        
    } else {
        
        [UIView setAnimationDidStopSelector:@selector(navigationAnimationIn:finished:context:)];

        mealScrollView.frame = CGRectMake(0 , mealScrollOriginY-(mealScrollHeight), mealScrollWidth, mealScrollHeight);
        topFillerBar.frame = CGRectMake(0 , fillerBarOriginY-(fillerBarHeight), fillerBarWidth, fillerBarHeight);
        hallScrollView.frame = CGRectMake(0 , mealScrollHeight, hallScrollWidth, hallScrollHeight);
        alternateScroller.frame = CGRectMake(0, hallScrollHeight + mealScrollHeight, altScrollerWidth, altScrollerHeight);
        
        
        navigationBarsAnimatedOut = YES;
        [customTableView setAlpha:0.0];
        [alternateScroller setAlpha:1.0];
        [dayDeciderBar setAlpha:1.0];

        
    }
    
    [UIView commitAnimations];
    

}

// Method Triggerd at the Stop of an Animation
- (void)navigationAnimationOut{
    
    [customTableView removeFromSuperview];
    [self.view addSubview:dayDeciderView];

    [alternateScroller setAlpha:1.0];
    [alternateScroller setUserInteractionEnabled:YES];
    
}

// Method Triggerd at the Stop of an Animation
- (void)navigationAnimationIn{
    
    [self.view addSubview:customTableView];
    [alternateScroller setUserInteractionEnabled:NO];
    [alternateScroller setAlpha:0.0];
    
}
		 
- (void)tableViewAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
			 
	// reloads the table view		
	[customTableView reloadData];
	
	// animates the tableView back in
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
	[UIView setAnimationDelegate:self]; 
	customTableView.alpha = 1.0;
	[UIView commitAnimations];
			 
			
			 
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	NSLog(@"Number of Sections");

	return [localScheduler numberOfSectionsForLocation:currentHallPage atMealIndex:currentMealPage];

}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"Number of Rows");
	return [localScheduler sizeOfSection:section forLocation:currentHallPage atMealIndex:currentMealPage];
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
    static NSString *CellIdentifier = @"Cell";
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [localScheduler returnItemFromLocation:currentHallPage atMealIndex:currentMealPage atPath:indexPath];
	
	if (cell.isFavorited == YES) {
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];;
	}
	
	// Configures whether a cell is bold or not
	if (indexPath.row != 0) {
		[cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
		cell.textLabel.numberOfLines = 3;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		
	} else {
		[cell.textLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
		
	}

	
    return cell;
}


// Height of Table View Headers
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	
	if (section == 0) {
		return 0.0;
	}
	else {
		return 0.0;
	}

}

// Height of Rows
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{	
	
	if (indexPath.row == 0) {
		return 40.0;
	}
	else {
		
		return [localScheduler returnHeightForCellatLocation:currentHallPage atMealIndex:currentMealPage atPath:indexPath];
		//return [loca returnHeightForCellatLocation:currentHallPage atMealIndex:currentMealPage atPath:indexPath]; //+ (cell.detailTextLabel.numberOfLines - 1) * 19.0;
	}

}


// Method for Setting Background Color
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath	{		
		cell.backgroundColor = [UIColor whiteColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
}
														

#pragma mark -
#pragma mark Table view delegate
// Displays actions for items
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CustomTableViewCell *cell = (CustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSString *itemTitle = cell.textLabel.text;
	NSString *canelButtonTitle = @"Dismiss";
	NSString *removeFavoriteButton = @"Remove This Favorite";
	NSString *favoriteThisItem = @"Favorite This Item";
	NSString *shareThisItem = @"Share This Item";
	
	
	// Need to add in support for not selecting the first item of any section
	// so that "Main Course" can't be selected
	
	if (cell.isFavorited) {

		UIActionSheet *favoriteSheet = [[UIActionSheet alloc] initWithTitle:itemTitle 
																   delegate:self 
														  cancelButtonTitle:canelButtonTitle 
													 destructiveButtonTitle:removeFavoriteButton 
														  otherButtonTitles:shareThisItem, nil];
		[favoriteSheet showInView:self.view];
		

	} else {
				
		UIActionSheet *favoriteSheet = [[UIActionSheet alloc] initWithTitle:itemTitle 
																   delegate:self 
														  cancelButtonTitle:canelButtonTitle 
													 destructiveButtonTitle:nil 
														  otherButtonTitles:favoriteThisItem, shareThisItem, nil];
		[favoriteSheet showInView:self.view];
		
	}

		
	
	selectedIndexPath = indexPath;

	
}


#pragma mark -
#pragma mark Favorite Control
// Method for registering favorite selection
-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	CustomTableViewCell *cell = (CustomTableViewCell *)[customTableView cellForRowAtIndexPath:selectedIndexPath];
	
	// Favoriting Tag
	if (buttonIndex == 0) {
		
		
		if (cell.isFavorited) {
			cell.isFavorited = NO;
		} else {
			cell.isFavorited = YES;
		}

		[customTableView reloadData];
		
		
	}
	else if (buttonIndex == 1) {
		
		
		
	}
	
}

// Method for Sending Email with Item
- (void)composeEmail{
	
	NSString *itemTitle = @"Pancakes"; //cell.textLabel.text;
	NSString *mealTitle = @"Breakfast";
	NSString *hallTitle = @"Thorne";
	
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	[controller setSubject:mealTitle];
	controller.mailComposeDelegate = self;
	// code for creating message body
	NSString *messageBody = [NSString stringWithFormat:@"%@ is at %@ for %@", itemTitle, hallTitle, mealTitle];
	
	[controller setMessageBody:messageBody isHTML:NO];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}
// Generic method for navigating a ScrollView right.
- (void)navigateScrollBarRight:(UIScrollView*)scrollView {
	
	NSLog(@"Navigate Right Method");
	
	// Decides the current page of the Hall scroller.	
	CGFloat hallPageCurrentX = scrollView.contentOffset.x;
	CGFloat hallPageTotalWidth = scrollView.contentSize.width;
	
	if (hallPageCurrentX + 320.0 >= hallPageTotalWidth) {
		// Do Nothing
	} else {
		[scrollView setContentOffset:CGPointMake(hallPageCurrentX + 320.0, 0) animated:YES];
	}
}

// Generic method for navigating a ScrollView left 
- (void)navigateScrollBarLeft:(UIScrollView*)scrollView {
	
	// Decides the current page of the Hall scroller.	
	CGFloat hallPageCurrentX = scrollView.contentOffset.x;
	
	if (hallPageCurrentX - 320.0 < 0) {
		// Do Nothing
	} else {
		[scrollView setContentOffset:CGPointMake(hallPageCurrentX - 320.0, 0) animated:YES];
	}
}

- (IBAction)navigateRight:(id)sender {
    
	if ([sender tag] == 1) {
		[self navigateScrollBarRight:mealScrollView];
	} else {
		[self navigateScrollBarRight:hallScrollView];

	}

    
}

- (IBAction)navigateLeft:(id)sender {
	
	if ([sender tag] == 1) {
		[self navigateScrollBarLeft:mealScrollView];
	} else {
		[self navigateScrollBarLeft:hallScrollView];
		
	}	
}


#pragma mark -
#pragma mark Export Options

- (IBAction)displayActionPage{
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Export" 
															delegate:self 
												   cancelButtonTitle:@"Dismiss"
											  destructiveButtonTitle:nil
												   otherButtonTitles:@"Export to Email", nil];
	
	[actionSheet showInView:self.view];
	
	
	
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

	if (item.tag == 0) {
		
		hallNavBar.timeToDisplay = @"FUN";
		[hallNavBar setNeedsDisplay];

	} else if (item.tag == 1) {
		
		HoursViewController *controller = [[HoursViewController alloc] initWithScheduleDecider:localScheduler];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];	
		
	} else if (item.tag == 2) {

		PolarPoints *polarController = [[PolarPoints alloc] init];
		[self.navigationController pushViewController:polarController animated:YES];
		[polarController release];	
		
	}
	
	
}

- (IBAction)displayPolarPoints{
	
	
}

- (IBAction)displayHoursPage{
	
		
	
	
}	

- (IBAction)changeTime{
	
		
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end

