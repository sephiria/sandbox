//
//  RootViewController.h
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import <UIKit/UIKit.h>

#import "FlickrDataSource.h"
#import "PhotoTableViewController.h"

@class YAFAPhoto;

@interface RootViewController : UIViewController <FlickrDataSourceDelegate, UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet PhotoTableViewController *tableViewController;
@property (nonatomic, retain) FlickrDataSource *dataSource;

- (void)pushViewForPhoto:(YAFAPhoto *)photo;

@end
