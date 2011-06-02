//
//  FlickrDataSource.h
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import <Foundation/Foundation.h>
#import "FlickrOperation.h"

@protocol FlickrDataSourceDelegate <NSObject>
- (void)didCompleteSearch:(NSString *)searchText withResults:(id)results;
- (void)didFailSearch:(NSString *)searchText withError:(NSError *)error;
@end

@interface FlickrDataSource : NSObject <FlickrOperationDelegate> {
     NSOperationQueue *queue;
}

@property (nonatomic, assign) id<FlickrDataSourceDelegate> delegate;

+ (FlickrDataSource *)dataSourceWithDelegate:(id<FlickrDataSourceDelegate>)theDelegate;
- (id)initWithDelegate:(id<FlickrDataSourceDelegate>)theDelegate;
- (void)search:(NSString *)searchText maxResults:(NSUInteger)maxResults;
- (void)cancelOperations;

@end
