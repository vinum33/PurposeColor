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
       
        if ([_journalDetails objectForKey:@"emotion_title"]){
            
             NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] init];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Journal_Emotion_Happy.png"];
            
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == 2)
                icon = [UIImage imageNamed:@"Journal_Emotion_Very_Happy.png"];
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == 1)
                icon = [UIImage imageNamed:@"Journal_Emotion_Happy.png"];
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == 0)
                icon = [UIImage imageNamed:@"Journal_Emotion_Neutral.png"];
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == -1)
                icon = [UIImage imageNamed:@"Journal_Emotion_Sad.png"];
            if ([[_journalDetails objectForKey:@"emotion_value"] integerValue] == -2)
                icon = [UIImage imageNamed:@"Journal_Emotion_Very_Sad.png"];

            attachment.image = icon;
            attachment.bounds = CGRectMake(0, -(icon.size.height / 2) -  cell.lblEmotion.font.descender, icon.size.width, icon.size.height);
            
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *strFeel = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            NSMutableAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" Feeling %@",[_journalDetails objectForKey:@"emotion_title"]]];
            [strFeel appendAttributedString:myText];
            [myString appendAttributedString:strFeel];
            [myString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0,9)];
            cell.lblEmotion.attributedText = myString;
            
        }
        
       
            NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] init];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Journal_Emotion_Happy.png"];
            
            if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == 2)
                icon = [UIImage imageNamed:@"Journal_Emotion_Very_Happy.png"];
            if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == 1)
                icon = [UIImage imageNamed:@"Journal_Emotion_Happy.png"];
            if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == 0)
                icon = [UIImage imageNamed:@"Journal_Emotion_Neutral.png"];
            if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == -1)
                icon = [UIImage imageNamed:@"Journal_Emotion_Sad.png"];
            if ([[_journalDetails objectForKey:@"drive_value"] integerValue] == -2)
                icon = [UIImage imageNamed:@"Journal_Emotion_Very_Sad.png"];
            
            attachment.image = icon;
            attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblGoal.font.descender), icon.size.width, icon.size.height);
            
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *strFeel = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            
            if ([_journalDetails objectForKey:@"goal_title"]) {
                NSMutableAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[_journalDetails objectForKey:@"goal_title"]]];
                [strFeel appendAttributedString:myText];
            }
           
            [myString appendAttributedString:strFeel];
            cell.lblGoal.attributedText = myString;
            
       
        
        return cell;

    }
    else if (indexPath.row == 2) {
        
        JournalImageCell *cell = (JournalImageCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalImageCell"];
        float imageHeight = 1;
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
