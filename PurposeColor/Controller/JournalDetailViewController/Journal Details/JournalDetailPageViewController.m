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
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JournalImageCell *cell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell = (JournalImageCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalImageCell"];
    
    if (indexPath.row == 0) {
        
        if (![_journalDetails objectForKey:@"display_image"]) {
            
            JournalNoImageCell * cell = (JournalNoImageCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalNoImageCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.lblTitle.text = [_journalDetails objectForKey:@"event_title"];
            return cell;
            
        }else{
            
            JournalImageCell *cell = (JournalImageCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalImageCell"];
            
            float imageHeight = 0;
            float width = [[_journalDetails objectForKey:@"image_width"] floatValue];
            float height = [[_journalDetails objectForKey:@"image_height"] floatValue];
            float ratio = width / height;
            imageHeight = (tableView.frame.size.width) / ratio;
            [cell.activityIndicator startAnimating];
            [cell.imgJournal sd_setImageWithURL:[NSURL URLWithString:[_journalDetails objectForKey:@"display_image"]]
                               placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          
                                          [cell.activityIndicator stopAnimating];
                                          
                                      }];
            cell.heightConstraint.constant = imageHeight;

            
            
           
            [cell layoutIfNeeded];
            cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 99999);
            cell.contentView.bounds = cell.bounds;
            [cell layoutIfNeeded];
            cell.lblTitle.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblTitle.frame);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.lblTitle.text = [_journalDetails objectForKey:@"event_title"];
            return cell;
        }

    }
    
    if (indexPath.row == 1) {
        
        JournalDateInfo *cell = (JournalDateInfo *)[aTableView dequeueReusableCellWithIdentifier:@"JournalDateInfo"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 99999);
        cell.contentView.bounds = cell.bounds;
        [cell layoutIfNeeded];
        cell.lblDateAndConatct.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblDateAndConatct.frame);
        cell.lblOtherInfo.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblOtherInfo.frame);
        NSMutableAttributedString *myString;
        myString = [[NSMutableAttributedString alloc] initWithString:[Utility getDateStringFromSecondsWith:[[_journalDetails objectForKey:@"journal_datetime"] doubleValue] withFormat:@"d MMM,yyyy h:mm a "]];
        
        if ([_journalDetails objectForKey:@"location_name"]) {
            
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Location_White.png"];
            attachment.image = icon;
            attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblDateAndConatct.font.descender), icon.size.width, icon.size.height);
            
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            [myString appendAttributedString:attachmentString];
            NSAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ",[_journalDetails objectForKey:@"location_name"]]];
            [myString appendAttributedString:myText];
        }
        if ([_journalDetails objectForKey:@"contact_name"]) {
            
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Contact_White.png"];
            attachment.image = icon;
            attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblDateAndConatct.font.descender), icon.size.width, icon.size.height);
            
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            [myString appendAttributedString:attachmentString];
            NSAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[_journalDetails objectForKey:@"contact_name"]]];
            [myString appendAttributedString:myText];
        }
        cell.lblDateAndConatct.attributedText = myString;
        
        myString = [[NSMutableAttributedString alloc] init];
        
        if ([_journalDetails objectForKey:@"emotion_title"]){
            
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Journal_Emotion_Happy.png"];
            attachment.image = icon;
            attachment.bounds = CGRectMake(0, -(icon.size.height / 2) -  cell.lblOtherInfo.font.descender, icon.size.width, icon.size.height);
            
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *strFeel = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            NSMutableAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" Feeling %@",[_journalDetails objectForKey:@"emotion_title"]]];
            [strFeel appendAttributedString:myText];
            [myString appendAttributedString:strFeel];
            
        }
        
        if ([_journalDetails objectForKey:@"goal_title"]) {
            
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Journal_Emotion_Happy.png"];
            attachment.image = icon;
            attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblOtherInfo.font.descender), icon.size.width, icon.size.height);
            
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *strFeel = [[NSMutableAttributedString alloc] initWithString:@" | "];
            [strFeel appendAttributedString:attachmentString];
            NSMutableAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[_journalDetails objectForKey:@"goal_title"]]];
            [strFeel appendAttributedString:myText];
            [myString appendAttributedString:strFeel];
            
        }
        cell.lblOtherInfo.attributedText = myString;
        
        return cell;

    }else{
        
         JournalDescription *cell = (JournalDescription *)[aTableView dequeueReusableCellWithIdentifier:@"JournalDescription"];
        if ([_journalDetails objectForKey:@"journal_desc"]) cell.lbDescription.text = [_journalDetails objectForKey:@"journal_desc"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
        
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
  
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
