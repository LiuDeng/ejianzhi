//
//  Single.m
//  ejianzhi
//
//  Created by 小哥 on 15/7/14.
//  Copyright (c) 2015年 Studio Of Spicy Hot. All rights reserved.
//

#import "Single.h"

@implementation Single
static Single * shareUserInfo=nil;
+(Single *)shareUserInstance
{
    @synchronized(self)
    {
        if (!shareUserInfo){
            shareUserInfo = [[Single alloc] init];
        }
        
    }
    
    return shareUserInfo;
}
@end
