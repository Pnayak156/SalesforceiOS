//
//  Contact.h
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 10/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Account;

@interface Contact : NSObject

@property (nonatomic, strong) NSString * idL;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSDate * lastModifiedDate;
@property (nonatomic, strong) NSNumber * syncFlag;
@property (nonatomic, strong) Account *account;

@end
