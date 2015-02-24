//
//  GroupsTableViewController.h
//  NotificationComponent
//
//  Created by Furqan Saleem on 27/11/2014.
//  Copyright (c) 2014 Chau Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupsModel.h"
#import "DatabaseClass.h"
#import "AddGroupViewController.h"
#import "NotificationManager.h"


@interface GroupsTableViewController : UITableViewController <UIAlertViewDelegate>
{
    int selectedIndex;
    NSMutableArray *groupArray;
}


@end
