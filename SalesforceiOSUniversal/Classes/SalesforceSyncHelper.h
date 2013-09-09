//
//  SalesforceSyncHelper.h
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 09/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRestAPI.h"
#import "SFRestRequest.h"
@protocol SalesforceSyncHelperDelegate <NSObject, SFRestDelegate>

@optional
- (void)errorDidOccurInSyncService:(NSError *)error withContext:(NSString *)context;
@end

@interface SalesforceSyncHelper : NSObject<SFRestDelegate>
@property (nonatomic, unsafe_unretained) id<SalesforceSyncHelperDelegate> delegate;
+(SalesforceSyncHelper *)sharedInstance;
- (BOOL)registerSyncObjectClass:(Class)clazz;
- (void)startSync;

@end
