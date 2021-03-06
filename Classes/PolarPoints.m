//
//  PolarPoints.m
//  Bowdoin Dining
//
//  Created by Ben Johnson on 7/13/10.
//  Copyright Two Fourteen Software. All rights reserved.
//

#import "PolarPoints.h"
#import "CSGoldController.h"
#import "LogInViewController.h"
#import "RecentTransactions.h"

@implementation PolarPoints


- (void)loadCSGoldDataWithUserName:(NSString *)login password:(NSString*)pass{
		
	userName = login;
	password = pass;
	
	// ** HUD Code by Matej Bukovinski ** //
	
	// Initializes Heads Up Display
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	
	// Adds HUD to screen
	HUD.delegate = self;
	
	HUD.labelText = @"Loading..";
	[self.view addSubview:HUD];
	
	[HUD showWhileExecuting:@selector(beginCSGoldDownload) onTarget:self withObject:nil animated:YES];	
	//[self parseXMLFileAtURL:feedAddress];
	
		
}

- (void)viewDidLoad{
	
	NSLog(@"Points View Did Load");
	
	self.title = @"Polar Points";
	[self registerForNotifications];
	
	// Sets up the Activity Indicators to Start Spinning when view is loaded.
	activityIndicator1.hidesWhenStopped = YES;
	activityIndicator2.hidesWhenStopped = YES;
	activityIndicator3.hidesWhenStopped = YES;

	
	[activityIndicator1 startAnimating];
	[activityIndicator2	startAnimating];
	[activityIndicator3	startAnimating];
	
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoginStored"]) {
		
		NSString *login = [[NSUserDefaults standardUserDefaults] valueForKey:@"Login"];
		NSString *pass = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];
		
		NSLog(@"Updating with Stored Login:%@ and Password:*****", login);
		
		
		[self loadCSGoldDataWithUserName:login password:pass];
		
	
	} else {
		
		LogInViewController *loginController = [[LogInViewController alloc] init];
		[self.navigationController presentModalViewController:loginController animated:YES];
		loginController.delegate = self;
		[loginController release];	
		
	}



	
}

// Privacy Protection on view exit
- (void)viewWillDisappear:(BOOL)animated{
	
	[self destroySessionInformation];
	
}

- (void)beginCSGoldDownload{
	
	CSGoldController *theController = [[CSGoldController alloc]init];	
	session_Controller = theController;
	[session_Controller getCSGoldDataWithUserName:userName password:password];
	
}

- (void)registerForNotifications{
	
	NSLog(@"Registering For Notification");
	
	// Polar Point Authorization
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVisibleInformation)
												 name:@"CSGold DownloadCompleted" object:nil];
	
	
}

- (void)updateVisibleInformation{
	
	NSLog(@"Updating Visible Information");
	
	// Information is Current - stop animating indicators
	[activityIndicator1 stopAnimating];
	[activityIndicator2	stopAnimating];
	[activityIndicator3	stopAnimating];
	
	mealsRemaining.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"MealsRemaining"];
	
	// Low Balance Warning
	if ([mealsRemaining.text intValue] <= 3) {
		mealsRemaining.textColor = [UIColor redColor];
	} 
	
	polarPoints.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"PolarPointBalance"];
	NSString *polarPointsRaw = [[NSUserDefaults standardUserDefaults] valueForKey:@"PolarPointBalance_RAW"];
	
	// Low Balance Warning
	if (polarPointsRaw != nil && [polarPointsRaw intValue] <= 1000) {
		polarPoints.textColor = [UIColor redColor];
	}
	
	// Low Balance Warning
	oneCardBalance.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"OneCardBalance"];
	NSString *oneCardBalanceRAW = [[NSUserDefaults standardUserDefaults] valueForKey:@"OneCardBalance_RAW"];

	if (oneCardBalanceRAW != nil && [oneCardBalanceRAW intValue] <= 1000) {
		oneCardBalance.textColor = [UIColor redColor];
	}
	
	lastUpdatedLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"CSGold_LastTime_Updated"];

	NSLog(@"Finished Updating Visible Text");
	
}

-(IBAction)dismissPage{
	
	[self.navigationController popViewControllerAnimated:self];
	
}

- (IBAction)refreshInformation{
	
	
	NSString *login = [[NSUserDefaults standardUserDefaults] valueForKey:@"Login"];
	NSString *pass = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];
	
	if (login != NULL && pass != NULL) {
		
		NSLog(@"Updating with Stored Login:%@ and Password:*****", login);
		[self loadCSGoldDataWithUserName:login password:pass];

	} else {
		
		LogInViewController *loginController = [[LogInViewController alloc] init];
		[self.navigationController presentModalViewController:loginController animated:YES];
		loginController.delegate = self;
		[loginController release];	
	}

	
	
	
}

- (IBAction)logout{
	
	[self destroyLoginInformation];
	[self destroySessionInformation];
	
	[self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)launchRecentTransactions{
	
	RecentTransactions *recentTransactionsPage = [[RecentTransactions alloc] initWithUserName:userName andPassword:password];
	[self.navigationController pushViewController:recentTransactionsPage animated:YES];
	[recentTransactionsPage release];
	
	
	
}

- (void)destroyLoginInformation{
	
	NSLog(@"Destroying Login Information");

	
	// Destroy Previous Saved Login and set LoginStored to NO
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LoginStored"];
	[[NSUserDefaults standardUserDefaults] setValue:NULL forKey:@"Login"];
	[[NSUserDefaults standardUserDefaults] setValue:NULL forKey:@"Password"];
	
	}

- (void)destroySessionInformation{
	
	NSLog(@"Destroying Session Information");
	
	// If the login is not stored, destroy session information
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"LoginStored"]) {
		
		// Destroy Past One Card Balance 
		[[NSUserDefaults standardUserDefaults] setValue:NULL forKey:@"OneCardBalance"];
		[[NSUserDefaults standardUserDefaults] setValue:NULL forKey:@"OneCardBalance_RAW"];
		
		// Destroy Past Polar Point Balance 
		[[NSUserDefaults standardUserDefaults] setValue:NULL forKey:@"PolarPointBalance"];
		[[NSUserDefaults standardUserDefaults] setValue:NULL forKey:@"PolarPointBalance_RAW"];
		
		// Destroy Past Meal Balances
		[[NSUserDefaults standardUserDefaults] setValue:NULL forKey:@"MealsRemaining"];
		
		
		if (session_Controller != nil) {
		//	[session_Controller release];
		}

	}
	
	
}

- (void)hudWasHidden{
	
}
	

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[session_Controller release];
    [super dealloc];
}


@end
