//
//  EmotionalIntelligenceHelpView.m
//  PurposeColor
//
//  Created by Purpose Code on 31/05/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "EmotionalIntelligenceHelpView.h"

@interface EmotionalIntelligenceHelpView() <UICollectionViewDelegate,UICollectionViewDataSource>{
    
    IBOutlet UICollectionView *collectionView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIButton *btnSkip;
}

@end

@implementation EmotionalIntelligenceHelpView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setUp{
    
    btnSkip.layer.cornerRadius = 5.f;
    btnSkip.layer.borderWidth = 1.f;
    btnSkip.layer.borderColor = [UIColor getThemeColor].CGColor;
    btnSkip.hidden = true;
    
    UINib *cellNib = [UINib nibWithNibName:@"ItelligenceCollectionViewCell" bundle:nil];
    [collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ItelligenceCollectionViewCell"];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ItelligenceCollectionViewCell" forIndexPath:indexPath];
    UIImageView *bg;
    
    if ([[cell contentView]viewWithTag:1])
        bg = (UIImageView*) [[cell contentView]viewWithTag:1];
    
    if (indexPath.row == 0) {
        bg.image = [UIImage imageNamed:@"Intelligence_Intro_1"];
    }
    if (indexPath.row == 1) {
        bg.image = [UIImage imageNamed:@"Intelligence_Intro_2"];
    }
    if (indexPath.row == 2) {
        bg.image = [UIImage imageNamed:@"Intelligence_Intro_3"];
        
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float width = _collectionView.bounds.size.width;
    return CGSizeMake(width, _collectionView.frame.size.height);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = collectionView.frame.size.width;
    float currentPage = collectionView.contentOffset.x / pageWidth;
    
    if (0.0f != fmodf(currentPage, 1.0f))
        pageControl.currentPage = currentPage + 1;
    else
        pageControl.currentPage = currentPage;
    if (currentPage == 2) {
        btnSkip.hidden = false;
    }
    
}

-(IBAction)closePopUp{
    
    if ([self.delegate respondsToSelector:@selector(intelligenceHelpPopUpCloseAppplied)]) {
        [self.delegate intelligenceHelpPopUpCloseAppplied];
    }
}


@end
