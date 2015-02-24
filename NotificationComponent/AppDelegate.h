//
//  AppDelegate.h
//  NotificationComponent
//
//  Created by Furqan Saleem on 27/11/2014.
//  Copyright (c) 2014 Chau Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

    UILocalNotification* localNotification;
    NotificationManager *notificationMngrObj;

}
@property (strong, nonatomic) UIWindow *window;



@end

