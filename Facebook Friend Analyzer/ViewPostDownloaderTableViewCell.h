//
//  ViewPostDownloaderTableViewCell.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 8/3/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewPostDownloaderTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextView *postTextView;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentsLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end