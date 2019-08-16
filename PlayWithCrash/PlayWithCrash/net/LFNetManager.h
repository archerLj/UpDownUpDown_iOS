//
//  LFNetManager.h
//  PlayWithCrash
//
//  Created by ArcherLj on 2019/8/15.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface LFNetManager: NSObject
+(AFHTTPSessionManager *)defaultManager;

+(AFURLSessionManager *)defaultSessionManager;
@end
