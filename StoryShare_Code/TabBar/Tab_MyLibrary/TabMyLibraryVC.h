//
//  TabMyLibraryVC.h
//  Share_Story
//
//  Created by Ankush on 2/7/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabMyLibraryVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *viewForStatus;

- (IBAction)actionOnHome:(id)sender;
- (IBAction)actionOnSetting:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnSharedStoies;
@property (weak, nonatomic) IBOutlet UIButton *btnLikedStories;
@property (weak, nonatomic) IBOutlet UIButton *btnInterestedStories;
@property (weak, nonatomic) IBOutlet UIButton *btnContinueSavedStory;
@property (weak, nonatomic) IBOutlet UIButton *btnMyPens;

- (IBAction)actionOnSharedStories:(UIButton*)sender;
- (IBAction)actionOnLikedStories:(UIButton*)sender;
- (IBAction)actionOnInterestedStories:(UIButton*)sender;
- (IBAction)actionOnContinueSaved:(UIButton *)sender;
- (IBAction)actionOnMyPens:(UIButton*)sender;



@end
