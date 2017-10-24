//
//  TabHomeVC.h
//  Share_Story
//
//  Created by Ankush on 2/7/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomStarRank.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "TVTwitterController.h"
#import "ODRefreshControl.h"
#import "UIPopoverListView.h"
#import "TVFBController.h"
#import <StoreKit/StoreKit.h>
@import GoogleMobileAds;
@interface TabHomeVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,CustomStarRankDelegate,FBSDKSharingDelegate,TVTwitterDelegate,UITextFieldDelegate,UIPopoverListViewDataSource,UIPopoverListViewDelegate,TVFBDelegate,SKPaymentTransactionObserver,SKProductsRequestDelegate,SKRequestDelegate,SKStoreProductViewControllerDelegate>
{
    __weak IBOutlet UIView *viewForgenreList;
    CustomStarRank *viewForCustomStar;
    int pageNo;
    IBOutlet UIImageView *imgForSetting;
    IBOutlet UIButton *btnForSetting;
    NSString *strForIsMore;
    NSTimer*timer;
    BOOL isRefresh;
    ODRefreshControl *refreshControl1;
    UIPopoverListView *poplistview;
    
    //Payment Objects:--
    SKProductsRequest *productsRequest;
    NSArray *validProducts;
    NSString*strForProduct;
    
}
@property (weak, nonatomic) IBOutlet UIButton *btnForSearch;
- (IBAction)actionOnSearchBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *viewForSearch;
@property (weak, nonatomic) IBOutlet UITextField *txtForSearch;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constrantForaActiveView;
@property (weak, nonatomic) IBOutlet UIView *viewForHeader;
@property (weak, nonatomic) IBOutlet UIView *viewForStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnActive;
@property (strong, nonatomic) IBOutlet UIButton *btnComplete;
@property (weak, nonatomic) IBOutlet UIButton *btnFilter;
@property (weak, nonatomic) IBOutlet UITableView *tblViewStoryList;

@property (strong, nonatomic) NSMutableArray *arryForStoryList;
@property (strong, nonatomic) NSMutableArray *arrForGenre;
@property (weak, nonatomic) IBOutlet UILabel *lblForEmptyArray;

@property(nonatomic, strong) GADInterstitial *interstitial;

- (IBAction)actionOnActiveBtn:(id)sender;
- (IBAction)actionOnCompleteBtn:(id)sender;
- (IBAction)actionOnFilterBtn:(UIButton*)sender;

- (IBAction)actionFilterBtn:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *viewForFilter;

@property (weak, nonatomic) IBOutlet UIButton *btnForMostRated;
@property (weak, nonatomic) IBOutlet UIButton *btnForMostShared;
@property (weak, nonatomic) IBOutlet UIButton *btnForMostLiked;

- (IBAction)actionOnMostRated:(id)sender;
- (IBAction)actionOnMostShared:(id)sender;
- (IBAction)actionOnMostLiked:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tblViewGenreList;

- (IBAction)actionOnOkBtn:(id)sender;
- (IBAction)actionOnResetBtn:(id)sender;

// View For Story PopUp
@property (weak, nonatomic) IBOutlet UIView *viewForStoryPopUp;
@property (weak, nonatomic) IBOutlet UIView *viewForBlackBG;
@property (weak, nonatomic) IBOutlet UIView *viewForPopUp;
@property (weak, nonatomic) IBOutlet UIView *viewForStoryName;
@property (weak, nonatomic) IBOutlet UILabel *lblForStoryName;
@property (weak, nonatomic) IBOutlet UIView *viewForCenter;
@property (weak, nonatomic) IBOutlet UIImageView *imgForStoryTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblForStoryNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblForStoryText;
@property (weak, nonatomic) IBOutlet UIView *viewForLikeAndShare;
@property (weak, nonatomic) IBOutlet UIView *viewForStar;
@property (weak, nonatomic) IBOutlet UIImageView *imgForLikeBtn;

@property (weak, nonatomic) IBOutlet UIImageView *imgForBackOrHome;
@property (weak, nonatomic) IBOutlet UIImageView *imgForBack;

- (IBAction)actionOnBackBtn:(id)sender;
- (IBAction)actionOnSetting:(id)sender;

- (IBAction)actionOnReadMore:(id)sender;
- (IBAction)actionOnLikeStory:(UIButton*)sender;
- (IBAction)actionOnShareStoryWith:(UIButton*)sender;
// View For Story PopUp

@end
