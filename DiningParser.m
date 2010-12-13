//
//  Parser.m
//  TableView
//
//  Created by Ben Johnson on 6/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DiningParser.h"
#import "mealHandler.h"
#import "WristWatch.h"

@implementation DiningParser
@synthesize todaysMealHandler, thorneBreakfast, thorneLunch, thorneDinner, thorneBrunch, moultonBreakfast, moultonLunch, moultonDinner, moultonBrunch;

-(id)init{
	
	thorneBreakfast = [[NSMutableArray	alloc] init];
	thorneLunch = [[NSMutableArray alloc] init];
	thorneDinner = [[NSMutableArray alloc] init];
	thorneBrunch = [[NSMutableArray alloc] init];
	
	moultonBreakfast = [[NSMutableArray alloc] init];
	moultonLunch = [[NSMutableArray alloc] init];
	moultonDinner = [[NSMutableArray alloc] init];
	moultonBrunch = [[NSMutableArray alloc] init];
	
	return self;
}

-(void)parseXMLData:(NSData *)data forDay:(int)day{
	mealArray = [[NSMutableArray alloc] init];
	
    currentDayIndex = day;
	
	rssParser = [[NSXMLParser alloc] initWithData:data];
	
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[rssParser setDelegate:self];
	
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[rssParser setShouldProcessNamespaces:NO];
	[rssParser setShouldReportNamespacePrefixes:NO];
	[rssParser setShouldResolveExternalEntities:NO];
	
	[rssParser parse];
	
}

#pragma mark -
#pragma mark Parser Code

-(void)parserDidStartDocument:(NSXMLParser *)parser {
	
	thorneBreakfast = [[NSMutableArray alloc] init];
	thorneLunch = [[NSMutableArray alloc] init];
	thorneDinner = [[NSMutableArray alloc] init];
	thorneBrunch = [[NSMutableArray alloc] init];
	
	moultonBreakfast = [[NSMutableArray alloc] init];
	moultonLunch = [[NSMutableArray alloc] init];
	moultonDinner = [[NSMutableArray alloc] init];
	moultonBrunch = [[NSMutableArray alloc] init];

}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
    [self storeXMLDataforDay:(int)currentDayIndex];
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	currentElement = [elementName copy];
	
	
	// storing Breakfast
	if ([elementName isEqualToString:@"meal"] && [[attributeDict objectForKey:@"id"] isEqualToString:@"Breakfast"]) {
		currentMeal = @"Breakfast";
		
	}
	
	// storing Brunch
	if ([elementName isEqualToString:@"meal"] && [[attributeDict objectForKey:@"id"] isEqualToString:@"Brunch"]) {
		currentMeal = @"Brunch";
		
	}
	
	// storing Lunch
	if ([elementName isEqualToString:@"meal"] && [[attributeDict objectForKey:@"id"] isEqualToString:@"Lunch"]) {
		currentMeal = @"Lunch";
	}
	
	// storing Dinner
	if ([elementName isEqualToString:@"meal"] && [[attributeDict objectForKey:@"id"] isEqualToString:@"Dinner"]) {
		currentMeal = @"Dinner";
	}
	
	// Storing to Thorne Array
	if ([elementName isEqualToString:@"unit"] && [[attributeDict objectForKey:@"id"] isEqualToString:@"49"]) {
		currentUnit = @"Thorne";
		
	}
	
	// Storing to Moulton Array
	if ([elementName isEqualToString:@"unit"] && [[attributeDict objectForKey:@"id"] isEqualToString:@"48"]) {
		currentUnit = @"Moulton";
		
	}
	
	// Storing to Thorne Array
	if ([elementName isEqualToString:@"webLongName"] ) {
		currentTitle = [[NSMutableString alloc] init];
		
	}
	
	if ([elementName isEqualToString:@"course"] ) {
		currentTitle = [[NSMutableString alloc] init];
		
	}

	
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
		
	// if course is the the same as current course - continue to add to course array key
	if ([elementName isEqualToString:@"course"]) {
		if (currentCourse == nil) {
			currentCourse = currentTitle;
			mealArray = [[NSMutableArray alloc] init];
			
		}
		
		else if (![currentCourse isEqualToString:currentTitle]) {
			[self addArrayofItems:mealArray forCourse:currentCourse forMeal:currentMeal forHall:currentUnit];
			currentCourse = currentTitle;
			//wipes contents of Array
			mealArray = [[NSMutableArray alloc] init];
		}
	}
	
	if ([elementName isEqualToString:@"webLongName"]) {
		// save values to an item, then store that item into the array with the current course key
		[mealArray addObject:currentTitle];
		
	}
	
	if ([elementName isEqualToString:@"error"]) {
		
	}
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"webLongName"]) {
		[currentTitle appendString:string];
		
	}
	
	if ([currentElement isEqualToString:@"course"]) {
		[currentTitle appendString:string];
		
	}
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	NSLog(@"** Parsing Error Occurred \n--%@", parseError);
	
}

-(void)displayError:(NSString*)errorToDisplay {
	NSLog(@"Error parsing XML: %@", errorToDisplay);
	
}

#pragma mark -
#pragma mark Data Storage

-(void)storeXMLDataforDay:(int)day{
	
	WristWatch *watch = [[WristWatch alloc] init];
	
	int currentWeek = [watch getWeekofYear];
	
    NSString *archivePath = [NSString stringWithFormat:@"%@/week%d/thorneBreakfast%d.xml",[self documentsDirectory], currentWeek, day];
    [thorneBreakfast writeToFile:archivePath atomically:YES];
	NSLog(@"Storing: %@", archivePath);
	NSLog(@"Description = %@", thorneBreakfast);
	
    archivePath = [NSString stringWithFormat:@"%@/week%d/thorneLunch%d.xml",[self documentsDirectory], currentWeek, day];
    [thorneLunch writeToFile:archivePath atomically:YES];
	NSLog(@"Storing: %@", [archivePath stringByReplacingOccurrencesOfString:[self documentsDirectory] withString:@"docdirectory"]);
	NSLog(@"Description = %@", thorneLunch);

    archivePath = [NSString stringWithFormat:@"%@/week%d/thorneDinner%d.xml",[self documentsDirectory], currentWeek, day];
    [thorneDinner writeToFile:archivePath atomically:YES];
	NSLog(@"Storing: %@", [archivePath stringByReplacingOccurrencesOfString:[self documentsDirectory] withString:@"docdirectory"]);
	
    archivePath = [NSString stringWithFormat:@"%@/week%d/thorneBrunch%d.xml",[self documentsDirectory], currentWeek, day];
    [thorneBrunch writeToFile:archivePath atomically:YES];
	NSLog(@"Storing: %@", [archivePath stringByReplacingOccurrencesOfString:[self documentsDirectory] withString:@"docdirectory"]);
	
    archivePath = [NSString stringWithFormat:@"%@/week%d/moultonBreakfast%d.xml",[self documentsDirectory], currentWeek, day];
    [moultonBreakfast writeToFile:archivePath atomically:YES];
	NSLog(@"Storing: %@", [archivePath stringByReplacingOccurrencesOfString:[self documentsDirectory] withString:@"docdirectory"]);
	
    archivePath = [NSString stringWithFormat:@"%@/week%d/moultonLunch%d.xml",[self documentsDirectory], currentWeek, day];
    [moultonLunch writeToFile:archivePath atomically:YES];
	NSLog(@"Storing: %@", [archivePath stringByReplacingOccurrencesOfString:[self documentsDirectory] withString:@"docdirectory"]);
	
    archivePath = [NSString stringWithFormat:@"%@/week%d/moultonDinner%d.xml",[self documentsDirectory], currentWeek, day];
    [moultonDinner writeToFile:archivePath atomically:YES];
	NSLog(@"Storing: %@", [archivePath stringByReplacingOccurrencesOfString:[self documentsDirectory] withString:@"docdirectory"]);
	
    archivePath = [NSString stringWithFormat:@"%@/week%d/moultonBrunch%d.xml",[self documentsDirectory], currentWeek, day];
    [moultonBrunch writeToFile:archivePath atomically:YES];
	NSLog(@"Storing: %@", [archivePath stringByReplacingOccurrencesOfString:[self documentsDirectory] withString:@"docdirectory"]);
	
}

-(NSString *)documentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

-(void)addArrayofItems:(NSMutableArray *)items forCourse:(NSString *)courseTitle forMeal:(NSString *)mealTitle forHall:(NSString *)diningHall {	
	if ([diningHall isEqualToString:@"Thorne"]) {
		
		if ([mealTitle isEqualToString:@"Breakfast"]) {
			items = [self addTitleToArray:courseTitle forArray:items];
			
			// Inserts the Main Course at the First Index
			if ([courseTitle isEqualToString:@"Main Course"]) {
				[thorneBreakfast insertObject:items atIndex:0];
			} else {
				[thorneBreakfast addObject:items];
			}
			
		}
		
		if ([mealTitle isEqualToString:@"Lunch"]) {
			items = [self addTitleToArray:courseTitle forArray:items];
			
			// Inserts the Main Course at the First Index
			if ([courseTitle isEqualToString:@"Main Course"]) {
				[thorneLunch insertObject:items atIndex:0];
			} else {
				[thorneLunch addObject:items];
			}
			
		}
		if ([mealTitle isEqualToString:@"Dinner"]) {
			items = [self addTitleToArray:courseTitle forArray:items];
			
			// Inserts the Main Course at the First Index
			if ([courseTitle isEqualToString:@"Main Course"]) {
				[thorneDinner insertObject:items atIndex:0];
			} else {
				[thorneDinner addObject:items];
			}
			
		}
		if ([mealTitle isEqualToString:@"Brunch"]) {
			items = [self addTitleToArray:courseTitle forArray:items];
			
			// Inserts the Main Course at the First Index
			if ([courseTitle isEqualToString:@"Main Course"]) {
				[thorneBrunch insertObject:items atIndex:0];
			} else {
				[thorneBrunch addObject:items];
			}
			
		}
		
	}
	else {
		
		
		if ([mealTitle isEqualToString:@"Breakfast"]) {
			items = [self addTitleToArray:courseTitle forArray:items];
			
			// Inserts the Main Course at the First Index
			if ([courseTitle isEqualToString:@"Main Course"]) {
				[moultonBreakfast insertObject:items atIndex:0];
			} else {
				[moultonBreakfast addObject:items];
			}
		}
		
		if ([mealTitle isEqualToString:@"Lunch"]) {
			items = [self addTitleToArray:courseTitle forArray:items];
			
			// Inserts the Main Course at the First Index
			if ([courseTitle isEqualToString:@"Main Course"]) {
				[moultonLunch insertObject:items atIndex:0];
			} else {
				[moultonLunch addObject:items];
			}
			
		}
		if ([mealTitle isEqualToString:@"Dinner"]) {
			items = [self addTitleToArray:courseTitle forArray:items];
			
			// Inserts the Main Course at the First Index
			if ([courseTitle isEqualToString:@"Main Course"]) {
				[moultonDinner insertObject:items atIndex:0];
			} else {
				[moultonDinner addObject:items];
			}
			
		}
		if ([mealTitle isEqualToString:@"Brunch"]) {
			items = [self addTitleToArray:courseTitle forArray:items];
			
			// Inserts the Main Course at the First Index
			if ([courseTitle isEqualToString:@"Main Course"]) {
				[moultonBrunch insertObject:items atIndex:0];
			} else {
				[moultonBrunch addObject:items];
			}			
		}
		
	}
	
}

-(NSMutableArray*)addTitleToArray:(NSString*)theTitle forArray:(NSMutableArray *)theArray{
	
	// Inserts the course title into the array at index 0
	[theArray insertObject:theTitle atIndex:0];
	
	return theArray;
	
	
}
@end
