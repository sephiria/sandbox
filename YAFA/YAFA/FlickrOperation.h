//
//  FlickrOperation.h
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import <Foundation/Foundation.h>

@protocol FlickrOperationDelegate;

@interface FlickrOperation : NSOperation {
    BOOL executing;
    BOOL finished;
}

@property (nonatomic, retain) NSData *activeDownload;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) id<FlickrOperationDelegate> delegate;
@property (nonatomic, retain) NSURL *url;

- (id)initWithUrl:(NSURL *)theUrl delegate:(id<FlickrOperationDelegate>)theDelegate;

@end

@protocol FlickrOperationDelegate <NSObject>
- (void)flickrOperation:(FlickrOperation *)operation didCompleteWithResults:(id)results;
- (void)flickrOperation:(FlickrOperation *)operation didFailWithError:(NSError *)error;
@end