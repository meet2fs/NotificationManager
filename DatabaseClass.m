//
//  DatabaseClass.m
//  QuraniQaida
//
//  Created by Furqan Saleem on 15/10/2014.
//  Copyright (c) 2014 chauSolutions All rights reserved.
//

#import "DatabaseClass.h"
#define DataBaseName @"Notification.sqlite"

@implementation DatabaseClass
@synthesize databaseObj;

// singalton object of database

+ (id)sharedManager {
    static DatabaseClass *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self CopyDatabase];
        databaseObj = [FMDatabase databaseWithPath:[self DatabasePath]];
    }
    
    return self;
    // Do any additional setup after loading the view from its nib.
}

- (NSString*)DatabasePath
{
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocumentDir = [Paths objectAtIndex:0];
    return [DocumentDir stringByAppendingPathComponent:DataBaseName];
    
}

// This method copy the data base file
- (void)CopyDatabase
{
    BOOL success;
    NSLog(@" full path = %@",[self DatabasePath]);
    
    success = [[NSFileManager defaultManager] fileExistsAtPath:[self DatabasePath]];
    NSString *FileDB = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:DataBaseName];
    
    if (success==YES)
    {
        NSLog(@"File Exist");
        
    }
    else
    {
        [[NSFileManager defaultManager] copyItemAtPath:FileDB toPath:[self DatabasePath] error:nil];
        
    }
}

#pragma mark GROUP CRUD methods

-(BOOL)saveGroup:(GroupsModel*)groupParam{

    [self.databaseObj open];
    
    long timeInLong = [groupParam.notificationFireTime timeIntervalSince1970];
    NSString  *Query = [NSString stringWithFormat:@"INSERT into Groups (GROUP_NAME,NOTIFICATION_START_TIME,IS_ENABLE,TIME_INTERVAL,NEXT_NOTIFICATION_POSITION,LOOP_COUNT,NOTIFICATION_SIZE) VALUES ('%@',%ld,%d,%d,%d,%d,%d)",groupParam.groupName,timeInLong,groupParam.isEnable,groupParam.repetationPeriod,groupParam.nextNotificationPosition,groupParam.loopCount,groupParam.notificationSize];
    
    BOOL result = [self.databaseObj executeUpdate:Query];
    int groupId = (int)[self.databaseObj lastInsertRowId];
    [self.databaseObj close];
    
    for (NotificationModel *notificationObj in groupParam.notificationMsgArray) {
        [self saveNotificationString:groupId withString:notificationObj.notificationString];
    }

    return result;
}

-(BOOL)updateGroup:(GroupsModel*)groupParam{

    [self.databaseObj open];
    
    long timeInLong = [groupParam.notificationFireTime timeIntervalSince1970];
    
    NSString  *Query = [NSString stringWithFormat:@"UPDATE Groups set GROUP_NAME = '%@', IS_ENABLE = %d, TIME_INTERVAL = %d, NOTIFICATION_START_TIME = %ld, NEXT_NOTIFICATION_POSITION = %d, LOOP_COUNT = %d WHERE GROUP_ID = %d",groupParam.groupName,groupParam.isEnable,groupParam.repetationPeriod,timeInLong,groupParam.nextNotificationPosition,groupParam.loopCount,groupParam.groupId];

    BOOL result = [self.databaseObj executeUpdate:Query];
    
    [self.databaseObj close];
    
    return result;

}
// this function update the group notification start time
-(BOOL)updateGroupStartTime:(GroupsModel*)groupParam{
    
    [self.databaseObj open];
    //yime and date save in DB in form of sec
    long timeInLong = [groupParam.notificationFireTime timeIntervalSince1970];
    
    NSString  *Query = [NSString stringWithFormat:@"UPDATE Groups set NOTIFICATION_START_TIME = %ld WHERE GROUP_ID = %d",timeInLong,groupParam.groupId];
    
    BOOL result = [self.databaseObj executeUpdate:Query];
    
    [self.databaseObj close];
    
    
    return result;
    
}
// this function search or check is givin group already added
-(BOOL)isGroupFound:(GroupsModel*)groupParam{
    
    [self.databaseObj open];
    
    NSString  *Query = [NSString stringWithFormat:@"SELECT Count(*) Groups WHERE GROUP_NAME = '%@'",groupParam.groupName];
        BOOL isResultFound = NO;
    int resultCount = [self.databaseObj intForQuery:Query];
    
    [self.databaseObj close];
    
    if (resultCount==0) {
        isResultFound = NO;
    }
    else{
        isResultFound = YES;
        
    }
    
    return isResultFound;
    
}



// this function will delete all notification belong to a group then delete group its self
-(BOOL)deleteGroupWithNotifications:(GroupsModel*)groupParam{

    BOOL isDelete ;
    if ([self deleteNotificaiton:groupParam.groupId]) {
        isDelete = [self deleteGroup:groupParam];
    }
    return isDelete;
}

// this function will delete group
-(BOOL)deleteGroup:(GroupsModel*)groupParam{

    [self.databaseObj open];
    
    NSString  *Query = [NSString stringWithFormat:@"DELETE From Groups WHERE GROUP_ID = '%d'",groupParam.groupId];
    
    BOOL result = [self.databaseObj executeUpdate:Query];
    
    [self.databaseObj close];
    
    
    return result;
    
}
// this function will select Group  and also select its notification
// we are not using any query in query OR joins
-(NSMutableArray*)selectAllGroupWithNotification{

    NSMutableArray *allGroupArray = [self selectAllGroup];
    for (GroupsModel *tempGroupObj in allGroupArray) {
        
        tempGroupObj.notificationMsgArray = [self selectNotificationData:tempGroupObj.groupId];
        
    }
    return allGroupArray;
}

// this function will select ALL Group
-(NSMutableArray*)selectAllGroup{

    [self.databaseObj open];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    NSString  *Query = [NSString stringWithFormat:@"SELECT * FROM Groups "];
    
    FMResultSet *result = [self.databaseObj executeQuery:Query];
    
    while ([result next]) {
        
        
        GroupsModel *group            = [[GroupsModel alloc] init];
        group.groupId                 = [result intForColumn:@"GROUP_ID"];
        group.groupName               = [result stringForColumn:@"GROUP_NAME"];
        group.notificationFireTime    = [self longToDate:[result longForColumn:@"NOTIFICATION_START_TIME"]];
        group.repetationPeriod        = [result intForColumn:@"TIME_INTERVAL"];
        group.nextNotificationPosition= [result intForColumn:@"NEXT_NOTIFICATION_POSITION"];
        group.loopCount               = [result intForColumn:@"LOOP_COUNT"];
        group.notificationSize        = [result intForColumn:@"NOTIFICATION_SIZE"];
        group.isEnable                = [result intForColumn:@"IS_ENABLE"];
        [resultArray addObject:group];
    }
    
    [self.databaseObj close];
    return resultArray;
    
}
// this function will select Group
-(GroupsModel*)selectGroup:(int)groupId{
    
    [self.databaseObj open];
    GroupsModel *group = [[GroupsModel alloc] init];
    NSString  *Query = [NSString stringWithFormat:@"SELECT * FROM Groups WHERE GROUP_ID = '%d'",groupId];
    
    FMResultSet *result = [self.databaseObj executeQuery:Query];
    
    while ([result next]) {
        
        group.groupId                 = [result intForColumn:@"GROUP_ID"];
        group.groupName               = [result stringForColumn:@"GROUP_NAME"];
        group.notificationFireTime    = [self longToDate:[result longForColumn:@"NOTIFICATION_START_TIME"]];
        group.repetationPeriod        = [result intForColumn:@"TIME_INTERVAL"];
        group.nextNotificationPosition= [result intForColumn:@"NEXT_NOTIFICATION_POSITION"];
        group.loopCount               = [result intForColumn:@"LOOP_COUNT"];
        group.notificationSize        = [result intForColumn:@"NOTIFICATION_SIZE"];
        group.isEnable                = [result intForColumn:@"IS_ENABLE"];
    }
    
    [self.databaseObj close];
    return group;
    
}

#pragma mark NOTIFICATIONS CRUD methods

// This function will select Notification
-(NSMutableArray*)selectNotificationData:(int)groupIdParam{

    [self.databaseObj open];
    
    NSString  *Query = [NSString stringWithFormat:@"SELECT * FROM Notifications WHERE GROUP_ID = '%d'",groupIdParam];
    
    FMResultSet *result = [self.databaseObj executeQuery:Query];
    NSMutableArray *notificationArray = [[NSMutableArray alloc] init];
    while ([result next]) {
        
        NotificationModel *notificationObj = [[NotificationModel alloc] init];
        notificationObj.groupId               = [result intForColumn:@"GROUP_ID"];
        notificationObj.notificationId        = [result intForColumn:@"NOTIFICATION_ID"];
        notificationObj.notificationString    = [result stringForColumn:@"NOTIFICATION_STRING"];
        [notificationArray addObject:notificationObj];
    }
    
    [self.databaseObj close];
    return notificationArray;

}

// This function will Save Notification
-(void)saveNotificationString:(int )groupID withString:(NSString*)string{

    [self.databaseObj open];
    NSString * Query =  [NSString stringWithFormat:@"INSERT INTO Notifications (GROUP_ID,NOTIFICATION_STRING) VALUES (%d,'%@')",groupID,string];
    [self.databaseObj executeUpdate:Query];
    [self.databaseObj close];

}
// This function will delete Notification of givin groupID
-(BOOL)deleteNotificaiton:(int)groupIdParam{

    [self.databaseObj open];
    NSString  *Query = [NSString stringWithFormat:@"DELETE From Notifications WHERE GROUP_ID = '%d'",groupIdParam];
    BOOL result = [self.databaseObj executeUpdate:Query];
    [self.databaseObj close];
    
    return result;

}

// WE are saving timeinterval in DB so this function ruturn as date of timeinterval
-(NSDate*)longToDate:(long)sec{
    
    NSDate *dateFromDb;
    if ( sec != 0) {
        
        dateFromDb = [NSDate dateWithTimeIntervalSince1970:sec];
    }
    else{
        
        dateFromDb = [[NSDate date] dateByAddingTimeInterval:10];
    }
    
    
    return dateFromDb;
}


@end
