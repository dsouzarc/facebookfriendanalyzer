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

@property (strong, nonatomic) NSOperationQueue *downloadProfilePhotosQueue;
@property (strong, nonatomic) NSString *directoryToSavePhotoTo;
@property (strong, nonatomic) UIImage *blankProfilePictureImage;
@property (nonatomic) CGSize photoSize;
@property (nonatomic) NSInteger finishedPhotosDownloaded;

@property (strong, nonatomic) UIImageView *inflatedPhoto;
@property (strong, nonatomic) UIView *blackScreen;

@property (strong, nonatomic) DatabaseManager *dbManager;

@property (strong, nonatomic) FacebookFriendsInfoViewController *friendInfoViewController;

@property (strong, nonatomic) PQFBouncingBalls *loadingAnimation;

@end

@implementation GetFacebookFriendsViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.dbManager = [DatabaseManager databaseManager];
        
        self.downloadProfilePhotosQueue = [[NSOperationQueue alloc] init];
        [self.downloadProfilePhotosQueue setMaxConcurrentOperationCount:5];
        self.directoryToSavePhotoTo = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.photoSize = CGSizeMake(40, 40);
        self.finishedPhotosDownloaded = 0;
        
        self.allFriends = [[NSMutableDictionary alloc] init];
        self.autoCompleteFriendsToShow = [[NSMutableArray alloc] init];
        NSMutableArray *allFriends = [self.dbManager getAllPeople];
        for(Person *person in allFriends) {
            [self.allFriends setObject:person forKey:person.name];
        }
        
        [self.autoCompleteFriendsToShow addObjectsFromArray:self.allFriends.allKeys];
        self.autoCompleteFriendsToShow = [NSMutableArray arrayWithArray:[self.autoCompleteFriendsToShow sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingAnimation = [[PQFBouncingBalls alloc] initLoaderOnView:self.view];
    self.loadingAnimation.loaderColor = [UIColor blueColor];
    self.loadingAnimation.jumpAmount = 50;
    self.loadingAnimation.separation = 40;
    self.loadingAnimation.zoomAmount = 40;
    
    if(self.allFriends.count == 0) {
        [self getFacebookFriends];
    }
    
    [self.downloadProfilePhotosQueue addObserver:self forKeyPath:@"ImageDownloaderQueue" options:0 context:NULL];
}


/****************************************
 *       GET FRIENDS METHODS
 ****************************************/

# pragma mark - Friends

- (void) getFacebookFriends
{
    [self.loadingAnimation show];
    
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
        [self.loadingAnimation hide];
        [self.dbManager addPeopleToDatabase:[self.allFriends allValues]];
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
            
            [self savePersonProfilePhoto:person];
        }
        @catch (NSException *exception) {
            NSLog(@"EXCEPTION ADDING: %@", exception.reason);
        }
    }
    self.autoCompleteFriendsToShow = [NSMutableArray arrayWithArray:[self.autoCompleteFriendsToShow sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    [self.friendsTableView reloadData];
}


/****************************************
 *       TABLEVIEW DELEGATE
 ****************************************/

# pragma mark - TableView

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSString *name = self.autoCompleteFriendsToShow[indexPath.row];
    
    NSString *imageName = [NSString stringWithFormat:@"%@_ProfilePicture.png", name];
    NSString *imagePath = [self.directoryToSavePhotoTo stringByAppendingPathComponent:imageName];
    UIImage *profilePicture = [UIImage imageWithContentsOfFile:imagePath];
    
    if(profilePicture) {
        profilePicture = [self resizeImage:profilePicture convertToSize:self.photoSize];
    }
    else {
        if(self.blankProfilePictureImage) {
            profilePicture = self.blankProfilePictureImage;
        }
        else {
            profilePicture = [UIImage imageWithContentsOfFile:@"blank_profile_picture.png"];
            profilePicture = [self resizeImage:profilePicture convertToSize:self.photoSize];
        }
    }
    
    cell.textLabel.text = name;
    cell.imageView.image = profilePicture;
    cell.imageView.layer.cornerRadius = profilePicture.size.width / 2;
    cell.imageView.layer.masksToBounds = YES;

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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = self.autoCompleteFriendsToShow[indexPath.row];
    NSString *imageName = [NSString stringWithFormat:@"%@_ProfilePicture.png", name];
    NSString *imagePath = [self.directoryToSavePhotoTo stringByAppendingPathComponent:imageName];
    UIImage *profilePicture = [UIImage imageWithContentsOfFile:imagePath];
    
    if(!profilePicture) {
        profilePicture = [UIImage imageNamed:@"blank_profile_picture.png"];
    }
    
    self.friendInfoViewController = [[FacebookFriendsInfoViewController alloc] initWithNibName:@"FacebookFriendsInfoViewController" bundle:[NSBundle mainBundle] profilePicture:profilePicture person:self.allFriends[name]];
    [self.friendInfoViewController showInView:self.view];
}


/****************************************
 *       SEARCHBAR DELEGATE
 ****************************************/

# pragma mark - SEARCHBAR

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


/****************************************
 *       BUTTON LISTENERS
 ****************************************/

# pragma mark - Buttons

- (IBAction)refreshFriends:(id)sender {
    [self.dbManager deleteAllPeople];
    
    [self.allFriends removeAllObjects];
    [self.autoCompleteFriendsToShow removeAllObjects];
    [self.friendsTableView reloadData];
    
    [self getFacebookFriends];
}

- (IBAction)backToMainViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/****************************************
 *      MISCELLANEOUS METHODS
 ****************************************/

#pragma mark - Miscellaneous

- (void) savePersonProfilePhoto:(Person*)person
{
    NSBlockOperation *downloadPhoto = [NSBlockOperation blockOperationWithBlock:^(void) {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:person.profilePicture]];
        UIImage *profilePicture = [UIImage imageWithData:imageData];
        
        self.finishedPhotosDownloaded++;
        
        if(!profilePicture) {
            NSLog(@"ERROR GETTING PERSON PROFILE PICTURE: %@\t%@", person.name, person.profilePicture);
        }
        else {
            NSString *imageName = [NSString stringWithFormat:@"%@_ProfilePicture.png", person.name];
            NSString *imagePath = [self.directoryToSavePhotoTo stringByAppendingPathComponent:imageName];
            
            imageData = UIImagePNGRepresentation(profilePicture);
            
            if(![imageData writeToFile:imagePath atomically:YES]) {
                NSLog(@"PROBLEM SAVING PERSON'S IMAGE TO FILE: %@\t%@", person.name, person.profilePicture);
            }
        }
    }];
    
    [self.downloadProfilePhotosQueue addOperation:downloadPhoto];
}

- (UIImage *)resizeImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self.downloadProfilePhotosQueue && [keyPath isEqualToString:@"ImageDownloaderQueue"]) {
        if(self.finishedPhotosDownloaded % 20 == 0 || self.finishedPhotosDownloaded == self.allFriends.count) {
            [self.friendsTableView reloadData];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end