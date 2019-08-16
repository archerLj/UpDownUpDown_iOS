//
//  LFUpload.m
//  PlayWithCrash
//
//  Created by ArcherLj on 2019/8/15.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import "LFUpload.h"
#import "LFNetManager.h"
#import "FileUtil.h"

static int offset = 1024*1024; // 每片的大小是1Mb

@interface LFUpload()
@property (nonatomic, assign) NSInteger truncks;
@property (nonatomic, copy) NSString *fileMD5;
@property (nonatomic, copy) Progress progress;
@end

@implementation LFUpload
-(void)uploadFile:(NSString *)fileName withType:(NSString *)fileType progress:(Progress)progress {
    self.progress = progress;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    self.truncks = fileData.length % offset == 0 ? fileData.length/offset : fileData.length/offset + 1;
    self.fileMD5 = [FileUtil getMD5ofFile:filePath];
    [self checkTrunck:1];
}

// 检查分片是否已经上传
-(void)checkTrunck:(NSInteger)currentTrunck {
    
    if (currentTrunck > self.truncks) {
        self.progress(100, NO);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.fileMD5 forKey:@"md5file"];
    [params setValue:@(currentTrunck) forKey:@"chunk"];
    
    [[LFNetManager defaultManager] POST:@"https://192.168.1.57:443/checkChunk" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *code = [responseObject objectForKey:@"code"];
        if ([code isEqualToString:@"0002"]) { //分片未上传
            [weakSelf uploadTrunck:currentTrunck];
        } else {
            CGFloat progressFinished = currentTrunck * 1.0/self.truncks; // 已经完成的进度
            self.progress(progressFinished, NO);
            [weakSelf checkTrunck:currentTrunck + 1];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.progress(0, YES);
    }];
}

// 上传分片
-(void)uploadTrunck:(NSInteger)currentTrunck {
    
    __weak typeof(self) weakSelf = self;
    
    [[LFNetManager defaultManager] POST:@"https://192.168.1.57:443/upload"
                             parameters:nil
              constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                  
                  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"myFilm" ofType:@"mp4"];
                  NSData *data;
                  NSFileHandle *readHandler = [NSFileHandle fileHandleForReadingAtPath:filePath];
                  [readHandler seekToFileOffset:offset * (currentTrunck - 1)];
                  data = [readHandler readDataOfLength:offset];
                  
                  [formData appendPartWithFileData:data name:@"file" fileName:@"myFilm.mp4" mimeType:@"application/mp4"];
                  
                  // md5File
                  NSData *md5FileData = [self.fileMD5 dataUsingEncoding:NSUTF8StringEncoding];
                  [formData appendPartWithFormData:md5FileData name:@"md5File"];
                  
                  // truncks
                  NSData *truncksData = [[NSString stringWithFormat:@"%ld", (long)self.truncks] dataUsingEncoding:NSUTF8StringEncoding];
                  [formData appendPartWithFormData:truncksData name:@"truncks"];
                  
                  // currentTrunck
                  NSData *trunckData = [[NSString stringWithFormat:@"%ld", (long)currentTrunck] dataUsingEncoding:NSUTF8StringEncoding];
                  [formData appendPartWithFormData:trunckData name:@"currentTrunck"];
                  
              } progress:^(NSProgress * _Nonnull uploadProgress) {
                  CGFloat progressInThisTrunck = (1.0 * uploadProgress.completedUnitCount) / (uploadProgress.totalUnitCount * self.truncks);
                  CGFloat progressFinished = (currentTrunck - 1) * 1.0/self.truncks; // 已经完成的进度
                  self.progress(progressInThisTrunck + progressFinished, NO);
                  
              } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  [weakSelf checkTrunck:currentTrunck + 1];
                  
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  self.progress(0, YES);
              }];
}

@end
