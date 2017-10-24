//
//  TabActivityVC.m
//  Share_Story
//
//  Created by Ankush on 2/7/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import "TabActivityVC.h"
#import "Constant.h"
#import "TabActivity_Cell.h"
#import "SettingsVC.h"
#import "HomeVC.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "TVTwitterController.h"
#import "MTReachabilityManager.h"
#import <Social/Social.h>
#import <UIKit/UIKit.h>
#import "CreateStoryVC.h"
#import "StoryDetailVC.h"
#import "UIView+Toast.h"

@interface TabActivityVC ()
{
    NSInteger _indexPathForDelete;
    NSString *strForDeleteType;
    UIActivityIndicatorView *activityIndicator;
    NSUInteger tagForIndex;
    NSString *strForLikeUnlike;
    NSString *strForDetailsHandler;
    NSDictionary *dictDetailsHandler;
}
@end

@implementation TabActivityVC

@synthesize tblViewActivityList,arryForActivityList,viewForStatus;

- (void)viewDidLoad {
    [super viewDidLoad];
    isRefreshNoification= NO;
    arryForActivityList=[[NSMutableArray alloc] init];
    
    // Pull to Refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    [tblViewActivityList addSubview:refreshControl];
    self.navigationController.navigationBar.hidden=YES;
    self.navigationController.navigationBarHidden=YES;
}
//****************Change Color Status****************************//
-(void)status_bar_color
{
    UIApplication *app = [UIApplication sharedApplication];
    CGFloat statusBarHeight = app.statusBarFrame.size.height;
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, statusBarHeight)];
    [viewForStatus addSubview:statusBarView];
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[AppDelegate sharedInstance] setTabBarHidden:NO];
    [self.navigationController.navigationItem hidesBackButton];
    [arryForActivityList removeAllObjects];
    [tblViewActivityList reloadData];
    strForIsMore=@"";
    strForDetailsHandler=@"";
    pageNoCount=1;
    [self getNotificationListWeb];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 50, 0);
    self.tblViewActivityList.contentInset = insets;
    self.tblViewActivityList.scrollIndicatorInsets = insets;
}
#pragma  mark Tableview Delegates
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [arryForActivityList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([arryForActivityList count] - 1 == indexPath.row){
        if([strForIsMore isEqualToString:@"Yes"])
        {
            [self performSelector:@selector(getNotificationListWeb) withObject:nil];
        }
    }
    TabActivity_Cell *cell=[tblViewActivityList dequeueReusableCellWithIdentifier:@"TabActivity_Cell"];
    if (cell == nil)
    {
        [tableView registerNib:[UINib nibWithNibName:@"TabActivity_Cell" bundle:nil] forCellReuseIdentifier:@"TabActivity_Cell"];
        cell=[tableView dequeueReusableCellWithIdentifier:@"TabActivity_Cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary*dictNotification=[arryForActivityList objectAtIndex:indexPath.row];
    cell.lblForImageLbl.text=[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"];
    cell.lblForStoryName.text=[[dictNotification valueForKey:@"story_id"] valueForKey:@"story_title"];
    cell.lblForLikedNames.text=[dictNotification valueForKey:@"message"];
    cell.lblForDate.text=[dictNotification valueForKey:@"createdAt"];
    
    if ([[dictNotification valueForKey:@"is_liked"] integerValue]==1) {
        cell.imgForLike.image = [UIImage imageNamed:@"create_like_on"];
    }else{
        cell.imgForLike.image = [UIImage imageNamed:@"create_like_off"];
    }
    if ([[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Miscellaneous"]) {
        cell.imgForStoryBook.image=[UIImage imageNamed:@"new_adult"];
    }else if ([[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Children"]) {
        cell.imgForStoryBook.image=[UIImage imageNamed:@"new_children"];
    }else if ([[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Adult"]) {
        cell.imgForStoryBook.image=[UIImage imageNamed:@"new_adult"];
    }else if ([[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"SCi-fi/Tech"]) {
        cell.imgForStoryBook.image=[UIImage imageNamed:@"new_sci-fi"];
    }else if ([[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Drama"]) {
        cell.imgForStoryBook.image=[UIImage imageNamed:@"new_drama"];
    }else if ([[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Horror"]) {
        cell.imgForStoryBook.image=[UIImage imageNamed:@"new_horror"];
    }else if ([[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Comedy"]) {
        cell.imgForStoryBook.image=[UIImage imageNamed:@"new_comedy"];
    }else if ([[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Thriller"]) {
        cell.imgForStoryBook.image=[UIImage imageNamed:@"new_adult"];
    }else if ([[[dictNotification valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Romance"]) {
        cell.imgForStoryBook.image=[UIImage imageNamed:@"new_romance"];
    }
    
    [cell.btnForLike setTag:indexPath.row];
    [cell.btnForLike addTarget:self action:@selector(actionOnLikeBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btnForShareStory setTag:indexPath.row];
    [cell.btnForShareStory addTarget:self action:@selector(actionOnShareStory:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    strForDetailsHandler=@"2";
    [self getStoryDetailsWeb];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5) {
        return 73;
    }else if (IS_IPHONE_6){
        return 83;
    }else{
        return 93;
    }
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"     "  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your deleteAction here
        strForDeleteType=@"1";
        _indexPathForDelete = indexPath.row;
        [self getDeleteNotificationWeb];
    }];
    deleteAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"delete_newsfeed"]];
    return @[deleteAction];
}
// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (editingStyle == UITableViewCellEditingStyleDelete)
    //    {
    //        strForDeleteType=@"1";
    //        _indexPathForDelete = indexPath.row;
    //        [self getDeleteNotificationWeb];
    //    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
- (IBAction)actionOnHomeBtn:(id)sender {
    NSArray *viewControllers = [[AppDelegate sharedInstance].navigationMain viewControllers];
    for (int i=0; i<viewControllers.count; i++) {
        if ([[viewControllers objectAtIndex:i] isKindOfClass:[HomeVC class]])
        {
            [self.navigationController.navigationBar setHidden:NO];
            [[AppDelegate sharedInstance].navigationMain popToViewController:[viewControllers objectAtIndex:i] animated:YES];
        }
    }
}
- (IBAction)actionOnSetting:(id)sender {
    [TVStoredData sharedInstance].strCommingForSetting=@"";
    SettingsVC *objSettingVC = [[SettingsVC alloc]init];
    [self.navigationController pushViewController:objSettingVC animated:YES];
}
- (IBAction)actionOnDeleteBtn:(UIButton *)sender {
    if(arryForActivityList.count > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"StoryShare" message:@"Are you sure, you want to clear your newsfeeds" delegate:self cancelButtonTitle:@"Yes, I'm sure" otherButtonTitles:@"Cancel", nil];
        alert.tag = 1;
        [alert show];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"StoryShare" message:@"No Notification found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}
- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the user clicked one of the OK/Cancel buttons
    if (alert.tag==101) {
        switch (buttonIndex){
            case 0:
                break;
            case 1:
                [self sharingWithFacebook];
                break;
            case 2:
                [self sharingWithTwitter];
                break;
            default:
                break;
        }
    }else{
        if(alert.tag == 1)
        {
            if(buttonIndex == alert.cancelButtonIndex)
            {
                strForDeleteType=@"2";
                [self getDeleteNotificationWeb];
            }
            else
            {
            }
        }
    }
}

-(void)actionOnLikeBtn:(UIButton*)sender{
    tagForIndex = sender.tag;
    if([[[arryForActivityList objectAtIndex:tagForIndex] valueForKey:@"is_liked"] integerValue]==1){
        strForLikeUnlike=@"";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getStoryLikeWeb];
        });
    }else{
        strForLikeUnlike=@"1";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getStoryLikeWeb];
        });
        
    }
}
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(getNotificationListPullToRefresh) withObject:nil afterDelay:0.0];
        refreshControl1 = refreshControl;
        pageNoCount=1;
        isRefreshNoification=YES;
    });
}

#pragma mark:WebService Notification List Method:---
-(void)getNotificationListWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        if([arryForActivityList count]>0)
        {
            pageNoCount=(int)([arryForActivityList count]/10);
            if(arryForActivityList==0)
            {
                pageNoCount=1;
            }else{
                pageNoCount=(int)([arryForActivityList count]/10)+1;
            }
        }
        if (pageNoCount>1) {
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityIndicator startAnimating];
            activityIndicator.frame = CGRectMake(0, 0, 320, 50);
            tblViewActivityList.tableFooterView = activityIndicator;
        }else{
            [AppDelegate showHud];
        }
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getNotificationListHandler:)];
        [service getNotificationList_page_no:[NSString stringWithFormat:@"%d",pageNoCount]];
    }
}
#pragma mark:Handler Notification List Note---
-(void)getNotificationListHandler:(id)sender{
    [activityIndicator stopAnimating];
    tblViewActivityList.tableFooterView = 0;
    [AppDelegate killHud];
    if([sender isKindOfClass:[NSError class]])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"Oops! Something went wrong. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else
    {
        if ([sender isKindOfClass:[NSArray class]])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"All fields are required." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            if([[sender valueForKey:@"status"] integerValue]==1){
                // 1 - Success
                if (pageNoCount==1) {
                    [arryForActivityList removeAllObjects];
                }
                [arryForActivityList addObjectsFromArray:[[sender valueForKey:@"data"] mutableCopy]];
                if ([[sender valueForKey:@"data"] count]<10) {
                    strForIsMore=@"No";
                }else{
                    strForIsMore=@"Yes";
                }
                if ([arryForActivityList count] < 1 ) {
                    
                }
                [tblViewActivityList setDelegate:self];
                [tblViewActivityList setDataSource:self];
                [tblViewActivityList reloadData];
            }
            else{
                // Other
            }
        }
    }
}
#pragma mark:WebService Pull To Refresh Notification List Method:---
-(void)getNotificationListPullToRefresh{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [refreshControl1 endRefreshing];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getNotificationListPullToRefreshHandler:)];
        [service getNotificationList_page_no:@"1"];
    }
}
#pragma mark:Handler Pull To Refresh Notification Note---
-(void)getNotificationListPullToRefreshHandler:(id)sender{
    [refreshControl1 endRefreshing];
    if([sender isKindOfClass:[NSError class]])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"Oops! Something went wrong. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else
    {
        if ([sender isKindOfClass:[NSArray class]])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"All fields are required." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            if([[sender valueForKey:@"status"] integerValue]==1){
                // 1 - Success
                if([arryForActivityList count]>0){
                    [arryForActivityList removeAllObjects];
                }
                if ([[sender valueForKey:@"data"] count]<10) {
                    strForIsMore=@"No";
                }else{
                    strForIsMore=@"Yes";
                }
                [arryForActivityList addObjectsFromArray:[[sender valueForKey:@"data"] mutableCopy]];
                if ([arryForActivityList count] < 1 ) {
                    
                }
                [tblViewActivityList setDelegate:self];
                [tblViewActivityList setDataSource:self];
                [tblViewActivityList reloadData];
            }
            else{
                // Other
                NSString*strFormsg=[sender valueForKey:@"message"];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:strFormsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

#pragma mark:WebService Delete Notification Method:---
-(void)getDeleteNotificationWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getDeleteNotificationHandler:)];
        
        [service getDeleteNotification_id:[NSString stringWithFormat:@"%@", [[arryForActivityList objectAtIndex:_indexPathForDelete] valueForKey:@"_id"]] type:strForDeleteType];
    }
}
#pragma mark:Handler Notification List Note---
-(void)getDeleteNotificationHandler:(id)sender{
    [AppDelegate killHud];
    if([sender isKindOfClass:[NSError class]])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"Oops! Something went wrong. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else
    {
        if ([sender isKindOfClass:[NSArray class]])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"All fields are required." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            if([[sender valueForKey:@"status"] integerValue]==1){
                // 1 - Success
                // arryForActivityList=[sender valueForKey:@"data"];
                if ([strForDeleteType isEqualToString:@"1"]) {
                    [arryForActivityList removeObjectAtIndex:_indexPathForDelete];
                    // NSIndexPath *path = [NSIndexPath indexPathForRow:_indexPathForDelete inSection:0];
                    [tblViewActivityList reloadData];
                    //                    [tblViewActivityList beginUpdates];
                    //                    [arryForActivityList removeObjectAtIndex:_indexPathForDelete];
                    //                    [tblViewActivityList deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
                    //                    [tblViewActivityList endUpdates];
                }else{
                    [arryForActivityList removeAllObjects];
                    [tblViewActivityList reloadData];
                }
            }
            else{
                // Other
            }
        }
    }
}

#pragma mark:Webservice Story Like Method:---
-(void)getStoryLikeWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getStoryLikeHandler:)];
        [service getLikeStory_action:strForLikeUnlike story_id:[NSString stringWithFormat:@"%@",[[[arryForActivityList objectAtIndex:tagForIndex] valueForKey:@"story_id"] valueForKey:@"_id"]] genre_id:[NSString stringWithFormat:@"%@",[[[arryForActivityList objectAtIndex:tagForIndex] valueForKey:@"genre_id"] valueForKey:@"_id"]]];
    }
}

#pragma mark:Handler Story Like Method:---
-(void)getStoryLikeHandler:(id)sender{
    [AppDelegate killHud];
    if([sender isKindOfClass:[NSError class]])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"Oops! Something went wrong. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else
    {
        if ([sender isKindOfClass:[NSArray class]])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"All fields are required." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            if([[sender valueForKey:@"status"] integerValue]==1){
                // 1 - Success
                TabActivity_Cell *cell = (TabActivity_Cell*) [tblViewActivityList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tagForIndex inSection:0]];
                NSMutableDictionary*dict=[[NSMutableDictionary alloc] init];
                dict=[[arryForActivityList objectAtIndex:tagForIndex] mutableCopy];
                if ([strForLikeUnlike isEqualToString:@"1"]) {
                    cell.imgForLike.image = [UIImage imageNamed:@"create_like_on"];
                    [dict setValue:@"1" forKey:@"is_liked"];
                }else{
                    cell.imgForLike.image = [UIImage imageNamed:@"create_like_off"];
                    [dict setValue:@"0" forKey:@"is_liked"];
                }
                [arryForActivityList replaceObjectAtIndex:tagForIndex withObject:dict];
                
                // Reload single Table Cell
                NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:tagForIndex inSection:0];
                NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
                [tblViewActivityList reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
            }
            else{
                // Other
            }
        }
    }
}
- (IBAction)actionOnShareStory:(UIButton*)sender {
    strForDetailsHandler=@"1";
    tagForIndex = sender.tag;
    [self getStoryDetailsWeb];
}
//****************Social Share FaceBook****************************//
-(void)sharingWithFacebook{
    if(![MTReachabilityManager isReachable])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"StoryShare" message:@"Server not responding. Please try after some time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil ];
        [alert show];
        return;
    }
    else
    {
        if (FBSDKAccessToken.currentAccessToken != nil)
        {
            // already logged in with the requested permissions
            FBSDKShareLinkContent *LinkContent = [[FBSDKShareLinkContent alloc] init];
            //FBSDKSharePhoto *linkImage = [[FBSDKSharePhoto alloc] init];
            
            //Text
            LinkContent.contentTitle = [NSString stringWithFormat:@"%@",[[dictDetailsHandler valueForKey:@"story_id"] valueForKey:@"story_title"]];
            LinkContent.contentDescription = [NSString stringWithFormat:@"%@",[[[dictDetailsHandler valueForKey:@"story_id"]valueForKey:@"story_users"] valueForKey:@"story_text"]];
            LinkContent.contentURL = [NSURL URLWithString:@"https://www.facebook.com"];
            [FBSDKShareDialog showFromViewController:self withContent:LinkContent delegate:self];
        }
        else
        {
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                if (error) {
                    
                }
                else if (result.isCancelled) {
                    // Handle cancellations
                }
                else {
                    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                    content.contentTitle = [NSString stringWithFormat:@"%@",[[dictDetailsHandler valueForKey:@"story_id"] valueForKey:@"story_title"]];
                    content.contentDescription = [NSString stringWithFormat:@"%@",[[[dictDetailsHandler valueForKey:@"story_id"]valueForKey:@"story_users"] valueForKey:@"story_text"]];
                    [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
                    if ([result.grantedPermissions containsObject:@"email"]) {
                        // Do work
                    }
                }
            }];
        }
    }
}
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary *)results {
    [self getShareStorySocial];
}
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:[error description] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil ];
    [alert show];
}
//****************Social Share Twitter****************************//
-(void)sharingWithTwitter{
    if(![MTReachabilityManager isReachable])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"StoryShare" message:@"Server not responding. Please try after some time." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil ];
        [alert show];
        return;
    }
    else
    {
        [AppDelegate showHud];
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        //Text
        [controller addURL:[NSURL URLWithString:@"https://twitter.com/"]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData  *data;
            //Text
            data=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"https://twitter.com/"]];
            if (data)
            {
                UIImage*image=[[UIImage alloc]initWithData:data];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image)
                    {
                        [controller addImage:image];
                        //Text
                        [controller setInitialText:[NSString stringWithFormat:@"%@",[[dictDetailsHandler valueForKey:@"story_users"] valueForKey:@"story_text"]]];
                        [self performSelector:@selector(remove) withObject:nil afterDelay:0.5];
                        [self presentViewController:controller
                                           animated:YES
                                         completion:^(){
                                         }];
                    }
                    else
                    {
                        //Text
                        [controller setInitialText:[NSString stringWithFormat:@"%@",[[dictDetailsHandler valueForKey:@"story_users"] valueForKey:@"story_text"]]];
                        [self performSelector:@selector(remove) withObject:nil afterDelay:0.5];
                        [self presentViewController:controller
                                           animated:YES
                                         completion:^(){
                                         }];
                    }
                });
            }
        });
        [controller setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             NSString *output;
             switch(result)
             {
                 case SLComposeViewControllerResultCancelled:
                     output = @"Action Cancelled";
                     break;
                 case SLComposeViewControllerResultDone:
                     output = @"Post Successfull";
                     break;
                 default:
                     break;
             }
             if(![output isEqualToString:@"Action Cancelled"])
             {
                 [self getShareStorySocial];
             }
         }];
    }
}
- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}
-(void)remove
{
    [AppDelegate killHud];
}

#pragma mark:WebService Get story Detail Method:---
-(void)getStoryDetailsWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getStoryDetailsHandler:)];
        [service getStory_id:[NSString stringWithFormat:@"%@",[[[arryForActivityList objectAtIndex:tagForIndex] valueForKey:@"story_id"] valueForKey:@"_id"]]];
    }
}

#pragma mark:Handler Get story Detail Method:---
-(void)getStoryDetailsHandler:(id)sender{
    [AppDelegate killHud];
    if([sender isKindOfClass:[NSError class]]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"Oops! Something went wrong. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else
    {
        if ([sender isKindOfClass:[NSArray class]]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"All fields are required." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            if([[sender valueForKey:@"status"] integerValue]==1){
                // 1 - Success
                dictDetailsHandler = [[sender valueForKey:@"data"] objectAtIndex:0];
                if ([strForDetailsHandler isEqualToString:@"1"]){
                    UIAlertView *alertView1 = [[UIAlertView alloc]initWithTitle:@"StoryShare" message:@"Share Story with.." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Facebook", @"Twitter", nil];
                    alertView1.tag = 101;
                    [alertView1 show];
                }else{
                    if ([[NSString stringWithFormat:@"%@", [dictDetailsHandler valueForKey:@"lastEdited_By"]] isEqualToString:[NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults] valueForKey:@"UserDetails"] valueForKey:@"_id"]]] && ![[NSString stringWithFormat:@"%@", [dictDetailsHandler valueForKey:@"lockedBy"]] isEqualToString:[[[NSUserDefaults standardUserDefaults] valueForKey:@"UserDetails"] valueForKey:@"_id"]] && ![[NSString stringWithFormat:@"%@", [dictDetailsHandler valueForKey:@"lockedBy"]] isEqualToString:@""]) {
                        
                        StoryDetailVC *stoyRead = [[StoryDetailVC alloc] init];
                        stoyRead.dictReadStoryDetails = [sender mutableCopy];
                        [self.navigationController pushViewController:stoyRead animated:YES];
                    }
                    else if (![[NSString stringWithFormat:@"%@", [dictDetailsHandler valueForKey:@"lockedBy"]] isEqualToString:@""]){
                        if ([[NSString stringWithFormat:@"%@", [dictDetailsHandler valueForKey:@"lockedBy"]] isEqualToString:[[[NSUserDefaults standardUserDefaults] valueForKey:@"UserDetails"] valueForKey:@"_id"]]) {
                            CreateStoryVC *stoyCreate = [[CreateStoryVC alloc] init];
                            [TVStoredData sharedInstance].isCommingForm = @"EditStory_Notification";
                            stoyCreate.dictForStoryDetails = [sender mutableCopy];
                            [self.navigationController pushViewController:stoyCreate animated:YES];
                        }else {
                            StoryDetailVC *stoyRead = [[StoryDetailVC alloc] init];
                            stoyRead.dictReadStoryDetails = [sender mutableCopy];
                            [self.navigationController pushViewController:stoyRead animated:YES];
                        }
                    }else{
                        StoryDetailVC *stoyRead = [[StoryDetailVC alloc] init];
                        stoyRead.dictReadStoryDetails = [sender mutableCopy];
                        [self.navigationController pushViewController:stoyRead animated:YES];
                    }
                }
            }
            else{
                // Other
                NSString*strFormsg=[sender valueForKey:@"message"];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:strFormsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}
#pragma mark:Webservice Share Story Method:---
-(void)getShareStorySocial{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getShareStorySocialHandler:)];
        [service getShareStory_story_id:[NSString stringWithFormat:@"%@",[dictDetailsHandler  valueForKey:@"_id"]] genre_id:[NSString stringWithFormat:@"%@",[[dictDetailsHandler  valueForKey:@"genre_id"] valueForKey:@"_id"]]];
    }
}
#pragma mark:Handler Share Story Method:---
-(void)getShareStorySocialHandler:(id)sender{
    [AppDelegate killHud];
    if([sender isKindOfClass:[NSError class]])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"Oops! Something went wrong. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    else
    {
        if ([sender isKindOfClass:[NSArray class]])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:@"All fields are required." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            if([[sender valueForKey:@"status"] integerValue]==1){
                // 1 - Success
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"StoryShare" message:@"You have shared on your timeline successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil ];
                [alert show];
            }
            else{
                // Other
                NSString*strFormsg=[sender valueForKey:@"message"];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"StoryShare" message:strFormsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

@end
