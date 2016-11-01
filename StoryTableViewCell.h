//
//  StoryTableViewCell.h
//  TestMaps
//
//  Created by Pavel Hrybouski on 13.10.16.
//  Copyright © 2016 Pavel Hrybouski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;


@end
