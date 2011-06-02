//
//  FlickrSearchOperation.m
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import "FlickrSearchOperation.h"


@implementation FlickrSearchOperation

@synthesize searchText;

- (void)dealloc {
    self.searchText = nil;
    [super dealloc];
}

@end
