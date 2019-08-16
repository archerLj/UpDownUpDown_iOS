//
//  LFUpload.h
//  PlayWithCrash
//
//  Created by ArcherLj on 2019/8/15.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^Progress)(CGFloat progress, Boolean error);

@interface LFUpload : NSObject
-(void)uploadFile:(NSString *)fileName withType:(NSString*)fileType progress:(Progress)progress;
@end
