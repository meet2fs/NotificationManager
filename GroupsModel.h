//
//  GroupsModel.h
//  NotificationComponent
//
//  Created by Furqan Saleem on 27/11/2014.
//  Copyright (c) 2014 Chau Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationModel.h"

@interface GroupsModel : NSObject


-(id)init;


@property(nonatomic,strong) NSMutableArray *notificationMsgArray;
@property(nonatomic,strong) NSString *notificationString;
@property(nonatomic,strong) NSString *groupName;
@property(nonatomic,strong) NSDate  *notificationFireTime;
@property(nonatomic) int    repetationPeriod;
@property(nonatomic) int    groupId;
@property(nonatomic) int    nextNotificationPosition;
@property(nonatomic) int    loopCount;
@property(nonatomic) int    notificationSize;
@property(nonatomic) BOOL   isEnable;




@end
