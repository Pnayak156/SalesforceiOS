//
//  LibraryAPI.h
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 09/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryAPI : NSObject
+(LibraryAPI *)sharedInstane;
- (void)startSync;
@property (nonatomic, strong) NSMutableDictionary *modelObjects;
@end
