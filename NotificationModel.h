//
//  NotificationModel.h
//  NotificationComponent
//
//  Created by Furqan Saleem on 29/11/2014.
//  Copyright (c) 2014 Chau Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationModel : NSObject

@property(nonatomic) int notificationId;
@property(nonatomic) int groupId;
@property(nonatomic,strong)NSDate *notificationFireTime; 
@property(nonatomic,strong) NSString * notificationString;

@end
