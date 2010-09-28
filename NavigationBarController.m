//
//  NavigationBarController.m
//  DiningTableViewTest
//
//  Created by Ben Johnson on 8/11/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "NavigationBarController.h"


@implementation NavigationBarController
@synthesize scheduleArray;

-(id)initWithScheduleArray:(NSMutableArray *)theScheduleArray{
    
    // Sets the Passed Schedule Array within the class.
    scheduleArray = theScheduleArray;
    
    return self;
    
}


-(UIScrollView*)returnTopScrollBar{
	
	
	UIScrollView *theScroller = [[UIScrollView alloc] init];

	return theScroller;
	
}


-(UIView*)returnMealNavigationBar{
    
    float barWidth = 320;
    float barHeight = 44;
        
    UIView *theMasterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barWidth * [scheduleArray count], barHeight)];
	[theMasterView setBackgroundColor:[UIColor clearColor]];
    
    for (int i = 0; i < [scheduleArray count]; i++){
        
        // Returns the NSString at each index of the array
        NSString *mealTitle = [scheduleArray objectAtIndex:i];
        NSString *leftTitle;
        NSString *rightTitle;
        
        // Makes sure no out of bounds errors will occur
        if (i != 0){
            leftTitle = [scheduleArray objectAtIndex:i-1];
        } else {
            leftTitle = NULL;
        }
        
        if (i != [scheduleArray count]-1){
            rightTitle = [scheduleArray objectAtIndex:i+1];
        } else {
            rightTitle = NULL;
        }
        
        NSLog(@"Meal Title: %@, leftTitle: %@, rightTitle: %@", mealTitle,leftTitle,rightTitle);
        
        [theMasterView addSubview:[self createMealHeader:mealTitle atIndex:i leftTitle:leftTitle rightTitle:rightTitle]];
        
    }
    
    return theMasterView;
}

-(UIView*)createMealHeader:(NSString *)mealName atIndex:(int)index leftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle{
    
    // Initializes the View
    
    float barWidth = 320;
    float barHeight = 44;
    float indicatorOffset = 10;

    
    UIView *theView = [[UIView alloc] initWithFrame:CGRectMake(0+ index*barWidth, 0, barWidth, barHeight)];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UILabel *mealDescription = [[UILabel alloc]initWithFrame:CGRectMake(0 + index*barWidth, 0, barWidth, barHeight)];
    mealDescription.text = [NSString stringWithFormat:@"Today's %@", mealName];
    mealDescription.textColor = [UIColor whiteColor];
	mealDescription.backgroundColor = [UIColor clearColor];
    mealDescription.textAlignment = UITextAlignmentCenter;
	
	[mealDescription setFont:[UIFont boldSystemFontOfSize:18.0]];

   
    if (leftTitle != NULL){
        
		UILabel *leftIndicator = [[UILabel alloc]initWithFrame:CGRectMake(indicatorOffset+ index*barWidth, 0, barWidth - 2*indicatorOffset, barHeight)];
        
		leftIndicator.text = [NSString stringWithFormat:@"< %@", leftTitle];
        leftIndicator.textColor = [UIColor whiteColor];
		leftIndicator.backgroundColor = [UIColor clearColor];
        leftIndicator.textAlignment = UITextAlignmentLeft;
        [leftIndicator setFont:[UIFont boldSystemFontOfSize:10.0]];
		
		[theView addSubview:leftIndicator];

    }
    
    
    if (rightTitle != NULL){
		UILabel *rightIndicator = [[UILabel alloc]initWithFrame:CGRectMake(indicatorOffset+ index*barWidth, 0, barWidth - 2*indicatorOffset, barHeight)];
        
		rightIndicator.text = [NSString stringWithFormat:@"%@ >", rightTitle];
        rightIndicator.textColor = [UIColor whiteColor];
		rightIndicator.backgroundColor = [UIColor clearColor];
        rightIndicator.textAlignment = UITextAlignmentRight;
        [rightIndicator setFont:[UIFont boldSystemFontOfSize:10.0]];
		
		[theView addSubview:rightIndicator];

        
    }
    
    
    [theView addSubview:mealDescription];

    return theView;
    
}





@end
