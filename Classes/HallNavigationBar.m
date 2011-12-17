//
//  HallNavigationBar.m
//  Bowdoin Dining
//
//  Created by Ben Johnson on 10/3/10.
//  Copyright Two Fourteen Software. All rights reserved.
//

#import "HallNavigationBar.h"


@implementation HallNavigationBar
@synthesize timeToDisplay;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
	 
	 float barWidth = 320;
	 float barHeight = 44;
	 float indicatorOffset = 10;
	 [self setBackgroundColor:[UIColor whiteColor]];

	 
	 NSString *title;
	 // Iterator to populate the entire bar
	 for (int x = 0; x < 3; x++) {

		 switch (x) {
			 case 0:
				 title = @"Thorne Hall";
				 break;
			 case 1:
				 title = @"Moulton Union";
				 break;
			 case 2:
				 title = @"The Grill | The Cafe";
				 break;
			 default:
				 break;
		 }
		 
		 UILabel *mealDescription = [[UILabel alloc]initWithFrame:CGRectMake(0 + (barWidth * x), 0, barWidth, 30)];
		 mealDescription.text = title;
		 mealDescription.textColor = [UIColor blackColor];
		 mealDescription.backgroundColor = [UIColor whiteColor];
		 mealDescription.textAlignment = UITextAlignmentCenter;
		 // Made the font a little bigger for the grill/cafe so that it doesn't look weird without the hours
         	 if(x != 2) [mealDescription setFont:[UIFont boldSystemFontOfSize:18.0]];
		 else [mealDescription setFont:[UIFont boldSystemFontOfSize:20.0]];
		 [self addSubview:mealDescription];		
		 
		 [mealDescription release];
		
		 
		 UILabel *mealTimes = [[UILabel alloc]initWithFrame:CGRectMake(0 + (barWidth * x), 22, barWidth, 22)];
             mealTimes.text = timeToDisplay;
		 mealTimes.textColor = [UIColor blackColor];
		 mealTimes.backgroundColor = [UIColor whiteColor];
		 mealTimes.textAlignment = UITextAlignmentCenter;
		 [mealTimes setFont:[UIFont systemFontOfSize:14.0]];
		 // 12/16/11 CHANGE
		 // Don't show the hours when the grill/cafe is being displayed
		 // The time is different for them and can be found under "Hours" anyways
		 if(x != 2){
             		[self addSubview:mealTimes];	
		 }
         [mealTimes release];

		 
		 UILabel *leftIndicator = [[UILabel alloc]initWithFrame:CGRectMake(indicatorOffset + (barWidth * x), 0, barWidth - 2*indicatorOffset, barHeight)];
		 
		// leftIndicator.text = @"< Thorne";
		 leftIndicator.textColor = [UIColor blackColor];
		 leftIndicator.backgroundColor = [UIColor clearColor];
		 leftIndicator.textAlignment = UITextAlignmentLeft;
		 [leftIndicator setFont:[UIFont boldSystemFontOfSize:11.0]];
		 
		 
		 
		 UILabel *rightIndicator = [[UILabel alloc]initWithFrame:CGRectMake(indicatorOffset + (barWidth * x), 0, barWidth - 2*indicatorOffset, barHeight)];
		 
		// rightIndicator.text = @"Moulton >";
		 rightIndicator.textColor = [UIColor blackColor];
		 rightIndicator.backgroundColor = [UIColor clearColor];
		 rightIndicator.textAlignment = UITextAlignmentRight;
		 [rightIndicator setFont:[UIFont boldSystemFontOfSize:11.0]];
		 
		 
		 
		 // Makes sure no out of bounds errors will occur
		 if (x == 0){

			 rightIndicator.text = @"Moulton >";
			 [self addSubview:rightIndicator];
		 } 
		 
		 
		 else if (x == 1){
			 leftIndicator.text = @"< Thorne";
			 rightIndicator.text = @"Union >";
			 [self addSubview:leftIndicator];
			 [self addSubview:rightIndicator];
			
		 } 
		 
		 else if (x == 2){
			 
			 leftIndicator.text = @"< Moulton";
			 [self addSubview:leftIndicator];
		 }
		 
		 [rightIndicator release];
		 [leftIndicator release];
		 
		 
	 }
 }

- (void)dealloc {
    [super dealloc];
}


@end

