//
//  LFNetManager.m
//  PlayWithCrash
//
//  Created by ArcherLj on 2019/8/15.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import "LFNetManager.h"

@implementation LFNetManager

+(AFHTTPSessionManager *)defaultManager {
    static AFHTTPSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *pfxPath = [[NSBundle mainBundle] pathForResource:@"mymeizi" ofType:@"cer"];
        NSData *pfxData = [NSData dataWithContentsOfFile:pfxPath];
        
        // AFSSLPinningModeCertificate 和
        // AFSSLPinningModePublicKey 只能用于安全的访问链接，及浏览器地址栏https安全表示是绿色那种
        // 如果不是从可信任机构颁发的，而是自签名证书，就用AFSSLPinningModeNone模式
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        // 默认不允许过期或者自签名证书的，如果是自签名证书，这里要设置为YES
        securityPolicy.allowInvalidCertificates = YES;
        // 默认是要验证请求的域名和证书中的域名是否完全一致，即使是子域名也不行，这里我们可以在证书中使用通配符域名
        // 这里，我们用于测试服务器，直接使用IP地址，所以把它关掉即可。
        securityPolicy.validatesDomainName = NO;
        if (pfxData) {
            securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:pfxData, nil];
        }
        
        manager = [AFHTTPSessionManager manager];
        manager.securityPolicy = securityPolicy;
    });
    
    return manager;
}

+(AFURLSessionManager *)defaultSessionManager {
    static AFURLSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *pfxPath = [[NSBundle mainBundle] pathForResource:@"mymeizi" ofType:@"cer"];
        NSData *pfxData = [NSData dataWithContentsOfFile:pfxPath];
        
        // AFSSLPinningModeCertificate 和
        // AFSSLPinningModePublicKey 只能用于安全的访问链接，及浏览器地址栏https安全表示是绿色那种
        // 如果不是从可信任机构颁发的，而是自签名证书，就用AFSSLPinningModeNone模式
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        // 默认不允许过期或者自签名证书的，如果是自签名证书，这里要设置为YES
        securityPolicy.allowInvalidCertificates = YES;
        // 默认是要验证请求的域名和证书中的域名是否完全一致，即使是子域名也不行，这里我们可以在证书中使用通配符域名
        // 这里，我们用于测试服务器，直接使用IP地址，所以把它关掉即可。
        securityPolicy.validatesDomainName = NO;
        if (pfxData) {
            securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:pfxData, nil];
        }
        
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.securityPolicy = securityPolicy;
    });
    
    return manager;
}
@end
