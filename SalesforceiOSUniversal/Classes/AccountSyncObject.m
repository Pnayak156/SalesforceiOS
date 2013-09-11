//
//  AccountSyncObject.m
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 09/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import "AccountSyncObject.h"

@implementation AccountSyncObject
- (NSString *)sobjectName {
    return @"Account";
}
- (NSString *)entityName {
    return @"Account";
}
- (NSString *)syncStatusName{
    return @"Loading Account";
}
- (NSDictionary *)propertyMapping{
    return @{@"id":@"Id", @"name":@"Name", @"lastModifiedDate":@"LastModifiedDate",
             @"phone":@"Phone", @"industry":@"Industry", @"accountNumber":@"AccountNumber"};
}
- (NSString *)lastModifiedDate{
    return @"lastModifiedDate";
}
- (NSString *)offlineSyncFlag{
    return @"syncFlag";
}
- (BOOL)hasParentEntity {
    return NO;
}
@end
