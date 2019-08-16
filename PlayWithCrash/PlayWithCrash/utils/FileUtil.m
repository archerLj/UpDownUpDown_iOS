//
//  FileUtil.m
//  PlayWithCrash
//
//  Created by ArcherLj on 2019/8/15.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import "FileUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation FileUtil

+(NSString *)getMD5ofFile:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath isDirectory:nil]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        unsigned char digst[CC_MD5_DIGEST_LENGTH];
        CC_MD5(data.bytes, (CC_LONG)data.length, digst);
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digst[i]];
        }
        return output;
    } else {
        return @"";
    }
}
@end
