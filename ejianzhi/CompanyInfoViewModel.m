//
//  CompanyInfoViewModel.m
//  ejianzhi
//
//  Created by Mac on 4/29/15.
//  Copyright (c) 2015 Studio Of Spicy Hot. All rights reserved.
//

#import "CompanyInfoViewModel.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+Add.h"
@interface CompanyInfoViewModel ()

@property (nonatomic,strong) NSString *companyId;


@end


@implementation CompanyInfoViewModel



-(instancetype)initWithData:(NSString *)companyid
{
    if (self=[super init]) {
        if (companyid!=nil) {
            self.companyId=companyid;
        }
        
    }
    return self;
}



-(void)mapKeyValueFromAVObjects:(AVObject*)obj
{
    self.comName=[obj objectForKey:@"qiYeName"];
    self.comTitle=[obj objectForKey:@"qiYeName"];

    self.comFileNum=[obj objectForKey:@"qiYeLicenseNumber"];
    self.comArea=[NSString stringWithFormat:@"%@ %@ %@",[obj objectForKey:@"qiYeProvince"],[obj objectForKey:@"qiYeCity"],[obj objectForKey:@"qiYeDistrict"]];
    self.comIndustry=[obj objectForKey:@"qiYeIndustry"];
    self.comAddress=[obj objectForKey:@"qiYeDetailAddress"];
    self.comContactors=[obj objectForKey:@"qiYeLinkName"];
    self.comPhone=[obj objectForKey:@"qiYeMobile"];
    self.comEmail=[obj objectForKey:@"qiYeEmail"];
    self.comScaleNum=[obj objectForKey:@"qiYeScale"];
    self.comProperty=[obj objectForKey:@"qiYeProperty"];
    
    
    self.tag1Icon=(BOOL)[obj objectForKey:@"qiYeIsValidate"]==YES?nil:[UIImage imageNamed:@"label_xx"];

    self.comIcon=[UIImage imageNamed:@"placeholder"];
}






/**
 *  请求网络数据
 */
-(void)fetchCompanyDataFromAVOS:(NSString *)companyId{
    
    if(companyId!=nil){
    AVQuery *query=[AVQuery queryWithClassName:@"QiYeInfo"];
    query.cachePolicy=kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge=3600*24;
    [query whereKey:@"objectId" equalTo:companyId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count]>0) {
                [self mapKeyValueFromAVObjects:[objects firstObject]];
            }else{
                NSString *errorString=[NSString stringWithFormat:@"您还没有填写信息哦"];
                [MBProgressHUD showError:errorString toView:nil];
            }
        }else{
            NSString *errorString=[NSString stringWithFormat:@"sorry，加载出错。错误原因：%@"  ,error.description];
            [MBProgressHUD showError:errorString toView:nil];
        }
        
    }];
    
    }
}
@end