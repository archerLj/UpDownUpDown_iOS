//
//  LFDownload.m
//  PlayWithCrash
//
//  Created by ArcherLj on 2019/8/15.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import "LFDownload.h"
#import "LFNetManager.h"
#import <AFNetworking.h>
#import "FileUtil.h"

@interface LFDownload()
@property (nonatomic, copy) DownloadProgress progress;
@property (nonatomic, assign) NSInteger allTruncks;
@property (nonatomic, assign) NSInteger currentTrunck;
@property (nonatomic, copy) NSString *fileMD5;
@end

@implementation LFDownload
-(void)downloadWithCallBack:(DownloadProgress)callback {
    self.progress = callback;
    [self getTruncks];
    [self getProgress];
}

-(void)getTruncks {
    
    __weak typeof(self) weakSelf = self;
    
    [[LFNetManager defaultManager] GET:@"https://192.168.1.57:443/getTruncks" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([[responseObject valueForKey:@"code"] isEqualToString:@"0000"]) {
            weakSelf.allTruncks = [[responseObject valueForKey:@"truncks"] integerValue];
            weakSelf.fileMD5 = [responseObject valueForKey:@"fileMD5"];
            
            if ([self checkMD5FilePath]) {
                [self downloadWithTrunck:1];
            } else {
                weakSelf.progress(0, YES);
            }
            
        } else {
            weakSelf.progress(0, YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakSelf.progress(0, YES);
    }];
}

//  检查存放temp文件的文件夹是否存在
-(BOOL)checkMD5FilePath {
    
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.fileMD5];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = YES;
    BOOL fileMD5PathExists = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (!fileMD5PathExists) {
        NSError *error;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"下载失败");
            return NO;
        }
    }
    
    return YES;
}


// 下载完成，合并所有temp文件
-(void)mergeTempFiles {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *finalFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"myFilm.mp4"];
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:finalFilePath isDirectory:&isDir]) {
        BOOL result = [fileManager createFileAtPath:finalFilePath contents:nil attributes:nil];
        if (!result) {
            self.progress(0, YES);
            NSLog(@"文件合并失败");
            return;
        }
    }
    
    NSFileHandle *outFileHandler = [NSFileHandle fileHandleForUpdatingAtPath:finalFilePath];
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.fileMD5];
    for (int i=1; i<= self.allTruncks; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%d.temp", i];
        NSString *tempFilePath = [path stringByAppendingPathComponent:fileName];
        NSFileHandle *inFileHandler = [NSFileHandle fileHandleForReadingAtPath:tempFilePath];
        
        int offsetIndex = 0;
        BOOL end = NO;
        while (!end) {
            [inFileHandler seekToFileOffset:1024 * offsetIndex];
            NSData *data = [inFileHandler readDataOfLength:1024];
            if (data.length == 0) {
                end = YES;
            } else {
                [outFileHandler seekToEndOfFile];
                [outFileHandler writeData:data];
            }
            offsetIndex += 1;
        }

        [inFileHandler closeFile];
    }
    [outFileHandler closeFile];
    NSLog(@"文件合并成功");
}

-(void)downloadWithTrunck:(NSInteger)currentTrunck {
    
    if (currentTrunck > self.allTruncks) {
        NSLog(@"下载完成");
        self.progress(1.0, NO);
        [self mergeTempFiles];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    NSString *urlStr = [NSString stringWithFormat:@"https://192.168.1.57:443/downloadFile?trunck=%ld", (long)currentTrunck];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSString *fileName = [NSString stringWithFormat:@"%ld.temp", (long)currentTrunck];
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.fileMD5];
    NSString *tempFilePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL tempFileExists = [fileManager fileExistsAtPath:tempFilePath isDirectory:&isDir];
    
    if (tempFileExists) { // 文件已经下载了
        NSLog(@"%ld.temp 已经下载过了", currentTrunck);
        self.progress(currentTrunck * 1.9 /self.allTruncks, NO);
        [weakSelf downloadWithTrunck:currentTrunck + 1];
        
    } else { // 开始下载文件
        
        self.currentTrunck = currentTrunck;
        NSURLSessionDownloadTask *task = [[LFNetManager defaultSessionManager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            /* 由于后台使用gzip压缩的原因，导致http header中没有Content-Length字段，所以这里不能获取到下载进度 */
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSLog(@"%@", tempFilePath);
            return [NSURL fileURLWithPath:tempFilePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (error) {
                weakSelf.progress(0, YES);
            } else {
                [weakSelf downloadWithTrunck:currentTrunck + 1];
            }
        }];
        
        [task resume];
    }
}

// 我们自己在回调中计算进度
-(void)getProgress {
    
    __weak typeof(self) weakSelf = self;
    
    [[LFNetManager defaultSessionManager] setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        // 这里总长度应该从后台单独获取，这里取一个大致的值，假设所有的trunk都有1Mb，其实，只有最后一个没有1Mb
        long allBytes = 1024 * 1024 * self.allTruncks;
        long downloadedBytes = bytesWritten + 1024 * 1024 * (self.currentTrunck - 1); // 当前trunk已经下载的大小 + 前面已经完成的trunk的大小
        weakSelf.progress(downloadedBytes * 1.0 / allBytes, NO);
    }];
}
@end
