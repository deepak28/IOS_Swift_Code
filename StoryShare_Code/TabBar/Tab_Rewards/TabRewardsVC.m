//
//  TabRewardsVC.m
//  Share_Story
//
//  Created by Ankush on 2/7/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import "TabRewardsVC.h"
#import "HomeVC.h"
#import "SettingsVC.h"
#import "AppDelegate.h"
#import "TabMyLibraryVC.h"
#import "UIView+Toast.h"
@import GoogleMobileAds;
@interface TabRewardsVC ()<SKProductsRequestDelegate,SKRequestDelegate,SKStoreProductViewControllerDelegate,GADRewardBasedVideoAdDelegate,SKPaymentTransactionObserver>
{
    NSDictionary *dic;
    int no_OfPens;
    int manageWord;
    NSString *strRedeem_Type;
    NSString *strForProduct;
}

@end

@implementation TabRewardsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    lblForPenIHave.layer.cornerRadius=9.0;
    lblForPenIHave.clipsToBounds=YES;
    self.navigationController.navigationBar.hidden=YES;
    self.navigationController.navigationBarHidden=YES;
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    [self requestRewardedVideo];
}
-(void)setBorder:(UIButton*)btn{
    btn.layer.cornerRadius=5.0;
    btn.layer.borderColor=(__bridge CGColorRef _Nullable)([UIColor colorWithRed:33.0/255.0 green:66.0/255.0 blue:99.0/255.0 alpha:1.0]);
    btn.layer.masksToBounds=YES;
    btn.layer.borderWidth = 1.0;
}
-(void)setBorderLbl:(UILabel*)btn{
    btn.layer.cornerRadius=5.0;
    btn.layer.borderColor=(__bridge CGColorRef _Nullable)([UIColor colorWithRed:33.0/255.0 green:66.0/255.0 blue:99.0/255.0 alpha:1.0]);
    btn.layer.masksToBounds=YES;
    btn.layer.borderWidth = 1.0;
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
    btnVideo.userInteractionEnabled=NO;
    [super viewWillAppear:YES];
    [[AppDelegate sharedInstance] setTabBarHidden:NO];
    if ([[TVStoredData sharedInstance].strCommingForRewards isEqualToString:@"home"]) {
        //[imgBackOrHome setImage:[UIImage imageNamed:@"tab_home_off"]];
        imgBack.hidden=YES;
        imgBackOrHome.hidden=NO;
        imgSetting.hidden=NO;
        btnSetting.hidden=NO;
        [[AppDelegate sharedInstance] setTabBarHidden:NO];
    }else if ([[TVStoredData sharedInstance].strCommingForRewards isEqualToString:@"create_story"]){
        imgBack.hidden=NO;
        imgBackOrHome.hidden=YES;
        imgSetting.hidden=YES;
        btnSetting.hidden=YES;
        [[AppDelegate sharedInstance] setTabBarHidden:YES];
    }else {
        //[imgBackOrHome setImage:[UIImage imageNamed:@"back_white"]];
        imgBack.hidden=NO;
        imgBackOrHome.hidden=YES;
        imgSetting.hidden=NO;
        btnSetting.hidden=NO;
        [[AppDelegate sharedInstance] setTabBarHidden:NO];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getRewardWeb];
        [self getUserConfigWeb];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//****************Change Color StatusBar****************************//
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
#pragma mark:Google Video Addd:---
- (void)requestRewardedVideo {
    GADRequest *request = [GADRequest request];
    //    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
    //                                           withAdUnitID:@"ca-app-pub-2234190694191381/7086106556"];
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:@"ca-app-pub-7240906535586790/2279606615"];
}
#pragma mark UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    //[self startNewGame];
}
#pragma mark GADRewardBasedVideoAdDelegate implementation
- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
}
- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    //self.showVideoButton.hidden = YES;
}

//****************RewardBased VideoAd****************************//
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        // [AppDelegate showHud];
        strRedeem_Type=@"video";
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getRedeemHandler:)];
        [service get_redeem_type:strRedeem_Type word_count:[NSString stringWithFormat:@"%@", reward.amount]];
    }
}
- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
}
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
    [self requestRewardedVideo];
}
- (IBAction)actionBack:(id)sender {
    if ([[TVStoredData sharedInstance].strCommingForRewards isEqualToString:@"home"]) {
        NSArray *viewControllers = [[AppDelegate sharedInstance].navigationMain viewControllers];
        for (int i=0; i<viewControllers.count; i++) {
            if ([[viewControllers objectAtIndex:i] isKindOfClass:[HomeVC class]])
            {
                [self.navigationController.navigationBar setHidden:NO];
                [[AppDelegate sharedInstance].navigationMain popToViewController:[viewControllers objectAtIndex:i] animated:YES];
            }
        }
    }else if ([[TVStoredData sharedInstance].strCommingForRewards isEqualToString:@"create_story"]){
        [TVStoredData sharedInstance].strForEditTxtHandle = @"YES";
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        //[self.navigationController popViewControllerAnimated:YES];
        [[AppDelegate sharedInstance].btnHomeTab setSelected:NO];
        [[AppDelegate sharedInstance].btnMyLibraryTab setSelected:YES];
        [[AppDelegate sharedInstance].btnRewardsTab setSelected:NO];
        [[AppDelegate sharedInstance].btnActivityTab setSelected:NO];
        [AppDelegate sharedInstance].tabBar.selectedIndex=1;
    }
}
- (IBAction)actionHome:(id)sender {
    NSArray *viewControllers = [[AppDelegate sharedInstance].navigationMain viewControllers];
    for (int i=0; i<viewControllers.count; i++) {
        if ([[viewControllers objectAtIndex:i] isKindOfClass:[HomeVC class]])
        {
            [self.navigationController.navigationBar setHidden:NO];
            [[AppDelegate sharedInstance].navigationMain popToViewController:[viewControllers objectAtIndex:i] animated:YES];
        }
    }
}

- (IBAction)actionSetting:(id)sender {
    [TVStoredData sharedInstance].strCommingForSetting=@"";
    SettingsVC *objSettingVC = [[SettingsVC alloc]init];
    [self.navigationController pushViewController:objSettingVC animated:YES];
}

- (IBAction)actionFor10Words:(id)sender {
    strForProduct=@"10Word";
    [self fetchAvailableProducts];
}

- (IBAction)actionFor30Words:(id)sender {
    strForProduct=@"30Word";
    [self fetchAvailableProducts];
}

- (IBAction)actionFor60Words:(id)sender {
    strForProduct=@"60Word";
    [self fetchAvailableProducts];
}

- (IBAction)actionOnRedeemBtn:(id)sender {
    if (no_OfPens > 0) {
        strRedeem_Type = @"pen";
        manageWord = no_OfPens*10;
        [self getRedeemWeb];
    }else{
        [self.navigationController.view makeToast:@"No pens avaliable."
                                         duration:2.0
                                         position:CSToastPositionBottom];
    }
}

- (IBAction)actionOnVideoBtn:(id)sender {
    [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
    //[self fetchAvailableProducts];
}

#pragma mark:Webservice Reward Data Method:---
-(void)getRewardWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getRewardHandler:)    ];
        [service get_RewardScreenData];
    }
}
#pragma mark:Handler Reward Method:---
-(void)getRewardHandler:(id)sender{
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
                dic = [[[NSDictionary alloc] initWithDictionary:sender] valueForKey:@"data"];
                no_OfPens = [[dic valueForKey:@"pens"] intValue];
                if (no_OfPens>0) {
                    lblForPenIHave.hidden=NO;
                    lblForPenIHave.text = [NSString stringWithFormat:@"%d",no_OfPens];
                }else{
                    lblForPenIHave.hidden=YES;
                }
                //[btnForWordCount setTitle:wordIhave forState:UIControlStateNormal];
                lblFor10Words.text=[[[dic valueForKey:@"pricing"] objectAtIndex:0] valueForKey:@"Title"];
                lblFor30Words.text=[[[dic valueForKey:@"pricing"] objectAtIndex:1] valueForKey:@"Title"];
                lblFor60Words.text=[[[dic valueForKey:@"pricing"] objectAtIndex:2] valueForKey:@"Title"];
                NSString *word10Words = [NSString stringWithFormat:@"£%@",[[[dic valueForKey:@"pricing"] objectAtIndex:0] valueForKey:@"Price"]];
                NSString *word30Words = [NSString stringWithFormat:@"£%@",[[[dic valueForKey:@"pricing"] objectAtIndex:1] valueForKey:@"Price"]];
                NSString *word60Words = [NSString stringWithFormat:@"£%@",[[[dic valueForKey:@"pricing"] objectAtIndex:2] valueForKey:@"Price"]];
                [btn50p setTitle:word10Words forState:UIControlStateNormal];
                [btn100 setTitle:word30Words forState:UIControlStateNormal];
                [btn200 setTitle:word60Words forState:UIControlStateNormal];
                
            }else{
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
                manageWord = [[[sender valueForKey:@"data"] valueForKey:@"word_bank"] intValue];
                NSString *wordIhave = [NSString stringWithFormat:@"%d",manageWord];
                [btnForWordCount setTitle:wordIhave forState:UIControlStateNormal];
                if (no_OfPens>0) {
                    lblForPenIHave.hidden=NO;
                    lblForPenIHave.text = [NSString stringWithFormat:@"%d",no_OfPens];
                }else{
                    lblForPenIHave.hidden=YES;
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
#pragma mark:User Redeem Method:---
-(void)getRedeemWeb{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You're Offline" message:@"You need to be online to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [AppDelegate showHud];
        WebserviceOperation *service=[[WebserviceOperation alloc]initWithDelegate:self callback:@selector(getRedeemHandler:)];
        [service get_redeem_type:strRedeem_Type word_count:[NSString stringWithFormat:@"%d", manageWord]];
    }
}
#pragma mark:Handler User Config Method:---
-(void)getRedeemHandler:(id)sender{
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
                if ([strRedeem_Type isEqualToString:@"pen"]) {
                    if (no_OfPens>0) {
                        no_OfPens=0;
                        [self getUserConfigWeb];
                        lblForPenIHave.hidden=YES;
                    }
                }else if ([strRedeem_Type isEqualToString:@"buy"]){
                    [self getUserConfigWeb];
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

#pragma mark: In App Purchase
- (IBAction)actionOnPurchaseButton:(id)sender {
    [self purchaseMyProduct:nil];
}
//NSSet *productIdentifiers;
-(void)fetchAvailableProducts{
    [AppDelegate showHud];
    NSSet *productIdentifiers = [NSSet
                                 setWithObjects:strForProduct,nil];
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
                     isEqualToString:@"10Word"] || [transaction.payment.productIdentifier
                                                    isEqualToString:@"30Word"] || [transaction.payment.productIdentifier isEqualToString:@"60Word"]) {
                    strRedeem_Type=@"buy";
                    if([transaction.payment.productIdentifier
                        isEqualToString:@"10Word"]){
                        manageWord = 10;
                    }else if([transaction.payment.productIdentifier
                              isEqualToString:@"30Word"]){
                        manageWord = 30;
                    }else{
                        manageWord = 60;
                    }
                    [AppDelegate killHud];
                    [self getRedeemWeb];
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
    int count = [response.products count];
    if (count>0) {
        validProduct = response.products;
        validProduct = [response.products objectAtIndex:0];
        if ([validProduct.productIdentifier
             isEqualToString:@"10Word"] || [validProduct.productIdentifier
                                            isEqualToString:@"30Word"] || [validProduct.productIdentifier
                                                                           isEqualToString:@"60Word"]) {
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
