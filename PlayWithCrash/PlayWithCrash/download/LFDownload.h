//
//  LFDownload.h
//  PlayWithCrash
//
//  Created by ArcherLj on 2019/8/15.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^DownloadProgress)(CGFloat progress, Boolean error);

@interface LFDownload : NSObject
-(void)downloadWithCallBack:(DownloadProgress)callback;
@end
