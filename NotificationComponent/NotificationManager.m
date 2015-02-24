//
//  NotificationManager.m
//  NotificationComponent
//
//  Created by Furqan Saleem on 27/11/2014.
//  Copyright (c) 2014 Chau Solutions. All rights reserved.
//

#import "NotificationManager.h"

@implementation NotificationManager


-(id)init{

    self = [super init];
    if (self) {
        
        self.isRepeatOn  = YES;//[[NSUserDefaults standardUserDefaults] boolForKey:@"REPEATKEY"];
      
    
    }
    return self;
}


-(UILocalNotification*)createNotification:(NotificationModel*)notParam {

    //  here we creating notification to schedule it
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate  = notParam.notificationFireTime;

    localNotification.alertBody = [NSString stringWithFormat:@"%@ for Group %d",notParam.notificationString,notParam.groupId ];
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotification.soundName= UILocalNotificationDefaultSoundName;
    
    NSLog(@"fire date  %@",localNotification.fireDate);
    
    return localNotification;
    
}

-(NotificationModel*)createNotificationObject:(GroupsModel*)groupParam with:(long)notificationFireTime{

    // this function create and provide all important information to create UILocalNotification
    NotificationModel *notificationObj   = (NotificationModel*)[groupParam.notificationMsgArray objectAtIndex:groupParam.nextNotificationPosition];
    
    NSString *notificationString         = notificationObj.notificationString;
    
    NSLog(@"notification Group %@ ",groupParam.groupName);
    
    // crearting date from timeinterval , this date will be fire date of notification
    notificationObj.notificationFireTime =  [NSDate dateWithTimeIntervalSince1970:notificationFireTime];
    
    notificationObj.notificationString   = notificationString;
    
    notificationObj.groupId              = groupParam.groupId;

    return notificationObj;
}



-(void)scheduleNotificationsToFillTheBucket
{
    // here i check how much notification are schedule
    long numberOfScheduledLocalNotifications = [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
    // here i check how much notification fired
    int numberOfEmptyNotificationSlots = 64 - (int)numberOfScheduledLocalNotifications;
    
    NSLog(@"numberOfEmptyNotificationSlots %d",numberOfEmptyNotificationSlots);
   
    
    // n number of notification are re fill in uiapplication 64 notification bucket
    for(int i =0;i < numberOfEmptyNotificationSlots; i++) {
        
        		
       UILocalNotification *localNotification = [self getSoonestLocalNotifiation];
        if (localNotification != nil) {
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        else{
            
            // If ve have not received any notification from getSoonestLocalNotifiation then it means all notifications heve been used and there is no more to be added
            
            break;
        
        }
        
    }
    
    NSLog(@" scheduled notification %lu",(unsigned long)[[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
}


-(UILocalNotification*)getSoonestLocalNotifiation {
    
// loop all groups and find getNextLocalNotificationFireTime of all , and keep the soonest
    
    NSMutableArray *groupArray     = [[DatabaseClass sharedManager] selectAllGroupWithNotification];
    
    GroupsModel *selectedTempGroup = nil;//[groupArray objectAtIndex:0];
    long selectedFireTime          = 0;//[self getNextLocalNotificationFireTime:selectedTempGroup];
    
    
    for (GroupsModel *tempGroupObj in groupArray) {
        // cehcking is user wants notification or not.
        if (tempGroupObj.isEnable == NO) {
            continue;
        }
        
        if (selectedTempGroup == nil) {
            
            if (tempGroupObj.nextNotificationPosition < tempGroupObj.notificationSize) {
                selectedTempGroup = tempGroupObj;
                selectedFireTime  = [self getNextLocalNotificationFireTime:selectedTempGroup];
            }
            
            continue;
            
        }
 
        if (tempGroupObj.nextNotificationPosition >= tempGroupObj.notificationSize ) {
            
            continue;
            
        }
        
        long tempFireTime  = [self getNextLocalNotificationFireTime:tempGroupObj];
        
        if (selectedFireTime > tempFireTime) {
            selectedFireTime    = tempFireTime;
            selectedTempGroup   = tempGroupObj;
            
        }
     }
    // check if the sekectedgroup is not nill and that group has not reached its limit as well
    if (selectedTempGroup == nil) {
         return nil;
    }
    
    UILocalNotification *notification = [self createNotification:[self createNotificationObject:selectedTempGroup  with:(long)selectedFireTime]];
    
    if (![self updateIncrementGroupPosition:selectedTempGroup]) {
        return nil;
    }
    
    return notification;
}

-(long)getNextLocalNotificationFireTime:(GroupsModel*)groupParam{
    
    //TODO: loop the group position until fire time becomes grater then current time; and save the new position and loop count of the group in the database
    int  position           = groupParam.nextNotificationPosition;
    int  loopCount          = groupParam.loopCount;
    int  noOfNotification   = groupParam.notificationSize;
    long startTime          = [groupParam.notificationFireTime timeIntervalSince1970];
    long timeInterval       = groupParam.repetationPeriod;
    long fireTime           = startTime + (position * timeInterval) + (timeInterval*noOfNotification*loopCount );
    
    return fireTime;
}

-(BOOL)updateIncrementGroupPosition:(GroupsModel*)groupParam{

    int  position           = groupParam.nextNotificationPosition;
    int  loopCount          = groupParam.loopCount;
    int  noOfNotification   = groupParam.notificationSize;
    
    position++;
    
    if (position >= noOfNotification && self.isRepeatOn == YES) {
        
        position = 0;
        loopCount++;
        
    }
    
     groupParam.nextNotificationPosition = position;
     groupParam.loopCount                = loopCount;
     groupParam.notificationSize         = noOfNotification ;
    
   return [[DatabaseClass sharedManager] updateGroup:groupParam];
}


-(NSDate*)addTimeInCurrentDate:(NSTimeInterval)time{

    
    NSDate *dateEightHoursAhead = selectedGroup.notificationFireTime;
    //NSLog(@"old date %@",dateEightHoursAhead);
    NSDate *nextNotificationDate = [dateEightHoursAhead dateByAddingTimeInterval:time];
    //NSLog(@"new date %@",nextNotificationDate);
    return nextNotificationDate;
}

-(void)updateNotifications{

    NSMutableArray *groupArray     = [[DatabaseClass sharedManager] selectAllGroupWithNotification];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    long currentTime               = [[NSDate date] timeIntervalSince1970];
    
    for ( GroupsModel *groupObj in groupArray) {
    
        BOOL isGraterDateFound =  NO;
        int position           = 0 ;
        int loopCount          = 0 ;
      
        
        while (isGraterDateFound == NO) {
            groupObj.nextNotificationPosition = position;
            groupObj.loopCount                = loopCount;
            
           long fireTime = [self getNextLocalNotificationFireTime:groupObj];
            
            if (fireTime > currentTime) {
                
                isGraterDateFound = YES;
        
            }
            else{
                position++;
                if (position == groupObj.notificationSize ) {
                    if (self.isRepeatOn == NO ) {
                        isGraterDateFound = YES;
                    }
                    else{
                        loopCount++;
                        position = 0;
                    }
                }
            
            }
            
        }
     
        [[DatabaseClass sharedManager] updateGroup:groupObj];
    }
    
    [self scheduleNotificationsToFillTheBucket];
}


@end
