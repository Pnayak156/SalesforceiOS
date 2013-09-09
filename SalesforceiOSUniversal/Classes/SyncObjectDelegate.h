//
//  SyncObjectDelegate.h
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 09/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SyncObjectDelegate <NSObject>
@required
- (NSString *)sobjectName;
- (NSString *)entityName;
- (NSString *)syncStatusName;
- (NSDictionary *)propertyMapping;
- (NSString *)lastModifiedDate;
- (NSString *)offlineSyncFlag;
- (BOOL)hasParentEntity;

@optional
- (NSString *)parentLacolAttributeName;
- (NSString *)sfdcParentFieldName;
- (NSString *)parentEntity;
@end
