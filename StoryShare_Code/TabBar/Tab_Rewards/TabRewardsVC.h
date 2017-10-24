//
//  TabRewardsVC.h
//  Share_Story
//
//  Created by Ankush on 2/7/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface TabRewardsVC : UIViewController
{
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UILabel *lblRedeem;
    IBOutlet UILabel *lbl50p;
    IBOutlet UILabel *lbl100;
    IBOutlet UILabel *lbl200;
    IBOutlet UILabel *lblVideo;
    
    __weak IBOutlet UIImageView *imgBack;
    __weak IBOutlet UILabel *lblForPenIHave;
    __weak IBOutlet UIImageView *imgBackOrHome;
    __weak IBOutlet UIView *viewForStatus;
    __weak IBOutlet UIButton *btnForWordCount;
    __weak IBOutlet UILabel *lblFor10Words;
    __weak IBOutlet UILabel *lblFor30Words;
    __weak IBOutlet UILabel *lblFor60Words;
    __weak IBOutlet UILabel *lblForWatchVideo;
    __weak IBOutlet UIImageView *imgSetting;
    __weak IBOutlet UIButton *btnSetting;
    __weak IBOutlet UILabel *lblForVideoWord;    
    
    IBOutlet UIButton *btnredeem;
    IBOutlet UIButton *btn50p;
    IBOutlet UIButton *btn100;
    IBOutlet UIButton *btn200;
    IBOutlet UIButton *btnVideo;
    
    SKProductsRequest *productsRequest;
    NSArray *validProducts;
}
- (IBAction)actionBack:(id)sender;
- (IBAction)actionHome:(id)sender;
- (IBAction)actionSetting:(id)sender;

- (IBAction)actionFor10Words:(id)sender;
- (IBAction)actionFor30Words:(id)sender;
- (IBAction)actionFor60Words:(id)sender;

- (IBAction)actionOnRedeemBtn:(id)sender;
- (IBAction)actionOnVideoBtn:(id)sender;


@end
