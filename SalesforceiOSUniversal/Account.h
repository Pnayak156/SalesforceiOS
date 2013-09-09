//
//  Account.h
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 10/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Account : NSObject

@property (nonatomic, strong) NSString * idL;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSDate * lastModifiedDate;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * industry;
@property (nonatomic, strong) NSString * accountNumber;
@property (nonatomic, strong) NSNumber * syncFlag;
//@property (nonatomic, strong) NSArray *contact;
@end
