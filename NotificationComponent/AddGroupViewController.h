//
//  AddGroupViewController.h
//  NotificationComponent
//
//  Created by Furqan Saleem on 29/11/2014.
//  Copyright (c) 2014 Chau Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupsModel.h"
#import "NotificationModel.h"
#import "DatabaseClass.h"
#import "NotificationManager.h"

@interface AddGroupViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>{

    UIDatePicker *datePicker;
    UIPickerView *intervalPicker;
    UIView *datePickerView;
    long selectedInterval;
    NSMutableArray *notificationStringArray;
    NSDate *selectedDate;
    
}

@property (nonatomic) BOOL editMode;
@property (weak, nonatomic) GroupsModel* selectedGroupObj;
@property (weak, nonatomic) IBOutlet UITextView *notificationMsgTextView;
@property (weak, nonatomic) IBOutlet UILabel *selectedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedIntervalLabel;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *notificationEnableSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;

- (IBAction)addNotificationMassege:(id)sender;

- (IBAction)selectIntervalButtonPressed:(id)sender;

- (IBAction)selectDateButtonPressed:(id)sender;

- (IBAction)SaveButtonPressed:(id)sender;
@end
