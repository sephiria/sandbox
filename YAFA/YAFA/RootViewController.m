//
//  RootViewController.m
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import "RootViewController.h"

#import "WebViewController.h"
#import "YAFAPhoto.h"

@implementation RootViewController

@synthesize dataSource;
@synthesize searchBar;
@synthesize tableViewController;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dataSource = [FlickrDataSource dataSourceWithDelegate:self];
    }
    return self;
}

- (void)pushViewForPhoto:(YAFAPhoto *)photo {
    [self.searchBar resignFirstResponder];
    
    UIViewController *viewController = [[WebViewController alloc] initWithPhoto:photo];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (void)showErrorForSearch:(NSString *)searchText {
    NSString *title = [NSString stringWithFormat:@"Failed to retrieve results for '%@'", searchText];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:nil
                                                   delegate:self 
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self.dataSource cancelOperations];
    [self.dataSource search:theSearchBar.text maxResults:50];
    [searchBar resignFirstResponder];
}

#pragma mark - View lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                              style: UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil] autorelease];
    if (!self.searchBar.text) {
        self.searchBar.text = @"kittens";
        [self.dataSource search:self.searchBar.text maxResults:50];
    }
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    // TODO: tableViewController gets overwritten b/c we're initializing it from the xib
    // and this results in a bad user experience when coming back from the web view. 
    // Don't initialize the tableViewController from the xib or compress the RootViewController
    // and PhotoTableViewController into one.
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    self.dataSource = nil;
    self.searchBar = nil;
    self.tableViewController = nil;
    
    [super dealloc];
}

#pragma mark - FlickrDataSourceDelegate

- (void)didCompleteSearch:(NSString *)searchText withResults:(id)results {
    if (!results || [results count] <= 0) {
        [self performSelectorOnMainThread:@selector(showErrorForSearch:) 
                               withObject:searchText 
                            waitUntilDone:NO];
        return;
    }
    
    self.tableViewController.data = results;
    
    if ([NSThread isMainThread]) {
        [self.tableViewController.tableView reloadData];
    } else {
        [self.tableViewController.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void)didFailSearch:(NSString *)searchText withError:(NSError *)error {
    [self performSelectorOnMainThread:@selector(showErrorForSearch:) 
                           withObject:searchText 
                        waitUntilDone:NO];
}

@end
