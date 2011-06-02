//
//  FlickrOperation.m
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import "FlickrOperation.h"

#import "JSON.h"
#import "YAFAPhoto.h"

@interface FlickrOperation ()
- (void)completeOperation;
- (void)didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading;
@end

@implementation FlickrOperation

@synthesize activeDownload;
@synthesize delegate;
@synthesize connection;
@synthesize url;

- (id)initWithUrl:(NSURL *)theUrl delegate:(id<FlickrOperationDelegate>)theDelegate {
    self = [super init];
    
    if (self) {
        self.delegate = theDelegate;
        self.url = theUrl;
        executing = NO;
        finished = NO;
    }
    
    return self;
}

- (void)dealloc {
    self.activeDownload = nil;
    [self.connection cancel];
    self.connection = nil;
    self.url = nil;
    
    [super dealloc];
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

- (void)start {
    [self willChangeValueForKey:@"isExecuting"];
	executing = YES;
	[self didChangeValueForKey:@"isExecuting"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:self.url] autorelease];
    
    if (self.isCancelled) {
        [self completeOperation];
        return;
    }
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    self.activeDownload = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        [self didFailWithError:error];
    } else {
        [self connectionDidFinishLoading];
    }
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
    
    [self completeOperation];
    
    [super cancel];
}

- (void)completeOperation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)didFailWithError:(NSError *)error {
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.connection = nil;
    
    [self.delegate flickrOperation:self didFailWithError:error];
    [self completeOperation];
}

- (void)connectionDidFinishLoading {
    if (!self.isCancelled) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSString *jsonString = [[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding];
        NSDictionary *results = [jsonString JSONValue];
        NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
        NSMutableArray *yphotos = [NSMutableArray array];
        
        for (NSDictionary *photo in photos) {
            NSString *title = [photo objectForKey:@"title"];
            
            NSString *photoURLString = 
            [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_", 
             [photo objectForKey:@"farm"], [photo objectForKey:@"server"], 
             [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
            
            YAFAPhoto *yphoto = [YAFAPhoto photoWithTitle:title photoUrl:photoURLString];
            [yphotos addObject:yphoto];
        }
        [self.delegate flickrOperation:self didCompleteWithResults:yphotos];
        
        [pool release];
    }
    
    [self completeOperation];
}

@end
