//
//  LibraryAPI.m
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 09/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import "LibraryAPI.h"
#import "SalesforceSyncHelper.h"
#import "AccountSyncObject.h"
#import "ContactSyncObject.h"

@implementation LibraryAPI
- (void)startSync{
    [[SalesforceSyncHelper sharedInstance] startSync];
}

+(LibraryAPI *)sharedInstane{
    static LibraryAPI *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
        [[SalesforceSyncHelper sharedInstance] registerSyncObjectClass:[AccountSyncObject class]];
        [[SalesforceSyncHelper sharedInstance] registerSyncObjectClass:[ContactSyncObject class]];
    });
    return _sharedInstance;
}
@end
