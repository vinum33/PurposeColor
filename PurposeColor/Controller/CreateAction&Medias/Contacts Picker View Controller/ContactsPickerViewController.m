//
//  ContactsPickerViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 15/03/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "ContactsPickerViewController.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ContactsTableViewCell.h"
#import "Constants.h"

@interface ContactsPickerViewController () <UISearchBarDelegate>{
    
    NSMutableArray *contactList;
    NSMutableArray *arrFiltered;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnDone;
    UISearchBar *searchBar;
    BOOL isDataAvailable;
}

@end

@implementation ContactsPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpSearchBar];
    [self getUserPermission];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUpSearchBar{
    
    btnDone.hidden = true;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [searchBar setShowsCancelButton:YES];
    searchBar.delegate = self;
    
    UIView *headerView = [[UIView alloc] initWithFrame:searchBar.frame];
    [headerView addSubview:searchBar];
    tableView.tableHeaderView = headerView;
}
-(void)getUserPermission{
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            [self getAllContacts];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self getAllContacts];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }}

- (IBAction)getAllContacts {
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    [self getContactsWithAddressBook:addressBook];
    
}

// Get the contacts.
- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    
    contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSString *name;
        if (firstName) name = [NSString stringWithFormat:@"%@", firstName];
        if (lastName) name = [NSString stringWithFormat:@"%@ %@",name,lastName];
        [dOfPerson setObject:[NSString stringWithFormat:@"%@",name] forKey:@"name"];
        
        // For getting the user image.
        UIImage *contactImage;
        if(ABPersonHasImageData(ref)){
            contactImage = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(ref)];
             [dOfPerson setObject:contactImage forKey:@"contact_image"];
        }
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
        }
        //For Phone number
        NSString* mobileLabel;
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
//            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
//            {
//                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
//            }
//            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
//            {
//                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
//                break ;
//            }
            [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            break;
            
        }
        [dOfPerson setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
        [contactList addObject:dOfPerson];
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        isDataAvailable = false;
        if (contactList.count) isDataAvailable = true;
        arrFiltered = [NSMutableArray arrayWithArray:contactList];
        [tableView reloadData];
    });
    
   
        
    //NSLog(@"Contacts = %@",contactList);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) return 1;
    return arrFiltered.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsTableViewCell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.btnCheckBox.tag = indexPath.row;
    cell.imgUser.layer.cornerRadius = 25;
    cell.imgUser.layer.borderWidth = 1.f;
    cell.imgUser.layer.borderColor = [UIColor clearColor].CGColor;
    cell.imgUser.clipsToBounds = YES;
    cell.lblNameIcon.hidden = false;
    cell.imgUser.image = nil;
    [cell.btnCheckBox addTarget:self action:@selector(selectContact:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnCheckBox setImage:[UIImage imageNamed:@"CheckBox_Goals"] forState:UIControlStateNormal];
    
    if (!isDataAvailable) {
        UITableViewCell *cell =  (UITableViewCell*)[Utility getNoDataCustomCellWith:aTableView withTitle:@"No Contacts Available."];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = false;
        cell.textLabel.textColor = [UIColor grayColor];
        return cell;
    }
    
    if (indexPath.row < arrFiltered.count) {
        NSDictionary *details = arrFiltered[indexPath.row];
        if (NULL_TO_NIL([details objectForKey:@"name"])) {
            cell.lblName.text = [details objectForKey:@"name"];
            cell.lblNameIcon.text = [[[details objectForKey:@"name"] substringToIndex:1] uppercaseString];
        }
        if (NULL_TO_NIL([details objectForKey:@"Phone"])) {
            cell.lblPhoneNumber.text = [details objectForKey:@"Phone"];
        }
        if (NULL_TO_NIL([details objectForKey:@"contact_image"])) {
            cell.lblNameIcon.hidden = true;
            cell.imgUser.image = (UIImage*) [details objectForKey:@"contact_image"];
        }
        if ([[details objectForKey:@"isSelected"] boolValue]) {
            [cell.btnCheckBox setImage:[UIImage imageNamed:@"CheckBox_Goals_Active"] forState:UIControlStateNormal];
        }
        
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 80;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self selectContact:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return  0.1;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}

-(IBAction)selectContact:(id)sender{
    NSInteger index = 0;
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *_sender = (UIButton*)sender;
        index = _sender.tag;
    }else{
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        index = indexPath.row;
    }
    if (index < arrFiltered.count) {
        NSMutableDictionary *details = arrFiltered[index];
        if ([[details objectForKey:@"isSelected"] boolValue]) {
            [details setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
        }else{
             [details setObject:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
        }
        
        [tableView reloadData];
        btnDone.hidden = true;
        for (NSDictionary *dict in arrFiltered) {
            if ([[dict objectForKey:@"isSelected"] boolValue]) {
                   btnDone.hidden = false;
            }
        }
       
        
    }

}

#pragma mark - Search Methods and Delegates


- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchString{
    
    [arrFiltered removeAllObjects];
    if (searchString.length > 0) {
        if (contactList.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString *regexString  = [NSString stringWithFormat:@".*\\b%@.*", searchString];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name matches[cd] %@", regexString];
                arrFiltered = [NSMutableArray arrayWithArray:[contactList filteredArrayUsingPredicate:predicate]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    isDataAvailable = true;
                    if (arrFiltered.count <= 0)isDataAvailable = false;
                    [tableView reloadData];
                });
            });
        }
    }else{
        if (contactList.count > 0) {
            if (searchBar.text.length > 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSString *regexString  = [NSString stringWithFormat:@".*\\b%@.*", searchString];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name matches[cd] %@", regexString];
                    arrFiltered = [NSMutableArray arrayWithArray:[contactList filteredArrayUsingPredicate:predicate]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        isDataAvailable = true;
                        if (arrFiltered.count <= 0)isDataAvailable = false;
                        [tableView reloadData];
                    });
                });
            }else{
                arrFiltered = [NSMutableArray arrayWithArray:contactList];
                dispatch_async(dispatch_get_main_queue(), ^{
                    isDataAvailable = true;
                    if (arrFiltered.count <= 0)isDataAvailable = false;
                    [tableView reloadData];
                });
            }
            
        }
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar{
    
    [_searchBar resignFirstResponder];
    
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar{
    
    [searchBar resignFirstResponder];
    arrFiltered = [NSMutableArray arrayWithArray:contactList];
    if (arrFiltered.count) {
        isDataAvailable = true;
    }
    [tableView reloadData];
    searchBar.text = @"";
    
    
}

-(IBAction)done:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(pickedContactsList:)]) {
        [self.delegate pickedContactsList:arrFiltered];
    }
     [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)goBack:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
