//
//  YAFAPhoto.h
//  YAFA
//
//  Created by Judy Liu on 5/30/11.
//

#import <Foundation/Foundation.h>

typedef enum {
    YAFAPhotoSizeSquare = 0,
    YAFAPhotoSizeThumb,
	YAFAPhotoSizeSmall,
    YAFAPhotoSizeMedium,
	YAFAPhotoSizeLarge
} YAFAPhotoSize;

@interface YAFAPhoto : NSObject {
    NSMutableDictionary *fetchedImages;
}

@property (nonatomic, retain) NSString *photoUrl;
@property (nonatomic, retain) NSString *title;

+ (YAFAPhoto *)photoWithTitle:(NSString *)theTitle photoUrl:(NSString *)thePhotoUrl;
- (id)initWithTitle:(NSString *)theTitle photoUrl:(NSString *)thePhotoUrl;
- (NSString *)photoUrlForSize:(YAFAPhotoSize)size;
- (UIImage *)imageForSize:(YAFAPhotoSize)size;
- (BOOL)isImageLoadedForSize:(YAFAPhotoSize)size;
- (void)clearImageCache;

@end
