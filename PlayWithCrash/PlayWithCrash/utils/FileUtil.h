//
//  FileUtil.h
//  PlayWithCrash
//
//  Created by ArcherLj on 2019/8/15.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

// 获取文件的md5值
+(NSString *)getMD5ofFile:(NSString *)filePath;

@end
