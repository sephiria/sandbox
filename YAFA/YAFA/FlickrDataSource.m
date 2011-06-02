//
//  FlickrDataSource.m
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import "FlickrDataSource.h"

#import "FlickrSearchOperation.h"
#import "NSString+URLEncoding.h"

#warning you should probably be using your own keys
#define API_KEY     @"d10bba01b8d9c7caa70b38f9ce59f01a"
#define API_SECRET  @"692eb747a8ea054d"

@implementation FlickrDataSource

@synthesize delegate;

+ (FlickrDataSource *)dataSourceWithDelegate:(id<FlickrDataSourceDelegate>)theDelegate {
    return [[[FlickrDataSource alloc] initWithDelegate:theDelegate] autorelease];
}

- (id)initWithDelegate:(id<FlickrDataSourceDelegate>)theDelegate {
    self = [super init];
    if (self) {
        queue = [[NSOperationQueue alloc] init];
        self.delegate = theDelegate;
    }
    return self;
}

- (void)dealloc {
    [queue release];
    [super dealloc];
}

- (void)search:(NSString *)searchText maxResults:(NSUInteger)maxResults {
    static NSString *urlFormat = @"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=%d&format=json&nojsoncallback=1";
    
    NSString *urlString = [NSString stringWithFormat:urlFormat, API_KEY, [searchText urlEncodeUsingEncoding:NSUTF8StringEncoding], maxResults];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"url: %@", urlString);
    FlickrSearchOperation *search = [[FlickrSearchOperation alloc] initWithUrl:url delegate:self];
    search.searchText = searchText;
    [queue addOperation:search];
    
    [search release];
}

- (void)cancelOperations {
    // cancel non-running operations
    [queue cancelAllOperations];
}

#pragma mark - FlickrOperationDelegate

- (void)flickrOperation:(FlickrOperation *)operation didCompleteWithResults:(id)results {
    if ([operation isKindOfClass:[FlickrSearchOperation class]]) {
        [self.delegate didCompleteSearch:((FlickrSearchOperation *)operation).searchText 
                             withResults:results];
    }
}

- (void)flickrOperation:(FlickrOperation *)operation didFailWithError:(NSError *)error {
    if ([operation isKindOfClass:[FlickrSearchOperation class]]) {
        [self.delegate didFailSearch:((FlickrSearchOperation *)operation).searchText 
                           withError:error];
    }
}

@end
