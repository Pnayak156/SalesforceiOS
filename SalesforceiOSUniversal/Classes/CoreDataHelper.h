//
//  CoreDataHelper.h
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 09/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject
- (NSManagedObjectContext *)newManagedObjectContext;
+ (CoreDataHelper *)sharedInstance;
- (void)initializeDatabase;
@end
