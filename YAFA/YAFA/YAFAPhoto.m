//
//  YAFAPhoto.m
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import "YAFAPhoto.h"


@implementation YAFAPhoto

@synthesize photoUrl;
@synthesize title;

+ (YAFAPhoto *)photoWithTitle:(NSString *)theTitle photoUrl:(NSString *)thePhotoUrl {
    return [[[YAFAPhoto alloc] initWithTitle:theTitle photoUrl:thePhotoUrl] autorelease];
}

- (id)initWithTitle:(NSString *)theTitle photoUrl:(NSString *)thePhotoUrl {
    self = [super init];
    
    if (self) {
        self.title = theTitle;
        self.photoUrl = thePhotoUrl;
        fetchedImages = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)dealloc {
    [fetchedImages release];
    fetchedImages = nil;
    
    self.photoUrl = nil;
    self.title = nil;
    
    [super dealloc];
}

- (void)clearImageCache {
    [fetchedImages removeAllObjects];
}

static NSArray *_sizeMapping = nil;

- (NSArray *)sizeMapping {
    if (!_sizeMapping) {
        _sizeMapping = [[NSArray alloc] initWithObjects:@"s", @"t", @"m", @"z", @"b", nil];
    }
    
    return _sizeMapping;
}

- (NSString *)photoUrlForSize:(YAFAPhotoSize)size {
    return [NSString stringWithFormat:@"%@%@.jpg", self.photoUrl, [self.sizeMapping objectAtIndex:size]];
}

- (BOOL)isImageLoadedForSize:(YAFAPhotoSize)size {
    return [fetchedImages objectForKey:[self.sizeMapping objectAtIndex:size]] ? YES : NO;
}

- (UIImage *)imageForSize:(YAFAPhotoSize)size {
    NSString *sizeKey = [self.sizeMapping objectAtIndex:size];
    UIImage *image = [fetchedImages objectForKey:sizeKey];
    
    if (!image) {
        NSURL *url = [NSURL URLWithString:[self photoUrlForSize:size]];
        
        // TODO: should add retry when image fails to load
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        
        if (image && size <= YAFAPhotoSizeSmall) {
            // don't cache large images so we don't run out of space
            [fetchedImages setObject:image forKey:sizeKey];
        }
    }
    
    return image;
}

@end
