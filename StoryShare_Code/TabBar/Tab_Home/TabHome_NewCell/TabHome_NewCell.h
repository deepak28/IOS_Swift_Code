//
//  TabHome_NewCell.h
//  Share_Story
//
//  Created by Ankush on 2/26/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabHome_NewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgForStory;
@property (weak, nonatomic) IBOutlet UILabel *lblForStoryNameOnImg;
@property (weak, nonatomic) IBOutlet UILabel *lblForStoryName;
@property (weak, nonatomic) IBOutlet UIButton *btnForMulitpalName;
@property (weak, nonatomic) IBOutlet UILabel *lblForTimaAndDate;
@property (weak, nonatomic) IBOutlet UILabel *lblForRating;
@property (weak, nonatomic) IBOutlet UIButton *btnForSaveToLibrary;
@property (weak, nonatomic) IBOutlet UILabel *lblForWardCount;
@property (weak, nonatomic) IBOutlet UIButton *btnForShare;
@property (weak, nonatomic) IBOutlet UILabel *lblForLikeCount;

@property (weak, nonatomic) IBOutlet UIView *viewForActive;
@property (weak, nonatomic) IBOutlet UIView *viewForLibrary;
@property (weak, nonatomic) IBOutlet UILabel *lblForlike;
@property (weak, nonatomic) IBOutlet UIImageView *imgForPen;
@property (weak, nonatomic) IBOutlet UIImageView *imgForLike;
@property (weak, nonatomic) IBOutlet UIButton *btnForLikeOrPen;
@property (weak, nonatomic) IBOutlet UILabel *lblForDelete;
@property (weak, nonatomic) IBOutlet UIImageView *imgForDelete;
@property (weak, nonatomic) IBOutlet UIImageView *imgForShare;
@property (weak, nonatomic) IBOutlet UIButton *btnForDelete;

@property (weak, nonatomic) IBOutlet UIView *viewForShareLib;
@property (weak, nonatomic) IBOutlet UILabel *lblForSingleLine;
@property (weak, nonatomic) IBOutlet UIView *viewForDeleteLib;



@end
