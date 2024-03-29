
//  MLResumePreviewVC.m
//  EJianZhi
//
//  Created by RAY on 15/4/3.
//  Copyright (c) 2015年 &#40635;&#36771;&#24037;&#20316;&#23460;. All rights reserved.
//

#import "MLResumePreviewVC.h"
#import "freeselectViewCell.h"
#import "DateUtil.h"
#import <AVOSCloud/AVOSCloud.h>
#import "MBProgressHUD.h"
#import "MBProgressHUD+Add.h"
#import "UIImageView+EMWebCache.h"
#import "ResumeVC.h"
#import "imageWithUrlObject.h"
#import "SDPhotoBrowser.h"
#import "CDService.h"
#import "CDUserFactory.h"

#define  PIC_WIDTH 80
#define  PIC_HEIGHT 80
#define  INSETS 10

static NSString *selectFreecellIdentifier = @"freeselectViewCell";

@interface MLResumePreviewVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate,SDPhotoBrowserDelegate>{
    CGFloat freecellwidth;
    NSArray *selectfreetimetitleArray;
    bool selectFreeData[21];
    NSArray *selectfreetimepicArray;
    
    BOOL loaded;

}

@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userAgeLabel;
@property (strong, nonatomic) IBOutlet UILabel *userHeightLabel;
@property (strong, nonatomic) IBOutlet UILabel *userGenderLabel;
@property (strong, nonatomic) IBOutlet UILabel *userSchoolLabel;
@property (strong, nonatomic) IBOutlet UILabel *userMajorLabel;
@property (strong, nonatomic) IBOutlet UILabel *userIntentionLabel;
@property (strong, nonatomic) IBOutlet UITextView *userIntroductionLabel;
@property (strong, nonatomic) IBOutlet UITextView *userExperienceLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *selectfreeCollectionOutlet;
@property (strong, nonatomic) IBOutlet UILabel *userJobConclution;

@property (strong, nonatomic) IBOutlet UIButton *refuseBtn;
@property (strong, nonatomic) IBOutlet UIButton *acceptBtn;


//约束
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *introductionConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *experienceConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *totalConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewConstraint;
@end

@implementation MLResumePreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.16 green:0.73 blue:0.65 alpha:1.0]];
    self.navigationController.navigationBar.translucent=NO;
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary:[[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [self.navigationController.navigationBar setTitleTextAttributes:titleBarAttributes];

    if (self.type== type_preview) {
        
        if (!self.fromEnterprise) {
            self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:Nil style:UIBarButtonItemStyleBordered target:self action:@selector(editResume)];
            [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
            self.title=@"我的简历";
            self.refuseBtn.hidden=YES;
            self.acceptBtn.hidden=YES;
            self.scrollViewConstraint.constant=0;
        }else{
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"联系" style:UIBarButtonItemStylePlain target:self action:@selector(contactUser)];
            
            CDIM* im=[CDIM sharedInstance];
            im.userDelegate=[CDIMService shareInstance];
            [im openWithClientId:[AVUser currentUser].objectId callback:^(BOOL succeeded, NSError *error) {
                if(!error){
                    
                }
            }];
        }
        
        [self initDataFromNet];
        loaded=YES;
    }
    
    if (self.type== type_preview_edit) {
        self.title=@"简历预览";
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:Nil style:UIBarButtonItemStyleBordered target:self action:@selector(returnResume)];
        [self.navigationItem.leftBarButtonItem setTitle:@"返回"];
        
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:Nil style:UIBarButtonItemStyleBordered target:self action:@selector(saveResume)];
        [self.navigationItem.rightBarButtonItem setTitle:@"保存"];
        [self initData];
        
        self.refuseBtn.hidden=YES;
        self.acceptBtn.hidden=YES;
        self.scrollViewConstraint.constant=0;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.type== type_preview&&!loaded) {
        [self initDataFromNet];
    }
    loaded=NO;
}

- (void)returnResume{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)returnAndSave{
    [self returnResume];
    [self.saveDelegate finishSave];
}

- (void)editResume{
    ResumeVC *resumeVC=[[ResumeVC alloc]init];
    resumeVC.userDetailModel=self.userDetailModel;
    [self.navigationController pushViewController:resumeVC animated:YES];
}

- (void)saveResume{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.userDetailModel saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
        if (succeeded) {
            [MBProgressHUD showSuccess:@"保存成功" toView:self.view];
            [self performSelector:@selector(returnAndSave) withObject:nil afterDelay:1.0f];
        }else{
            [MBProgressHUD showSuccess:@"保存失败" toView:self.view];
        }
    }];
    
    if ([self.userImageArray count]>0) {
    
        AVQuery *query=[AVUser query];
        [query whereKey:@"objectId" equalTo:[AVUser currentUser].objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                AVUser *currentUser=[objects objectAtIndex:0];
                
                imageWithUrlObject *imageObject=[self.userImageArray objectAtIndex:0];
                
                //上传图片
                NSData *imageData = UIImageJPEGRepresentation(imageObject.image, 0.5);
                
                AVFile *imageFile = [AVFile fileWithName:@"AvatarImage" data:imageData];
                
                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [currentUser setObject:imageFile forKey:@"avatar"];
                        [currentUser saveEventually];
                    }
                }];
                
                NSUserDefaults *defaultData=[NSUserDefaults standardUserDefaults];
                [defaultData setObject:[self.userDetailModel.userImageArray objectAtIndex:0] forKey:@"userAvatar"];
                [defaultData synchronize];
            }
        }];
    }
}

- (void)initImageScrollView{
    
    for (UIImageView *img in [self.imageScrollView subviews]) {
        [img removeFromSuperview];
    };
    
    if (self.type== type_preview_edit) {
        if ([self.userImageArray count]>0) {
            for (int i=0; i<[self.userImageArray count];i++){
                UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(INSETS+i*(INSETS+PIC_WIDTH), INSETS, PIC_WIDTH, PIC_HEIGHT)];
                imageWithUrlObject *imgUrlObj=[self.userImageArray objectAtIndex:i];
                if (imgUrlObj.image) {
                    [imgView setImage:imgUrlObj.image];
                }else{
                    [imgView sd_setImageWithURL:[NSURL URLWithString:imgUrlObj.url] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                }
                //添加全屏手势
                imgView.tag=i;
                imgView.userInteractionEnabled=YES;
                UITapGestureRecognizer *Gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fullScreen:)];
                [imgView addGestureRecognizer:Gesture];
                
                [self.imageScrollView addSubview:imgView];
            }
            [self.imageScrollView setContentSize:CGSizeMake(INSETS+[self.userImageArray count]*(INSETS+PIC_WIDTH), 100)];
        }
    }else{
        
        if ([self.userDetailModel.userImageArray count]>0) {
            
            if (self.userImageArray==nil) {
                self.userImageArray=[[NSMutableArray alloc] init];
            }else
                [self.userImageArray removeAllObjects];

            for (int i=0; i<[self.userDetailModel.userImageArray count];i++){
                UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(INSETS+i*(INSETS+PIC_WIDTH), INSETS, PIC_WIDTH, PIC_HEIGHT)];
                [imgView sd_setImageWithURL:[self.userDetailModel.userImageArray objectAtIndex:i] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                imageWithUrlObject *imgUrlObj=[[imageWithUrlObject alloc] initWithUrl:[self.userDetailModel.userImageArray objectAtIndex:i]];
                [self.userImageArray addObject:imgUrlObj];
                //添加全屏手势
                imgView.tag=i;
                imgView.userInteractionEnabled=YES;
                UITapGestureRecognizer *Gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fullScreen:)];
                [imgView addGestureRecognizer:Gesture];
                
                [self.imageScrollView addSubview:imgView];
            }
            [self.imageScrollView setContentSize:CGSizeMake(INSETS+[self.userDetailModel.userImageArray count]*(INSETS+PIC_WIDTH), 100)];
        }
    }
}

-(void)fullScreen:(UIGestureRecognizer*)sender{
    
    UIImageView* imgView=(UIImageView*)sender.self.view;
    
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self.imageScrollView; // 原图的父控件
    browser.imageCount = self.userImageArray.count; // 图片总数
    browser.currentImageIndex = (int)imgView.tag;
    browser.delegate = self;
    [browser show];
}

-(void)endFullScreen{

}


- (void)initData{
    if ([self.userDetailModel.userRealName length]>0) {
        self.userNameLabel.text=self.userDetailModel.userRealName;
        self.title=@"我的简历";
    }
    if (self.userDetailModel.userBirthYear) {
        self.userAgeLabel.text=[DateUtil ageFromBirthToNow:self.userDetailModel.userBirthYear];
    }
    if ([self.userDetailModel.userHeight length]>0) {
        self.userHeightLabel.text=[NSString stringWithFormat:@"%@cm",self.userDetailModel.userHeight];
    }
    if (self.userDetailModel.userGender) {
        self.userGenderLabel.text=self.userDetailModel.userGender;
    }
    if ([self.userDetailModel.userSchool length]>0) {
        self.userSchoolLabel.text=self.userDetailModel.userSchool;
    }
    if ([self.userDetailModel.userProfesssion length]>0) {
        self.userMajorLabel.text=self.userDetailModel.userProfesssion;
    }
    if ([self.userDetailModel.userJobIntention length]>0) {
        self.userIntentionLabel.text=self.userDetailModel.userJobIntention;
    }
    
    CGRect rect1;
    CGRect rect2;
    
    if ([self.userDetailModel.userIntroduction length]>0) {
        self.userIntroductionLabel.text=self.userDetailModel.userIntroduction;
        
        rect1 =[self.userIntroductionLabel.text boundingRectWithSize:CGSizeMake(self.userIntroductionLabel.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
        self.introductionConstraint.constant=rect1.size.height+20;

    }
    if ([self.userDetailModel.userWorkExperience length]>0) {
        self.userExperienceLabel.text=self.userDetailModel.userWorkExperience;
        rect2 =[self.userExperienceLabel.text boundingRectWithSize:CGSizeMake(self.userExperienceLabel.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}  context:nil];

        self.experienceConstraint.constant=rect2.size.height+20;
    }
    self.totalConstraint.constant=670+rect1.size.height+rect2.size.height;
    
    [self timeCollectionViewInit];
    
    [self initImageScrollView];
}

- (void)initDataFromNet{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AVQuery *query=[UserDetail query];
    [query whereKey:@"userObjectId" equalTo:self.userObjectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            if ([objects count]>0) {
                self.userDetailModel=[objects objectAtIndex:0];
                [self initData];
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"您还没有创建简历哦" message:nil delegate:self cancelButtonTitle:@"再看看" otherButtonTitles:@"立刻创建", nil];
                alert.tag=1001;
                [alert show];
            }
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"简历加载失败" message:@"是否重新加载" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1001) {
        if (buttonIndex==1) {
            [self editResume];
        }
    }else{
        if (buttonIndex==1) {
            [self initDataFromNet];
        }
    }
}

#pragma mark - Collection View Data Source

- (void)timeCollectionViewInit{
    
    selectfreetimepicArray = [[NSMutableArray alloc]init];
    selectfreetimetitleArray = [[NSMutableArray alloc]init];
    freecellwidth = ([UIScreen mainScreen].bounds.size.width - 100)/7;
    
    selectfreetimetitleArray = @[
                                 [UIImage imageNamed:@"d1"],
                                 [UIImage imageNamed:@"d2"],
                                 [UIImage imageNamed:@"d3"],
                                 [UIImage imageNamed:@"d4"],
                                 [UIImage imageNamed:@"d5"],
                                 [UIImage imageNamed:@"d6"],
                                 [UIImage imageNamed:@"d7"],
                                 ];
    
    selectfreetimepicArray = @[[UIImage imageNamed:@"no"],
                               [UIImage imageNamed:@"yes"],
                               [UIImage imageNamed:@"no"],
                               [UIImage imageNamed:@"yes"],
                               [UIImage imageNamed:@"no"],
                               [UIImage imageNamed:@"yes"]
                               ];
    NSArray *freeTime;
    if ([self.userDetailModel.userIdleTime length]>0) {
        freeTime =[self.userDetailModel.userIdleTime componentsSeparatedByString:@","];
    }
    
    for (int index = 0; index<21; index++) {
        selectFreeData[index] = FALSE;
    }
    
    for (NSString *free in freeTime) {
        if (free.intValue >=0 && free.intValue <=21) {
            selectFreeData[free.intValue] = true;
        }
    }
    
    self.selectfreeCollectionOutlet.delegate = self;
    self.selectfreeCollectionOutlet.dataSource = self;
    UINib *niblogin = [UINib nibWithNibName:selectFreecellIdentifier bundle:nil];
    [self.selectfreeCollectionOutlet registerNib:niblogin forCellWithReuseIdentifier:selectFreecellIdentifier];
    [self.selectfreeCollectionOutlet reloadData];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 28;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(freecellwidth, freecellwidth);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>=0 && indexPath.row<7) {
        return NO;
    }
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    freeselectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:selectFreecellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[freeselectViewCell alloc]init];
    }
    
    if (indexPath.row>=0 && indexPath.row<7) {
        cell.imageView.image = [selectfreetimetitleArray objectAtIndex:indexPath.row];
    }
    
    
    if (indexPath.row>=7 && indexPath.row<14) {
        if (selectFreeData[indexPath.row-7]) {
            cell.imageView.image = [selectfreetimepicArray objectAtIndex:1];
        }else{
            cell.imageView.image = [selectfreetimepicArray objectAtIndex:0];
        }
    }
    if (indexPath.row>=14 && indexPath.row<21) {
        if (selectFreeData[indexPath.row-7]) {
            cell.imageView.image = [selectfreetimepicArray objectAtIndex:3];
        }else{
            cell.imageView.image = [selectfreetimepicArray objectAtIndex:2];
        }
    }
    if (indexPath.row>=21 && indexPath.row<28) {
        if (selectFreeData[indexPath.row-7]) {
            cell.imageView.image = [selectfreetimepicArray objectAtIndex:5];
        }else{
            cell.imageView.image = [selectfreetimepicArray objectAtIndex:4];
        }
    }
    return cell;
}

#pragma mark - photobrowser代理方法

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    imageWithUrlObject *imgUrlObj=[self.userImageArray objectAtIndex:index];
    
    return imgUrlObj.image;
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    imageWithUrlObject *imgUrlObj=[self.userImageArray objectAtIndex:index];
    return [NSURL URLWithString:imgUrlObj.url];
}

- (IBAction)refusetJob:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *parameters=[[NSDictionary alloc]initWithObjectsAndKeys:self.shenqingObjectId,@"jianZhiShenQingId",nil];
    [AVCloud callFunctionInBackground:@"jujue_shenqing" withParameters:parameters block:^(id object, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            [MBProgressHUD showSuccess:@"您已拒绝该求职者" toView:self.view];
        }else{
            [MBProgressHUD showSuccess:@"请求失败，请再次尝试" toView:self.view];
        }
    }];
}

- (IBAction)acceptJob:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *parameters=[[NSDictionary alloc]initWithObjectsAndKeys:self.shenqingObjectId,@"jianZhiShenQingId",nil];
    [AVCloud callFunctionInBackground:@"luyong" withParameters:parameters block:^(id object, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            
            [MBProgressHUD showSuccess:@"您已录用该求职者" toView:self.view];
        }else{
            [MBProgressHUD showSuccess:@"请求失败，请再次尝试" toView:self.view];
        }
    }];
}


- (void)contactUser{

    AVQuery *userQuery=[AVUser query];
    [userQuery whereKey:@"objectId" equalTo:self.userObjectId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            AVUser *_user=[objects objectAtIndex:0];
            [CDCache registerUser:_user];
            
            CDIM* im=[CDIM sharedInstance];
            WEAKSELF
            [im fetchConvWithUserId:_user.objectId callback:^(AVIMConversation *conversation, NSError *error) {
                if(error){
                    DLog(@"%@",error);
                }else{
                    CDChatRoomVC* chatRoomVC=[[CDChatRoomVC alloc] initWithConv:conversation];
                    chatRoomVC.hidesBottomBarWhenPushed=YES;
                    [weakSelf.navigationController pushViewController:chatRoomVC animated:YES];
                }
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
