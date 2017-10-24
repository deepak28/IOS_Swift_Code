//
//  TabHome_CellVC.h
//  Share_Story
//
//  Created by Ankush on 2/9/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabHome_CellVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgSotryType;
@property (weak, nonatomic) IBOutlet UILabel *lblStoryName;
@property (weak, nonatomic) IBOutlet UILabel *lblStoryTimeAndDate;

@property (weak, nonatomic) IBOutlet UIView *viewForHide;
@property (weak, nonatomic) IBOutlet UILabel *lblForHide;

//Need to hide Element on conditions
@property (weak, nonatomic) IBOutlet UILabel *lblForShareChang;
@property (weak, nonatomic) IBOutlet UIImageView *imgForShareChange;
@property (weak, nonatomic) IBOutlet UILabel *lblForLikeCountChange;
@property (weak, nonatomic) IBOutlet UIImageView *imgForCountLineChnage;
@property (weak, nonatomic) IBOutlet UIImageView *imgForLike;
@property (weak, nonatomic) IBOutlet UIImageView *imgForDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnForDelete;
//

@property (weak, nonatomic) IBOutlet UILabel *lblWardCount;
@property (weak, nonatomic) IBOutlet UIButton *bntShareStory;
@property (weak, nonatomic) IBOutlet UILabel *lblLikesCount;

@end
