//
//  CustomCellWithTable.m
//  PurposeColor
//
//  Created by Purpose Code on 06/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define OneK                    1000
#define kPadding                10
#define kDefaultNumberOfCells   1
#define kHeightForCell          250
#define kHeightForHeader        70


#import "CustomCellWithTable.h"
#import "InnerTableViewCell.h"
#import "Constants.h"
#import "KILabel.h"

@interface CustomCellWithTable()<ActionCellDelegate>{
    
    NSArray *dataSource;
    NSInteger parentSection;
}

@end
@implementation CustomCellWithTable

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpActionsWithDataSource:(NSArray*)_dataSource{
    
    dataSource = _dataSource;
    [_tableView reloadData];
}

-(void)setUpParentSection:(NSInteger)_parentSection;{
   
    parentSection = _parentSection;
}

#pragma mark - UITableViewDataSource Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return dataSource.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger totalCount = 0;
    if (section < dataSource.count) {
        NSDictionary *medias = dataSource[section];
        if (NULL_TO_NIL([medias objectForKey:@"action_media"])) {
            NSArray *mediaItems  = [medias objectForKey:@"action_media"];
            totalCount += mediaItems.count;
        }
    }
    totalCount += 1;
    return totalCount;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell = [self configureCellForIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        // GEM Description
        
        static NSString *CellIdentifier;
        if (_isTabEmotion) {
            CellIdentifier = @"ActionInfoForEmotion";
        }else{
            CellIdentifier = @"ActionInfoForGoal";
        }
        
        UITableViewCell *cell = (UITableViewCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        
        
        if (indexPath.section < dataSource.count) {
            NSDictionary *details = dataSource[indexPath.section];
            KILabel *lblInfo;
            if ([[[cell contentView] viewWithTag:1] isKindOfClass:[KILabel class]]) {
                lblInfo = [[cell contentView] viewWithTag:1];
                lblInfo.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
                    // Open URLs
                    [self attemptOpenURL:[NSURL URLWithString:string]];
                };

                
            }
            if (NULL_TO_NIL([details objectForKey:@"action_details"])) {
                
                UIFont *font = [UIFont fontWithName:CommonFont size:14];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineHeightMultiple = 1.2f;
                NSDictionary *attributes = @{NSFontAttributeName:font,
                                             };
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[details objectForKey:@"action_details"] attributes:attributes];
                lblInfo.attributedText = attributedText;
                
            }
            UILabel *lblBorder;
            if ([[[cell contentView] viewWithTag:10] isKindOfClass:[UILabel class]]){
                lblBorder = [[cell contentView] viewWithTag:10];
                lblBorder.hidden = true;
            }
            
            if (NULL_TO_NIL([details objectForKey:@"action_media"])) {
                //Media available
            }else{
                //Media not available show Border
                lblBorder.hidden = false;
            }
            
            if ([[[cell contentView] viewWithTag:3] isKindOfClass:[UIView class]]){
                UIView *vwBg = [[cell contentView] viewWithTag:3];
                vwBg.hidden = true;
                if ([[vwBg viewWithTag:4] isKindOfClass:[UILabel class]]){
                    UILabel *lblAddress = (UILabel*) [vwBg viewWithTag:4];
                    lblAddress.text = @"";
                    if (NULL_TO_NIL([details objectForKey:@"location_name"])) {
                        lblAddress.text = [details objectForKey:@"location_name"];
                        vwBg.hidden = false;
                    }
                    
                }
                
            }
            
            if ([[[cell contentView] viewWithTag:5] isKindOfClass:[UIView class]]){
                UIView *vwBg = [[cell contentView] viewWithTag:5];
                vwBg.hidden = true;
                if ([[vwBg viewWithTag:6] isKindOfClass:[UILabel class]]){
                    UILabel *lblAddress = (UILabel*) [vwBg viewWithTag:6];
                    lblAddress.text = @"";
                    if (NULL_TO_NIL([details objectForKey:@"contact_name"])) {
                        lblAddress.text = [details objectForKey:@"contact_name"];
                        vwBg.hidden = false;
                    }
                    
                }
                
            }
        }
        
        
    return cell;
        
    }else{
        
        static NSString *CellIdentifier = @"InnerTableViewCell";
        InnerTableViewCell *cell = (InnerTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.imgGem setImage:[UIImage imageNamed:@"NoImage.png"]];
        [cell.activityIndicator stopAnimating];
        [[cell btnVideoPlay]setHidden:YES];
        [[cell btnAudioPlay]setHidden:YES];
        cell.delegate = self;
        [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
        
        if (indexPath.section < dataSource.count) {
            NSDictionary *details = dataSource[indexPath.section];
            if (NULL_TO_NIL([details objectForKey:@"action_media"])) {
                NSArray *goalMedia = [details objectForKey:@"action_media"];
                if (indexPath.row - 1 < goalMedia.count) {
                    NSDictionary *mediaInfo = goalMedia[indexPath.row - 1];
                    if (mediaInfo) {
                        
                        NSString *mediaType ;
                        if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
                            mediaType = [mediaInfo objectForKey:@"media_type"];
                        }
                        
                        if (mediaType) {
                            
                            if ([mediaType isEqualToString:@"image"]) {
                                
                                // Type Image
                                [cell.imgGem setImage:[UIImage imageNamed:@"NoImage.png"]];
                                [cell.activityIndicator startAnimating];
                                [cell.imgGem sd_setImageWithURL:[NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]]
                                               placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                          [UIView transitionWithView:cell.imgGem
                                                                            duration:.5f
                                                                             options:UIViewAnimationOptionTransitionCrossDissolve
                                                                          animations:^{
                                                                              cell.imgGem.image = image;
                                                                          } completion:nil];
                                                          
                                                          
                                                          [cell.activityIndicator stopAnimating];
                                                      }];
                            }
                            
                            else if ([mediaType isEqualToString:@"audio"]) {
                                
                                // Type Audio
                                [cell.imgGem setImage:[UIImage imageNamed:@"NoImage.png"]];
                                if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                                    [[cell btnAudioPlay]setHidden:false];
                                    
                                }
                                
                            }
                            
                            else if ([mediaType isEqualToString:@"video"]) {
                                
                                // Type Video
                                if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                                    NSString *videoURL = [mediaInfo objectForKey:@"gem_media"];
                                    if (videoURL.length){
                                        [[cell btnVideoPlay]setHidden:false];
                                    }
                                }
                                
                                if (NULL_TO_NIL([mediaInfo objectForKey:@"video_thumb"])) {
                                    NSString *videoThumb = [mediaInfo objectForKey:@"video_thumb"];
                                    if (videoThumb.length) {
                                        [cell.activityIndicator startAnimating];
                                        [cell.imgGem sd_setImageWithURL:[NSURL URLWithString:videoThumb]
                                                       placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                                  [cell.activityIndicator stopAnimating];
                                                                  [UIView transitionWithView:cell.imgGem
                                                                                    duration:.5f
                                                                                     options:UIViewAnimationOptionTransitionCrossDissolve
                                                                                  animations:^{
                                                                                      cell.imgGem.image = image;
                                                                                  } completion:nil];
                                                              }];
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
            }
        }
        return cell;
    }
  
    
    return cell;
  
    
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.row == 0) {
        if (indexPath.section < dataSource.count) {
            NSDictionary *details = dataSource[indexPath.section];
            if (NULL_TO_NIL([details objectForKey:@"action_details"])) {
                NSString *strDetails = [details objectForKey:@"action_details"];
                if (strDetails.length) {
                    height = [self getLabelHeight:strDetails];
                }
                else {
                    height = 0;
                }
            }
            
            float padding = 0;
            if (NULL_TO_NIL([details objectForKey:@"contact_name"])) {
                height += [self getLabelHeightForOtherInfo:[details objectForKey:@"contact_name"] withFont:[UIFont fontWithName:CommonFont size:12]];
                padding = 15;
            }
            
            if (NULL_TO_NIL([details objectForKey:@"location_name"])) {
                height += [self getLabelHeightForOtherInfo:[details objectForKey:@"location_name"] withFont:[UIFont fontWithName:CommonFontBold size:12]];
                padding = 15;
            }
            return height + padding;
            
        }
        
    }
    height = kHeightForCell;
    return height;
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *vwHeader = [UIView new];
    UIView *vwBG = [UIView new];
    [vwHeader addSubview:vwBG];
    vwBG.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwBG]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBG)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwBG]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBG)]];
    vwBG.backgroundColor = [UIColor whiteColor];
    //vwBG.backgroundColor = [UIColor greenColor];
    
    // Top Border
    
    if (section > 0 && _isTabEmotion) {
        
        UIView *vwTopBorder = [UIView new];
        [vwHeader addSubview:vwTopBorder];
        vwTopBorder.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[vwTopBorder]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwTopBorder)]];
        vwTopBorder.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
        
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:vwTopBorder
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:5.0]];
        [vwTopBorder addConstraint:[NSLayoutConstraint constraintWithItem:vwTopBorder
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.0
                                                                 constant:1.0]];
    }

    UIView *vwBorder = [UIView new];
    [vwHeader addSubview:vwBorder];
    vwBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwBorder]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBorder)]];
    vwBorder.backgroundColor = [UIColor colorWithRed:0.98 green:0.38 blue:0.38 alpha:1.0];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:vwBorder
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:vwHeader
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0.0]];
    [vwBorder addConstraint:[NSLayoutConstraint constraintWithItem:vwBorder
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:5.0]];
    
    UILabel *_lblTitle = [UILabel new];
    _lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _lblTitle.numberOfLines = 0;
    [vwBG addSubview:_lblTitle];
    [vwBG addConstraint:[NSLayoutConstraint constraintWithItem:_lblTitle
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:vwBG
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:-10.0]];
    if (_isTabEmotion) {
        [vwBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_lblTitle]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
    }else{
        [vwBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[_lblTitle]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
    }
    _lblTitle.font = [UIFont fontWithName:CommonFontBold size:14];
    _lblTitle.textColor = [UIColor blackColor];
    
    UILabel *lblDate= [UILabel new];
    lblDate.numberOfLines = 1;
    lblDate.translatesAutoresizingMaskIntoConstraints = NO;
    [vwBG addSubview:lblDate];
    if (_isTabEmotion) {
       [vwBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblDate]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblDate)]];
    }else{
       [vwBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[lblDate]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblDate)]];
    }
    
    
    [vwBG addConstraint:[NSLayoutConstraint constraintWithItem:lblDate
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:vwBG
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-10.0]];
    lblDate.font = [UIFont fontWithName:CommonFont size:11];
    lblDate.textColor = [UIColor lightGrayColor];
    
    if (section < dataSource.count) {
        NSDictionary *details = dataSource[section];
        if (NULL_TO_NIL([details objectForKey:@"action_title"])) {
            _lblTitle.text = [details objectForKey:@"action_title"];
        }
        UIColor *selectedColor;
        NSString *status;
        if (NULL_TO_NIL([details objectForKey:@"action_status"])) {
            status = @"ACTIVE";
            NSInteger _status = [[details objectForKey:@"action_status"] integerValue];
            selectedColor = [UIColor colorWithRed:1.00 green:0.45 blue:0.36 alpha:1.0];
            if (_status == 1) {
                status = @"COMPLETED";
                selectedColor = [UIColor colorWithRed:0.02 green:0.52 blue:0.03 alpha:1.0];
            }
        }
        if (status) {
          
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ | %@",[Utility getDateStringFromSecondsWith:[[details objectForKey:@"action_datetime"] doubleValue] withFormat:@"d MMM,yyyy h:mm a"],status]];
            [text addAttribute: NSForegroundColorAttributeName value:selectedColor range: NSMakeRange(text.length - status.length, status.length)];
            [lblDate setAttributedText: text];

            
        }else{
            lblDate.text = [NSString stringWithFormat:@"%@",[Utility getDateStringFromSecondsWith:[[details objectForKey:@"action_datetime"] doubleValue] withFormat:@"d MMM,yyyy h:mm a"]]  ;
        }
        
        if (NULL_TO_NIL([details objectForKey:@"action_media"])) {
            
        }else{
            
            // No Media
            
            if (NULL_TO_NIL([details objectForKey:@"action_details"])) {
            }else{
                
                // No media And Description
                UILabel *lblBorder= [UILabel new];
                lblBorder.translatesAutoresizingMaskIntoConstraints = NO;
                [vwBG addSubview:lblBorder];
                [vwBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lblBorder]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblBorder)]];
                lblBorder.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
                
                [lblBorder addConstraint:[NSLayoutConstraint constraintWithItem:lblBorder
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1.0
                                                                       constant:1.0]];
                [vwBG addConstraint:[NSLayoutConstraint constraintWithItem:lblBorder
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:vwBG
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-1.0]];
            }
            
        }
        
    }
    
    if (!_isTabEmotion) {
        
        UIImageView *imgBanner = [UIImageView new];
        [vwBG addSubview:imgBanner];
        imgBanner.image = [UIImage imageNamed:@"Action_Banner.png"];
        imgBanner.translatesAutoresizingMaskIntoConstraints = NO;
        imgBanner.backgroundColor = [UIColor clearColor];
        [imgBanner addConstraint:[NSLayoutConstraint constraintWithItem:imgBanner
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:20.0]];
        [imgBanner addConstraint:[NSLayoutConstraint constraintWithItem:imgBanner
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:Nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:70.0]];
        [vwBG addConstraint:[NSLayoutConstraint constraintWithItem:imgBanner
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwBG
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:0.0]];
        [vwBG addConstraint:[NSLayoutConstraint constraintWithItem:imgBanner
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwBG
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0]];
    }
    
    return vwHeader;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   CGFloat minimumHeight = kHeightForHeader;
    if (section < dataSource.count) {
        NSDictionary *details = dataSource[section];
        if (NULL_TO_NIL([details objectForKey:@"action_title"])) {
            float padding = 30;
            if (_isTabEmotion) {
                padding = 15;
            }
          CGFloat height =  [self getHeaderHeight:[details objectForKey:@"action_title"] withPadding:padding];
            if (!_isTabEmotion) {
                if (height < minimumHeight)
                    return minimumHeight;
                else return height + 15;
            }
            else return height;
            
        }
        
    }
    return kHeightForHeader;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)getLabelHeight:(NSString*)description
{
    float heightPadding = 20;
    float widthPadding = 15;
    if (!_isTabEmotion) {
        widthPadding = 30;
    }
    CGFloat height = 0;
    CGSize constraint = CGSizeMake(_tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    if (description) {
        constraint = CGSizeMake(_tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 1.2f;
        CGSize boundingBox = [description boundingRectWithSize:constraint
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],
                                                                 NSParagraphStyleAttributeName:paragraphStyle}
                                                       context:context].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        height = size.height + heightPadding;
    }
    
    
    return height;
    
}

- (CGFloat)getHeaderHeight:(NSString*)description withPadding:(float)widthPadding
{
    float heightPadding = 50;
    CGFloat height = 0;
    CGSize constraint = CGSizeMake(_tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    if (description) {
        constraint = CGSizeMake(_tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
        CGSize boundingBox = [description boundingRectWithSize:constraint
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],
                                                                 }
                                                       context:context].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        height = size.height + heightPadding;
    }
    
    
    return height;
    
}

- (CGFloat)getLabelHeightForOtherInfo:(NSString*)description withFont:(UIFont*)font
{
    CGFloat height = 0;
    float widthPadding = 30;
    if (!_isTabEmotion) {
        widthPadding = 45;
    }
    CGSize constraint = CGSizeMake(_tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    constraint = CGSizeMake(_tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize boundingBox = [description boundingRectWithSize:constraint
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:font
                                                             }
                                                   context:context].size;
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    height = size.height;
    //    if (height < 15) {
    //        height = 15;
    //    }
    
    return height;
    
}



-(void)mediaCellClickedWithSection:(NSInteger)section andIndex:(NSInteger)index{
    
    if ([self.delegate respondsToSelector:@selector(mediaCellClickedWithSection:andIndex:parentSection:)]) {
        [self.delegate mediaCellClickedWithSection:section andIndex:index parentSection:parentSection];
    }

}

- (void)attemptOpenURL:(NSURL *)url
{
    
    
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (!safariCompatible) {
        
        NSString *urlString = url.absoluteString;
        urlString = [NSString stringWithFormat:@"http://%@",url.absoluteString];
        url = [NSURL URLWithString:urlString];
        
    }
    safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem"
                                                        message:@"The selected link cannot be opened."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
