//
//  Single.h
//  ejianzhi
//
//  Created by 小哥 on 15/7/14.
//  Copyright (c) 2015年 Studio Of Spicy Hot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Single : NSObject
+(Single *)shareUserInstance;
@property (nonatomic, assign) BOOL isAudit;
@end
