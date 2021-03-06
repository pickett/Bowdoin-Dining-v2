//
//  RootViewController.h
//  Bowdoin Dining
//
//  Created by Ben Johnson on 7/8/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "HallNavigationBar.h"
#import "MealNavigationBar.h"
#import "MBProgressHUD.h"
#import <CoreData/CoreData.h>

@class mealHandler;
@class WristWatch;
@class UICustomTableView;
@class ScheduleDecider;

@interface RootViewController : UIViewController <UITableViewDelegate, UITabBarDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MBProgressHUDDelegate> {
	
	// Core Data
	NSManagedObjectContext *managedObjectContext;	    
	
	@private

	// Table View Outlets
	IBOutlet UICustomTableView *customTableView;
	
	// Navigation Scrollers and Buttons
	IBOutlet UIScrollView *hallScrollView;
	IBOutlet UIScrollView *mealScrollView;
	IBOutlet UIButton *mealLeftButton;
	IBOutlet UIButton *mealRightButton;
	IBOutlet UIButton *hallLeftButton;
	IBOutlet UIButton *hallRightButton;

	
	// Grill Buttons
	IBOutlet UIButton *callButton;
	IBOutlet UIButton *menuButton;
	IBOutlet UILabel *callText;
	IBOutlet UILabel *menuText;
	
	IBOutlet UIView *grillAccessoryView;
	

    IBOutlet UISegmentedControl *dayDeciderBar;
    IBOutlet UIToolbar *topFillerBar;
    
	
	// Data Controllers
	WristWatch *watch;
	NSIndexPath *selectedIndexPath;
	
	ScheduleDecider *scheduler;
    
	BOOL downloadSucceeded;
    BOOL navigationBarsAnimatedOut;
	BOOL contentReady;
	BOOL animating;
	BOOL navigatingRight;
	BOOL navigatingLeft;

	int currentHallPage;
	int currentMealPage;
	
	MealNavigationBar *mealNavBar;
	HallNavigationBar *hallNavBar;
	
	UIView *localAlertView;
	UIView *globalAlertView;
	
	
	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	    


@property (nonatomic, retain) IBOutlet UICustomTableView *customTableView;
@property (nonatomic, retain) IBOutlet UIScrollView *hallScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *mealScrollView;

@property (nonatomic, retain) IBOutlet UIButton *mealLeftButton;
@property (nonatomic, retain) IBOutlet UIButton *mealRightButton;
@property (nonatomic, retain) IBOutlet UIButton *hallLeftButton;
@property (nonatomic, retain) IBOutlet UIButton *hallRightButton;

@property (nonatomic, retain) IBOutlet UISegmentedControl *dayDeciderBar;

@property (nonatomic, retain) IBOutlet UIButton * callButton;
@property (nonatomic, retain) IBOutlet UILabel * callText;
@property (nonatomic, retain) IBOutlet UIButton * menuButton;
@property (nonatomic, retain) IBOutlet UILabel * menuText;
@property (nonatomic, retain) IBOutlet UIView * grillAccessoryView;

@property (nonatomic, retain) ScheduleDecider *scheduler;


@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

-(void)setupMealData;
-(void)registerNotifications;

- (IBAction)navigateRight:(id)sender;
- (IBAction)navigateLeft:(id)sender;
- (IBAction)launchPhone;
- (IBAction)launchGrillMenu;
- (IBAction)displayActionPage;





@end
