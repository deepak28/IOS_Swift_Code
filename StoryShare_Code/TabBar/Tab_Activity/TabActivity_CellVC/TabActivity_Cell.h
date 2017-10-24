//
//  TabActivity_Cell.h
//  Share_Story
//
//  Created by Ankush on 2/14/17.
//  Copyright © 2017 techvalens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabActivity_Cell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgForStoryBook;
@property (weak, nonatomic) IBOutlet UILabel *lblForStoryName;
@property (weak, nonatomic) IBOutlet UILabel *lblForLikedNames;
@property (weak, nonatomic) IBOutlet UILabel *lblForDate;
@property (weak, nonatomic) IBOutlet UILabel *lblForImageLbl;
@property (weak, nonatomic) IBOutlet UIButton *btnForLike;
@property (weak, nonatomic) IBOutlet UILabel *btnForShare;
@property (weak, nonatomic) IBOutlet UIButton *btnForDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnForShareStory;
@property (weak, nonatomic) IBOutlet UIImageView *imgForLike;


@end
