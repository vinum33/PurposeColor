//
//  AwarenessMediaViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 05/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "AwarenessMediaViewController.h"
#import "ActionMediaListCell.h"
#import "PhotoBrowser.h"
#import "CustomAudioPlayerView.h"
#import <AVKit/AVKit.h>

@interface AwarenessMediaViewController () <ActionInfoCellDelegate,CustomAudioPlayerDelegate,PhotoBrowserDelegate,UIGestureRecognizerDelegate>{
    
     IBOutlet UITableView *tableView;
    PhotoBrowser *photoBrowser;
    CustomAudioPlayerView *vwAudioPlayer;
     CGPoint viewStartLocation;
}

@property (nonatomic,strong) NSIndexPath *draggingCellIndexPath;
@property (nonatomic,strong) UIView *cellSnapshotView;


@end

@implementation AwarenessMediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dragCell:)];
    [longPressGestureRecognizer setDelegate:self];
    [tableView addGestureRecognizer:longPressGestureRecognizer];
    [tableView reloadData];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
   return  _arrMedias.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MediaList";
    ActionMediaListCell *cell = (ActionMediaListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [[cell btnVideoPlay]setHidden:true];
    [[cell btnAudioPlay]setHidden:true];
    cell.delegate = self;
    [cell.indicator stopAnimating];
    [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
    
    if (indexPath.row < _arrMedias.count) {
        id object = _arrMedias[indexPath.row];
        NSString *strFile;
        if ([object isKindOfClass:[NSString class]]) {
            
            //When Create
            
            strFile = (NSString*)_arrMedias[indexPath.row];
            cell.lblTitle.text = strFile;
            cell.imgMediaThumbnail.backgroundColor = [UIColor clearColor];
            NSString *fileName = _arrMedias[indexPath.row];
            if ([[fileName pathExtension] isEqualToString:@"jpeg"]) {
                //This is Image File with .png Extension , Photos.
                NSString *filePath = [Utility getMediaSaveFolderPath];
                NSString *imagePath = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                if (imagePath.length) {
                    [cell.indicator startAnimating];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:imagePath];
                        UIImage *image = [UIImage imageWithData:data];
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            cell.imgMediaThumbnail.image = image;
                            [cell.indicator stopAnimating];
                        });
                    });
                    
                }
            }
            else if ([[fileName pathExtension] isEqualToString:@"mp4"]) {
                //This is Image File with .mp4 Extension , Video Files
                NSString *filePath = [Utility getMediaSaveFolderPath];
                NSString *imagePath = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                [[cell btnVideoPlay]setHidden:false];
                if (imagePath.length){
                    [cell.indicator startAnimating];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                        UIImage *thumbnail = [Utility getThumbNailFromVideoURL:imagePath];
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            cell.imgMediaThumbnail.image = thumbnail;
                            [cell.indicator stopAnimating];
                        });
                    });
                    cell.imgMediaThumbnail.image = [UIImage imageNamed:@"Video_Play_Button.png"];
                }
            }
            else if ([[fileName pathExtension] isEqualToString:@"aac"]){
                // Recorded Audio
                [cell.indicator startAnimating];
                [[cell btnAudioPlay]setHidden:false];
                cell.imgMediaThumbnail.image = [UIImage imageNamed:@"NoImage.png"];
                [cell.indicator stopAnimating];
            }
            
        }
        
        
    }
    
    cell.btnDelete.tag = indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(deleteSelectedMedia:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 200;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray *images = [NSMutableArray new];
    if (indexPath.row < _arrMedias.count) {
        NSString *strURL = (NSString*)_arrMedias[indexPath.row];
        if ([strURL hasPrefix:@"PurposeColorImage"]) {
            if (![images containsObject:strURL]) {
                [images addObject:strURL];
            }
        }
    }
    
    if (images.count) {
        for (id details in _arrMedias) {
            NSString *strURL = (NSString*)details;
            if ([strURL hasPrefix:@"PurposeColorImage"]) {
                if (![images containsObject:strURL]) {
                    [images addObject:strURL];
                }
            }
        }
    }
    
    if (images.count) {
        [self presentGalleryWithImages:images];
    }

    
}

#pragma mark - Media Drag and Drop Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] || [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    if ([touch.view isDescendantOfView:tableView])
        return NO;
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}



-(void)dragCell:(UILongPressGestureRecognizer *)panner
{
    if(panner.state == UIGestureRecognizerStateBegan)
    {
        viewStartLocation = [panner locationInView:tableView];
        tableView.scrollEnabled = NO;
        
        //if needed do some initial setup or init of views here
    }
    else if(panner.state == UIGestureRecognizerStateChanged)
    {
        //move your views here.
        if (! self.cellSnapshotView) {
            CGPoint loc = [panner locationInView:tableView];
            self.draggingCellIndexPath = [tableView indexPathForRowAtPoint:loc];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.draggingCellIndexPath];
            if (cell){
                
                UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0);
                [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                // create and image view that we will drag around the screen
                self.cellSnapshotView = [[UIImageView alloc] initWithImage:cellImage];
                self.cellSnapshotView.alpha = 0.8;
                self.cellSnapshotView.layer.borderColor = [UIColor redColor].CGColor;
                self.cellSnapshotView.layer.borderWidth = 1;
                self.cellSnapshotView.frame =  cell.frame;
                [tableView addSubview:self.cellSnapshotView];
                
                //[tableView reloadRowsAtIndexPaths:@[self.draggingCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            // replace the cell with a blank one until the drag is over
        }
        
        CGPoint location = [panner locationInView:tableView];
        CGPoint translation;
        translation.x = location.x - viewStartLocation.x;
        translation.y = location.y - viewStartLocation.y;
        //  NSIndexPath *current =  [tableView indexPathForRowAtPoint:location];
        //        if (current.row  < arrDataSource.count) {
        //            NSIndexPath *next =  [NSIndexPath indexPathForRow:current.row inSection:eSectionTwo];
        //            [tableView scrollToRowAtIndexPath:next atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        //        }
        
        CGPoint cvCenter = self.cellSnapshotView.center;
        cvCenter.x = location.x;
        cvCenter.y = location.y;
        self.cellSnapshotView.center = cvCenter;
        
        
        
    }
    else if(panner.state == UIGestureRecognizerStateEnded || (panner.state == UIGestureRecognizerStateCancelled) || (panner.state == UIGestureRecognizerStateFailed))
    {
        tableView.scrollEnabled = YES;
        UITableViewCell *droppedOnCell;
        CGRect largestRect = CGRectZero;
        for (UITableViewCell *cell in tableView.visibleCells) {
            CGRect intersection = CGRectIntersection(cell.frame, self.cellSnapshotView.frame);
            if (intersection.size.width * intersection.size.height >= largestRect.size.width * largestRect.size.height) {
                largestRect = intersection;
                droppedOnCell =  cell;
            }
        }
        
        NSIndexPath *droppedOnCellIndexPath = [tableView indexPathForCell:droppedOnCell];
        [UIView animateWithDuration:.2 animations:^{
            self.cellSnapshotView.center = droppedOnCell.center;
        } completion:^(BOOL finished) {
            [self.cellSnapshotView removeFromSuperview];
            self.cellSnapshotView = nil;
            NSIndexPath *savedDraggingCellIndexPath = self.draggingCellIndexPath;
            if (![self.draggingCellIndexPath isEqual:droppedOnCellIndexPath]) {
                //self.draggingCellIndexPath = [NSIndexPath indexPathForRow:-1 inSection:1];
                [_arrMedias exchangeObjectAtIndex:savedDraggingCellIndexPath.row withObjectAtIndex:droppedOnCellIndexPath.row];
                [tableView reloadRowsAtIndexPaths:@[savedDraggingCellIndexPath, droppedOnCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                // self.draggingCellIndexPath = [NSIndexPath indexPathForRow:-1 inSection:1];
                [tableView reloadRowsAtIndexPaths:@[savedDraggingCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        
    }
}


-(void)deleteSelectedMedia:(UIButton*)btnDelete{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Delete"
                                  message:@"Delete the selected media ?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             if (btnDelete.tag < _arrMedias.count) {
                                 id object = _arrMedias[btnDelete.tag];
                                 if ([object isKindOfClass:[NSString class]]) {
                                     // Created medias
                                     NSString *fileName = _arrMedias[btnDelete.tag];
                                     [self removeAMediaFileWithName:fileName];
                                 }else{
                                     //Editing medias
                                    
                                     
                                 }
                                 
                             }
                             
                             
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)removeAMediaFileWithName:(NSString *)filename
{
    NSString *dataPath = [Utility getMediaSaveFolderPath];
    NSString *filePath = [dataPath stringByAppendingPathComponent:filename];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success){
        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    [self reloadMediaLibraryTable];
}

-(void)reloadMediaLibraryTable{
    
    NSMutableArray *mediaForEdit = [NSMutableArray new];
    for (id object in _arrMedias) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [mediaForEdit addObject:object];
        }
        
    }
    [_arrMedias removeAllObjects];
    for (NSDictionary *dict in mediaForEdit) {
        [_arrMedias addObject:dict];
    }
    [self getAllMediaFiles];
    [tableView reloadData];
    
    
    
}
-(void)getAllMediaFiles{
    
    NSString *dataPath = [Utility getMediaSaveFolderPath];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:NULL];
    NSError* error = nil;
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[directoryContent count]];
    for(NSString* file in directoryContent) {
        
        if (![file isEqualToString:@".DS_Store"]) {
            NSString* filePath = [dataPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:filePath
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileCreationDate];
            
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           nil]];
            
        }
    }
    // sort using a block
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                // invert ordering
                                if (comp == NSOrderedDescending) {
                                    comp = NSOrderedAscending;
                                }
                                else if(comp == NSOrderedAscending){
                                    comp = NSOrderedDescending;
                                }
                                return comp;
                            }];
    
    for (NSInteger i = sortedFiles.count - 1; i >= 0; i --) {
        NSDictionary *dict = sortedFiles[i];
        [_arrMedias insertObject:[dict objectForKey:@"path" ] atIndex:0];
    }
    
}


-(void)removeAllContentsInMediaFolder{
    
    NSString *dataPath = [Utility getMediaSaveFolderPath];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:dataPath error:&error];
    if (success){
        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
}


#pragma mark - Photo Browser & Deleagtes

- (void)presentGalleryWithImages:(NSArray*)images
{
    [self.view endEditing:YES];
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

-(void)playSelectedMediaWithIndex:(NSInteger)tag {
    
    if (tag < _arrMedias.count){
        
        // When Create
        
        id object = _arrMedias[tag];
        if ([object isKindOfClass:[NSString class]]) {
            NSString *fileName = _arrMedias[tag];
            if ([[fileName pathExtension] isEqualToString:@"jpeg"]) {
                //This is Image File with .png Extension , Photos.
                //NSString *filePath = [Utility getMediaSaveFolderPath];
                
            }
            else if ([[fileName pathExtension] isEqualToString:@"mp4"]) {
                //This is Image File with .mp4 Extension , Video Files
                NSError* error;
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                [[AVAudioSession sharedInstance] setActive:NO error:&error];
                NSString *filePath = [Utility getMediaSaveFolderPath];
                NSString *path = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                NSURL  *videourl =[NSURL fileURLWithPath:path];
                AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                playerViewController.player = [AVPlayer playerWithURL:videourl];
                [playerViewController.player play];
                [self presentViewController:playerViewController animated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(videoDidFinish:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                           object:[playerViewController.player currentItem]];
                
            }
            else if ([[fileName pathExtension] isEqualToString:@"aac"]){
                // Recorded Audio
                
                NSString *filePath = [Utility getMediaSaveFolderPath];
                NSString *path = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                NSURL  *audioURL = [NSURL fileURLWithPath:path];
                [self showAudioPlayerWithURL:audioURL];
                
            }
            
        }
        
    }
    
}

- (void)videoDidFinish:(id)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
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

-(IBAction)goBack:(id)sender{
    if ([self.delegate respondsToSelector:@selector(closeButtonAppliedWithChangedArray:)]) {
        [self.delegate closeButtonAppliedWithChangedArray:_arrMedias];
    }
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
