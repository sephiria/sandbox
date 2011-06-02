//
//  PhotoTableViewController.h
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface PhotoTableViewController : UITableViewController <UIScrollViewDelegate> {
    dispatch_queue_t queue;
}

@property (nonatomic, retain) NSArray *data;
@property (nonatomic, assign) IBOutlet RootViewController *parent;

@end
