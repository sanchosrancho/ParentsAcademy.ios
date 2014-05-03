//
//  VideoListCell.m
//  ParentsAcademy
//
//  Created by Alex on 5/3/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import "VideoListCell.h"

@implementation VideoListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self.titleLabel setText:title];
}

- (void)setThumbnail:(UIImage *)thumbnail
{
    _thumbnail = thumbnail;
    [self.thumbnailImageView setImage:thumbnail];
}

@end
