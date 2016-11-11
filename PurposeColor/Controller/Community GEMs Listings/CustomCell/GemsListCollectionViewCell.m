//
//  ProductCollectionViewCell.m
//  SignSpot
//
//  Created by Purpose Code on 12/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "GemsListCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>


@implementation GemsListCollectionViewCell

-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;{
    
    self.row = row;
    self.section = section;
    _imgProfile.layer.borderColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0].CGColor;
    _imgProfile.layer.borderWidth = 2.f;
    _btnBanner.layer.borderWidth = 1.f;
    _btnBanner.layer.borderColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0].CGColor;
    _btnBanner.layer.cornerRadius = 3.f;

}

-(IBAction)likeGemsApplied:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(likeGemsClicked:)]) {
        [self.delegate likeGemsClicked:self.row];
    }

}
-(IBAction)shareGemsApplied:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(shareButtonClickedWithIndex:button:)]) {
        [self.delegate shareButtonClickedWithIndex:self.row button:self.btnShare];
    }
    
}

-(IBAction)commentComposeApplied:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(commentComposeViewClickedBy:)]) {
        [self.delegate commentComposeViewClickedBy:self.row];
    }
    
}

-(IBAction)moreGalleryButtonApplied:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(moreGalleryPageClicked:)]) {
        [self.delegate moreGalleryPageClicked:self.row];
    }
    
}


-(IBAction)followButtonClicked:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(followButtonClickedWith:)]) {
        [self.delegate followButtonClickedWith:self.row];
    }
    
}

-(IBAction)deleteButtonClicked:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(deleteAGemWithIndex:)]) {
        [self.delegate deleteAGemWithIndex:self.row];
    }
    
}


-(IBAction)hideButtonClicked:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(moreButtonClickedWithIndex:view:)]) {
        [self.delegate moreButtonClickedWithIndex:self.row view:_btnMore];
    }
    
}

-(IBAction)editButtonClicked:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(editAGemWithIndex:)]) {
        [self.delegate editAGemWithIndex:self.row];
    }
    
}

-(IBAction)showButtonClicked:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(showGEMSInCommunity:)]) {
        [self.delegate showGEMSInCommunity:self.row];
    }
    
}

-(IBAction)showAllGemLikedUsers:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(showAllLikedUsers:)]) {
        [self.delegate showAllLikedUsers:self.row];
    }
    
}


-(IBAction)showAllGemCommentedUsers:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(showAllCommentedUsers:)]) {
        [self.delegate showAllCommentedUsers:self.row];
    }
    
}



@end
