//
//  GetFacebookFriendsViewController.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/26/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "GetFacebookFriendsViewController.h"

@interface GetFacebookFriendsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *findFriendsSearchBar;

@property (strong, nonatomic) NSMutableDictionary *allFriends;
@property (strong, nonatomic) NSMutableArray *autoCompleteFriendsToShow;

@end

@implementation GetFacebookFriendsViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.allFriends = [[NSMutableDictionary alloc] init];
        self.autoCompleteFriendsToShow = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.autoCompleteFriendsToShow removeAllObjects];
    
    for(NSString *name in self.allFriends.allKeys) {
        if([[name lowercaseString] containsString:[searchText lowercaseString]]) {
            [self.autoCompleteFriendsToShow addObject:name];
        }
    }
    
    if(searchText.length == 0) {
        [self.autoCompleteFriendsToShow removeAllObjects];
        [self.autoCompleteFriendsToShow addObjectsFromArray:self.allFriends.allKeys];
    }
    
    self.autoCompleteFriendsToShow = [NSMutableArray arrayWithArray:[self.autoCompleteFriendsToShow sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    
    [self.friendsTableView reloadData];
    
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.autoCompleteFriendsToShow removeAllObjects];
    [self.autoCompleteFriendsToShow addObjectsFromArray:self.allFriends.allKeys];
    self.autoCompleteFriendsToShow = [NSMutableArray arrayWithArray:[self.autoCompleteFriendsToShow sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    [self.friendsTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getFacebookFriends];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSString *name = self.autoCompleteFriendsToShow[indexPath.row];
    cell.textLabel.text = name;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.autoCompleteFriendsToShow.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (IBAction)backToMainViewController:(id)sender {
    //self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/****************************************
 *       FACEBOOK FRIENDS
 ****************************************/

# pragma mark - Friends

- (void) getFacebookFriends
{
    //GET LIST OF FRIENDS
    NSString *urlRequest = @"/me/taggable_friends?fields=name,picture.width(300),limit=500";
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER FRIENDS TAGGABLE \t%@", [error description]);
        }
        
        else {
            NSDictionary *formattedResults = (NSDictionary*) result;
            NSArray *people = [formattedResults objectForKey:@"data"];
            [self addPeople:people];
            
            NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
            if(pagingInformation && pagingInformation[@"next"]) {
                [self recursivelyAddPeople:pagingInformation[@"next"]];
            }
        }
    }];
}

- (void) recursivelyAddPeople:(NSString*)url
{
    NSLog(@"Still working... %ld", (long)self.allFriends.count);
    NSData *data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *formattedResults = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSArray *people = [formattedResults objectForKey:@"data"];
    [self addPeople:people];
    NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
    
    if(pagingInformation && pagingInformation[@"next"]) {
        [self recursivelyAddPeople:pagingInformation[@"next"]];
    }
    
    else {
        //[self.dbManager addPeopleToDatabase:[self.people allObjects]];
        NSLog(@"Done getting people");
    }
}

- (void) addPeople:(NSArray*)people
{
    for(NSDictionary *person in people) {
        @try {
            NSString *personID = person[@"id"];
            NSString *name = person[@"name"];
            
            NSDictionary *personData = person[@"picture"];
            personData = personData[@"data"];
            NSString *pictureURL = personData[@"url"];
            
            Person *person = [[Person alloc] initWithID:personID name:name profilePicture:pictureURL];
            if([self.allFriends objectForKey:name]) {
                NSLog(@"ALREADY CONTAINED: %@", name);
            }
            else {
                [self.allFriends setObject:person forKey:person.name];
                
                if(!self.findFriendsSearchBar.text || self.findFriendsSearchBar.text.length == 0) {
                    [self.autoCompleteFriendsToShow addObject:name];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"EXCEPTION ADDING: %@", exception.reason);
        }
    }
    self.autoCompleteFriendsToShow = [NSMutableArray arrayWithArray:[self.autoCompleteFriendsToShow sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    [self.friendsTableView reloadData];
}

@end
