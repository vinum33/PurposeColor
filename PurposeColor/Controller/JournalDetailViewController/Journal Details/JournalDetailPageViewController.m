//
//  JournalDetailPageViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 21/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "JournalDetailPageViewController.h"
#import "JournalImageCell.h"
#import "JournalNoImageCell.h"
#import "JournalDateInfo.h"
#import "JournalDescription.h"
#import "Constants.h"
#import "JournalGalleryViewController.h"

@interface JournalDetailPageViewController (){
    
    IBOutlet UITableView *tableView;
}

@end

@implementation JournalDetailPageViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 10;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JournalImageCell *cell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell = (JournalImageCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalImageCell"];
    
    if (indexPath.row == 0) {
        
        JournalNoImageCell * cell = (JournalNoImageCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalNoImageCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.lblTitle.text = [_journalDetails objectForKey:@"event_title"];
        return cell;
        
    }
    
   else if (indexPath.row == 1) {
        
        JournalDateInfo *cell = (JournalDateInfo *)[aTableView dequeueReusableCellWithIdentifier:@"JournalDateInfo"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 99999);
        cell.contentView.bounds = cell.bounds;
        [cell layoutIfNeeded];
        cell.lblDate.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblDate.frame);
        cell.lblContact.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblContact.frame);
        cell.lblEmotion.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblEmotion.frame);
        cell.lblGoal.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblGoal.frame);
        cell.lblDate.text = [Utility getDateStringFromSecondsWith:[[_journalDetails objectForKey:@"journal_datetime"] doubleValue] withFormat:@"d MMM,yyyy h:mm a "];
        NSMutableAttributedString *strContactInfo = [[NSMutableAttributedString alloc] init];
        BOOL isLocPresent = false;
       
        if ([_journalDetails objectForKey:@"location_name"]) {
            isLocPresent = true;
             NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Location_White.png"];
            attachment.image = icon;
            attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblLoc.font.descender), icon.size.width, icon.size.height);
            
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            [myString appendAttributedString:attachmentString];
            NSAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[_journalDetails objectForKey:@"location_name"]]];
            [myString appendAttributedString:myText];
             [strContactInfo appendAttributedString:myString];
        }
        if ([_journalDetails objectForKey:@"contact_name"]) {
            
            NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] init];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Contact_White.png"];
            attachment.image = icon;
            attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblContact.font.descender) + 5, icon.size.width, icon.size.height);
            NSAttributedString *space;
            if (isLocPresent) {
                space = [[NSMutableAttributedString alloc] initWithString:@"\n\n"];
            }else{
                space = [[NSMutableAttributedString alloc] initWithString:@"\n"];
            }
            [strContactInfo appendAttributedString:space];
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            [strContactInfo appendAttributedString:attachmentString];
            NSAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[_journalDetails objectForKey:@"contact_name"]]];
            [myString appendAttributedString:myText];
            [strContactInfo appendAttributedString:myString];
        }
       if (strContactInfo.length) {
           cell.lblLoc.attributedText = strContactInfo;
       }
       NSMutableAttributedString *myString;
        if ([_journalDetails objectForKey:@"emotion_title"]){
            
            myString = [[NSMutableAttributedString alloc] init];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"5_Star_Filled"];
            
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == 2)
                icon = [UIImage imageNamed:@"5_Star_Filled"];
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == 1)
                icon = [UIImage imageNamed:@"4_Star_Filled"];
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == 0)
                icon = [UIImage imageNamed:@"3_Star_Filled"];
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == -1)
                icon = [UIImage imageNamed:@"2_Star_Filled"];
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == -2)
                icon = [UIImage imageNamed:@"1_Star_Filled"];

            attachment.image = icon;
            attachment.bounds = CGRectMake(0, -(icon.size.height / 2) -  cell.lblEmotion.font.descender, icon.size.width, icon.size.height);
            
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *strFeel = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            NSMutableAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" Feeling %@",[_journalDetails objectForKey:@"emotion_title"]]];
            [strFeel appendAttributedString:myText];
            [myString appendAttributedString:strFeel];
            [myString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1 alpha:0.8] range:NSMakeRange(0,9)];
             cell.lblEmotion.attributedText = myString;
        }
       
            NSMutableAttributedString *driveString = [[NSMutableAttributedString alloc] init];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Strongly_Agree"];
       
       
       if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == 2)
           icon = [UIImage imageNamed:@"Strongly_Agree"];
       if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == 1)
           icon = [UIImage imageNamed:@"Agree"];
       if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == 0)
           icon = [UIImage imageNamed:@"Neutral"];
       if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == -1)
           icon = [UIImage imageNamed:@"Disagree"];
       if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == -2)
           icon = [UIImage imageNamed:@"Strongly_Disagree"];
       
            attachment.image = icon;
            attachment.bounds = CGRectMake(0, (-(20) -  cell.lblGoal.font.descender), 40,40);
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *strFeel = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            [driveString appendAttributedString:strFeel];
            cell.lblEmotion.attributedText = myString;
       
            NSMutableAttributedString *title = [NSMutableAttributedString new];
            [title appendAttributedString:driveString];
            if ([_journalDetails objectForKey:@"goal_title"]) {
               
                NSAttributedString *newAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" Reaction : %@",[_journalDetails objectForKey:@"goal_title"]]];
                [title appendAttributedString:newAttString];
                [title addAttribute:NSForegroundColorAttributeName
                              value:[UIColor colorWithWhite:1 alpha:0.8]
                              range:NSMakeRange(1, 11)];
            
            }
       cell.lblGoal.attributedText = title;
        return cell;

    }
    else if (indexPath.row == 2) {
        
        JournalImageCell *cell = (JournalImageCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalImageCell"];
        float imageHeight = 0.01;
        float width = [[_journalDetails objectForKey:@"image_width"] floatValue];
        float height = [[_journalDetails objectForKey:@"image_height"] floatValue];
        [cell.activityIndicator stopAnimating];
        if (width && height > 0) {
            float ratio = width / height;
            imageHeight = (tableView.frame.size.width) / ratio;
            [cell.activityIndicator startAnimating];
            [cell.imgJournal sd_setImageWithURL:[NSURL URLWithString:[_journalDetails objectForKey:@"display_image"]]
                               placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          
                                          [cell.activityIndicator stopAnimating];
                                          
                                      }];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.heightConstraint.constant = imageHeight;
        return cell;

    }
    
    else if (indexPath.row == 3){
        
        JournalDescription *cell = (JournalDescription *)[aTableView dequeueReusableCellWithIdentifier:@"JournalDescription"];
        if ([_journalDetails objectForKey:@"journal_desc"]) cell.lbDescription.text = [_journalDetails objectForKey:@"journal_desc"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 2) {
        [self showGallery:nil];
    }
}

-(IBAction)showGallery:(id)sender{
    
    JournalGalleryViewController *galleryVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForJournalGallery];
    galleryVC.arrMedia = [_journalDetails objectForKey:@"journal_media"];
    [self.navigationController pushViewController:galleryVC animated:YES];
}

-(IBAction)goBack:(id)sender{
    
    [[self navigationController] popViewControllerAnimated:YES];
    
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
