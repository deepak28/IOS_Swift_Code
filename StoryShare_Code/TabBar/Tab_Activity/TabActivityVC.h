//
//  TabActivityVC.h
//  Share_Story
//
//  Created by Ankush on 2/7/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODRefreshControl.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "TVTwitterController.h"

@interface TabActivityVC : UIViewController<UITableViewDelegate,UITableViewDataSource,FBSDKSharingDelegate,TVTwitterDelegate,UIAlertViewDelegate>
{
    NSString *strForIsMore;
    int pageNoCount;
    ODRefreshControl *refreshControl1;
    BOOL isRefreshNoification;
}

@property (weak, nonatomic) IBOutlet UIView *viewForStatus;
- (IBAction)actionOnHomeBtn:(id)sender;
- (IBAction)actionOnSetting:(id)sender;
- (IBAction)actionOnDeleteBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnForDelete;
@property (weak, nonatomic) IBOutlet UITableView *tblViewActivityList;
@property (strong, nonatomic) NSMutableArray *arryForActivityList;

@end
