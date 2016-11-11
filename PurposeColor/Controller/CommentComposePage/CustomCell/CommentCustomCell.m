//
//  CommentCustomCell.m
//  PurposeColor
//
//  Created by Purpose Code on 11/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "CommentCustomCell.h"

@implementation CommentCustomCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)deleteCommentClicked:(UIButton*)btnDelete{
    
    if ([self.delegate respondsToSelector:@selector(deleteCommentClicked:)]) {
        [self.delegate deleteCommentClicked:_index];
    }
    
}


@end
