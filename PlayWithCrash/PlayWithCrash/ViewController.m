//
//  ViewController.m
//  PlayWithCrash
//
//  Created by ArcherLj on 2019/8/13.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "LFNetManager.h"
#import "LFUpload.h"
#import "LFDownload.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *uploadFileBtn;
@property (nonatomic, strong) UIButton *downloadFileBtn;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) LFUpload *uploadUtils;
@property (nonatomic, strong) LFDownload *downloadUtils;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.uploadUtils = [[LFUpload alloc] init];
    self.downloadUtils = [[LFDownload alloc] init];
    [self viewInit];
}

-(void)viewInit {
    self.uploadFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.uploadFileBtn setTitle:@"上传文件" forState:UIControlStateNormal];
    [self.uploadFileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.uploadFileBtn setBackgroundColor:[UIColor blackColor]];
    [self.uploadFileBtn addTarget:self action:@selector(uploadFile:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.uploadFileBtn];
    
    self.downloadFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downloadFileBtn setTitle:@"下载文件" forState:UIControlStateNormal];
    [self.downloadFileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.downloadFileBtn setBackgroundColor:[UIColor blackColor]];
    [self.downloadFileBtn addTarget:self action:@selector(downloadFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadFileBtn];
    
    self.progressView = [[UIProgressView alloc] init];
    [self.progressView setTintColor:[UIColor blackColor]];
    [self.progressView setProgressTintColor:[UIColor redColor]];
    [self.view addSubview:self.progressView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
                                              [self.progressView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:100],
                                              [self.progressView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                                              [self.progressView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
                                              [self.progressView.heightAnchor constraintEqualToConstant:20.0]
                                              ]];
    
    [self.uploadFileBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
                                              [self.uploadFileBtn.widthAnchor constraintEqualToConstant:120.0],
                                              [self.uploadFileBtn.heightAnchor constraintEqualToConstant:50.0],
                                              [self.uploadFileBtn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
                                              [self.uploadFileBtn.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
                                              ]];
    
    [self.downloadFileBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
                                              [self.downloadFileBtn.widthAnchor constraintEqualToConstant:120.0],
                                              [self.downloadFileBtn.heightAnchor constraintEqualToConstant:50.0],
                                              [self.downloadFileBtn.topAnchor constraintEqualToAnchor:self.uploadFileBtn.bottomAnchor constant:50.0],
                                              [self.downloadFileBtn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
                                              ]];
}

-(void)updateProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress animated:YES];
    });
}

-(void)downloadFile {
    __weak typeof(self) weakSelf = self;
    [self.progressView setProgress:0 animated:YES];
    [self.downloadUtils downloadWithCallBack:^(CGFloat progress, Boolean error) {
        if (error) {
            NSLog(@"下载失败");
        } else {
            [weakSelf updateProgress:progress];
        }
    }];
}

-(void)uploadFile:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    [self.progressView setProgress:0.0 animated:YES];
    [self.uploadUtils uploadFile:@"myFilm" withType:@"mp4" progress:^(CGFloat progress, Boolean error) {
        if (error) {
            NSLog(@"上传失败");
        } else {
            [weakSelf updateProgress:progress];
            if (progress == 1.0) {
                NSLog(@"上传成功!");
            }
        }
    }];
}

@end
