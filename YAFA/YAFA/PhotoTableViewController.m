//
//  PhotoTableViewController.m
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import "PhotoTableViewController.h"

#import "FlickrDataSource.h"
#import "RootViewController.h"
#import "YAFAPhoto.h"

@implementation PhotoTableViewController

@synthesize data;
@synthesize parent;

- (void)dealloc {
    self.data = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    for (YAFAPhoto *photo in self.data) {
        [photo clearImageCache];
    }
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ([self.data count] > 0) {
        // Configure the cell...
        YAFAPhoto *photo = [self.data objectAtIndex:indexPath.row];
        cell.textLabel.text = photo.title;
        
        if (![photo isImageLoadedForSize:YAFAPhotoSizeSquare]) {
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
                dispatch_async(queue, ^{
                    [cell.imageView performSelectorOnMainThread:@selector(setImage:) withObject:[photo imageForSize:YAFAPhotoSizeSquare] waitUntilDone:NO];
                });
            }
        } else {
            cell.imageView.image = [photo imageForSize:YAFAPhotoSizeSquare];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YAFAPhoto *photo = [self.data objectAtIndex:indexPath.row];
    [self.parent pushViewForPhoto:photo];
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows {
    if ([self.data count] > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            // TODO: throttle number of requests
            dispatch_async(queue, ^{
                YAFAPhoto *photo = [self.data objectAtIndex:indexPath.row];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.imageView.image = [photo imageForSize:YAFAPhotoSizeSquare];
            });
        }
    }
}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}

@end
