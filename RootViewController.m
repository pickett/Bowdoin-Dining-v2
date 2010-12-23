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
#import "GrillAreaViewController.h"
#import "LineCountViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RootViewController (PrivateMethods)

- (void)animateNavigationBars;
- (IBAction)launchPhone;
- (IBAction)launchGrillMenu;
- (void)setNavigationBarsWithArray:(NSMutableArray*)scheduleArray;

@end

@implementation RootViewController

@synthesize customTableView, hallScrollView, mealScrollView, selectedIndexPath, 
dayDeciderBar, callButton, callText, menuButton, menuText, scheduler;

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
	[customTableView release];
	[hallScrollView release];
	[mealScrollView release];
	[selectedIndexPath release];
	[dayDeciderBar release];
	[callButton release];
	[callText release];
	[menuButton release];
	[menuText release];
	[scheduler release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -
#pragma mark Application State Changes

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
}

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

- (void)becomeActive:(NSNotification *)notification{
	NSLog(@"Did Become Active");
	[self setupMealData];
}


- (void)showNoMealNotification{
	
	if (!mealInformationDownloaded) {
		return;
	}
	
	
	if (noMealAlertView == nil) {
		UIView *noMealView = [[UIView alloc] initWithFrame:CGRectMake(60, 175, 200, 130)];
		noMealView.layer.cornerRadius = 10.0;
		noMealView.backgroundColor = [UIColor blackColor];
	
		noMealAlertView.alpha = 0.0;
		noMealAlertView = noMealView;
		
		
		NSString *alertTitle = @"No Menu";
		NSString *alertSubTitle =  = @"This meal is closed or \n no menu was found";
		

		UILabel *alertText_Title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
		alertText_Title.textAlignment = UITextAlignmentCenter;
		alertText_Title.text = alertTitle;
		alertText_Title.font = [UIFont boldSystemFontOfSize:20.0];
		alertText_Title.textColor = [UIColor whiteColor];
		alertText_Title.backgroundColor = [UIColor clearColor];
		
		
		UILabel *alertText_Subtitile = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 200, 100)];
		alertText_Subtitile.textAlignment = UITextAlignmentCenter;
		alertText_Subtitile.text = alertSubTitle;
		alertText_Subtitile.numberOfLines = 2;
		alertText_Subtitile.font = [UIFont systemFontOfSize:16.0];
		alertText_Subtitile.textColor = [UIColor whiteColor];
		alertText_Subtitile.backgroundColor = [UIColor clearColor];
		
		[noMealAlertView addSubview:alertText_Title];
		[noMealAlertView addSubview:alertText_Subtitile];
	}

	// Flashes Meal Notifcation
	[UIView beginAnimations:nil context:nil];
	[self.view addSubview:noMealAlertView];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:noMealAlertView cache:YES];
	[UIView setAnimationDelegate:self]; 
	noMealAlertView.alpha = 1.0;
	[UIView commitAnimations];
	
}

/*
- (void)showNoInternetNotificaiton{
	
	UIView *noInternetView = [[UIView alloc] initWithFrame:CGRectMake(60, 175, 200, 230)];
	noInternetView.layer.cornerRadius = 10.0;
	noInternetView.backgroundColor = [UIColor blackColor];
	
	
	
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[refreshButton setFrame:CGRectMake(165, 95, 40, 40)];
	[refreshButton setImage:[UIImage imageNamed:@"01-refresh-white.png"] forState:UIControlStateNormal];
	[noInternetView addSubview:refreshButton];		
	
	
	
	UILabel *alertText_Title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
	alertText_Title.textAlignment = UITextAlignmentCenter;
	alertText_Title.text = alertTitle;
	alertText_Title.font = [UIFont boldSystemFontOfSize:20.0];
	alertText_Title.textColor = [UIColor whiteColor];
	alertText_Title.backgroundColor = [UIColor clearColor];
	
	
	UILabel *alertText_Subtitile = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 200, 100)];
	alertText_Subtitile.textAlignment = UITextAlignmentCenter;
	alertText_Subtitile.text = alertSubTitle;
	alertText_Subtitile.numberOfLines = 2;
	alertText_Subtitile.font = [UIFont systemFontOfSize:16.0];
	alertText_Subtitile.textColor = [UIColor whiteColor];
	alertText_Subtitile.backgroundColor = [UIColor clearColor];
	
	
	[noInternetView addSubview:alertText_Title];
	[noInternetView addSubview:alertText_Subtitile];
	[self.view addSubview:noInternetView];
	
}
 */

- (void)hideNoMealAlertView{
	
	if (!mealInformationDownloaded) {
		return;
	}
	
	NSLog(@"Hiding No Meal Notification");

	if (noMealAlertView != nil) {
		
		// Flashes TableView
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:noMealAlertView cache:YES];
		[UIView setAnimationDelegate:self]; 
		noMealAlertView.alpha = 0.0;
		[UIView commitAnimations];
		
	}
		
}

#pragma mark -
#pragma mark View lifecycle

// Navigation Bars
#define hallScroller 1
#define mealScroller 2

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	// Creating the Main View
	[self.navigationController setNavigationBarHidden:YES animated: NO];
	self.title = @"Main";
	
	// Table View Initiliazation - sets data source and delegate
	customTableView.dataSource = self;
	customTableView.delegate = self;
	customTableView.separatorColor = [UIColor clearColor];
	
    // WristWatch is the global timer.
    WristWatch *localWatch = [[WristWatch alloc]init];
	watch = localWatch;
	
    [self registerNotifications];
	[self setupMealData];
	
	// Creates the No Meal Alert View

}


 /**
	Handles Menu Data
 */
- (void)setupMealData{

	// Initializes the Download Manager to Deal with Meal Data
	DownloadManager *manager = [[DownloadManager alloc] init];
    [manager setDelegate:self];
	
	// Successful Download Activates DownloadCompleted method
	[manager initializeDownloads];	
	
}

/**
	Activated by NSNotificationCenter when Menus have Downloaded
 */
- (void)downloadCompleted {
   
	NSLog(@"Download Completed");
	
	// Sets DownloadComplete BOOL
	mealInformationDownloaded = YES;
	
	// Initializes the Schedule Decider which determines the current meals
	ScheduleDecider *decider = [[ScheduleDecider alloc] init];
	self.scheduler = decider; // sets the scheduler
	[scheduler processArrays];
   
	[self setNavigationBarsWithArray:[scheduler returnNavBarArray]];
	
	/*
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"downloadSuccessful"] ) {
		NSLog(@"Reloading TableView Data");
		[customTableView reloadData];

	} else {
		NSLog(@"Showing Internet Notification - Download Failed");
		[self showNoInternetNotificaiton];
	}
	 */
	
	[customTableView reloadData];
	
	
	
}

/**
	Creates a Navigation Bar from an Array of Meals
	@param scheduleArray array generated by Schedule Decider
 */
- (void)setNavigationBarsWithArray:(NSMutableArray*)scheduleArray {
    
	if (scheduleArray == nil) {
		NSLog(@"FUCK Navigation Bar Array");

	}
	
    NavigationBarController *navBarController = [[NavigationBarController alloc] initWithScheduleArray:scheduleArray];
	
    NSLog(@"Setting Navigation Bar Array");
    // Establishes the meal bars at the top of the page

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
	hallNavBar.timeToDisplay = [scheduler hoursOfOperationForHall:0 meal:0];

    [hallScrollView setContentSize:CGSizeMake(960, 44)];
	
	[hallScrollView setOpaque:NO];
	
	[hallScrollView setShowsHorizontalScrollIndicator:NO];
	[hallScrollView setTag:hallScroller];
	[hallScrollView setDelegate:self];
	
	[hallScrollView addSubview:hallNavBar];
	[hallScrollView setBackgroundColor:[UIColor whiteColor]];
	[hallScrollView setPagingEnabled:YES];
    

    
}

    #define thorne		0
    #define moulton		1

/**
	Delegate Method activated when ScrollView scrolls
	@param scrollView the message-sending scrollView
 */

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

- (void)mailComposeController:(MFMailComposeViewController*)controller 
		  didFinishWithResult:(MFMailComposeResult)result 
						error:(NSError*)error {
	
	[self dismissModalViewControllerAnimated:YES];
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

#pragma mark -
#pragma mark Main Page Navigation

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	
	if (item.tag == 0) {
		
		LineCountViewController *lines = [[LineCountViewController alloc] init];
		[self.navigationController pushViewController:lines animated:YES];
		[lines release];
		
		
	} else if (item.tag == 1) {
		
		HoursViewController *controller = [[HoursViewController alloc] initWithScheduleDecider:scheduler];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];	
		
	} else if (item.tag == 2) {
		
		PolarPoints *polarController = [[PolarPoints alloc] init];
		[self.navigationController pushViewController:polarController animated:YES];
		[polarController release];	
		
	}
	
	
}

- (IBAction)launchPhone{
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://2077253888"]];
	
	UIDevice *device = [UIDevice currentDevice];
	if (![device.model isEqualToString:@"iPhone"]){
		NSString *title = @"Jack Magee's Grill";
		NSString *message = @"207-725-3888";
		NSString *cancelButtonTitle = @"Dismiss";
		
		UIAlertView *tempPhoneNumberAlert = [[UIAlertView alloc] initWithTitle:(NSString *)title 
																	   message:(NSString *)message 
																	  delegate: self 
															 cancelButtonTitle:(NSString *)cancelButtonTitle
															 otherButtonTitles: NULL];
		
		[tempPhoneNumberAlert show];
		
	}
	
	
}

- (IBAction)launchGrillMenu{
	
	GrillAreaViewController *grill = [[GrillAreaViewController alloc] init];
	[self.navigationController presentModalViewController:grill animated:YES];
	[grill release];
	
	
}

#pragma mark -
#pragma mark - Navigation Bar Operation

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	NSLog(@"ScrollViewScrolled");
	
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
			
			
			currentHallPage = hallPage;
            currentMealPage = mealPage;
			
			[customTableView reloadData];

          
            return;
            
        }
        
		// Flashes TableView
		 [UIView beginAnimations:nil context:nil];
		 [UIView setAnimationDuration:0.2];
		 [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
		 [UIView setAnimationDelegate:self]; 
		 [UIView setAnimationDidStopSelector:@selector(tableViewAnimationDone:finished:context:)];
		 customTableView.alpha = 0.0;
		 [UIView commitAnimations];
		 
		 

		currentHallPage = hallPage;
		currentMealPage = mealPage;
		
		hallNavBar.timeToDisplay = [scheduler hoursOfOperationForHall:currentHallPage meal:currentMealPage];
		[hallNavBar setNeedsDisplay];
        
        
	} else if (currentHallPage != hallPage && hallPage == 2){
        
        
        [self animateNavigationBars];
     
        currentHallPage = hallPage;
		currentMealPage = mealPage;

		[customTableView reloadData];

		
		hallNavBar.timeToDisplay = [scheduler hoursOfOperationForHall:currentHallPage meal:currentMealPage];
		[hallNavBar setNeedsDisplay];
		
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

- (void)navigateScrollBarLeft:(UIScrollView*)scrollView {
	
	// Decides the current page of the Hall scroller.	
	CGFloat hallPageCurrentX = scrollView.contentOffset.x;
	
	if (hallPageCurrentX - 320.0 < 0) {
		// Do Nothing
	} else {
		[scrollView setContentOffset:CGPointMake(hallPageCurrentX - 320.0, 0) animated:YES];
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
    
 //   CGFloat altScrollerHeight = alternateScroller.frame.size.height;
 //   CGFloat altScrollerWidth = alternateScroller.frame.size.width;
    
    
    if (navigationBarsAnimatedOut){
        
        [UIView setAnimationDidStopSelector:@selector(navigationAnimationOut:finished:context:)];

        mealScrollView.frame = CGRectMake(0, 0, mealScrollWidth, mealScrollHeight);
        topFillerBar.frame = CGRectMake(0 , -1, fillerBarWidth, fillerBarHeight);
        hallScrollView.frame = CGRectMake(0 , mealScrollHeight, hallScrollWidth, hallScrollHeight);
               
        
        navigationBarsAnimatedOut = NO;
        [customTableView setAlpha:1.0];

		// Sets Buttons
		[callButton setAlpha:0.0];
		[callText setAlpha:0.0];
		[menuButton setAlpha:0.0];
		[menuText setAlpha:0.0];
		
		
        [dayDeciderBar setAlpha:0.0];
        
        
        
    } else {
        
        [UIView setAnimationDidStopSelector:@selector(navigationAnimationIn:finished:context:)];

        mealScrollView.frame = CGRectMake(0 , mealScrollOriginY-(mealScrollHeight), mealScrollWidth, mealScrollHeight);
        topFillerBar.frame = CGRectMake(0 , fillerBarOriginY-(fillerBarHeight), fillerBarWidth, fillerBarHeight);
        hallScrollView.frame = CGRectMake(0 , mealScrollHeight, hallScrollWidth, hallScrollHeight);
        
        
        navigationBarsAnimatedOut = YES;
        [customTableView setAlpha:1.0];

		[callButton setAlpha:1.0];
		[callText setAlpha:1.0];
		[menuButton setAlpha:1.0];
		[menuText setAlpha:1.0];
		

        
    }
    
    [UIView commitAnimations];
    

}

- (void)navigationAnimationOut{
    
	[callButton setAlpha:1.0];
	[callButton setUserInteractionEnabled:YES];
	
	[callText setAlpha:1.0];
	[menuText setAlpha:1.0];

	[menuButton setAlpha:1.0];
	[menuButton setUserInteractionEnabled:YES];

    
}

- (void)navigationAnimationIn{
    [callButton setAlpha:0.0];
	[callButton setUserInteractionEnabled:NO];
	
	[callText setAlpha:0.0];
	[menuText setAlpha:0.0];
	
	[menuButton setAlpha:0.0];
	[menuButton setUserInteractionEnabled:NO];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	
	NSInteger *numberOfSections = [scheduler numberOfSectionsForLocation:currentHallPage atMealIndex:currentMealPage];
	
	NSLog(@"Number of Sections = %d", numberOfSections);

	
	if (numberOfSections == 1 || numberOfSections == nil) {
		[self showNoMealNotification];
	}
	
	else {
		[self hideNoMealAlertView];
	}
	
	return numberOfSections;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"Rows = %d", [scheduler sizeOfSection:section forLocation:currentHallPage atMealIndex:currentMealPage] );

	return [scheduler sizeOfSection:section forLocation:currentHallPage atMealIndex:currentMealPage];
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
    static NSString *CellIdentifier = @"Cell";
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [scheduler returnItemFromLocation:currentHallPage atMealIndex:currentMealPage atPath:indexPath];
	
	if (cell.isFavorited == YES) {
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];;
	}
	
	// Configures whether a cell is bold or not
	if (indexPath.row != 0) {
		[cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
		cell.textLabel.numberOfLines = 10;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		
	} else{
		[cell.textLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
		
	}

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	
	if (section == 0) {
		return 0.0;
	}
	else {
		return 0.0;
	}

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{	
	
	if (indexPath.row == 0) {
		return 40.0;
	}
	else {
		
		return [scheduler returnHeightForCellatLocation:currentHallPage atMealIndex:currentMealPage atPath:indexPath];
	}

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath	{		
		cell.backgroundColor = [UIColor whiteColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
}
														
#pragma mark -
#pragma mark Table view delegate
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

@end

