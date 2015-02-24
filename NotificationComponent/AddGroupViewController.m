//
//  AddGroupViewController.m
//  NotificationComponent
//
//  Created by Furqan Saleem on 29/11/2014.
//  Copyright (c) 2014 Chau Solutions. All rights reserved.
//

#import "AddGroupViewController.h"

@interface AddGroupViewController ()

@end

@implementation AddGroupViewController
@synthesize selectedGroupObj;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    notificationStringArray = [[NSMutableArray alloc] init];
    selectedInterval = 0;
    [self prepareForEdit];
    
    //[self.selectedIntervalLabel setText:[NSString stringWithFormat:@" %ld Sec",selectedInterval]];
    
    //Do any additional setup after loading the view.
}



-(void)prepareForEdit{

    if (self.editMode == YES) {
        
        self.selectedDateLabel.text     = [NSString stringWithFormat:@"%@",selectedGroupObj.notificationFireTime];
        
        self.selectedIntervalLabel.text = [NSString stringWithFormat:@"%d Sec",selectedGroupObj.repetationPeriod];
        
        selectedInterval                = selectedGroupObj.repetationPeriod;
        
        self.groupNameTextField.text    = selectedGroupObj.groupName;
        
        [self.notificationEnableSwitch setOn:selectedGroupObj.isEnable animated:YES];
        
        [self.enableSwitch setOn:selectedGroupObj.isEnable animated:YES];
        
        notificationStringArray = [[DatabaseClass sharedManager] selectNotificationData:selectedGroupObj.groupId];
    
        selectedDate = selectedGroupObj.notificationFireTime;
     
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 60;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld Sec", (long)row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

    selectedInterval = row;
    
    NSLog(@"selected value %ld",(long)row);

}

- (IBAction)addNotificationMassege:(id)sender {
    

    UIAlertView *alertViewChangeName = [[UIAlertView alloc] initWithTitle:@"Enter Notification String" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    
    alertViewChangeName.alertViewStyle=UIAlertViewStylePlainTextInput;

    [alertViewChangeName show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 123456) {
        return;
    }
    
    if (buttonIndex == 0) {
        NSString *editedGroupName = [[alertView textFieldAtIndex:0] text];
        if (editedGroupName.length >0) {
            
            NSString *previoustText = self.notificationMsgTextView.text;
            
            NotificationModel *notificationObj = [[NotificationModel alloc] init];
            notificationObj.notificationString = editedGroupName;
            
            [notificationStringArray addObject:notificationObj];
            
            NSString *combineText = [editedGroupName stringByAppendingString:[NSString stringWithFormat:@",%@",previoustText]];
            
            [self.notificationMsgTextView setText:combineText];

        }
        
    }
    
}


- (IBAction)selectIntervalButtonPressed:(id)sender {
    
    datePickerView = [[UIView alloc ] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 400)];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneIntervalPicker)] ];
    
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelIntervalPicker)] ];
    
    [toolbar setItems:items animated:NO];
    
    [datePickerView addSubview:toolbar];
    
    intervalPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 300)];
    intervalPicker.dataSource = self;
    intervalPicker.delegate = self;
    [intervalPicker setBackgroundColor:[UIColor whiteColor]];
    [datePickerView addSubview:intervalPicker];
    
    [self.view addSubview:datePickerView];
    
}
-(void)doneIntervalPicker{
 
    NSLog(@"selectedInterval %ld",selectedInterval);
    [self.selectedIntervalLabel setText:[NSString stringWithFormat:@" %ld Sec",selectedInterval]];
    [datePickerView removeFromSuperview];

}

-(void)cancelIntervalPicker{
    
    [datePickerView removeFromSuperview];

}
- (IBAction)selectDateButtonPressed:(id)sender {
    
    
    datePickerView = [[UIView alloc ] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 400)];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneDatePicker)] ];
    
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDatePicker)] ];
    
    [toolbar setItems:items animated:NO];
    
    [datePickerView addSubview:toolbar];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 300)];
    
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePickerView addSubview:datePicker];
    [self.view addSubview:datePickerView];
    

}
-(void)cancelDatePicker{
//
    [datePickerView removeFromSuperview];

}
-(void)doneDatePicker{
    
    NSLog(@"selected date  %@",datePicker.date);
    selectedDate = datePicker.date;
    [self.selectedDateLabel setText:[NSString stringWithFormat:@"%@",datePicker.date]];
    [datePickerView removeFromSuperview];
    
    
}

// when user save the changes this method will call in both add new group and edit group
- (IBAction)SaveButtonPressed:(id)sender {
    
    NSLog(@"selected date  %@",selectedDate);
    
    if ([self.groupNameTextField.text length]==0) {
        [self showWarningAlert:@"Group Name can not Be Empty" WithTitle:@"Warning"];
        return;
    }
    
    if (selectedDate == NULL) {
        [self showWarningAlert:@"Please select Start Date" WithTitle:@"Warning"];
        return;
    }
    else{
    
        NSDate *today = [NSDate date]; // it will give you current date
        NSComparisonResult result;
        
        result = [selectedDate compare:today]; // comparing two dates
        
        if(result==NSOrderedAscending&&self.editMode==NO){
            
            NSLog(@"datePicker.date is less");
            [self showWarningAlert:@"Can not select previous date" WithTitle:@"Warning"];
            return;
            
        }
        else{
            
            
        }
    }
    if ([notificationStringArray count] == 0) {
        [self showWarningAlert:@"Please add atleast one notification massege" WithTitle:@"Warning"];
        return;
    }

    if (selectedInterval <= 0) {
        [self showWarningAlert:@"Please select notification interval more then 0" WithTitle:@"Warning"];
        return;
    }
    
    GroupsModel *groupToAdd             = [[GroupsModel alloc] init];
    groupToAdd.notificationFireTime     = selectedDate;
    groupToAdd.repetationPeriod         = (int)selectedInterval;
    groupToAdd.groupName                = self.groupNameTextField.text;
    groupToAdd.isEnable                 = self.notificationEnableSwitch.isOn;
    groupToAdd.notificationMsgArray     = notificationStringArray;
    groupToAdd.groupId                  = selectedGroupObj.groupId;
    groupToAdd.notificationSize         = (int)[notificationStringArray count];
    
    if (self.editMode== YES) {
        
        [[DatabaseClass sharedManager] updateGroup:groupToAdd];
        
        NotificationManager *notificationManagerObj = [[NotificationManager alloc] init];
        
        [notificationManagerObj updateNotifications];
        
        [self showWarningAlert:@"Successfully Update" WithTitle:groupToAdd.groupName];
        
        
    }
    else {
        
        [[DatabaseClass sharedManager] saveGroup:groupToAdd];

        NotificationManager *notificationManagerObj = [[NotificationManager alloc] init];
        
        [notificationManagerObj updateNotifications];
        
        [self showWarningAlert:@"Successfully Saved" WithTitle:groupToAdd.groupName];
        
    }
}

-(void)showWarningAlert:(NSString*)msg WithTitle:(NSString*)titleParam{

    UIAlertView *dateAlert = [[UIAlertView alloc] initWithTitle:titleParam message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    dateAlert.tag = 123456;
    [dateAlert show];

}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(NSDate*)stringToDate:(NSString *)dateString{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss Z"];
    NSDate *dateFromDb = [dateFormat dateFromString:dateString];
    NSLog(@"date %@",dateFromDb);
    return dateFromDb;
}

@end
