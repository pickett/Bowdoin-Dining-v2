//
//  CSGoldParser.m
//  Bowdoin Dining
//
//  Created by Ben Johnson on 9/24/10.
//  Copyright Two Fourteen Software. All rights reserved.
//

#import "CSGoldParser.h"
#import "WristWatch.h"

@implementation CSGoldParser

@synthesize smallBucket, mediumBucket, tempSmallValue, tempMediumValue; 
- (void)parseWithData:(NSData *)data{
		
	theParser = [[NSXMLParser alloc] initWithData:data];
	[theParser setDelegate:self];
	[theParser setShouldProcessNamespaces:NO];
	[theParser setShouldReportNamespacePrefixes:NO];
	[theParser setShouldResolveExternalEntities:NO];
	[theParser parse];
	
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"Found CSGold File and started parsing");
	
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
	NSLog(@"Done With Document");
	
    // Store plan type and meals remaining in NSUserDefaults and Post Notification
	
	WristWatch *watch = [[WristWatch alloc] init];
	
	[[NSUserDefaults standardUserDefaults] setValue:[watch getUpdatedTimeString] forKey:@"CSGold_LastTime_Updated"];
	
	[watch release];
	
	if (mediumBucket != nil) {
		
		NSString *combinedBalance = [self returnCombinedBalance];
		[[NSUserDefaults standardUserDefaults] setValue:combinedBalance forKey:@"MealsRemaining"];

	}
	
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
}

#define onecard 1
#define polarpoints 2
#define NAaccount 3
#define fall 1
#define spring 2

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	
	// set the current element
	currentElement = elementName;
	NSLog(@"%@", elementName);
	
	// Checks for One Card Balance
	if ([elementName isEqualToString:@"dtCSGoldSVCBalances"] && [[attributeDict objectForKey:@"diffgr:id"] isEqualToString:@"dtCSGoldSVCBalances1"]) {
		currentSVCAccount = onecard;	
	}
	
	// Checks for Polar Points Balance
	// 12/16/11 CHANGES
	// dtCSGoldSVCBalance2 is actually the polar points for fall, and 3 is the polar points for spring
	// Added a wristwatch check here:
	// OLD CODE:
	//else if ([elementName isEqualToString:@"dtCSGoldSVCBalances"] && [[attributeDict objectForKey:@"diffgr:id"] isEqualToString:@"dtCSGoldSVCBalances3"]) {
	//	currentSVCAccount = polarpoints;	
	//}
	else if ([elementName isEqualToString:@"dtCSGoldSVCBalances"] && ([[attributeDict objectForKey:@"diffgr:id"] isEqualToString:@"dtCSGoldSVCBalances2"]||[[attributeDict objectForKey:@"diffgr:id"] isEqualToString:@"dtCSGoldSVCBalances3"])) {
        	WristWatch *watch = [[WristWatch alloc] init];
        	if(0 <= [watch getWeekofYear] && 24 >= [watch getWeekofYear] && [[attributeDict objectForKey:@"diffgr:id"] isEqualToString:@"dtCSGoldSVCBalances3"]){
        	    currentSVCAccount = polarpoints;	
        	}
        	else if(25 <= [watch getWeekofYear] && [[attributeDict objectForKey:@"diffgr:id"] isEqualToString:@"dtCSGoldSVCBalances2"]){
        	    currentSVCAccount = polarpoints;
        	}
        	else{
        	    currentSVCAccount = NAaccount;
        	}
            [watch release];
	}
	// END CHANGE
	else if ([elementName isEqualToString:@"dtCSGoldSVCBalances"]) {
		currentSVCAccount = NAaccount;	
	}
	
	
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	
    // 12/16/11 CHANGES
	// The Buckets get messed up depending on whether its fall or spring
    // The server response gives the SVCPlanDescription after the buckets
    // so I implemented a temp value
    // The temp values are now held, and if the plan description matches the date,
    // the values are put into the buckets
    if ([currentElement isEqualToString:@"SVCPLANDESCRIPTION"]){
        WristWatch *watch = [[WristWatch alloc] init];
        if([string hasPrefix:@"Fall"] && 25 <= [watch getWeekofYear]){
            self.mediumBucket = [NSString stringWithFormat:@"%d", tempMediumValue];
            self.smallBucket = [NSString stringWithFormat:@"%d", tempSmallValue];
        }
        if([string hasPrefix:@"Spring"] && 0 <= [watch getWeekofYear] && 24 >= [watch getWeekofYear]){
            self.mediumBucket = [NSString stringWithFormat:@"%d", tempMediumValue];
            self.smallBucket = [NSString stringWithFormat:@"%d", tempSmallValue];
        }
        [watch release];
            
    }
	if ([currentElement isEqualToString:@"MEDIUMBUCKET"]) {
        NSLog(@"Medium Bucket = %@", string);
        tempMediumValue = [string intValue];

	}
	if ([currentElement isEqualToString:@"SMALLBUCKET"]) {
		NSLog(@"Small Bucket = %@", string);
        tempSmallValue = [string intValue];
	}
	
	// Meal Plan | Meal Balances
	if ([currentElement isEqualToString:@"DESCRIPTION"]) {
		NSLog(@"Meal Plan = %@", string);
	}
	
	if ([currentElement isEqualToString:@"BALANCE"]) {
		
		if (currentSVCAccount == polarpoints) {
			NSLog(@"Polar Points Balance = %@", string);
			[[NSUserDefaults standardUserDefaults] setValue:string  forKey:@"PolarPointBalance_RAW"];
			[[NSUserDefaults standardUserDefaults] setValue:[self returnFormattedMoneyBalance:string]  forKey:@"PolarPointBalance"];
		}
		
		if (currentSVCAccount == onecard) {
			NSLog(@"One Card Balance = %@", string);
			[[NSUserDefaults standardUserDefaults] setValue:string  forKey:@"OneCardBalance_RAW"];
			[[NSUserDefaults standardUserDefaults] setValue:[self returnFormattedMoneyBalance:string] forKey:@"OneCardBalance"];
		}	
	}	
	
	
	
}



- (NSString*)returnFormattedMoneyBalance:(NSString *)inputString{
	NSLog(@"Formatting One Card");
	NSString *stringToReturn;
	

	if (inputString !=nil) {
		
		NSString *firstHalf;
		NSString *secondHalf;
		
		int indexForPeriod;
		
		switch (inputString.length) {
			// Must be displayed as $0.00
			case 0:
				return @"$0.00";
				break;
			
				
			// Must be displayed $0.01
			case 1:
				
				return [NSString stringWithFormat:@"$0.0%@", inputString];
				break;
				
			// Must be displayed $0.12
			case 2:
				return [NSString stringWithFormat:@"$0.%@", inputString];
				break;
				
			// Must be displayed $1.23
			case 3:
				indexForPeriod = 1;
				break;

			
			// Must be displayed $12.34
			case 4:
				indexForPeriod = 2;
				break;
				
			// Must be displayed $123.45	
			case 5:
				indexForPeriod = 3;
				break;

			// Must be displayed $1234.56
			case 6:
				indexForPeriod = 4;
				break;
				
			// If they have this many polar points - I envy them and you should too.
			case 7:
				indexForPeriod = 5;
				break;

			default:
				indexForPeriod = 0;
				break;
		}
		
		firstHalf = [inputString substringToIndex:indexForPeriod];
		secondHalf = [inputString substringFromIndex:indexForPeriod];
		
		stringToReturn = [NSString stringWithFormat:@"$%@.%@", firstHalf, secondHalf];
		
	}
	
	return stringToReturn;
	
}


- (NSString*)returnCombinedBalance{
	
	int smallValue;
	int mediumValue;
	
	if (smallBucket != nil) {
		NSLog(@"Printing small value %@", smallBucket);
		smallValue = [smallBucket intValue];

	} else {
		smallValue = 0;
	}

	
	
	if (mediumBucket != nil) {
		
		NSLog(@"Printing medium value %@", mediumBucket);
		mediumValue = [mediumBucket intValue];
		
		
	} else {
		mediumValue = 0;
	}


		
	int result = smallValue + mediumValue;
	
	
	return [NSString stringWithFormat:@"%d", result];
	
}


- (void)dealloc{
	[smallBucket release];
	[mediumBucket release];
	[error release];
	[theParser release];
	[super dealloc];
}



@end
