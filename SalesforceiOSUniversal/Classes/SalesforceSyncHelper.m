//
//  SalesforceSyncHelper.m
//  SalesforceiOSUniversal
//
//  Created by Prashant Kumar Nayak on 09/09/13.
//  Copyright (c) 2013 PKN. All rights reserved.
//

#import "SalesforceSyncHelper.h"
#import "SyncObjectDelegate.h"
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"
#import "LibraryAPI.h"
#import "Account.h"
#import "Contact.h"

static dispatch_queue_t processRecordsQueue;
static NSString const *DATA_RECEIVED_NOTIFICATION = @"DATA_RECEIVED_NOTIFICATION";

@interface SalesforceSyncHelper ()
@property (nonatomic, strong) NSMutableArray *registeredSyncObjects;
@property (nonatomic, strong) NSManagedObjectContext  *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *jsons;
@property (nonatomic, assign) int numberOfrequest;

@end

static SalesforceSyncHelper *sharedInstance = nil;

@implementation SalesforceSyncHelper

#pragma mark -
#pragma mark Setup Methods for Sync Service

- (BOOL)registerSyncObjectClass:(Class)clazz {
    BOOL objectWasRegistered;
    if (!self.registeredSyncObjects) {
        self.registeredSyncObjects = [NSMutableArray array];
    }
    if ([clazz conformsToProtocol:@protocol(SyncObjectDelegate)]) {
        NSUInteger registeredObjectIndex = [self.registeredSyncObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:clazz]) {
                *stop = YES;
                return *stop;
            } else {
                *stop = NO;
                return *stop;
            }
        }];
        
        if (registeredObjectIndex == NSNotFound) {
            NSObject<SyncObjectDelegate> *syncObject = [[clazz alloc] init];
            [self.registeredSyncObjects addObject:syncObject];
            objectWasRegistered = YES;
//            DebugLog(@"%@ was registered with the sync service", [clazz description]);
        } else {
            objectWasRegistered = NO;
//            DebugLog(@"%@ was not registered because it is already registered", [clazz description]);
        }
    } else {
        objectWasRegistered = NO;
//        DebugLog(@"%@ was not registered because it does not conform to the TSSyncObject protocol", [clazz description]);
    }
    
    return objectWasRegistered;
}

- (BOOL)unregisterSyncObjectClass:(Class)clazz {
    BOOL objectWasUnregistered;
    NSObject<SyncObjectDelegate> *objectToRemove = nil;
    if ([clazz conformsToProtocol:@protocol(SyncObjectDelegate)]) {
        for (id<SyncObjectDelegate> syncObject in self.registeredSyncObjects) {
            NSUInteger registeredObjectIndex = [self.registeredSyncObjects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:clazz]) {
                    *stop = YES;
                    return *stop;
                } else {
                    *stop = NO;
                    return *stop;
                }
            }];
            
            if (registeredObjectIndex != NSNotFound) {
                objectToRemove = [self.registeredSyncObjects objectAtIndex:registeredObjectIndex];
            }
        }
        
        if (objectToRemove) {
            [self.registeredSyncObjects removeObject:objectToRemove];
//            DebugLog(@"%@ was unregistered with the sync service", [clazz description]);
            objectWasUnregistered = YES;
        } else {
//            DebugLog(@"%@ was not unregistered because it was not registered", [clazz description]);
            objectWasUnregistered = NO;
        }
    } else {
//        DebugLog(@"%@ was not unregistered because it does not conform to the TSSyncObject protocol", [clazz description]);
        objectWasUnregistered = NO;
    }
    
    return objectWasUnregistered;
}

#pragma mark sending request
- (void)startSync {
    _numberOfrequest = 0;
//    if (!_managedObjectContext) {
//        [[CoreDataHelper sharedInstance] initializeDatabase];
//        _managedObjectContext = [[CoreDataHelper sharedInstance] newManagedObjectContext];
//    }
    for (id <SyncObjectDelegate> syncObject in self.registeredSyncObjects) {
        SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:[self queryForSyncObject:syncObject]];
        [[SFRestAPI sharedInstance] send:request delegate:self];
    }
       
}
#pragma mark create query

- (NSString *)queryForSyncObject:(id<SyncObjectDelegate>)syncObject {
    NSMutableString *query = [@"SELECT " mutableCopy];
    NSString *keys = [[[syncObject  propertyMapping] allValues] componentsJoinedByString:@","];
    [query appendString:keys];
    if ([syncObject hasParentEntity]) {
        [query appendFormat:@",%@",[syncObject sfdcParentFieldName]];
    }
    NSString *mostRecentLastModifiedDate = [self fetchMostRecentLastModifiedDateAsStringForSyncObjectLocally:syncObject];
    [query appendFormat:@" FROM %@ WHERE LastModifiedDate > %@", [syncObject sobjectName], mostRecentLastModifiedDate];
    return query;
}
#pragma mark lastmodifiedDate Local

- (NSString *)fetchMostRecentLastModifiedDateAsStringForSyncObjectLocally:(id<SyncObjectDelegate>)syncObject{
    NSDictionary *modelObjects = [[[LibraryAPI sharedInstane] modelObjects] copy];
    NSDate *mostRecentLastModifiedDate = nil;
    if (modelObjects.count) {
        NSArray *records = [modelObjects objectForKey:[syncObject sobjectName]];
        if (records.count) {
         records  =  [records sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:[syncObject lastModifiedDate] ascending:NO]]];
            mostRecentLastModifiedDate = [records[0] valueForKey:[syncObject lastModifiedDate]];
        } 
    
    }
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
    [dateTimeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
    NSString *lastModifiedDate = [dateTimeFormatter stringFromDate:mostRecentLastModifiedDate];
    if (!lastModifiedDate) {
        lastModifiedDate = [dateTimeFormatter stringFromDate:[NSDate distantPast]];
    }
    return lastModifiedDate;
}

#pragma mark lastmodifiedDate

- (NSString *)fetchMostRecentLastModifiedDateAsStringForSyncObject:(id<SyncObjectDelegate>)syncObject {
    
    NSDate *mostRecentLastModifiedDate = [self fetchMostRecentLastModifiedDateForSyncObject:syncObject];
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
    [dateTimeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
    NSString *lastModifiedDate = [dateTimeFormatter stringFromDate:mostRecentLastModifiedDate];
    if (!lastModifiedDate) {
        lastModifiedDate = [dateTimeFormatter stringFromDate:[NSDate distantPast]];
    }
    return lastModifiedDate;
}

- (NSDate *)fetchMostRecentLastModifiedDateForSyncObject:(id<SyncObjectDelegate>)syncObject {
    __block NSDate *mostRecentLastModifiedDate = nil;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[syncObject entityName] inManagedObjectContext:self.managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setFetchLimit:1];
        [request setPropertiesToFetch:[NSArray arrayWithObject:[syncObject lastModifiedDate]]];
        
        NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:[syncObject lastModifiedDate] ascending:NO];
        
        [request setSortDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
        
        NSError *error = nil;
        NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (error) {
            [self raiseError:error forContext:@"Fetch lastModifiedDate"];
//            DebugLog(@"Error fetching most recent lastModifiedDate property for %@ entity, error details: %@", [syncObject entityName], error);
        } else if ([result count] > 0) {
            if ([[[result objectAtIndex:0] valueForKey:@"lastModifiedDate"] copy] == nil || [[[result objectAtIndex:0] valueForKey:@"lastModifiedDate"] copy] == [NSNull null]) {
                mostRecentLastModifiedDate = [NSDate distantPast];
            }else {
                mostRecentLastModifiedDate = [[[result objectAtIndex:0] valueForKey:[syncObject lastModifiedDate]] copy];
            }
        } else {
            mostRecentLastModifiedDate = [NSDate distantPast];
        }
    }];
    return mostRecentLastModifiedDate;
}

#pragma mark -
#pragma mark Error Handling

- (void)raiseError:(NSError *)error forContext:(NSString *)context {
    if ([self.delegate respondsToSelector:@selector(errorDidOccurInSyncService:withContext:)]) {
        [self.delegate errorDidOccurInSyncService:error withContext:context];
    }
}
#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    _numberOfrequest ++;
    NSArray *records = [jsonResponse objectForKey:@"records"];
    if (!_jsons) {
        _jsons = [NSMutableDictionary dictionary];
    }
    if (records.count) {
        [_jsons setObject:records forKey:[[records valueForKeyPath:@"attributes.type"] lastObject]];
    }
    if (_numberOfrequest == self.registeredSyncObjects.count) {
        [self parseJSON];
    }
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
//    self.dataRows = records;
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    _numberOfrequest ++;
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}

#pragma mark -
#pragma parsing json

-(void)parseJSON{
    NSMutableDictionary *jsonTemp = [_jsons mutableCopy];
    NSMutableDictionary *jsonWithoutParent = [@{} mutableCopy];
    for (id<SyncObjectDelegate> type in _registeredSyncObjects) {
        if (![type hasParentEntity]) {
            NSArray *records = [jsonTemp objectForKey:[type sobjectName]];
            if (records.count) {
                [self saveRecordseForSyncObject:type record:records];
            }
            [jsonTemp removeObjectForKey:[type sobjectName]];
            
        }
    }
    for (id<SyncObjectDelegate> type in _registeredSyncObjects) {
        NSArray *records = [jsonTemp objectForKey:[type sobjectName]];
        if (records.count) {
            [self saveRecordseForSyncObject:type record:records];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_RECEIVED_NOTIFICATION object:nil];
    
}

- (void)saveRecordseForSyncObject:(id<SyncObjectDelegate>) syncObject record:(NSArray *)records {
    NSMutableDictionary *propertyMapping = [[syncObject propertyMapping] copy];
    NSString *entityName = [syncObject entityName];
    Class class = NSClassFromString(entityName);
    NSMutableArray *recordArray = [@[] mutableCopy];
    for (NSDictionary *objDict in records) {
        NSObject *obj = [[class alloc] init];
        if ([entityName isEqualToString:@"Account"]) {
            obj = [[Account alloc] init];
        } else if ([entityName isEqualToString:@"Contact"]) {
            obj = [[Contact alloc] init];
        }
        
        for (NSString *key in propertyMapping.allKeys) {
            NSString *value = [objDict valueForKey:[propertyMapping valueForKey:key]];
//            object_setInstanceVariable(obj, [@"name" UTF8String], value);
//            NSString *outputValue;
//            object_getInstanceVariable(obj, [@"name" UTF8String], &outputValue);
//            NSLog(@"value %@",outputValue);
//            object_setIvar(obj, class_getInstanceVariable(class,[key UTF8String]), value);
            [obj setValue:value forKey:key];
        }
        if ([syncObject hasParentEntity]) {
            NSMutableDictionary *modelObjs = [[LibraryAPI sharedInstane] modelObjects];
          __block  NSArray *parentRecords = [modelObjs objectForKey:[syncObject parentEntity]];
//            [parentRecords enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                NSString *outputValue;
//                object_getInstanceVariable(obj, [@"id" UTF8String], &outputValue);
//                if ([outputValue isEqualToString:[objDict valueForKey:[syncObject sfdcParentFieldName]]]) {
//                    parentRecords = @[obj];
//                }
//            }];
            parentRecords  = [parentRecords filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id = %@",[objDict valueForKey:[syncObject sfdcParentFieldName]]]];
//            NSObject *parentObj = [parentRecords lastObject];
//            object_setInstanceVariable(obj, [[syncObject parentLacolAttributeName] UTF8String], parentObj);
//            object_setIvar(obj, class_getInstanceVariable(class,[[syncObject parentLacolAttributeName] UTF8String]), parentObj);
            
            [obj setValue:[parentRecords lastObject] forKey:[syncObject parentLacolAttributeName]];
        }
        [recordArray addObject:obj];
    }
    if (![[LibraryAPI sharedInstane] modelObjects]) {
        [LibraryAPI sharedInstane].modelObjects = [@{} mutableCopy];
    }
  NSMutableDictionary *modelObjs = [[LibraryAPI sharedInstane] modelObjects];
    if ([modelObjs objectForKey:[syncObject sobjectName]]) {
        NSMutableArray *oldRecord = [modelObjs objectForKey:[syncObject sobjectName]];
        if (oldRecord.count) {
//            NSMutableArray *tobeDelete = [@[] mutableCopy];
//            [oldRecord enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                NSString *outputValue;
//                object_getInstanceVariable(obj, [@"id" UTF8String], &outputValue);
//                for (NSObject *objectTemp in recordArray) {
//                    NSString *newValue;
//                    object_getInstanceVariable(obj, [@"id" UTF8String], &newValue);
//                    if ([outputValue isEqualToString:newValue]) {
//                        [oldRecord addObject:obj];
//                    }
//                }
//            }];
            NSArray *tobeDelete = [oldRecord filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id in (%@)",[recordArray valueForKey:@"id"]]];
            if (tobeDelete.count) {
                [oldRecord removeObjectsInArray:tobeDelete];
            }

        } else {
            oldRecord = [@[] mutableCopy];
        }
        [oldRecord addObject:recordArray];
        [modelObjs setObject:oldRecord forKey:[syncObject sobjectName]];
    
    } else {
        [modelObjs setObject:recordArray forKey:[syncObject sobjectName]];
    }
    [LibraryAPI sharedInstane].modelObjects = modelObjs;
}

#pragma mark -
#pragma mark Singleton methods



+(SalesforceSyncHelper *)sharedInstance{
    @synchronized(self)
    {
        if (sharedInstance == nil) {
			sharedInstance = [[SalesforceSyncHelper alloc] init];
            processRecordsQueue = dispatch_queue_create("com.prashant.processJSON", NULL);
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


@end
