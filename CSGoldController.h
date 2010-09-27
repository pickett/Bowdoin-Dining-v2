//
//  CSGoldController.h
//  DiningTableViewTest
//
//  Created by Ben Johnson on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CSGoldController : NSObject {

	
	// Login Information
	NSString *userName;
	NSString *password;
	
	
}

// Public Methods
- (void)getCSGoldDataWithUserName:(NSString*)user password:(NSString*)pass;


// Private Methods
- (NSMutableString*)returnSoapEnvelopeForService:(NSString*)serviceRequested;

@end