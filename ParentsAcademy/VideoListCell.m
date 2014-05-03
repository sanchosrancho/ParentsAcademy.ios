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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.shadowColor = [[UIColor redColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(5.0, 15.0);
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 0.0;
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
