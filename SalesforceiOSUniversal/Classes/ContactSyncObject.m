//
//  ContactSyncObject.m
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 09/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import "ContactSyncObject.h"

@implementation ContactSyncObject
- (NSString *)sobjectName {
    return @"Contact";
}
- (NSString *)entityName {
    return @"Contact";
}
- (NSString *)syncStatusName{
    return @"Loading Contact";
}
- (NSDictionary *)propertyMapping{
    return @{@"idL":@"Id", @"name":@"Name", @"lastModifiedDate":@"LastModifiedDate",
             @"phone":@"Phone"};
}
- (NSString *)lastModifiedDate{
    return @"lastModifiedDate";
}
- (NSString *)offlineSyncFlag{
    return @"syncFlag";
}
- (BOOL)hasParentEntity {
    return YES;
}
- (NSString *)parentLacolAttributeName {
    return @"account";
}
- (NSString *)sfdcParentFieldName {
    return @"AccountId";
}
- (NSString *)parentEntity {
    return @"Account";
}
@end
