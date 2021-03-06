//
//  GEMDetailViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 11/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kCellHeight             300;
#define kHeightForHeader        100;
#define kHeightForFooter        .001;
#define kNumberOfSections       2;
#define kHeightPercentage       80;
#define OneK                    1000

#import "GEMDetailViewController.h"
#import "GemDetailsCustomTableViewCell.h"
#import "Constants.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CommentComposeViewController.h"
#import <AVKit/AVKit.h>
#import "CustomAudioPlayerView.h"
#import "PhotoBrowser.h"
#import "CreateActionInfoViewController.h"
#import "ACRObservingPlayerItem.h"
#import "KILabel.h"
#import "MTDURLPreview.h"
#import "GemDetailsCustomCellTitle.h"
#import "GemDetailsCustomCellDescription.h"
#import "GemDetailsCustomCellLocation.h"
#import "GemDetailsCustomCellContact.h"
#import "GemDetailsCustomCellPreview.h"

@interface GEMDetailViewController ()<GemDetailPageCellDelegate,CommentActionDelegate,CustomAudioPlayerDelegate,PhotoBrowserDelegate,ACRObservingPlayerItemDelegate,CreateMediaInfoDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblShareTitle;
    IBOutlet UIImageView *imgShareImage;
    NSArray *arrGemMedias;
    
    NSInteger playingIndex;
    BOOL isScrolling;
    BOOL isPlaying;
    CommentComposeViewController *composeComment;
    
    IBOutlet  UIImageView *imgLike;
    CustomAudioPlayerView *vwAudioPlayer;
    PhotoBrowser *photoBrowser;
    
    AVPlayer *videoPlayer;
    AVPlayerItem *videoPlayerItem;
    UIActivityIndicatorView *videoIndicator;
    ACRObservingPlayerItem *playerItem;
    NSMutableDictionary *heightsCache;
}

@end

@implementation GEMDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
   
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUp{
    
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    playingIndex = -1;
    arrGemMedias = [NSArray new];
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_media"]))
        arrGemMedias = [_gemDetails objectForKey:@"gem_media"];
    imgLike.image = [UIImage imageNamed:@"Like_Buton.png"];
    if ([[_gemDetails objectForKey:@"like_status"] boolValue])
        imgLike.image = [UIImage imageNamed:@"Like_Active.png"];
    if ([[_gemDetails objectForKey:@"gem_type"] isEqualToString:@"event"]) {
        lblTitle.text = [[NSString stringWithFormat:@"%@ DETAILS",@"MOMENT"] uppercaseString];
    }else{
         lblTitle.text = [[NSString stringWithFormat:@"%@ DETAILS",[_gemDetails objectForKey:@"gem_type"]] uppercaseString];
    }
    if (_canSave) {
        lblShareTitle.text = @"Save";
        imgShareImage.image = [UIImage imageNamed:@"Save_Gray.png"];
    }
    heightsCache =  [NSMutableDictionary new];
    [tableView reloadData];
    
}

#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        NSInteger rows = 4;
        if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"])){
            NSString *string = [_gemDetails objectForKey:@"gem_details"];
            NSError *error = nil;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                       error:&error];
            NSArray *matches = [detector matchesInString:string
                                                 options:0
                                                   range:NSMakeRange(0, [string length])];
            if (matches.count > 0) {
                rows = 5;
            }
        }
        return rows;
    }
    return arrGemMedias.count;
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            GemDetailsCustomCellTitle *cell = (GemDetailsCustomCellTitle *)[tableView dequeueReusableCellWithIdentifier:@"GemDetailsCustomCellTitle"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.lbltTitle.text = [_gemDetails objectForKey:@"gem_title"];
            cell.btnEdit.hidden = true;
            cell.btnDelete.hidden = true;
            if (_canDelete){
                cell.titleRightConstraint.constant = 40;
                cell.btnDelete.hidden = false;
            }
            if (_isFromGEM) {
                cell.titleRightConstraint.constant = 40;
                cell.btnEdit.hidden = false;
            }
            cell.lblDate.text = [Utility getDaysBetweenTwoDatesWith:[[_gemDetails objectForKey:@"gem_datetime"] doubleValue]];
            return cell;
        }
        
        if (indexPath.row == 1) {
            GemDetailsCustomCellLocation *cell = (GemDetailsCustomCellLocation *)[tableView dequeueReusableCellWithIdentifier:@"GemDetailsCustomCellLocation"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (NULL_TO_NIL([_gemDetails objectForKey:@"location_name"])){
                cell.lblLocation.text = [_gemDetails objectForKey:@"location_name"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        if (indexPath.row == 2) {
            GemDetailsCustomCellContact *cell = (GemDetailsCustomCellContact *)[tableView dequeueReusableCellWithIdentifier:@"GemDetailsCustomCellContact"];
            if (NULL_TO_NIL([_gemDetails objectForKey:@"contact_name"])){
                cell.lblContact.text = [_gemDetails objectForKey:@"contact_name"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }

        if (indexPath.row == 3) {
            GemDetailsCustomCellDescription *cell = (GemDetailsCustomCellDescription *)[tableView dequeueReusableCellWithIdentifier:@"GemDetailsCustomCellDescription"];
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:CommonFont_New size:14],
                                         };
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[_gemDetails objectForKey:@"gem_details"] attributes:attributes];
            cell.lbltDescription.attributedText = attributedText;
            cell.lbltDescription.systemURLStyle = YES;
            cell.lbltDescription.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
                // Open URLs
                [self attemptOpenURL:[NSURL URLWithString:string]];
            };
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        if (indexPath.row == 4) {
            GemDetailsCustomCellPreview *cell = (GemDetailsCustomCellPreview *)[tableView dequeueReusableCellWithIdentifier:@"GemDetailsCustomCellPreview"];
            if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"])){
                NSString *string = [_gemDetails objectForKey:@"gem_details"];
                NSError *error = nil;
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                           error:&error];
                NSArray *matches = [detector matchesInString:string
                                                     options:0
                                                       range:NSMakeRange(0, [string length])];
                if (matches.count > 0) {
                    NSTextCheckingResult *match = [matches firstObject];
                    [MTDURLPreview loadPreviewWithURL:[match URL] completion:^(MTDURLPreview *preview, NSError *error) {
                        [cell.indicator stopAnimating];
                        cell.lblTitle.text = preview.title;
                        cell.lblDescription.text = preview.content;
                        cell.lblDomain.text = preview.domain;
                        [cell.imgPreview sd_setImageWithURL:preview.imageURL
                                      placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             }];
                        
                    }];
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        

       
    }else{
        static NSString *CellIdentifier = @"reuseIdentifier";
        GemDetailsCustomTableViewCell *cell = (GemDetailsCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [self resetCellVariables:cell];
        [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
        if (indexPath.row < arrGemMedias.count)
            [self showMediaDetailsWithCell:cell andDetails:arrGemMedias[indexPath.row] index:indexPath.row];
        return cell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        float imageHeight = 250;
        float padding = 10;
        
        if (indexPath.row < arrGemMedias.count) {
            NSDictionary *details = arrGemMedias[indexPath.row];
            if ([heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]]) {
                imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]] floatValue];
            }else{
                float width = [[details objectForKey:@"image_width"] floatValue];
                float height = [[details objectForKey:@"image_height"] floatValue];
                float ratio = width / height;
                imageHeight = (self.view.frame.size.width - padding) / ratio;
                [heightsCache setObject:[NSNumber numberWithInteger:imageHeight] forKey:[NSNumber numberWithInteger:indexPath.row]];
            }
            
        }
        
        return imageHeight + 5;
    }
    else{
        
        if (indexPath.row == 1) {
            if (NULL_TO_NIL([_gemDetails objectForKey:@"location_name"]))
                return UITableViewAutomaticDimension;
            else
                return 0;
        }
        else if (indexPath.row == 2) {
            if (NULL_TO_NIL([_gemDetails objectForKey:@"contact_name"]))
                return UITableViewAutomaticDimension;
            else
                return 0;
        }
        else if (indexPath.row == 3) {
            if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"]))
                return UITableViewAutomaticDimension;
            else
                return 0;
        }
        else if (indexPath.row == 4) {
            return 85;
        }
        
    }
    
    return UITableViewAutomaticDimension;
    
}
- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1;
    
    
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"])){
        
        float widthPadding = 20;
        if (_canDelete || _isFromGEM) widthPadding = 60;
        float heightPadding = 25                                                    ;
        
        NSString *title = [_gemDetails objectForKey:@"gem_title"];
        
        NSString *message = [_gemDetails objectForKey:@"gem_details"];
        
        CGSize constraint = CGSizeMake(self.view.bounds.size.width - widthPadding, CGFLOAT_MAX);
        float height = 0;
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize boundingBox = [title boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFontBold size:14]}
                                               context:context].size;
        height += boundingBox.height;
        
        height += 15; // Date height
        
        widthPadding = 20;
        constraint = CGSizeMake(self.view.bounds.size.width - widthPadding, CGFLOAT_MAX);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        boundingBox = [message boundingRectWithSize:constraint
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],
                                                    NSParagraphStyleAttributeName:paragraphStyle}
                                          context:context].size;
        height = height + boundingBox.height;
        
        if (NULL_TO_NIL([_gemDetails objectForKey:@"location_name"])){
            height += 20;
        }
        if (NULL_TO_NIL([_gemDetails objectForKey:@"contact_name"])){
            height += 20;
        }
        
        BOOL checkIsURLAvailable = [Utility isStringContainsURLInString:[_gemDetails objectForKey:@"gem_details"]];
        float previewHeight = (checkIsURLAvailable) ? 90 : 0;
        height += previewHeight;
        return height += heightPadding;
        
    }
    
    return kHeightForHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return kHeightForFooter;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
    
    UIFont *font = [UIFont fontWithName:CommonFont size:12];
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor getBackgroundOffWhiteColor];

    /*! Title !*/
    
    UILabel *_lblTitle = [UILabel new];
    _lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:_lblTitle];
    _lblTitle.numberOfLines = 0;
    _lblTitle.textColor = [UIColor blackColor];;
    _lblTitle.font = [UIFont fontWithName:CommonFontBold size:14];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:_lblTitle
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:10.0]];
    
    if (_canDelete || _isFromGEM) {
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_lblTitle]-50-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
    }else{
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_lblTitle]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
    }
    
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_title"]))
        _lblTitle.text = [_gemDetails objectForKey:@"gem_title"];
    
      /*! Delete Button !*/
    
    
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [vwHeader addSubview:btnDelete];
    btnDelete.translatesAutoresizingMaskIntoConstraints = NO;
    [btnDelete addTarget:self action:@selector(deleteTheGem)
      forControlEvents:UIControlEventTouchUpInside];
    btnDelete.hidden = true;
    [btnDelete setImage:[UIImage imageNamed:@"Delete_Icon.png"] forState:UIControlStateNormal];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnDelete
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnDelete
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    
    [btnDelete addConstraint:[NSLayoutConstraint constraintWithItem:btnDelete
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:40]];
    
    [btnDelete addConstraint:[NSLayoutConstraint constraintWithItem:btnDelete
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:40]];
    
    if (_canDelete) {
        btnDelete.hidden = false;
    }
    
     /*! Edit , if From GEM Listings !*/
    
    UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [vwHeader addSubview:btnEdit];
    btnEdit.translatesAutoresizingMaskIntoConstraints = NO;
    [btnEdit addTarget:self action:@selector(editAGEM)
        forControlEvents:UIControlEventTouchUpInside];
    btnEdit.hidden = true;
    [btnEdit setImage:[UIImage imageNamed:@"Edit_Button.png"] forState:UIControlStateNormal];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnEdit
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnEdit
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    
    [btnEdit addConstraint:[NSLayoutConstraint constraintWithItem:btnEdit
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:35]];
    
    [btnEdit addConstraint:[NSLayoutConstraint constraintWithItem:btnEdit
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:35]];
    
    if (_isFromGEM) {
        btnEdit.hidden = false;
    }
    
    /*! User Other Details !*/
    
    UILabel *lblDate = [UILabel new];
    lblDate.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblDate];
    lblDate.numberOfLines = 1;
    lblDate.font = font;
    lblDate.textColor = [UIColor colorWithRed:127.f/255.f green:127.f/255.f blue:127.f/255.f alpha:1];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblDate
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_lblTitle
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:5.0]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblDate]-50-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblDate)]];
    
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_datetime"]))
        lblDate.text = [Utility getDaysBetweenTwoDatesWith:[[_gemDetails objectForKey:@"gem_datetime"] doubleValue]];
    
    float bottomGape = 5;
    
    if (NULL_TO_NIL([_gemDetails objectForKey:@"location_name"])) {
        
        UIView *vwLocInfo = [UIView new];
        [vwHeader addSubview:vwLocInfo];
        vwLocInfo.backgroundColor = [UIColor clearColor];
        vwLocInfo.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[vwLocInfo]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwLocInfo)]];
        [vwLocInfo addConstraint:[NSLayoutConstraint constraintWithItem:vwLocInfo
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:15.0]];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:vwLocInfo
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:lblDate
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:bottomGape]];
        
        UIImageView *imgLoc = [UIImageView new];
        imgLoc.translatesAutoresizingMaskIntoConstraints = NO;
        imgLoc.backgroundColor = [UIColor clearColor];
        [vwLocInfo addSubview:imgLoc];
        imgLoc.image = [UIImage imageNamed:@"Loc_Small.png"];
        [imgLoc addConstraint:[NSLayoutConstraint constraintWithItem:imgLoc
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:10.0]];
        [imgLoc addConstraint:[NSLayoutConstraint constraintWithItem:imgLoc
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:10.0]];
        [vwLocInfo addConstraint:[NSLayoutConstraint constraintWithItem:imgLoc
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:vwLocInfo
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        [vwLocInfo addConstraint:[NSLayoutConstraint constraintWithItem:imgLoc
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:vwLocInfo
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        UILabel *lblLocDetails = [UILabel new];
        lblLocDetails.translatesAutoresizingMaskIntoConstraints = NO;
        [vwLocInfo addSubview:lblLocDetails];
        lblLocDetails.numberOfLines = 1;
        lblLocDetails.font = [UIFont fontWithName:CommonFontBold size:12];
        lblLocDetails.textColor = [UIColor blackColor];
        [vwLocInfo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[lblLocDetails]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblLocDetails)]];
        [vwLocInfo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[lblLocDetails]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblLocDetails)]];
        
        if (NULL_TO_NIL([_gemDetails objectForKey:@"location_name"]))
            lblLocDetails.text = [_gemDetails objectForKey:@"location_name"];
        
        bottomGape += 20;
    }
    
    if (NULL_TO_NIL([_gemDetails objectForKey:@"contact_name"])) {
        
        UIView *vwLocInfo = [UIView new];
        [vwHeader addSubview:vwLocInfo];
        vwLocInfo.backgroundColor = [UIColor clearColor];
        vwLocInfo.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[vwLocInfo]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwLocInfo)]];
        [vwLocInfo addConstraint:[NSLayoutConstraint constraintWithItem:vwLocInfo
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:15.0]];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:vwLocInfo
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:lblDate
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:bottomGape]];
        
        UIImageView *imgLoc = [UIImageView new];
        imgLoc.translatesAutoresizingMaskIntoConstraints = NO;
        imgLoc.backgroundColor = [UIColor clearColor];
        [vwLocInfo addSubview:imgLoc];
        imgLoc.image = [UIImage imageNamed:@"contact_icon.png"];
        [imgLoc addConstraint:[NSLayoutConstraint constraintWithItem:imgLoc
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:10.0]];
        [imgLoc addConstraint:[NSLayoutConstraint constraintWithItem:imgLoc
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:10.0]];
        [vwLocInfo addConstraint:[NSLayoutConstraint constraintWithItem:imgLoc
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:vwLocInfo
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        [vwLocInfo addConstraint:[NSLayoutConstraint constraintWithItem:imgLoc
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:vwLocInfo
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        UILabel *lblLocDetails = [UILabel new];
        lblLocDetails.translatesAutoresizingMaskIntoConstraints = NO;
        [vwLocInfo addSubview:lblLocDetails];
        lblLocDetails.numberOfLines = 1;
        lblLocDetails.font = font;
        lblLocDetails.font = [UIFont fontWithName:CommonFont size:12];
        lblLocDetails.textColor = [UIColor blackColor];
        [vwLocInfo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[lblLocDetails]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblLocDetails)]];
        [vwLocInfo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lblLocDetails]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblLocDetails)]];
        
        if (NULL_TO_NIL([_gemDetails objectForKey:@"contact_name"]))
            lblLocDetails.text = [_gemDetails objectForKey:@"contact_name"];
        
        bottomGape += 20;
        
    }
    
    
    /*! Gem Details !*/
    
    KILabel *lblDetails = [KILabel new];
    lblDetails.translatesAutoresizingMaskIntoConstraints = NO;
    lblDetails.backgroundColor = [UIColor clearColor];
    [vwHeader addSubview:lblDetails];
    lblDetails.numberOfLines = 0;
    lblDetails.textColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0];;
    lblDetails.font = [UIFont fontWithName:CommonFont size:14];;
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblDetails
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:lblDate
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:bottomGape]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblDetails]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblDetails)]];
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"])){
        
        font = [UIFont fontWithName:CommonFont size:14];
        NSDictionary *attributes = @{NSFontAttributeName:font,
                                     };
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[_gemDetails objectForKey:@"gem_details"] attributes:attributes];
        lblDetails.attributedText = attributedText;
        lblDetails.systemURLStyle = YES;
        lblDetails.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
            // Open URLs
            [self attemptOpenURL:[NSURL URLWithString:string]];
        };

        
    }
    /*
    
    /************** URL Preview SetUp *******************/
    
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"])){
        NSString *string = [_gemDetails objectForKey:@"gem_details"];
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:&error];
        NSArray *matches = [detector matchesInString:string
                                             options:0
                                               range:NSMakeRange(0, [string length])];
        if (matches.count > 0) {
            
            UIView *vwLocPreview = [UIView new];
            [vwHeader addSubview:vwLocPreview];
            vwLocPreview.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
            vwLocPreview.translatesAutoresizingMaskIntoConstraints = NO;
            [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[vwLocPreview]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwLocPreview)]];
            [vwLocPreview addConstraint:[NSLayoutConstraint constraintWithItem:vwLocPreview
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:80.0]];
            
            [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:vwLocPreview
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:lblDetails
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
            
            UITapGestureRecognizer *singleFingerTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleSingleTap:)];
            [vwLocPreview addGestureRecognizer:singleFingerTap];
            
           
            
            //Image
            
            UIImageView *imgPreview = [UIImageView new];
            imgPreview.translatesAutoresizingMaskIntoConstraints = NO;
            imgPreview.backgroundColor = [UIColor clearColor];
            [vwLocPreview addSubview:imgPreview];
            [vwLocPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imgPreview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgPreview)]];
            
            [imgPreview addConstraint:[NSLayoutConstraint constraintWithItem:imgPreview
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0
                                                                constant:100.0]];
            
            [vwLocPreview addConstraint:[NSLayoutConstraint constraintWithItem:imgPreview
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:vwLocPreview
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            
            // Title
            
            UILabel *lblpreviewTitle = [UILabel new];
            lblpreviewTitle.translatesAutoresizingMaskIntoConstraints = NO;
            [vwLocPreview addSubview:lblpreviewTitle];
            lblpreviewTitle.numberOfLines = 1;
            lblpreviewTitle.font = [UIFont fontWithName:CommonFont_New size:15];
            lblpreviewTitle.textColor = [UIColor colorWithRed:0.39 green:0.44 blue:0.46 alpha:1.0];
            [vwLocPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-105-[lblpreviewTitle]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblpreviewTitle)]];
            [vwLocPreview addConstraint:[NSLayoutConstraint constraintWithItem:lblpreviewTitle
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:vwLocPreview
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:5.0]];
            
            // Content
            
            UILabel *lblContent = [UILabel new];
            lblContent.translatesAutoresizingMaskIntoConstraints = NO;
            [vwLocPreview addSubview:lblContent];
            lblContent.numberOfLines = 2;
            lblContent.font = [UIFont fontWithName:CommonFont_New size:14];
            lblContent.textColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1.0];
            [vwLocPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-105-[lblContent]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblContent)]];
            [vwLocPreview addConstraint:[NSLayoutConstraint constraintWithItem:lblContent
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:lblpreviewTitle
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0.0]];
            
            // Content
            
            UILabel *lbDomain = [UILabel new];
            lbDomain.translatesAutoresizingMaskIntoConstraints = NO;
            [vwLocPreview addSubview:lbDomain];
            lbDomain.numberOfLines = 1;
            lbDomain.font = [UIFont fontWithName:CommonFont_New size:12];
            lbDomain.textColor = [UIColor colorWithRed:0.39 green:0.44 blue:0.46 alpha:1.0];
            [vwLocPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-105-[lbDomain]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lbDomain)]];
            [vwLocPreview addConstraint:[NSLayoutConstraint constraintWithItem:lbDomain
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:lblContent
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0.0]];
            
            [vwLocPreview addConstraint:[NSLayoutConstraint constraintWithItem:lbDomain
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:vwLocPreview
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:-5.0]];

            //Indicator
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            // If you need custom color, use color property
            // activityIndicator.color = yourDesirableColor;
            [vwLocPreview addSubview:activityIndicator];
            activityIndicator.hidesWhenStopped = true;
            activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
            activityIndicator.color = [UIColor blackColor];
            [activityIndicator startAnimating];
            [vwLocPreview addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:vwLocPreview
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0]];
            [vwLocPreview addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:vwLocPreview
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0]];

            
            
            
            NSTextCheckingResult *match = [matches firstObject];
            [MTDURLPreview loadPreviewWithURL:[match URL] completion:^(MTDURLPreview *preview, NSError *error) {
                [activityIndicator stopAnimating];
                lblpreviewTitle.text = preview.title;
                lblContent.text = preview.content;
                lbDomain.text = preview.domain;
                [imgPreview sd_setImageWithURL:preview.imageURL
                                   placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          }];
                
            }];
        }
        

    }
    
    
    
    return vwHeader;
}

-(void)showMediaDetailsWithCell:(GemDetailsCustomTableViewCell*)cell andDetails:(NSDictionary*)mediaInfo index:(NSInteger)_index{
    
    NSString *mediaType ;
    if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
        mediaType = [mediaInfo objectForKey:@"media_type"];
    }
    
    if (mediaType) {
        
        if ([mediaType isEqualToString:@"image"]) {
            
            // Type Image
            //[cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
            [cell.activityIndicator startAnimating];
            [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]]
                                placeholderImage:[UIImage imageNamed:@""]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             [cell.activityIndicator stopAnimating];
                                       }];
        }
        
        else if ([mediaType isEqualToString:@"audio"]) {
            
            // Type Audio
            
            [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
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
                   // [self setUpAutoPlayWithURL:[NSURL URLWithString:videoURL] withCell:cell];
                }
            }
            
            if (NULL_TO_NIL([mediaInfo objectForKey:@"video_thumb"])) {
                NSString *videoThumb = [mediaInfo objectForKey:@"video_thumb"];
                if (videoThumb.length) {
                    [cell.activityIndicator startAnimating];
                    [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:videoThumb]
                                        placeholderImage:[UIImage imageNamed:@""]
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                   [cell.activityIndicator stopAnimating];
                                               }];
                }
                
            }
            
        }
        
        float imageHeight = 250;
        if ([heightsCache objectForKey:[NSNumber numberWithInt:_index]]) {
            imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:_index]] integerValue];
            cell.constraintForHeight.constant = imageHeight;
        }
        
    }
    
    
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isScrolling = NO;
   // [tableView reloadData];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView
{
    [videoPlayer pause];
    isPlaying = false;
    isScrolling = YES;
  //  [tableView reloadData];
    playingIndex = -1;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 4) {
        [self openPreviewURL];
       
    }else if (indexPath.section == 1){
        
        [tableView reloadData];
        [videoPlayer pause];
        videoPlayer = nil;
        
        NSMutableArray *images = [NSMutableArray new];
        NSString *mediaType ;;
        if (indexPath.row < arrGemMedias.count) {
            NSDictionary *mediaInfo = arrGemMedias[indexPath.row];
            if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
                mediaType = [mediaInfo objectForKey:@"media_type"];
            }
            if (mediaType) {
                if ([mediaType isEqualToString:@"image"]) {
                    NSURL *url =  [NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]];
                    [images addObject:url];
                    for (NSDictionary *details in arrGemMedias) {
                        if (NULL_TO_NIL([details objectForKey:@"media_type"])) {
                            mediaType = [details objectForKey:@"media_type"];
                        }
                        if (mediaType) {
                            if ([mediaType isEqualToString:@"image"]) {
                                NSURL *url =  [NSURL URLWithString:[details objectForKey:@"gem_media"]];
                                if (![images containsObject:url]) {
                                    [images addObject:url];
                                }
                                
                            }
                            
                        }
                    }
                    if (images.count) {
                        [self presentGalleryWithImages:images];
                    }
                }
                else if ([mediaType isEqualToString:@"video"]){
                    if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                        NSString *videoURL = [mediaInfo objectForKey:@"gem_media"];
                        if (videoURL.length){
                            NSError* error;
                            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                            [[AVAudioSession sharedInstance] setActive:NO error:&error];
                            NSURL *movieURL = [NSURL URLWithString:videoURL];
                            AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                            [playerViewController.player play];
                            playerViewController.player = [AVPlayer playerWithURL:movieURL];
                            [self presentViewController:playerViewController animated:YES completion:nil];
                            [[NSNotificationCenter defaultCenter] addObserver:self
                                                                     selector:@selector(videoDidFinish:)
                                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                                       object:[playerViewController.player currentItem]];
                            
                        }
                    }
                }
                
            }
        }
    }
    
    
}

- (void)videoDidFinish:(id)notification
{
    [self dismissViewControllerAnimated:YES completion:nil];
   [[NSNotificationCenter defaultCenter] removeObserver:self];

    
    //fade out / remove subview
}

-(void)resetCellVariables:(GemDetailsCustomTableViewCell*)cell{
    
    [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
    [cell.activityIndicator stopAnimating];
    [[cell btnVideoPlay]setHidden:YES];
    [[cell btnAudioPlay]setHidden:YES];
    [videoPlayer pause];
    [cell.videoActivity stopAnimating];
    cell.videoPlayer = nil;
    [cell.videoPlayer pause];
    [cell.avLayer removeFromSuperlayer];
    cell.videoItem = nil;
    cell.imgGemMedia.hidden = false;
    [videoIndicator stopAnimating];
    videoIndicator = nil;
    
}

#pragma mark - Player Methods and  Delegates

-(void)setUpAutoPlayWithURL:(NSURL*)videoURL withCell:(GemDetailsCustomTableViewCell*)cell{
    
    if (!isScrolling && !isPlaying) {
        [cell.videoActivity startAnimating];
        isPlaying = true;
        cell.imgGemMedia.hidden = true;
        [cell.btnVideoPlay setHidden:true];
        NSURL *url = videoURL;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                AVAsset *avAsset = [AVAsset assetWithURL:url];
                playerItem = [[ACRObservingPlayerItem alloc] initWithAsset:avAsset];
                cell.videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
                cell.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                videoPlayer =  cell.videoPlayer;
                cell.avLayer = [AVPlayerLayer playerLayerWithPlayer:cell.videoPlayer];
                cell.avLayer.frame = CGRectMake(5, 5, cell.imgGemMedia.frame.size.width, 245);
                cell.avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                [cell.contentView.layer addSublayer:cell.avLayer];
                [cell.contentView bringSubviewToFront:cell.videoActivity];
                videoIndicator = cell.videoActivity;
                playerItem.delegate = self;
                
            });
        });
    }
}

- (void)bufferEmpty{
    [videoIndicator startAnimating];
}
- (void)playerResumeAfterBuffer{
    [videoPlayer play];
    [videoIndicator stopAnimating];
}
- (void)playerItemReachedEnd{
    
    [videoIndicator stopAnimating];
    [tableView reloadData];
}
- (void)playerItemStalled{
    
}
- (void)playerItemReadyToPlay{
    [videoPlayer play];
    [videoIndicator stopAnimating];
}
- (void)playerItemPlayFailed{
    [videoIndicator stopAnimating];
}
- (void)playerItemRemovedObservation{
    
}

#pragma mark - Custom Cell Delegates

-(void)resetPlayerVaiablesForIndex:(NSInteger)tag{
    
    [tableView reloadData];
    [videoPlayer pause];
    videoPlayer = nil;
    
    if (tag < arrGemMedias.count){
        
        NSDictionary * mediaInfo = arrGemMedias[tag];
        NSString *mediaType ;
        if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
            mediaType = [mediaInfo objectForKey:@"media_type"];
        }
        
        if (mediaType) {
            
            if ([mediaType isEqualToString:@"image"]) {
                
            }
            
            else if ([mediaType isEqualToString:@"audio"]) {
                
                NSString *audioURL = [mediaInfo objectForKey:@"gem_media"];
                if (audioURL.length){
                    NSURL *movieURL = [NSURL URLWithString:audioURL];
                    [self showAudioPlayerWithURL:movieURL];
                }
            }
            
            else if ([mediaType isEqualToString:@"video"]) {
                // Type Video
                if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                    NSString *videoURL = [mediaInfo objectForKey:@"gem_media"];
                    if (videoURL.length){
                        NSError* error;
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                        [[AVAudioSession sharedInstance] setActive:NO error:&error];
                        NSURL *movieURL = [NSURL URLWithString:videoURL];
                        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                        playerViewController.player = [AVPlayer playerWithURL:movieURL];
                         [playerViewController.player play];
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(videoDidFinish:)
                                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                                   object:[playerViewController.player currentItem]];
                        [self presentViewController:playerViewController animated:YES completion:nil];
                        
                    }
                }
                
            }
            
        }
    }

}

-(void)showAudioPlayerWithURL:(NSURL*)url{
    
    if (!vwAudioPlayer) {
        vwAudioPlayer = [[[NSBundle mainBundle] loadNibNamed:@"CustomAudioPlayerView" owner:self options:nil] objectAtIndex:0];
        vwAudioPlayer.delegate = self;
    }
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIView *vwPopUP = vwAudioPlayer;
    [app.window.rootViewController.view addSubview:vwPopUP];
    vwPopUP.translatesAutoresizingMaskIntoConstraints = NO;
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    
    vwPopUP.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwPopUP.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [vwAudioPlayer setupAVPlayerForURL:url];
    }];
    
}

-(void)closeAudioPlayerView{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwAudioPlayer.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [vwAudioPlayer removeFromSuperview];
        vwAudioPlayer = nil;
        NSError* error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:NO error:&error];
    }];
    
    
    
}

#pragma mark - Photo Browser & Deleagtes

- (void)presentGalleryWithImages:(NSArray*)images
{
    [videoPlayer pause];
    videoPlayer = nil;
    
    if (!photoBrowser) {
        photoBrowser = [[[NSBundle mainBundle] loadNibNamed:@"PhotoBrowser" owner:self options:nil] objectAtIndex:0];
        photoBrowser.delegate = self;
    }
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIView *vwPopUP = photoBrowser;
    [app.window.rootViewController.view addSubview:vwPopUP];
    vwPopUP.translatesAutoresizingMaskIntoConstraints = NO;
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    
    vwPopUP.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwPopUP.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [photoBrowser setUpWithImages:images];
    }];
    
}

-(void)closePhotoBrowserView{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        photoBrowser.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [photoBrowser removeFromSuperview];
        photoBrowser = nil;
    }];
}


#pragma mark - Media share/ Like / Comment Methods

-(IBAction)likeMediaClicked{
    
    //Favourite / Like Clicked
    
    if ([self.delegate respondsToSelector:@selector(likeAppliedFromMediaPage:)]) {
        [self.delegate likeAppliedFromMediaPage:_clickedIndex];
        if (![[_gemDetails objectForKey:@"like_status"] boolValue]){
             imgLike.image = [UIImage imageNamed:@"Like_Active.png"];
            [_gemDetails setValue:[NSNumber numberWithBool:1] forKey:@"like_status"];
        }else{
              imgLike.image = [UIImage imageNamed:@"Like_Buton.png"];
            [_gemDetails setValue:[NSNumber numberWithBool:0] forKey:@"like_status"];
        }
        
    }
    
}

-(IBAction)shareButtonClicked{
    
    if ([self.delegate respondsToSelector:@selector(shareAppliedFromMediaPage:)]) {
        [self.delegate shareAppliedFromMediaPage:_clickedIndex];
    }
    
}

-(IBAction)commentButtonClicked{
    
    if ([self.delegate respondsToSelector:@selector(commentAppliedFromMediaPage:)]) {
        [self.delegate commentAppliedFromMediaPage:_clickedIndex];
    }

}

-(IBAction)deleteTheGem{
    
    if ([self.delegate respondsToSelector:@selector(deleteAppliedFromMediaPage:)]) {
        [self.delegate deleteAppliedFromMediaPage:_clickedIndex];
    }
    
}

-(IBAction)editAGEM{
    
    /*! Favourite Button Action!*/
    
    NSString *gemID;
    NSString *gemType;
        
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_id"]))
        gemID = [_gemDetails objectForKey:@"gem_id"];
        
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_type"]))
        gemType = [_gemDetails objectForKey:@"gem_type"];
        
    CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
    detailPage.actionType = eActionTypeGoalsAndDreams;
     if ([[_gemDetails objectForKey:@"gem_type"] isEqualToString:@"action"]) detailPage.actionType = eActionTypeActions;
    if (_isFromGEM) detailPage.delegate = self;
    if ([gemType isEqualToString:@"event"]) detailPage.actionType = eActionTypeEvent;
    detailPage.strTitle = [[NSString stringWithFormat:@"EDIT AS %@",[_gemDetails objectForKey:@"gem_type"]] uppercaseString] ;
    if ([[_gemDetails objectForKey:@"gem_type"] isEqualToString:@"community"]) {
        detailPage.strTitle = @"SAVE GEM";
    }
    [[self navigationController]pushViewController:detailPage animated:YES];
    [detailPage getMediaDetailsForGemsToBeEditedWithGEMID:gemID GEMType:gemType];
    
}


-(void)newActionCreatedWithActionTitle:(NSString*)actionTitle actionID:(NSInteger)actionID;{
    
    // If the detail page comes from Saved gems , after edit , the page should be reloaded.
    
    [self getUpdatedGEMDetails];
    
}

-(void)goalsAndDreamsCreatedWithGoalTitle:(NSString*)goalTitle goalID:(NSInteger)goalID{

    [self getUpdatedGEMDetails];
}

-(void)getUpdatedGEMDetails{
    
    NSString *gemID;
    NSString *gemType;
    
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_id"]))
        gemID = [_gemDetails objectForKey:@"gem_id"];
    
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_type"]))
        gemType = [_gemDetails objectForKey:@"gem_type"];
    
    [self showLoadingScreen];
    [APIMapper getAnyGemDetailsWithGEMID:[_gemDetails objectForKey:@"gem_id"] gemType:gemType userID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideLoadingScreen];
        [self refreshDetailPageWith:responseObject];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self hideLoadingScreen];
    }];

    
}

-(void)refreshDetailPageWith:(NSMutableDictionary*)details{
    
    _gemDetails = details;
    playingIndex = -1;
    arrGemMedias = [NSArray new];
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_media"]))
        arrGemMedias = [_gemDetails objectForKey:@"gem_media"];
    [heightsCache removeAllObjects];
    [tableView reloadData];
    if ([self.delegate respondsToSelector:@selector(refreshParentListings)]) {
        [self.delegate refreshParentListings];
    }
   

    
}



-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (void)openPreviewURL
{
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"])){
        NSString *string = [_gemDetails objectForKey:@"gem_details"];
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                       error:&error];
            NSArray *matches = [detector matchesInString:string
                                                 options:0
                                                   range:NSMakeRange(0, [string length])];
            if (matches.count > 0) {
                NSTextCheckingResult *match = [matches firstObject];
                [[UIApplication sharedApplication] openURL:[match URL]];
            }
        
    }

}
-(IBAction)goBack:(id)sender{
    
    if (self.navigationController.viewControllers.count == 1) {
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.navGeneral willMoveToParentViewController:nil];
        [app.navGeneral.view removeFromSuperview];
        [app.navGeneral removeFromParentViewController];
        app.navGeneral = nil;
        [app showLauchPage];
    }else{
        [[self navigationController] popViewControllerAnimated:YES];
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

- (void)dealloc {
    playerItem.delegate = nil;
    // or
    playerItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
