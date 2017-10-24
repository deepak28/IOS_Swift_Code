//
//  TabMyLibraryVC.m
//  Share_Story
//
//  Created by Ankush on 2/7/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import "TabMyLibraryVC.h"
#import "HelpVC.h"
#import "TVStoredData.h"
#import "AppDelegate.h"
#import "SettingsVC.h"
#import "HomeVC.h"

@interface TabMyLibraryVC ()

@end

@implementation TabMyLibraryVC

@synthesize btnLikedStories,btnSharedStoies,btnInterestedStories,btnMyPens,viewForStatus;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden=YES;
    self.navigationController.navigationBarHidden=YES;
}
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
-(void)viewWillAppear:(BOOL)animated{
    [TVStoredData sharedInstance].isCommingForm = @"";
    [super viewWillAppear:animated];
    [[AppDelegate sharedInstance] setTabBarHidden:NO];
    [self.navigationController.navigationItem hidesBackButton];
    btnInterestedStories.selected=NO;
    btnSharedStoies.selected=NO;
    btnLikedStories.selected=NO;
    btnMyPens.selected=NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)actionOnHome:(id)sender {
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

- (IBAction)actionOnSharedStories:(UIButton*)sender {
    sender.selected = YES;
    HelpVC *objHelpVC = [[HelpVC alloc]init];
    [TVStoredData sharedInstance].isCommingForm = @"ShareStores";
    [TVStoredData sharedInstance].strForCheckLibrary=@"YES";
    [self.navigationController pushViewController:objHelpVC animated:YES];
    
}
- (IBAction)actionOnLikedStories:(UIButton*)sender {
    sender.selected = YES;
    HelpVC *objHelpVC = [[HelpVC alloc]init];
    [TVStoredData sharedInstance].isCommingForm = @"LikedStores";
    [TVStoredData sharedInstance].strForCheckLibrary=@"YES";
    [self.navigationController pushViewController:objHelpVC animated:YES];
}
- (IBAction)actionOnInterestedStories:(UIButton*)sender {
    sender.selected = YES;
    HelpVC *objHelpVC = [[HelpVC alloc]init];
    [TVStoredData sharedInstance].isCommingForm = @"InterestedStores";
    [TVStoredData sharedInstance].strForCheckLibrary=@"YES";
    [self.navigationController pushViewController:objHelpVC animated:YES];
}

- (IBAction)actionOnContinueSaved:(UIButton *)sender{
    [TVStoredData sharedInstance].isCommingForm=@"SavedStoryMyLibrary";
    [TVStoredData sharedInstance].strForCheckLibrary=@"YES";
    HelpVC*objHelpVC=[[HelpVC alloc] init];
    [self.navigationController pushViewController:objHelpVC animated:YES];
}
- (IBAction)actionOnMyPens:(UIButton*)sender {
    sender.selected = YES;
    [TVStoredData sharedInstance].strCommingForRewards=@"";
    [[AppDelegate sharedInstance].btnHomeTab setSelected:NO];
    [[AppDelegate sharedInstance].btnMyLibraryTab setSelected:NO];
    [[AppDelegate sharedInstance].btnRewardsTab setSelected:YES];
    [[AppDelegate sharedInstance].btnActivityTab setSelected:NO];
    [AppDelegate sharedInstance].tabBar.selectedIndex=2;
}

@end
