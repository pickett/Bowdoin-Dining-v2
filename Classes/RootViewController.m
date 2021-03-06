//
//  RootViewController.m
//  The RootViewController directs the entirety of the application. It is the orchestrator of the application
//  Bowdoin Dining
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
#import "CSGoldController.h"
#import "HallNavigationBar.h"
#import "MealNavigationBar.h"
#import "GrillAreaViewController.h"
#import "LineCountViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AlertViews.h"
#import "FavoriteItem.h"

@interface RootViewController (PrivateMethods)

- (void)animateNavigationBars;
- (void)loadContent;
- (void)cleanupAlertViews;
- (void)navigateScrollBarRight:(UIScrollView*)scrollView;
- (void)navigateScrollBarLeft:(UIScrollView*)scrollView;
- (IBAction)launchPhone;
- (IBAction)launchGrillMenu;
- (void)setNavigationBarsWithArray:(NSMutableArray*)scheduleArray;

@end

@implementation RootViewController

@synthesize managedObjectContext;

@synthesize customTableView, hallScrollView, mealScrollView, selectedIndexPath, 
dayDeciderBar, callButton, callText, menuButton, menuText, scheduler, grillAccessoryView, mealLeftButton, mealRightButton, hallLeftButton, hallRightButton;

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
	[managedObjectContext release];
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadSucceeded)
												 name:@"Download Completed" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noInternetConnection)
												 name:@"No Internet Connection" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noBowdoinConnection)
												 name:@"No Bowdoin Connection" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noMenusAvailable)
												 name:@"No Menus Available" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(becomeActive:)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
    
}

- (void)becomeActive:(NSNotification *)notification{
	NSLog(@"Application Became Active");
	[self cleanupAlertViews];
	[self setupMealData];

}

- (void)showLocalAlertView{
	
	if (contentReady) {
		
		if (localAlertView == nil) {
			localAlertView = [AlertViews noMealAlert];
		}
		// Flashes Meal Notifcation
		[UIView beginAnimations:nil context:nil];
		[self.view addSubview:localAlertView];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:localAlertView cache:YES];
		[UIView setAnimationDelegate:self]; 
		localAlertView.alpha = 1.0;
		[UIView commitAnimations];
		
		NSLog(@"-- Local Alert View Displayed");
	}
	
}

- (void)hideLocalAlertView{
		
	if (localAlertView != nil) {
		
		// Flashes TableView
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:localAlertView cache:YES];
		[UIView setAnimationDelegate:self]; 
		localAlertView.alpha = 0.0;
		[UIView commitAnimations];
		
		NSLog(@"-- Local Alert View Hidden.");
		
	}
}

- (void)showGlobalAlertView{
	
	if (contentReady) {
		
		if (globalAlertView == nil) {
			globalAlertView = [AlertViews noInternetAlert];
		}
		// Flashes Meal Notifcation
		[UIView beginAnimations:nil context:nil];
		[self.view addSubview:globalAlertView];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:globalAlertView cache:YES];
		[UIView setAnimationDelegate:self]; 
		globalAlertView.alpha = 1.0;
		[UIView commitAnimations];
		
		NSLog(@"-- Global Alert View Displayed");
	}
	
	
	
	
}

- (void)hideGlobalAlertView{
	
	NSLog(@"Trying to hide global alert view");
	
	if (globalAlertView != nil) {
		
		// Flashes TableView
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:globalAlertView cache:YES];
		[UIView setAnimationDelegate:self]; 
		globalAlertView.alpha = 0.0;
		[UIView commitAnimations];
		
		NSLog(@"-- GLobal Alert View Hidden.");
		
	}
}

#pragma mark -
#pragma mark View lifecycle

// Navigation Bars
#define hallScroller 1
#define mealScroller 2

// MBProgressHUD delegate method
- (void)hudWasHidden{
	
	NSLog(@"HUD was hidden method triggered in RootView");
	
	/*if (downloadSucceeded) {
		localAlertView = [AlertViews noMealAlert];
		[self cleanupAlertViews];
		[self loadContent];
	} else {
		localAlertView = [AlertViews closedForSemesterAlert];
		[self loadContent];
	} */

}
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

- (void)viewDidAppear:(BOOL)animated{

	//[self stressTest];

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

- (void)cleanupAlertViews{
	
	[self hideLocalAlertView];
	[self hideGlobalAlertView];
	localAlertView = nil;
	globalAlertView = nil;
	
}

- (void)stressTest{
	
	//downloadSucceeded = YES;
	
	int currentDay = [watch getDay];
	int currentYear = [watch getYear];
	int currentWeek = [watch getWeekofYear];
	int currentMonth = [watch getMonth];
	// loop
	
	// Day Loop
	for (int weekday = 6; weekday <= 7; weekday++) {
		for (int hour = 20; hour < 24; hour++) {
			// increments by 5 minutes
			for (int minute = 0; minute < 60; minute += 5) {
				
				NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
				
				NSDateComponents *components = [[NSDateComponents alloc] init];
				
				[components setYear:currentYear];
				[components setDay:currentDay + weekday];
				[components setHour:hour];
				[components setMinute:minute];
				//[components setMonth:currentMonth];

				
				
				NSDate *result = [gregorian dateFromComponents:components];
				
				NSLog(@"Testing ----------------------");
				NSLog(@"WeekDay %d  Hour %d  Minute %d", weekday, hour, minute);
				
				ScheduleDecider *decider = [[ScheduleDecider alloc] init];
				self.scheduler = decider;
				
				[scheduler stressTestForDate:result day:weekday week:currentWeek];
				[self setNavigationBarsWithArray:[scheduler returnNavBarArray]];
				contentReady = YES;
			///	[self iterateArraysForMeals:[[scheduler returnNavBarArray] count]];
				

			}
		}
	}
		
}

- (void)iterateArraysForMeals:(int)numberOfMeals{
	
	[customTableView reloadData];

	NSLog(@"Checking Meals: %d", numberOfMeals);
	
	for (int meal = 1; meal <= numberOfMeals; meal++) {
		
		NSLog(@"Meal = %d", meal);
		
		for (int hall = 1; hall <= 2; hall ++) {
			
			NSLog(@"Hall = %d", hall);

			currentMealPage = meal;
			currentHallPage = hall;
			
			[customTableView reloadData];
			sleep(5);

		}
		
	}
	
	
	
	
	
	
	
	
}

/**
	Activated by NSNotificationCenter during normal download
 */
- (void)loadContent {
   	
	// Initializes the Schedule Decider if the scheduler does not exist
	// or the scheduler is out of date
	
	ScheduleDecider *decider = [[ScheduleDecider alloc] init];
	self.scheduler = decider;
	
	scheduler.managedObjectContext = self.managedObjectContext;
	
	[scheduler processArrays];
	[self setNavigationBarsWithArray:[scheduler returnNavBarArray]];
	
	
	contentReady = YES;
	[customTableView reloadData];
	
}

- (void)downloadSucceeded {
	
	
	downloadSucceeded = YES;
	localAlertView = [AlertViews noMealAlert];
	[self cleanupAlertViews];
	[self loadContent];
	
}

// No Internet Connectivity
- (void)noInternetConnection{
	
	globalAlertView = [AlertViews noInternetAlert];
	
	[self loadContent];
	[self showGlobalAlertView];
	
}

// Bowdoin Servers Down
- (void)noBowdoinConnection{
	
	globalAlertView = [AlertViews noServerAlert];
	
	[self loadContent];
	[self showGlobalAlertView];

}

// No Menus Available - Closed for Semester Break
- (void)noMenusAvailable{
	
	downloadSucceeded = NO;
	localAlertView = [AlertViews closedForSemesterAlert];
	[self loadContent];
		
}

/**
	Creates a Navigation Bar from an Array of Meals
	@param scheduleArray array generated by Schedule Decider
 */
- (void)setNavigationBarsWithArray:(NSMutableArray*)scheduleArray {
    
	
   // NavigationBarController *navBarController = [[NavigationBarController alloc] initWithScheduleArray:scheduleArray];
	
    // Establishes the meal bars at the top of the page

	[mealScrollView setContentSize:CGSizeMake(320 * [scheduleArray count], 44)];
	
	[mealScrollView setTag:mealScroller];
	[mealScrollView setDelegate:self];
	[mealScrollView setOpaque:NO];
	[mealScrollView setShowsHorizontalScrollIndicator:NO];
	
	mealNavBar = [[MealNavigationBar alloc] initWithArray:scheduleArray];
	
	[mealScrollView addSubview:mealNavBar];
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
	
	[actionSheet release];
	
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

	
	// Filters out UITableView Scroll Events which inherits from UIScrollView
	if ([scrollView isKindOfClass:[UITableView class]]) { return; }
	
	
	// Decides the current page of the Hall scroller.	
	CGFloat hallPageWidth = hallScrollView.frame.size.width;
	int hallPage = floor((hallScrollView.contentOffset.x - hallPageWidth / 2) / hallPageWidth) + 1;

	CGFloat mealPageWidth = mealScrollView.frame.size.width;
	int mealPage = floor((mealScrollView.contentOffset.x - mealPageWidth / 2) / mealPageWidth) + 1;
	
	// Filters out scroll events when no animation or change is necessary
	if (currentHallPage == hallPage && currentMealPage == mealPage) { return ; }

	
	if (hallPage != 2) {
		
        if (navigationBarsAnimatedOut){
            
            [self animateNavigationBars];
			
			currentHallPage = hallPage;
            currentMealPage = mealPage;
			
			hallNavBar.timeToDisplay = [scheduler hoursOfOperationForHall:currentHallPage meal:currentMealPage];
			[hallNavBar setNeedsDisplay];
			
        } else {
			
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
			
		}
        
	} else {
        
		[self animateNavigationBars];
     
		
		currentHallPage = hallPage;
		currentMealPage = mealPage;
						
		[hallNavBar setNeedsDisplay];
		
	}
       
		
}		

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
	
	NSLog(@"Scrolling Animation Over");
	navigatingRight = NO;
	navigatingLeft = NO;
	
	
}

- (IBAction)navigateRight:(id)sender {
	
	NSLog(@"Navigating Right Method. Currently Activated: %d", navigatingRight);
	
	if (navigatingRight == YES) {
		
		return;
	}
	
	navigatingRight = YES;

	
	if ([sender tag] == 1) {
		NSLog(@"Navigate Right Button Activated for Meal");
		[self navigateScrollBarRight:mealScrollView];
	} else {
		NSLog(@"Navigate Right Button Activated for Hall");
		[self navigateScrollBarRight:hallScrollView];
		
	}
	
    
}

- (IBAction)navigateLeft:(id)sender {
	
	NSLog(@"Navigating Left Method. Currently Activated: %d", navigatingLeft);

	if (navigatingLeft == YES) {
		return;
	}
	
	navigatingLeft = YES;
	
	
	if ([sender tag] == 1) {
		NSLog(@"Navigate Left Button Activated for Meal");
		[self navigateScrollBarLeft:mealScrollView];
	} else {
		NSLog(@"Navigate Left Button Activated for Hall");
		[self navigateScrollBarLeft:hallScrollView];
	}	
}

- (void)navigateScrollBarRight:(UIScrollView*)scrollView {
		
	NSLog(@"Scrolling Right");

	// Decides the current page of the Hall scroller.	
	CGFloat hallPageCurrentX = scrollView.contentOffset.x;
	CGFloat hallPageTotalWidth = scrollView.contentSize.width;
	
	CGFloat currentPage = hallPageCurrentX / 320.f;
	CGFloat totalPages = hallPageTotalWidth / 320.f;

	// Rounds Down
	int page = currentPage;
	int total = totalPages;
	
	NSLog(@"Current Page = %d", page);
	
	if (page == total - 1) {
		
		navigatingRight = NO;
		
	} else {
		
		CGFloat dispatchPage = (page * 320.0) + 320.0;
		[scrollView setContentOffset:CGPointMake(dispatchPage, 0) animated:YES];
		NSLog(@"Dispatching Scroller to : %f", dispatchPage);	
	}
		
}

- (void)navigateScrollBarLeft:(UIScrollView*)scrollView {
	
	NSLog(@"Scrolling Left");
	
	// Decides the current page of the Hall scroller.	
	CGFloat hallPageCurrentX = scrollView.contentOffset.x;
	//CGFloat hallPageTotalWidth = scrollView.contentSize.width;

	CGFloat currentPage = hallPageCurrentX / 320.f;
	//CGFloat totalPages = hallPageTotalWidth / 320.f;
	
	// Rounds Down
	int page = currentPage;
	
	NSLog(@"Current Page = %d", page);

	
	if (page == 0) {
		
		navigatingLeft = NO;
		
	} else {
		
		CGFloat dispatchPage = (page * 320.0) - 320.0;
		[scrollView setContentOffset:CGPointMake(dispatchPage, 0) animated:YES];
		NSLog(@"Dispatching Scroller to : %f", dispatchPage);
		
	}

}

- (void)animateNavigationBars{
        
	if (animating) { return; } else { animating = YES; }
	
	NSLog(@"Animation Method Excecuting");

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

	CGFloat mealLeftWidth = mealLeftButton.frame.size.width;
    CGFloat mealLeftHeight = mealLeftButton.frame.size.height;
	CGFloat mealLeftOriginX = mealLeftButton.frame.origin.x;
    CGFloat mealLeftOriginY = mealLeftButton.frame.origin.y;
	
	CGFloat mealRightWidth = mealRightButton.frame.size.width;
    CGFloat mealRightHeight = mealRightButton.frame.size.height;
	CGFloat mealRightOriginX = mealRightButton.frame.origin.x;
    CGFloat mealRightOriginY = mealRightButton.frame.origin.y;
	
	CGFloat hallLeftWidth = hallLeftButton.frame.size.width;
    CGFloat hallLeftHeight = hallLeftButton.frame.size.height;
	CGFloat hallLeftOriginX = hallLeftButton.frame.origin.x;
    CGFloat hallLeftOriginY = hallLeftButton.frame.origin.y;
	
	CGFloat hallRightWidth = hallRightButton.frame.size.width;
    CGFloat hallRightHeight = hallRightButton.frame.size.height;
	CGFloat hallRightOriginX = hallRightButton.frame.origin.x;
    CGFloat hallRightOriginY = hallRightButton.frame.origin.y;
	
	CGFloat tableViewWidth = customTableView.frame.size.width;
	CGFloat tableViewHeight = customTableView.frame.size.height;	

	CGFloat accessoryViewWidth = grillAccessoryView.frame.size.width;
	CGFloat accessoryViewHeight = grillAccessoryView.frame.size.height;
	CGFloat accessoryViewOriginY = grillAccessoryView.frame.origin.y;
	CGFloat accessoryViewOriginX = grillAccessoryView.frame.origin.x;

    
    if (navigationBarsAnimatedOut){
        
		[UIView setAnimationDidStopSelector:@selector(tableViewAnimationDone:finished:context:)];

        mealScrollView.frame = CGRectMake(0, 0, mealScrollWidth, mealScrollHeight);
        hallScrollView.frame = CGRectMake(0 , mealScrollHeight, hallScrollWidth, hallScrollHeight);
		
		customTableView.frame = CGRectMake(0, mealScrollHeight + hallScrollHeight, tableViewWidth, tableViewHeight);
	
		
		// Buttons
		mealLeftButton.frame = CGRectMake(mealLeftOriginX, mealLeftOriginY + mealScrollHeight, mealLeftWidth, mealLeftHeight);
		mealRightButton.frame = CGRectMake(mealRightOriginX, mealRightOriginY + mealScrollHeight, mealRightWidth, mealRightHeight);
		hallLeftButton.frame = CGRectMake(hallLeftOriginX, hallLeftOriginY + mealScrollHeight, hallLeftWidth, hallLeftHeight);		
		hallRightButton.frame = CGRectMake(hallRightOriginX, hallRightOriginY + mealScrollHeight, hallRightWidth, hallRightHeight);		
		
		
		grillAccessoryView.frame = CGRectMake(accessoryViewOriginX, accessoryViewOriginY + accessoryViewHeight, accessoryViewWidth , accessoryViewHeight);
		
        navigationBarsAnimatedOut = NO;
        [customTableView setAlpha:0.0];

		// Sets Buttons
		[callButton setAlpha:0.0];
		[callText setAlpha:0.0];
		[menuButton setAlpha:0.0];
		[menuText setAlpha:0.0];
		[grillAccessoryView setAlpha:0.0];
		
        [dayDeciderBar setAlpha:0.0];
        
        
        
    } else {
        
        [UIView setAnimationDidStopSelector:@selector(tableViewAnimationDone:finished:context:)];

        mealScrollView.frame = CGRectMake(0 , mealScrollOriginY-(mealScrollHeight), mealScrollWidth, mealScrollHeight);
        hallScrollView.frame = CGRectMake(0 , 0, hallScrollWidth, hallScrollHeight); // second changed away from mealScrollHeight
        
		customTableView.frame = CGRectMake(0, mealScrollHeight, tableViewWidth, tableViewHeight);
	
		// Buttons
		mealLeftButton.frame = CGRectMake(mealLeftOriginX, mealLeftOriginY - mealScrollHeight, mealLeftWidth, mealLeftHeight);
		mealRightButton.frame = CGRectMake(mealRightOriginX, mealRightOriginY - mealScrollHeight, mealRightWidth, mealRightHeight);
		hallLeftButton.frame = CGRectMake(hallLeftOriginX, hallLeftOriginY - mealScrollHeight, hallLeftWidth, hallLeftHeight);		
		hallRightButton.frame = CGRectMake(hallRightOriginX, hallRightOriginY - mealScrollHeight, hallRightWidth, hallRightHeight);		

		
		grillAccessoryView.frame = CGRectMake(accessoryViewOriginX, accessoryViewOriginY - accessoryViewHeight, accessoryViewWidth , accessoryViewHeight);

        
		
        navigationBarsAnimatedOut = YES;
        [customTableView setAlpha:0.0];

		[callButton setAlpha:1.0];
		[callText setAlpha:1.0];
		[menuButton setAlpha:1.0];
		[menuText setAlpha:1.0];
		[grillAccessoryView setAlpha:1.0];

		
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
    NSLog(@"Navigation Done");
	animating = NO;
    
}

- (void)navigationAnimationIn{
 
	
	[callButton setAlpha:0.0];
	[callButton setUserInteractionEnabled:NO];
	
	[callText setAlpha:0.0];
	[menuText setAlpha:0.0];
	
	[menuButton setAlpha:0.0];
	[menuButton setUserInteractionEnabled:NO];
    NSLog(@"Navigation Done");
	animating = NO;

}
		 
- (void)tableViewAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
		
	NSLog(@"Table View Animation Done");
	
	// reloads the table view		
	[customTableView reloadData];

	
	// animates the tableView back in
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
	[UIView setAnimationDelegate:self]; 
	customTableView.alpha = 1.0;
	[UIView commitAnimations];
			 
	animating = NO;
			
			 
}

#pragma mark -
#pragma mark Table view data source

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return [scheduler titleForHeaderInSection:section forLocation:currentHallPage];
}
 */

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (currentHallPage == 2) {
		
		// create the parent view
		UIView * customSectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 30)];
		customSectionView.backgroundColor = [UIColor whiteColor];
		
		//UIView * outline = [[UIView	alloc] initWithFrame:CGRectMake(0.0, 1.0, 320.0, 28.0)];
		//outline.backgroundColor = [UIColor whiteColor];
		
		// create the label
		UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, customSectionView.frame.size.height)];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.opaque = NO;
		headerLabel.textColor = [UIColor grayColor];
		headerLabel.highlightedTextColor = [UIColor grayColor];
		headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
		headerLabel.text = [self titleForHeaderInSection:section];
		headerLabel.textAlignment = UITextAlignmentLeft;

		// package and return
		//[customSectionView addSubview:outline];
		[customSectionView addSubview:headerLabel];
		
		[headerLabel release];
		return [customSectionView autorelease];
	
	}
	
	return NULL;
		
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	if (currentHallPage == 2 && section == 1) {
		
		// create the parent view
		UIView * customSectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 40)];
		customSectionView.backgroundColor = [UIColor whiteColor];
		
		UIView * coverUp = [[UIView	alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)];
		coverUp.backgroundColor = [UIColor whiteColor];
		
		UIView * outline = [[UIView	alloc] initWithFrame:CGRectMake(0.0, 21.0, 320.0, 18.0)];
		outline.backgroundColor = [UIColor whiteColor];
		
		// create the label
		UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, 20)];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.opaque = NO;
		headerLabel.textColor = [UIColor blackColor];
		headerLabel.highlightedTextColor = [UIColor whiteColor];
		headerLabel.font = [UIFont systemFontOfSize:14.0];
		headerLabel.text = [self titleForFooterInSection:section];

		headerLabel.textAlignment = UITextAlignmentCenter;
		
		// package and return
		[customSectionView addSubview:coverUp];
		[customSectionView addSubview:outline];
		[customSectionView addSubview:headerLabel];
		
		[headerLabel release];
		return [customSectionView autorelease];
		
	}
	
	return NULL;
	
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
	
	NSString *stringToReturn;
	
	if (currentHallPage == 2) {
		if (section == 0) {
			stringToReturn = @"The Grill:";
		} else {
			stringToReturn = @"The Cafe:";
		}

	}

	return stringToReturn;
}

- (NSString *)titleForFooterInSection:(NSInteger)section {
	
	NSString *stringToReturn;
	
	if (currentHallPage == 2) {
		if (section == 1) {
			stringToReturn = [scheduler titleForHeaderInSection:section forLocation:currentHallPage];
		} 
		
	}
	
	return stringToReturn;
	
}
	
	
	
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	if (currentHallPage == 2) {
		return 30.0;
	}
	
	else {
		return 0.0;
	}
	
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	if (currentHallPage == 2 && section == 1) {
		return 40.0;
	}
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	
	NSInteger *numberOfSections = [scheduler numberOfSectionsForLocation:currentHallPage atMealIndex:currentMealPage];
	
	NSLog(@"Number of Sections Captured == %d", numberOfSections);
	if (numberOfSections == 0 || numberOfSections == 1 || numberOfSections == nil) {
		
		NSLog(@"Showing Local Alert");

		[self showLocalAlertView];
	}
	
	else {
		
		NSLog(@"Hiding Local Alert");

		
		[self hideLocalAlertView];
	}
	
	return numberOfSections;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//NSLog(@"Rows = %d", [scheduler sizeOfSection:section forLocation:currentHallPage atMealIndex:currentMealPage] );

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
	if (indexPath.row != 0 || currentHallPage == 2) {
		[cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
		cell.textLabel.numberOfLines = 10;
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		
	} else{
		[cell.textLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
		
	}
	
	NSLog(@"Cell Created");

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{	
	
	if (indexPath.row == 0) {
		// Grill Table View
		if (currentHallPage == 2) {
			return [scheduler returnHeightForCellatLocation:currentHallPage atMealIndex:currentMealPage atPath:indexPath];
		}
		
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
	

@end

