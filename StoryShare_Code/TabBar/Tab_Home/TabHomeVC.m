//
//  TabHomeVC.m
//  Share_Story
//
//  Created by Ankush on 2/7/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import "TabHomeVC.h"
#import "Constant.h"
#import "TabHome_CellVC.h"
#import "CustomStarRank.h"
#import "SettingsVC.h"
#import "HomeVC.h"
#import "StoryDetailVC.h"
#import "TabHome_NewCell.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import <Accounts/Accounts.h>
#import "Tab_HomeModel.h"
#import "TVStoredData.h"
#import "CreateStoryVC.h"
#import "MTReachabilityManager.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "TVTwitterController.h"
#import <Social/Social.h>
#import "FilterGenreListCell.h"
#import "GenreListModel.h"
#import "UIView+Toast.h"
#import "TVFBController.h"
@import GoogleMobileAds;
@interface TabHomeVC ()<CustomStarRankDelegate,FBSDKSharingDelegate,TVFBDelegate,GADInterstitialDelegate>
{
    float starWidth;
    NSString *strForLikeDisLike;
    NSUInteger tagForPopUpView;
    NSString *starValue;
    NSString *strForActivityOrCompleteType;
    NSString *strTextStory;
    CGRect currentLabelFrame;
    GenreListModel *genreListModel;
    UIActivityIndicatorView *activityIndicator;
    NSString *strForFilter;
    NSString *strForGenreID;
    bool boolForSearch;
    NSMutableArray*arrForFilter;
    NSString *strCheckPopup;
    NSMutableArray  *arryForMulitipalUser;
    NSString*strForCommingToResignAds;
    NSMutableDictionary *dicForCofigResponce;
}

@end

@implementation TabHomeVC

@synthesize btnActive,btnFilter,btnComplete;
@synthesize tblViewStoryList,tblViewGenreList,arryForStoryList,arrForGenre,viewForFilter;
@synthesize viewForStoryPopUp,viewForBlackBG,viewForPopUp,viewForCenter,viewForLikeAndShare,viewForStar,imgForLikeBtn,lblForStoryName,lblForStoryNameTitle,lblForStoryText,imgForStoryTitle,imgForBackOrHome,lblForEmptyArray,viewForStatus,constrantForaActiveView,viewForSearch,txtForSearch,btnForSearch,btnForMostLiked,btnForMostRated,btnForMostShared,viewForHeader,imgForBack;

- (void)viewDidLoad {
    [super viewDidLoad];
    viewForSearch.hidden=YES;
    constrantForaActiveView.constant = -30;
    self.interstitial = [self createAndLoadInterstitial];
    self.navigationController.navigationBar.hidden=YES;
    self.navigationController.navigationBarHidden=YES;
    arryForStoryList=[[NSMutableArray alloc] init];
    arrForFilter=[[NSMutableArray alloc] init];
    starValue = @"";
    isRefresh=NO;
    pageNo=1;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionOnHidePopUp:)];
    [viewForBlackBG setUserInteractionEnabled:YES];
    [tapGesture setDelegate:self];
    [viewForStoryPopUp addGestureRecognizer:tapGesture];
    
    // Pull to Refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    [tblViewStoryList addSubview:refreshControl];
    UITapGestureRecognizer *tapForHideKeybord = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapHeader:)];
    [viewForHeader setUserInteractionEnabled:YES];
    [tapForHideKeybord setDelegate:self];
    [viewForHeader addGestureRecognizer:tapForHideKeybord];
    viewForPopUp.layer.cornerRadius = 5;
    viewForPopUp.clipsToBounds = YES;
    viewForPopUp.layer.borderWidth = 1;
    viewForPopUp.layer.borderColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:41.0/255.0 alpha:1].CGColor;
    viewForCenter.layer.borderWidth = 1;
    viewForLikeAndShare.layer.borderWidth = 1;
    viewForStar.layer.borderWidth = 1;
    viewForCenter.layer.borderColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:41.0/255.0 alpha:1].CGColor;
    viewForLikeAndShare.layer.borderColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:41.0/255.0 alpha:1].CGColor;
    viewForStar.layer.borderColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:41.0/255.0 alpha:1].CGColor;
    
    if (IS_IPHONE_5) {
        viewForCustomStar=[[CustomStarRank alloc]initWithFrame:CGRectMake(viewForStar.bounds.origin.x+10, (viewForStar.frame.size.height/2)-13, viewForStar.frame.size.width-50, 15)];
    }else if (IS_IPHONE_6){
        viewForCustomStar=[[CustomStarRank alloc]initWithFrame:CGRectMake(viewForStar.bounds.origin.x+10, (viewForStar.frame.size.height/2)-10, viewForStar.frame.size.width-20, 20)];
    }else{
        viewForCustomStar=[[CustomStarRank alloc]initWithFrame:CGRectMake(viewForStar.bounds.origin.x+10, (viewForStar.frame.size.height/2)-8, viewForStar.frame.size.width, 22)];
    }
    [viewForCustomStar setCustomStarRankDelegate:self];
    [viewForCustomStar setUserInteractionEnabled:YES];
    [viewForStar addSubview:viewForCustomStar];
    
    //****************Swipe Right****************************//
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeForComplete:)];
    [swipeRight setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [tblViewStoryList addGestureRecognizer:swipeRight];
    
    //****************Swipe Left****************************//
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeForActive:)];
    [swipeLeft setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [tblViewStoryList addGestureRecognizer:swipeLeft];
    btnComplete.selected=NO;
    btnActive.selected=YES;
}

//****************Star Rating Count****************************//
-(void)didChangedValue:(NSString*)value{
    starValue = value;
    if ([[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"is_rated"]] integerValue] == 0) {
        NSMutableDictionary*dict1=[[NSMutableDictionary alloc] init];
        dict1=[[arryForStoryList objectAtIndex:tagForPopUpView] mutableCopy];
        [dict1 setValue:[NSNumber numberWithInteger:1] forKey:@"is_rated"];
        [arryForStoryList replaceObjectAtIndex:tagForPopUpView withObject:dict1];
        [tblViewStoryList reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getStarRatingWeb];
        });
    }
}
//****************Pull to Refresh****************************//
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(getActivePullRefresh) withObject:nil afterDelay:0.0];
        refreshControl1 = refreshControl;
        pageNo=1;
        isRefresh=YES;
    });
}
//****************Chnage Color of SatusBar****************************//
-(void)status_bar_color{
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
- (void)actionOnHidePopUp:(id)sender
{
    [viewForStoryPopUp setHidden:YES];
}
-(void)hideFilterPopUp{
    viewForFilter.hidden=YES;
}
-(void)actionTapHeader:(id)sender{
    [txtForSearch resignFirstResponder];
}
#pragma mark - Events Start
- (void)handleTapToDismissToggled {
    [CSToastManager setTapToDismissEnabled:![CSToastManager isTapToDismissEnabled]];
}
- (void)handleQueueToggled {
    [CSToastManager setQueueEnabled:![CSToastManager isQueueEnabled]];
}
#pragma mark - Events End

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getUserConfigWeb];
    });
    [self setGenreListFilter];
    strForFilter=@"";
    txtForSearch.text=@"";
    boolForSearch=NO;
    strForIsMore=@"";
    pageNo=1;
    [[AppDelegate sharedInstance] setTabBarHidden:NO];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"arrForFilter"] count]>0 || ![strForFilter isEqualToString:@""]){
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter_show"] forState:UIControlStateNormal];
    }
    if ([[TVStoredData sharedInstance].ActiveOrComplete isEqualToString:@"Complete"]) {
        imgForBackOrHome.hidden=NO;
        imgForBack.hidden=YES;
        strForActivityOrCompleteType = @"2";
        [self completeBtnSeleted];
        btnForSetting.hidden=NO;
        imgForSetting.hidden=NO;
    }else if ([[TVStoredData sharedInstance].ActiveOrComplete isEqualToString:@"Suggestion"] || [[TVStoredData sharedInstance].strForSuggestion isEqualToString:@"Suggestion"]){
        imgForBackOrHome.hidden=YES;
        imgForBack.hidden=NO;
        strForActivityOrCompleteType = @"2";
        [self completeBtnSeleted];
        btnForSetting.hidden=YES;
        imgForSetting.hidden=YES;
        [[AppDelegate sharedInstance] setTabBarHidden:YES];
    }else{
        if ([strForActivityOrCompleteType isEqualToString:@"2"]) {
            if ([[TVStoredData sharedInstance].ActiveOrComplete isEqualToString:@"Active"]) {
                [self activeBtnSeleted];
            }else{
                [self completeBtnSeleted];
                btnComplete.selected=YES;
                btnActive.selected=NO;
            }
        }else{
            imgForBackOrHome.hidden=NO;
            imgForBack.hidden=YES;
            strForActivityOrCompleteType = @"1";
            [self activeBtnSeleted];
            btnForSetting.hidden=NO;
            imgForSetting.hidden=NO;
        }
    }
    [viewForStoryPopUp setHidden:YES];
    viewForFilter.hidden = YES;
    [self.navigationController.navigationItem hidesBackButton];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 50, 0);
    self.tblViewStoryList.contentInset = insets;
    self.tblViewStoryList.scrollIndicatorInsets = insets;
}
#pragma mark:Interstrial Ads:--
- (GADInterstitial *)createAndLoadInterstitial{
    self.interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-7240906535586790/7232550392"];
    self.interstitial.delegate = self;
    [self.interstitial loadRequest:[GADRequest request]];
    return self.interstitial;
}
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    if ([[TVStoredData sharedInstance].strForIsSubAndCompleted isEqualToString:@"Yes"]) {
        [TVStoredData sharedInstance].strForIsSubAndCompleted=@"";
        [self.interstitial presentFromRootViewController:self];
    }
}
- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    //self.interstitial = [self createAndLoadInterstitial];
}
-(void)interstitialWillDismissScreen:(GADInterstitial *)ad{
    
}
-(void)showAds{
    if (self.interstitial.isReady){
        [self.interstitial presentFromRootViewController:self];
    } else {
        self.interstitial= [self createAndLoadInterstitial];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    if ([[TVStoredData sharedInstance].strForIsSubAndCompleted isEqualToString:@"Yes"]) {
        [TVStoredData sharedInstance].strForIsSubAndCompleted=@"";
        [self showAds];
    }
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [self.view endEditing:YES];
}
-(void)leftSwipeForActive:(UIGestureRecognizer*)button{
    if (btnActive.selected!=YES) {
        [TVStoredData sharedInstance].strCommingFromHome = @"Yes";
        [self activeBtnSeleted];
    }
}
-(void)rightSwipeForComplete:(UIGestureRecognizer*)button{
    if (btnComplete.selected!=YES) {
        [TVStoredData sharedInstance].strCommingFromHome = @"Yes";
        [self completeBtnSeleted];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField==txtForSearch){
        [textField addTarget:self
                      action:@selector(searchMethod:)
            forControlEvents:UIControlEventEditingChanged];
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length==0 && [string isEqualToString:@" "]){
        return NO;
    }else{
        NSInteger newTextLength  = [textField.text length] - range.length +[string length];
        if (newTextLength>30){
            return NO;
        }else{
            return YES;
        }
    }
}
-(void)searchMethod:(id)sender{
    if (txtForSearch.text.length>0) {
        if ([timer isValid]) {
            [timer invalidate];
        }
        timer = nil;
        boolForSearch=YES;
        timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(getActiveStoryWeb)userInfo:nil repeats:NO];
    }
    else
    {
        boolForSearch=NO;
        [tblViewStoryList setDelegate:self];
        [tblViewStoryList setDataSource:self];
        [tblViewStoryList reloadData];
    }
}
//****************Active Tab Select****************************//
-(void)activeBtnSeleted{
    btnFilter.selected=false;
    viewForFilter.hidden = YES;
    [arrForFilter removeAllObjects];
    lblForEmptyArray.hidden=YES;
    [btnActive setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnActive.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1];
    btnComplete.backgroundColor = [UIColor clearColor];
    [btnComplete setTitleColor:[UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1] forState:UIControlStateNormal];
    btnFilter.backgroundColor = [UIColor clearColor];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"arrForFilter"] count]>0 || ![strForFilter isEqualToString:@""]) {
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter_show"] forState:UIControlStateNormal];
    }else{
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    }
    strForActivityOrCompleteType = @"1";
    pageNo=1;
    btnComplete.selected=NO;
    btnActive.selected=YES;
    if ([[TVStoredData sharedInstance].strCommingFromHome isEqualToString:@"Yes"]) {
        [TVStoredData sharedInstance].strCommingFromHome=@"";
        [arryForStoryList removeAllObjects];
        [tblViewStoryList reloadData];
        [self getActiveStoryWeb];
    }
}
//****************Complete Tab Select****************************//
-(void)completeBtnSeleted{
    btnFilter.selected=false;
    viewForFilter.hidden = YES;
    [arrForFilter removeAllObjects];
    lblForEmptyArray.hidden=YES;
    [btnComplete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnComplete.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1];
    btnActive.backgroundColor = [UIColor clearColor];
    [btnActive setTitleColor:[UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1] forState:UIControlStateNormal];
    btnFilter.backgroundColor = [UIColor clearColor];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"arrForFilter"] count]>0 || ![strForFilter isEqualToString:@""]) {
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter_show"] forState:UIControlStateNormal];
    }else{
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    }
    strForActivityOrCompleteType = @"2";
    pageNo=1;
    btnActive.selected=NO;
    btnComplete.selected=YES;
    if ([[TVStoredData sharedInstance].strCommingFromHome isEqualToString:@"Yes"] || [[TVStoredData sharedInstance].strForSuggestion isEqualToString:@"Suggestion"]) {
        [TVStoredData sharedInstance].strCommingFromHome=@"";
        [arryForStoryList removeAllObjects];
        [tblViewStoryList reloadData];
        [self getActiveStoryWeb];
    }
}

-(void)actionOnCreateNewStory{
    
}
- (IBAction)actionOnActiveBtn:(id)sender {
    [TVStoredData sharedInstance].strCommingFromHome = @"Yes";
    [self activeBtnSeleted];
}
- (IBAction)actionOnCompleteBtn:(id)sender {
    [TVStoredData sharedInstance].strCommingFromHome = @"Yes";
    [self completeBtnSeleted];
}
- (IBAction)actionOnFilterBtn:(UIButton*)sender {
    if (sender.isSelected==false) {
        viewForFilter.hidden = NO;
        [self setFilterComing];
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter_on"] forState:UIControlStateNormal];
        [self getGenreListWeb];
        sender.selected=true;
    }else{
        viewForFilter.hidden = YES;
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        sender.selected=false;
    }
    
}
//****************Filter Action****************************//
- (IBAction)actionFilterBtn:(UIButton *)sender {
    switch(sender.tag)
    {
        case 1:
            strForFilter=@"rate_count";
            [btnForMostRated setBackgroundImage:[UIImage imageNamed:@"check_box_on"] forState:UIControlStateNormal];
            [btnForMostShared setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
            [btnForMostLiked setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
            break;
        case 2:
            strForFilter=@"share_count";
            [btnForMostShared setBackgroundImage:[UIImage imageNamed:@"check_box_on"] forState:UIControlStateNormal];
            [btnForMostRated setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
            [btnForMostLiked setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
            break;
        case 3:
            strForFilter=@"like_count";
            [btnForMostLiked setBackgroundImage:[UIImage imageNamed:@"check_box_on"] forState:UIControlStateNormal];
            [btnForMostShared setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
            [btnForMostRated setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
            break;
        default :
            break; //Do nothing
    }
}
- (IBAction)actionOnMostRated:(id)sender {
}
- (IBAction)actionOnMostShared:(id)sender {
}
- (IBAction)actionOnMostLiked:(id)sender {
}
- (IBAction)actionOnOkBtn:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:arrForFilter forKey:@"arrForFilter"];
    [arrForFilter removeAllObjects];
    viewForFilter.hidden = YES;
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"arrForFilter"] count]>0 || ![strForFilter isEqualToString:@""]) {
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter_show"] forState:UIControlStateNormal];
    }else{
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    }
    btnFilter.selected=false;
    [self setGenreListFilter];
    [arryForStoryList removeAllObjects];
    [tblViewStoryList reloadData];
    [self getActiveStoryWeb];
}
//****************GenreList Filter Action****************************//
-(void)setGenreListFilter{
    if ([strForFilter isEqualToString:@"rate_count"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"rate_count" forKey:@"strForFilterOtn"];
    }else if ([strForFilter isEqualToString:@"share_count"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"share_count" forKey:@"strForFilterOtn"];
    }else if ([strForFilter isEqualToString:@"like_count"]){
        [[NSUserDefaults standardUserDefaults] setValue:@"like_count" forKey:@"strForFilterOtn"];
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"strForFilterOtn"];
    }
    NSMutableArray*arrForStoryText=[[NSMutableArray alloc] init];
    arrForStoryText = [[NSUserDefaults standardUserDefaults] valueForKey:@"arrForFilter"];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"arrForFilter"] count]!=0) {
        for (int i=0; i<[[[NSUserDefaults standardUserDefaults] valueForKey:@"arrForFilter"] count]; i++) {
            if (i==0) {
                strForGenreID=  [NSString stringWithFormat:@"%@",[[arrForStoryText objectAtIndex:i] valueForKey:@"_id"]];
            }else{
                strForGenreID=  [NSString stringWithFormat:@"%@,%@",strForGenreID,[[arrForStoryText objectAtIndex:i] valueForKey:@"_id"]];
            }
        }
    }else{
        strForGenreID=@"";
    }
}
//****************Checks for Filter Comming****************************//
-(void)setFilterComing{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"strForFilterOtn"] isEqualToString:@"rate_count"]) {
        [btnForMostRated setBackgroundImage:[UIImage imageNamed:@"check_box_on"] forState:UIControlStateNormal];
        [btnForMostShared setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
        [btnForMostLiked setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
    }else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"strForFilterOtn"] isEqualToString:@"share_count"]){
        [btnForMostShared setBackgroundImage:[UIImage imageNamed:@"check_box_on"] forState:UIControlStateNormal];
        [btnForMostRated setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
        [btnForMostLiked setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
    }else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"strForFilterOtn"] isEqualToString:@"like_count"]){
        [btnForMostLiked setBackgroundImage:[UIImage imageNamed:@"check_box_on"] forState:UIControlStateNormal];
        [btnForMostShared setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
        [btnForMostRated setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
    }else{
        [btnForMostLiked setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
        [btnForMostShared setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
        [btnForMostRated setBackgroundImage:[UIImage imageNamed:@"check_box_off"] forState:UIControlStateNormal];
    }
}
- (IBAction)actionOnResetBtn:(id)sender {
    btnFilter.selected=false;
    txtForSearch.text = @"";
    strForGenreID=@"";
    strForFilter=@"";
    pageNo=1;
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"strForFilterOtn"];
    [[NSUserDefaults standardUserDefaults] setValue:[[NSMutableArray alloc] init] forKey:@"arrForFilter"];
    [arrForFilter removeAllObjects];
    [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [tblViewGenreList reloadData];
    viewForFilter.hidden = YES;
    [arryForStoryList removeAllObjects];
    [tblViewStoryList reloadData];
    [self getActiveStoryWeb];
}

#pragma  mark Tableview Delegates
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==tblViewGenreList) {
        return [arrForGenre count];
    }else{
        return [arryForStoryList count];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==tblViewGenreList){
        FilterGenreListCell *cell= [tblViewGenreList dequeueReusableCellWithIdentifier:@"FilterGenreListCell"];
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"FilterGenreListCell" bundle:nil] forCellReuseIdentifier:@"FilterGenreListCell"];
            cell=[tableView dequeueReusableCellWithIdentifier:@"FilterGenreListCell"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary*dictFroGenre=[arrForGenre objectAtIndex:indexPath.row];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"arrForFilter"] count]!=0) {
            arrForFilter=[[[NSUserDefaults standardUserDefaults] valueForKey:@"arrForFilter"] mutableCopy];
        }
        if (![arrForFilter containsObject:[arrForGenre objectAtIndex:indexPath.row]]) {
            cell.btnForCheck.selected=NO;
        }else{
            cell.btnForCheck.selected=YES;
        }
        cell.lblForGenreName.text = [NSString stringWithFormat:@"%@",[dictFroGenre valueForKey:@"name"]];
        return cell;
    }
    if (tableView == tblViewStoryList) {
        TabHome_NewCell *cell=[tblViewStoryList dequeueReusableCellWithIdentifier:@"TabHome_NewCell"];
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"TabHome_NewCell" bundle:nil] forCellReuseIdentifier:@"TabHome_NewCell"];
            cell=[tableView dequeueReusableCellWithIdentifier:@"TabHome_NewCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary*dictFroStoryDetails=[arryForStoryList objectAtIndex:indexPath.row];
        if ([[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Miscellaneous"]) {
            cell.imgForStory.image=[UIImage imageNamed:@"new_adult"];
        }else if ([[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Children"]) {
            cell.imgForStory.image=[UIImage imageNamed:@"new_children"];
        }else if ([[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Adult"]) {
            cell.imgForStory.image=[UIImage imageNamed:@"new_adult"];
        }else if ([[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"SCi-fi/Tech"]) {
            cell.imgForStory.image=[UIImage imageNamed:@"new_sci-fi"];
        }else if ([[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Drama"]) {
            cell.imgForStory.image=[UIImage imageNamed:@"new_drama"];
        }else if ([[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Horror"]) {
            cell.imgForStory.image=[UIImage imageNamed:@"new_horror"];
        }else if ([[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Comedy"]) {
            cell.imgForStory.image=[UIImage imageNamed:@"new_comedy"];
        }else if ([[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Thriller"]) {
            cell.imgForStory.image=[UIImage imageNamed:@"new_romance"];
        }else if ([[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Romance"]) {
            cell.imgForStory.image=[UIImage imageNamed:@"new_romance"];
        }
        cell.lblForStoryName.text=[dictFroStoryDetails valueForKey:@"story_title"];
        cell.lblForStoryNameOnImg.text=[[dictFroStoryDetails valueForKey:@"genre_id"] valueForKey:@"name"];
        [cell.btnForMulitpalName setTitle:[[[dictFroStoryDetails valueForKey:@"story_users"] valueForKey:@"user"] valueForKey:@"username"] forState:UIControlStateNormal];
        cell.lblForRating.text=[NSString stringWithFormat:@"%ld/5",[[dictFroStoryDetails valueForKey:@"avgRating"] integerValue]];
        cell.lblForWardCount.text=[NSString stringWithFormat:@"%@/1000",[dictFroStoryDetails  valueForKey:@"story_word_count"]];
        cell.lblForLikeCount.text=[NSString stringWithFormat:@"%@",[dictFroStoryDetails valueForKey:@"like_count"] ];
        if ([[dictFroStoryDetails valueForKey:@"is_saved"] integerValue]==1) {
            [cell.btnForSaveToLibrary setTitle: @"Saved" forState: UIControlStateNormal];
        }else{
            [cell.btnForSaveToLibrary setTitle: @"Save to my Library" forState: UIControlStateNormal];
        }
        NSString * timeStampString =[NSString stringWithFormat:@"%@",[dictFroStoryDetails valueForKey:@"createdAt"]];
        cell.lblForTimaAndDate.text=timeStampString;
        [cell.btnForSaveToLibrary setContentMode:UIViewContentModeScaleToFill];
        [cell.btnForSaveToLibrary setTag:indexPath.row];
        [cell.btnForSaveToLibrary addTarget:self action:@selector(actionOnSavedToLibraryBtn:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnForShare setTag:indexPath.row];
        [cell.btnForShare addTarget:self action:@selector(actionOnShareStoryWith:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnForMulitpalName setTag:indexPath.row];
        [cell.btnForMulitpalName addTarget:self action:@selector(actionOnEditedUserList:) forControlEvents:UIControlEventTouchUpInside];
        if([arryForStoryList count] - 1 == indexPath.row){
            if([strForIsMore isEqualToString:@"Yes"]){
                [self performSelector:@selector(getActiveStoryWeb) withObject:nil];
            }
        }
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tblViewStoryList) {
        viewForFilter.hidden = YES;
        [btnFilter setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        tagForPopUpView = indexPath.row;
        viewForCustomStar.value = [[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"avgRating"]] floatValue];
        if ([strForActivityOrCompleteType isEqualToString:@"2"]){
            if ([[dicForCofigResponce valueForKey:@"account"] isEqualToString:@"Free"]) {
                [self getStoryReadStaus];
            }else{
                [viewForStoryPopUp setHidden:NO];
                [self popUpData];
            }
        }else{
            [viewForStoryPopUp setHidden:NO];
            [self popUpData];
        }
    }else{
        FilterGenreListCell* yourCell = (FilterGenreListCell*)[tblViewGenreList cellForRowAtIndexPath:indexPath];
        if ([arrForFilter containsObject:[arrForGenre objectAtIndex:indexPath.row]]) {
            [arrForFilter removeObject:[arrForGenre objectAtIndex:indexPath.row]];
            yourCell.btnForCheck.selected=NO;
        }else{
            [arrForFilter addObject:[arrForGenre objectAtIndex:indexPath.row]];
            yourCell.btnForCheck.selected=YES;
        }
    }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tblViewStoryList){
    }else{
        FilterGenreListCell* yourCell = (FilterGenreListCell*)[tblViewGenreList cellForRowAtIndexPath:indexPath];
        if ([arrForFilter containsObject:[arrForGenre objectAtIndex:indexPath.row]]) {
            [arrForFilter removeObject:[arrForGenre objectAtIndex:indexPath.row]];
            yourCell.btnForCheck.selected=NO;
        }else{
            [arrForFilter addObject:[arrForGenre objectAtIndex:indexPath.row]];
            yourCell.btnForCheck.selected=YES;
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //UITableViewAutomaticDimension
    if (tableView == tblViewStoryList) {
        return 118;
    }else{
        return 44;
    }
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

//****************Story PopUp Data****************************//
-(void)popUpData{
    lblForStoryName.text = [NSString stringWithFormat:@"%@",[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"]];
    lblForStoryNameTitle.text = [NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"story_title"]];
    lblForStoryText.text = [NSString stringWithFormat:@"%@",[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"story_users"] valueForKey:@"story_text"]];
    if ([[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"is_liked"]] isEqualToString:@"1"] ) {
        imgForLikeBtn.image = [UIImage imageNamed:@"liked_cliked"];
    }else{
        imgForLikeBtn.image = [UIImage imageNamed:@"liked_story"];
    }
    if ([[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"is_rated"] integerValue] == 0) {
        viewForCustomStar.userInteractionEnabled = YES;
    }else{
        viewForCustomStar.userInteractionEnabled = NO;
    }    
    if ([[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Miscellaneous"]) {
        imgForStoryTitle.image=[UIImage imageNamed:@"new_adult"];
    }else if ([[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Children"]) {
        imgForStoryTitle.image=[UIImage imageNamed:@"new_children"];
    }else if ([[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Adult"]) {
        imgForStoryTitle.image=[UIImage imageNamed:@"new_adult"];
    }else if ([[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"SCi-fi/Tech"]) {
        imgForStoryTitle.image=[UIImage imageNamed:@"new_sci-fi"];
    }else if ([[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Drama"]) {
        imgForStoryTitle.image=[UIImage imageNamed:@"new_drama"];
    }else if ([[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Horror"]) {
        imgForStoryTitle.image=[UIImage imageNamed:@"new_horror"];
    }else if ([[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Comedy"]) {
        imgForStoryTitle.image=[UIImage imageNamed:@"new_comedy"];
    }else if ([[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Thriller"]) {
        imgForStoryTitle.image=[UIImage imageNamed:@"new_romance"];
    }else if ([[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"name"] isEqualToString:@"Romance"]) {
        imgForStoryTitle.image=[UIImage imageNamed:@"new_romance"];
    }
}

// Story PopUp
- (IBAction)actionOnBackBtn:(id)sender {
    if ([[TVStoredData sharedInstance].ActiveOrComplete isEqualToString:@"Complete"]) {
        [[AppDelegate sharedInstance].navigationMain popViewControllerAnimated:YES];
    }else if ([[TVStoredData sharedInstance].strForSuggestion isEqualToString:@"Suggestion"]){
        if ([[TVStoredData sharedInstance].isCommingForm isEqualToString:@"CreateStory"]) {
            NSArray *viewControllers = [[AppDelegate sharedInstance].navigationMain viewControllers];
            for (int i=0; i<viewControllers.count; i++) {
                if ([[viewControllers objectAtIndex:i] isKindOfClass:[CreateStoryVC class]])
                {
                    [self.navigationController.navigationBar setHidden:NO];
                    [[AppDelegate sharedInstance].navigationMain popToViewController:[viewControllers objectAtIndex:i] animated:YES];
                }
            }
        }else{
            //[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
            [TVStoredData sharedInstance].strForEditTxtHandle = @"YES";
            [self.navigationController popViewControllerAnimated:YES];
        }
        [TVStoredData sharedInstance].strForSuggestion = @"";
    }else{
        NSArray *viewControllers = [[AppDelegate sharedInstance].navigationMain viewControllers];
        for (int i=0; i<viewControllers.count; i++) {
            if ([[viewControllers objectAtIndex:i] isKindOfClass:[HomeVC class]])
            {
                [self.navigationController.navigationBar setHidden:NO];
                [[AppDelegate sharedInstance].navigationMain popToViewController:[viewControllers objectAtIndex:i] animated:YES];
            }
        }
    }
}

- (IBAction)actionOnSetting:(id)sender{
    [TVStoredData sharedInstance].strCommingForSetting=@"";
    SettingsVC *objSettingVC = [[SettingsVC alloc]init];
    [self.navigationController pushViewController:objSettingVC animated:YES];
}

- (IBAction)actionOnReadMore:(id)sender{
    [self getStoryDetailsWeb];
}

// Story PopUp
- (IBAction)actionOnLikeStory:(UIButton*)sender {
    //tagForPopUpView = sender.tag;
    if([[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"is_liked"] integerValue]==1){
        strForLikeDisLike=@"";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getStoryLikeWeb];
        });
    }else{
        strForLikeDisLike=@"1";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getStoryLikeWeb];
        });
    }
}

// Story PopUp
- (IBAction)actionOnShareStoryWith:(UIButton*)sender {
    tagForPopUpView = sender.tag;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"StoryShare" message:@"Share Story with.." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Facebook", @"Twitter", nil];
    [alertView show];
}
//****************Edited UserList****************************//
-(void)actionOnEditedUserList:(UIButton*)sender{
    arryForMulitipalUser = [[arryForStoryList objectAtIndex:sender.tag] valueForKey:@"edit_users_list"];
    strCheckPopup = @"Multipaluser";
    poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(0, 0, 300, (50*arryForMulitipalUser.count)+30)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = true;
    [poplistview setTitle:@"Edited by"];
    [poplistview setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1]];
    [poplistview show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
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
            
            //Text
            LinkContent.contentTitle = [NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView]valueForKey:@"story_title"]];
            LinkContent.contentDescription = [NSString stringWithFormat:@"%@",[[[arryForStoryList objectAtIndex:tagForPopUpView]valueForKey:@"story_users"] valueForKey:@"story_text"]];
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
                    content.contentTitle = [NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"story_title"]];
                    content.contentDescription = [NSString stringWithFormat:@"%@",[[[arryForStoryList objectAtIndex:tagForPopUpView]valueForKey:@"story_users"] valueForKey:@"story_text"]];
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
                        [controller setInitialText:[NSString stringWithFormat:@"%@",[[[arryForStoryList objectAtIndex:tagForPopUpView]valueForKey:@"story_users"] valueForKey:@"story_text"]]];
                        [self performSelector:@selector(remove) withObject:nil afterDelay:0.5];
                        [self presentViewController:controller
                                           animated:YES
                                         completion:^(){
                                         }];
                    }
                    else
                    {
                        //Text
                        [controller setInitialText:[NSString stringWithFormat:@"%@",[[[arryForStoryList objectAtIndex:tagForPopUpView]valueForKey:@"story_users"] valueForKey:@"story_text"]]];
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
//****************Action on Saved to Library****************************//
-(void)actionOnSavedToLibraryBtn:(UIButton*)sender{
    tagForPopUpView = sender.tag;
    if ([[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"is_saved"]] isEqualToString:@"1"]) {
        [self.navigationController.view makeToast:@"You have already saved this story."
                                         duration:2.0
                                         position:CSToastPositionBottom];
    }else{
        sender.userInteractionEnabled=NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getSaveToLibraryWeb];
        });
    }
}

#pragma mark:Webservice Active Story List Method:---
-(void)getActiveStoryWeb{
    [self.view endEditing:YES];
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        if([arryForStoryList count]>0)
        {
            if (boolForSearch==YES) {
                pageNo=1;
            }else{
                pageNo=(int)([arryForStoryList count]/10);
                if(arryForStoryList==0)
                {
                    pageNo=1;
                }else{
                    pageNo=(int)([arryForStoryList count]/10)+1;
                }
            }
        }
        if (pageNo>1) {
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityIndicator startAnimating];
            activityIndicator.frame = CGRectMake(0, 0, 320, 50);
            tblViewStoryList.tableFooterView = activityIndicator;
        }else{
            [AppDelegate showHud];
        }
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getActiveStoryHandler:)];
        [service getActiveStory_page_no:[NSString stringWithFormat:@"%d",pageNo] type:strForActivityOrCompleteType genre_id:strForGenreID filter:strForFilter search:txtForSearch.text];
    }
}
#pragma mark:Handler Active Story Web Note---
-(void)getActiveStoryHandler:(id)sender{
    [activityIndicator stopAnimating];
    tblViewStoryList.tableFooterView = 0;
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
                boolForSearch=NO;
                if (pageNo==1) {
                    [arryForStoryList removeAllObjects];
                }
                [arryForStoryList addObjectsFromArray:[[sender valueForKey:@"data"] mutableCopy]];
                if ([[sender valueForKey:@"data"] count]<10) {
                    strForIsMore=@"No";
                }else{
                    strForIsMore=@"Yes";
                }
                if ([arryForStoryList count] < 1 ) {
                    if ([strForActivityOrCompleteType isEqualToString:@"1"]) {
                        lblForEmptyArray.hidden=NO;
                        lblForEmptyArray.text=@"you haven't created any story.";
                    }else{
                        lblForEmptyArray.hidden=NO;
                        lblForEmptyArray.text=@"you haven't created any story.";
                    }
                }else{
                    lblForEmptyArray.text=@"";
                }
                [tblViewStoryList setDelegate:self];
                [tblViewStoryList setDataSource:self];
                [tblViewStoryList reloadData];
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

#pragma mark:Webservice PullToRefresh Story List Method:---
-(void)getActivePullRefresh{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [refreshControl1 endRefreshing];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getActivePullRefreshHandler:)];
        [service getActiveStory_page_no:@"1" type:strForActivityOrCompleteType genre_id:strForGenreID filter:strForFilter search:txtForSearch.text];
    }
}
#pragma mark:Handler PullToRefresh Story List Note---
-(void)getActivePullRefreshHandler:(id)sender{
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
                if([arryForStoryList count]>0){
                    [arryForStoryList removeAllObjects];
                }
                if ([[sender valueForKey:@"data"] count]<10) {
                    strForIsMore=@"No";
                }else{
                    strForIsMore=@"Yes";
                }
                [arryForStoryList addObjectsFromArray:[[sender valueForKey:@"data"] mutableCopy]];
                if ([arryForStoryList count] < 1 ) {
                    if ([strForActivityOrCompleteType isEqualToString:@"1"]) {
                        lblForEmptyArray.hidden=NO;
                        lblForEmptyArray.text=@"You haven't any active story";
                    }else{
                        lblForEmptyArray.hidden=NO;
                        lblForEmptyArray.text=@"You haven't any complete story";
                    }
                }else{
                    lblForEmptyArray.text=@"";
                }
                [tblViewStoryList setDelegate:self];
                [tblViewStoryList setDataSource:self];
                [tblViewStoryList reloadData];
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

#pragma mark:Webservice Story Like Method:---
-(void)getStoryLikeWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        //[AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getStoryLikeHandler:)];
        [service getLikeStory_action:strForLikeDisLike story_id:[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"_id"]] genre_id:[NSString stringWithFormat:@"%@",[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"_id"]]];
    }
}

#pragma mark:Handler Story Like Method:---
-(void)getStoryLikeHandler:(id)sender{
    //[AppDelegate killHud];
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
                NSMutableDictionary*dict=[[NSMutableDictionary alloc] init];
                dict=[[arryForStoryList objectAtIndex:tagForPopUpView] mutableCopy];
                if ([strForLikeDisLike isEqualToString:@"1"]) {
                    imgForLikeBtn.image = [UIImage imageNamed:@"liked_cliked"];
                    [dict setValue:@"1" forKey:@"is_liked"];
                    [self.navigationController.view makeToast:@"This story has been saved to the 'my liked stories' section of your library."
                                                     duration:2.0
                                                     position:CSToastPositionBottom];
                }else{
                    imgForLikeBtn.image = [UIImage imageNamed:@"liked_story"];
                    [dict setValue:@"0" forKey:@"is_liked"];
                }
                [arryForStoryList replaceObjectAtIndex:tagForPopUpView withObject:dict];
                // Reload single Table Cell
                NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:tagForPopUpView inSection:0];
                NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
                [tblViewStoryList reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
            }
            else{
                // Other
            }
        }
    }
}

#pragma mark:Webservice Save to Library story Method:---
-(void)getSaveToLibraryWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        //[AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getSaveToStoryHandler:)];
        [service getSaveToLibrary_story_id:[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"_id"]] genre_id:[NSString stringWithFormat:@"%@",[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"_id"]]];
    }
}

#pragma mark:Handler Save to Library story Method:---
-(void)getSaveToStoryHandler:(id)sender{
     TabHome_NewCell *cell = (TabHome_NewCell*)[tblViewStoryList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tagForPopUpView inSection:0]];
    cell.btnForSaveToLibrary.userInteractionEnabled=YES;
    //[AppDelegate killHud];
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
                [cell.btnForSaveToLibrary setTitle: @"Saved" forState: UIControlStateNormal];
                [tblViewGenreList reloadData];
                if ([[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"is_saved"]] isEqualToString:@"1"]) {
                    [self.navigationController.view makeToast:@"You have already saved this story."
                                                     duration:2.0
                                                     position:CSToastPositionBottom];
                }else{
                    [self.navigationController.view makeToast:@"This story has been saved to the 'my saved stories' section of your library."
                                                     duration:2.0
                                                     position:CSToastPositionBottom];
                }
                // Reload single Table Cell
//                NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:tagForPopUpView inSection:0];
//                NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
//                [tblViewStoryList reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark:WebService Star Rating Method:---
-(void)getStarRatingWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        //[AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getStoryRatingHandler:)];
        [service getRatingSorty_story_id:[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"_id"]] rating:starValue];
    }
}

#pragma mark:Handler Star Rating Method:---
-(void)getStoryRatingHandler:(id)sender{
    //[AppDelegate killHud];
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
                [tblViewStoryList reloadData];
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
        [service getStory_id:[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"_id"]]];
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
                [viewForStoryPopUp setHidden:YES];
                NSDictionary *dict = [[sender valueForKey:@"data"] objectAtIndex:0];
                if ([strForActivityOrCompleteType isEqualToString:@"2"]) {
                    StoryDetailVC *stoyRead = [[StoryDetailVC alloc] init];
                    stoyRead.dictReadStoryDetails = [sender mutableCopy];
                    [self.navigationController pushViewController:stoyRead animated:YES];
                }else{
                    if ([[NSString stringWithFormat:@"%@", [dict valueForKey:@"lastEdited_By"]] isEqualToString:[NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults] valueForKey:@"UserDetails"] valueForKey:@"_id"]]] && ![[NSString stringWithFormat:@"%@", [dict valueForKey:@"lockedBy"]] isEqualToString:[[[NSUserDefaults standardUserDefaults] valueForKey:@"UserDetails"] valueForKey:@"_id"]] && ![[NSString stringWithFormat:@"%@", [dict valueForKey:@"lockedBy"]] isEqualToString:@""]) {
                        
                        StoryDetailVC *stoyRead = [[StoryDetailVC alloc] init];
                        stoyRead.dictReadStoryDetails = [sender mutableCopy];
                        [self.navigationController pushViewController:stoyRead animated:YES];
                    }
                    else if (![[NSString stringWithFormat:@"%@", [dict valueForKey:@"lockedBy"]] isEqualToString:@""]){
                        if ([[NSString stringWithFormat:@"%@", [dict valueForKey:@"lockedBy"]] isEqualToString:[[[NSUserDefaults standardUserDefaults] valueForKey:@"UserDetails"] valueForKey:@"_id"]]) {
                            CreateStoryVC *stoyCreate = [[CreateStoryVC alloc] init];
                            [TVStoredData sharedInstance].isCommingForm = @"EditStory";
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

#pragma mark:WebService Genre List Note---
-(void)getGenreListWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getGenreListHandler:)];
        [service getGenreList_by_token];
    }
}

#pragma mark:Handler Genre List Note---
-(void)getGenreListHandler:(id)sender{
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
                arrForGenre=[sender valueForKey:@"data"];
                tblViewGenreList.dataSource=self;
                tblViewGenreList.delegate=self;
                [tblViewGenreList reloadData];
            }
            else{
                // Other
            }
        }
    }
}

- (IBAction)actionOnSearchBtn:(UIButton *)sender {
    if ([sender isSelected]) {
        [self searchFiledOff];
        [sender setSelected: NO];
    } else {
        [self searchFiledOn];
        [sender setSelected: YES];
    }
}

//****************Search Filter On****************************//
-(void)searchFiledOn{
    viewForSearch.hidden=NO;
    [txtForSearch becomeFirstResponder];
    constrantForaActiveView.constant = +1;
}
//****************Search Filter Off****************************//
-(void)searchFiledOff{
    boolForSearch=NO;
    viewForSearch.hidden=YES;
    [txtForSearch resignFirstResponder];
    constrantForaActiveView.constant = -30;
    if (![txtForSearch.text isEqualToString:@""]) {
        txtForSearch.text=@"";
        [arryForStoryList removeAllObjects];
        [tblViewStoryList reloadData];
        [self getActiveStoryWeb];
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
        [service getShareStory_story_id:[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"_id"]] genre_id:[NSString stringWithFormat:@"%@",[[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"genre_id"] valueForKey:@"_id"]]];
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

#pragma mark - UIPOPOVER METHODS
-(NSInteger)popoverListView:(UIPopoverListView *)popoverListView numberOfSectionsInTableView:(NSInteger)sections{
    return 1.0;
}
- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView numberOfRowsInSection:(NSInteger)section
{
    return [arryForMulitipalUser count];
}
- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text=[[[arryForMulitipalUser objectAtIndex:indexPath.row] valueForKey:@"user"] valueForKey:@"username"];
    cell.textLabel.textColor=[UIColor blackColor];
    cell.textLabel.font=[UIFont systemFontOfSize:12.0];
    
    NSString *time = [[arryForMulitipalUser objectAtIndex:indexPath.row] valueForKey:@"updatedAt"];
    
    double value = [time doubleValue];
    double unixTimeStamp = value;
    NSTimeInterval timeInterval=unixTimeStamp/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setLocale:[NSLocale currentLocale]];
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *dateString=[dateformatter stringFromDate:date];
    
    cell.detailTextLabel.textColor=[UIColor blackColor];
    cell.detailTextLabel.text=dateString;
    cell.detailTextLabel.font=[UIFont systemFontOfSize:12.0];
    
    return cell;
}
- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPHONE_5)
        return 40;
    else if(IS_IPHONE_6)
        return 50;
    else
        return 55;
}
#pragma mark:User Config Method:---
-(void)getUserConfigWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        //[AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getUserConfigHandler:)];
        [service getUserConfig_by_token];
    }
}
#pragma mark:Handler User Config Method:---
-(void)getUserConfigHandler:(id)sender{
    //[AppDelegate killHud];
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
                dicForCofigResponce = [[sender valueForKey:@"data"] mutableCopy];
            }
            else{
                // Other
            }
        }
    }
}

#pragma mark:Story Read Staus:---
-(void)getStoryReadStaus{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getStoryReadStausHandler:)];
        [service get_StoryReadStaus:[NSString stringWithFormat:@"%@",[[arryForStoryList objectAtIndex:tagForPopUpView] valueForKey:@"_id"]]];
    }
}
#pragma mark:Handler Story Read Staus:---
-(void)getStoryReadStausHandler:(id)sender{
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
                // 1 - Success Read story
                [viewForStoryPopUp setHidden:NO];
                [self popUpData];
            }
            else if([[sender valueForKey:@"status"] integerValue]==2) {
                // 2 - Ristrct Read story
                UIAlertController * alert=[UIAlertController
                                           
                                           alertControllerWithTitle:@"StoryShare" message:@"To read more stories you have to buy our yearly subscription plan of £ 0.79."preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                [self okButtonPressed];
                                                
                                            }];
                UIAlertAction* noButton = [UIAlertAction
                                           actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action)
                                           {
                                               [self cancelButtonPressed];
                                               
                                           }];
                
                [alert addAction:yesButton];
                [alert addAction:noButton];
                
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                
            }
        }
    }
}

#pragma mark:Update Member Ship:---
-(void)getUpdateMemberShip{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getUpdateMemberShipHandler:)];
        [service get_UpdateMemberShip];
    }
}
#pragma mark:Handler Update Member Ship:---
-(void)getUpdateMemberShipHandler:(id)sender{
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
                // 1 - Success Read story
            }else{
                
            }
        }
    }
}
- (void)cancelButtonPressed{
    // write your implementation for cancel button here.
}

- (void)okButtonPressed{
    //write your implementation for ok button here
    [self fetchAvailableProducts];
}

#pragma mark:Payment Method:--
//NSSet *productIdentifiers;
-(void)fetchAvailableProducts{
    [AppDelegate showHud];
    NSSet *productIdentifiers = [NSSet
                                 setWithObjects:@"GetPremiumSubscription",nil];
    productsRequest = [[SKProductsRequest alloc]
                       initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}
- (BOOL)canMakePurchases{
    return [SKPaymentQueue canMakePayments];
}

- (void)purchaseMyProduct:(SKProduct*)product{
    if ([self canMakePurchases]) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else{
        [AppDelegate killHud];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  @"Purchases are disabled in your device" message:nil delegate:
                                  self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [AppDelegate killHud];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"In-App Store unavailable" message:@"The In-App Store is currently unavailable, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark StoreKit Delegate
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
                if ([transaction.payment.productIdentifier
                     isEqualToString:@"GetPremiumSubscription"]) {
                    [AppDelegate killHud];
                    [self getUpdateMemberShip];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [AppDelegate killHud];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [AppDelegate killHud];
                if (transaction.error.code != SKErrorPaymentCancelled)
                {
                }
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            default:
                break;
        }
    }
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    NSInteger count = [response.products count];
    if (count>0) {
        validProduct = response.products;
        validProduct = [response.products objectAtIndex:0];
        if ([validProduct.productIdentifier
             isEqualToString:@"GetPremiumSubscription"]) {
            [self purchaseMyProduct:validProduct];
        }
    } else {
        //[[AppDelegate sharedInstance] killHUD];
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Not Available"
                            message:@"No products to purchase"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];
        [tmp show];
    }
}

@end
