//
//  SRLoginVC.m
//  EJianZhi
//
//  Created by RAY on 15/1/21.
//  Copyright (c) 2015年 麻辣工作室. All rights reserved.
//

#import "SRLoginVC.h"
#import "SRRegisterVC.h"

#import "MLLoginViewModel.h"
#import "MLLoginManger.h"
#import "MLTabbarVC.h"
#import "MLTabbar1.h"
#import "ResetPwdViewController.h"
#import "UMSocial.h"
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import <AVOSCloudSNS/AVUser+SNS.h>
#import "UserDetail.h"
#import "MBProgressHUD.h"

@interface SRLoginVC ()<successRegistered,UIAlertViewDelegate>
{
    NSInteger loginType;
    UIView *_thirdLoginView;
}
@property (weak,nonatomic) MLLoginManger *loginManager;
@property (strong, nonatomic) IBOutlet UIButton *otherLoginBtn;
@property (strong, nonatomic) IBOutlet UIButton *lookAroundBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetPassword;
- (IBAction)resetPWDAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *weixinButton;
@property (weak, nonatomic) IBOutlet UILabel *weixinLabel;
@property (weak, nonatomic) IBOutlet UIButton *weiboButton;
@property (weak, nonatomic) IBOutlet UILabel *weiboLabel;
@property (weak, nonatomic) IBOutlet UIButton *qqButton;
@property (weak, nonatomic) IBOutlet UILabel *qqLabel;
@property (weak, nonatomic) IBOutlet UIView *leftViewLine;
@property (weak, nonatomic) IBOutlet UIView *rightViewLine;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SRLoginVC
//@synthesize userAccount=_userAccount;
//@synthesize userPassword=_userPassword;

static  SRLoginVC *thisController=nil;

+(id)shareLoginVC
{
    if (thisController==nil) {
        thisController=[[SRLoginVC alloc] initWithNibName:@"SRLoginVC" bundle:[NSBundle mainBundle]];
    }
    return thisController;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void)creatThirdLoginView{
    
    //self.weixinButton.hidden=YES;
    
    if(SCREENHEIGHT==480){
        self.weixinButton.hidden=YES;
        self.weixinLabel.hidden=YES;
        self.weiboButton.hidden=YES;
        self.weiboLabel.hidden=YES;
        self.qqButton.hidden=YES;
        self.qqLabel.hidden=YES;
    _thirdLoginView=[[UIView alloc]initWithFrame:CGRectMake(0, self.loginButton.frame.origin.y+80, SCREENWIDTH, 80)];
    //_thirdLoginView.backgroundColor=[UIColor redColor];
    [self.view addSubview:_thirdLoginView];
    }
    NSArray *imageArray=@[@"微信",@"微博",@"qq"];
    NSArray *titleArray=@[@"微信",@"微博",@"QQ"];
    
    for(NSInteger i=0; i<3; i++){
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat space=(SCREENWIDTH-150)/4;
        button.frame=CGRectMake(space+(50*i)+space*i, 0, 50, 50);
        [button setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(thirdButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag=200+i;
        UILabel *label=[[UILabel alloc]initWithFrame:
        CGRectMake(space+(50*i)+space*i, 51, 50, 21)];
        label.text=titleArray[i];
        label.textAlignment=UITextAlignmentCenter;
        [_thirdLoginView addSubview:label];
        [_thirdLoginView addSubview:button];
    }
}


-(void)thirdButtonClick:(UIButton *)button{
    switch (button.tag) {
        case 200:
        {
            [self weixinLoginAction:button];
        
        }
            break;
        case 201:
        {
            [self weiboLoginClick:button];
            
        }
            break;
        case 202:
        {
            [self qqLoginAction:button];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)checkVersion
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AVQuery *query = [AVQuery queryWithClassName:@"Version"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            if (objects.count > 0)
            {
                AVObject *object = [objects objectAtIndex:0];
                if ([[object objectForKey:@"versionNumber"] isEqualToString:@"1.0.9"])
                {
                    [Single shareUserInstance].isAudit = NO;
                    _weixinButton.hidden = NO;
                    _weixinLabel.hidden = NO;
                    _weiboButton.hidden = NO;
                    _weiboLabel.hidden = NO;
                    _qqButton.hidden = NO;
                    _qqLabel.hidden = NO;
                    _rightViewLine.hidden = NO;
                    _leftViewLine.hidden = NO;
                    _centerLabel.hidden = NO;
                    if (![Single shareUserInstance].isAudit)
                    {
                        [self creatThirdLoginView];
                        
                    }
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
                else
                {
                    [Single shareUserInstance].isAudit = YES;
                    [self appIsAudit];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
            }
            else
            {
                [Single shareUserInstance].isAudit = YES;
                [self appIsAudit];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }
        else
        {
            [Single shareUserInstance].isAudit = YES;
            [self appIsAudit];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (void)appIsAudit
{
    _weixinButton.hidden = YES;
    _weixinLabel.hidden = YES;
    _weiboButton.hidden = YES;
    _weiboLabel.hidden = YES;
    _qqButton.hidden = YES;
    _qqLabel.hidden = YES;
    _rightViewLine.hidden = YES;
    _leftViewLine.hidden = YES;
    _centerLabel.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.userPassword.clearButtonMode=NO;
    self.loginButton.tag=101;
    [self appIsAudit];
    [self checkVersion];
    
    
//    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREENWIDTH-80)/2, 48+44+20, 80, 80)];
//    headImageView.image = [UIImage imageNamed:@"Icon-60.png"];
//    [self.view addSubview:headImageView];
//    
//    UIButton *weiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    weiboButton.frame = CGRectMake((SCREENWIDTH-50)/2, 404, 50, 50);
//    [weiboButton setImage:[UIImage imageNamed:@"微博"] forState:UIControlStateNormal];
//    [weiboButton addTarget:self action:@selector(weiboLoginAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:weiboButton];
//    
//    UILabel *weiboLabel = [[UILabel alloc] initWithFrame:CGRectMake(weiboButton.frame.origin.x, weiboButton.frame.origin.y+50+5, weiboButton.frame.size.width, 32)];
//    weiboLabel.text = @"微博";
//    weiboLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:weiboLabel];
//    
//    UILabel *thirdLoginLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH-150)/2, 370, 150, 21)];
//    thirdLoginLabel.text = @"第三方登录";
//    thirdLoginLabel.textColor = [UIColor lightGrayColor];
//    thirdLoginLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:thirdLoginLabel];
//    
//    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(20, 380, 70, 0.5)];
//    leftView.backgroundColor = [UIColor lightGrayColor];
//    [self.view addSubview:leftView];
//    
//    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH-20-70, 380, 70, 0.5)];
//    rightView.backgroundColor = [UIColor lightGrayColor];
//    [self.view addSubview:rightView];
    
    NSUserDefaults *mySettingData = [NSUserDefaults standardUserDefaults];
    
    if ([[mySettingData objectForKey:@"type"] intValue] == 2 ) {
        MLTabbarVC *tabbar=[MLTabbarVC shareInstance];
        [self.navigationController pushViewController:tabbar animated:NO];
    }else if ([[mySettingData objectForKey:@"type"] intValue] == 1){
        MLTabbar1 *tabbar=[MLTabbar1 shareInstance];
        [self.navigationController pushViewController:tabbar animated:NO];
    }else
    {
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:@"type"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _weixinLabel.textColor = COLOR(48, 48, 48);
    _weiboLabel.textColor = COLOR(48, 48, 48);
    _qqLabel.textColor = COLOR(48, 48, 48);
    _loginButton.layer.cornerRadius = 5.0f;
    _loginButton.layer.masksToBounds = YES;
    
    self.sinaLoginButton.tag = 1001;
    
    
    loginType=0;
    self.loginManager=[MLLoginManger shareInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.rect1=self.floatView2.frame;
    
    loginer=[[SRLoginBusiness alloc]init];
    
    [self.userAccount.rac_textSignal subscribeNext:^(NSString *text) {
        loginer.username=text;
    }];
    
    
    [self.userPassword.rac_textSignal subscribeNext:^(NSString *text) {
        loginer.pwd=text;
    }];
    
    //[self.otherLoginBtn.layer setBorderWidth:1.0f];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 33/255.0, 174/255.0, 148/255.0, 1.0 });
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 255/255.0, 255/255.0, 255/255.0, 1.0 });
    
//    [self.otherLoginBtn.layer setBorderColor:colorref];
//    [self.otherLoginBtn.layer setCornerRadius:5.0];

    [self.lookAroundBtn.layer setBorderWidth:1.0f];
    [self.lookAroundBtn.layer setBorderColor:colorref];
    [self.lookAroundBtn.layer setCornerRadius:5.0];

    
//    //初始化检验步骤  误删后续有用
//        RACSignal *validUsernameSignal = [self.userAccount.rac_textSignal map:^id(NSString *value) {
//            return @(value.length > 0);
//        }];
//    
//        RACSignal *validPasswordSignal = [self.userPassword.rac_textSignal map:^id(NSString *value) {
//            return @(value.length > 0);
//        }];
    //
    //
//        [validUsernameSignal subscribeNext:^(NSNumber *usernameValid) {
////            if ([usernameValid boolValue]==NO) {
////                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入账户名或手机号码" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
////                [alert show];
////            }
//        }];
    //
//        [validPasswordSignal subscribeNext:^(NSNumber *passwordValid) {
//            if ([passwordValid boolValue]==NO) {
//                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入登陆密码" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                [alert show];
//            }
//    
//        }];
    //
    //
    //    //创建login信号
//        RACSignal *loginActiveSignal=[RACSignal combineLatest:@[validUsernameSignal,validPasswordSignal]
//           reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid){
//               return @(([usernameValid boolValue]&&[passwordValid boolValue]));
//           }];
//    
    //设置loginbutton 的rac_command
//    @weakify(self)
//    self.loginButton.rac_command=[[RACCommand alloc]initWithEnabled:loginActiveSignal signalBlock:^RACSignal *(id input) {
//        @strongify(self)
//        [self touchLoginButton:nil];
//        //监控这个这个信号，应该监控operation操作完成的信号
//        return RACObserve(self.loginManager,LoginState);
//    }];
    
//    RAC(self.loginButton,backgroundColor)=[loginActiveSignal map:^id(NSNumber *value) {
//        @strongify(self)
//        return self.loginButton.enabled? [UIColor colorWithRed:0.13 green:0.62 blue:0.52 alpha:1.0f]:[UIColor grayColor];
//    }];
    
    self.resetPassword.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        if ([self.userAccount.text length]==11) {
//            
//            
//            
//            
//            
//            [SMS_SDK sendSMS:self.userAccount.text AndMessage:[NSString stringWithFormat:@"重置密码成功,新密码为:123456,登录请及时修改"]];
        }
        
        return [RACSignal empty];
    }];
    
}

- (void)viewWillLayoutSubviews{
    [self.navBar setFrame:CGRectMake(0, 0, 320, 64)];
    self.navBar.translucent=NO;
    
}

- (IBAction)touchBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchRegister:(id)sender {
    SRRegisterVC *registerVC=[[SRRegisterVC alloc]init];
    registerVC.registerDelegate=self;
    registerVC.registerType=loginType;
    [self presentViewController:registerVC animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_userAccount resignFirstResponder];
    [_userPassword resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification{
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        
        //        CGRect rect2=CGRectMake(self.rect1.origin.x, self.rect1.origin.y-50, self.rect1.size.width, self.rect1.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            //self.floatView2.frame=rect2;
            self.floatView2.frame=CGRectMake(0, 0, SCREENWIDTH, 191);

        }];
    }
}

- (void)keyboardWillhide:(NSNotification *)notification{
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        
        [UIView animateWithDuration:0.3 animations:^{
           
            self.floatView2.frame=self.rect1;
        }];
    }
}

- (IBAction)touchLoginButton:(id)sender{
    
    if ([loginer.username length]==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入账户名或手机号码" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    else if ([loginer.pwd length]==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入登陆密码" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        
//        [loginer loginInbackground:loginer.username Pwd:loginer.pwd loginType:loginType withBlock:^(BOOL succeed, NSNumber *userType)  {
//        
//        }]
        [loginer loginInbackground:loginer.username Pwd:loginer.pwd loginType:loginType withBlock:^(BOOL succeed, NSNumber *userType)  {
            if (succeed) {
                AVQuery *query = [AVUser query];
                [query whereKey:@"username" equalTo:loginer.username];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (objects.count > 0)
                    {
                        AVUser *user = [objects objectAtIndex:0];
                        [[NSUserDefaults standardUserDefaults] setObject:user.objectId forKey:@"userObjectId"];
                        [[NSUserDefaults standardUserDefaults] setObject:user.username forKey:@"userName"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        
                        AVQuery *query1 = [AVQuery queryWithClassName:@"UserDetail"];
                        [query1 whereKey:@"userObjectId" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"userObjectId"]];
                        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error)
                            {
                                if (objects.count > 0)
                                {
                                    [self setValidateWithArray:objects];
                                    [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:hasJianLi];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }
                                else
                                {
                                    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:hasJianLi];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }
                            }
                            else
                            {
                                [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:hasJianLi];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                        }];
                    }
                }];
                
                AVUser *user = [AVUser currentUser];
                [user setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] forKey:@"installationId"];
                [user saveEventually];
                
                int type = [[[NSUserDefaults standardUserDefaults] objectForKey:@"type"] intValue];
                if (type == 1)
                {
                    if ([userType integerValue]==loginType)
                    {
                        MLTabbar1 *tabbar1=[MLTabbar1 shareInstance];
                        [self.navigationController pushViewController:tabbar1 animated:YES];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该账户为普通账户，是否继续登录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录普通账户",nil];
                        alert.tag=2002;
                        [alert show];
                    }
                    
                }
                else if (type == 2)
                {
                    if ([userType integerValue]==loginType)
                    {
                        MLTabbarVC *tabbar=[MLTabbarVC shareInstance];
                        [self.navigationController pushViewController:tabbar animated:YES];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该账户为企业账户，是否继续登录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录企业账户",nil];
                        alert.tag=3003;
                        [alert show];
                    }
                }
//                if ([userType integerValue]==0) {
//                    if ([userType integerValue]==loginType) {
//                        MLTabbarVC *tabbar=[MLTabbarVC shareInstance];
//                        [self.navigationController pushViewController:tabbar animated:YES];
//                    }else{
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该账户为普通账户，是否继续登录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录普通账户",nil];
//                        alert.tag=2002;
//                        [alert show];
//                    }
//                    
//                }else{
//                    if ([userType integerValue]==loginType) {
//                        MLTabbar1 *tabbar1=[MLTabbar1 shareInstance];
//                        [self.navigationController pushViewController:tabbar1 animated:YES];
//                    }else{
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该账户为企业账户，是否继续登录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录企业账户",nil];
//                        alert.tag=3003;
//                        [alert show];
//                    }
//                }
//
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:loginer.feedback message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

- (void)setValidateWithArray:(NSArray *)objects
{
    int type = [[[NSUserDefaults standardUserDefaults] objectForKey:@"type"] intValue];
    if (type == 2)
    {
        AVObject *user = [objects objectAtIndex:0];
        if ([[user objectForKey:@"isAuthorized"] isEqualToString:@"已认证"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"userIsValidate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else if ([[user objectForKey:@"isAuthorized"] isEqualToString:@"未认证"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"userIsValidate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else if ([[user objectForKey:@"isAuthorized"] isEqualToString:@"未处理"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:@"userIsValidate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"userIsValidate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2002) {
        if (buttonIndex==1) {
            MLTabbarVC *tabbar=[MLTabbarVC shareInstance];
            [self.navigationController pushViewController:tabbar animated:YES];
        }
    }
    if (alertView.tag==3003) {
        if (buttonIndex==1) {
            MLTabbar1 *tabbar1=[MLTabbar1 shareInstance];
            [self.navigationController pushViewController:tabbar1 animated:YES];
        }
    }
}

- (void)successRegistered{
    //[self logIn];
}

- (IBAction)lookAround:(id)sender {
    MLTabbarVC *tabbar=[MLTabbarVC shareInstance];
    [self.navigationController pushViewController:tabbar animated:YES];
}

- (IBAction)otherLogin:(id)sender {
    if ([self.titleLabel.text isEqualToString:@"求职者登录"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"type"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.titleLabel.text=@"企业登录";
        self.userAccount.placeholder=@"请输入企业登录账户";
        [self.otherLoginBtn setTitle:@"求职者登录" forState:UIControlStateNormal];
        loginType=1;
        self.view.backgroundColor = COLOR(53, 156, 108);
        [self.otherLoginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.backgroundColor = [UIColor whiteColor];
        [_loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 33/255.0, 174/255.0, 148/255.0, 1.0 });
//        UIColor *comColor=[UIColor colorWithRed:232/255.0 green:192/255.0 blue:111/255.0 alpha:1.0];
//        self.view.backgroundColor=comColor;
//        self.floatView2.backgroundColor=comColor;
////        self.loginButton.titleLabel.textColor=comColor;
//        self.navBar.barTintColor=comColor;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:@"type"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.userAccount.placeholder=@"请输入账户名";
        self.titleLabel.text=@"求职者登录";
        [self.otherLoginBtn setTitle:@"企业登录" forState:UIControlStateNormal];
        loginType=0;
        [self.otherLoginBtn setTitleColor:COLOR(53, 156, 108) forState:UIControlStateNormal];
        self.view.backgroundColor =COLOR(235, 235, 241);
        _loginButton.backgroundColor = COLOR(53, 156, 108);
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        UIColor *usrColor=[UIColor colorWithRed:33/255.0 green:174/255.0 blue:148/255.0 alpha:1.0f];
//        self.view.backgroundColor=usrColor;
//        self.floatView2.backgroundColor=usrColor;
////        self.loginButton.titleLabel.textColor=usrColor;
//        self.navBar.barTintColor=usrColor;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)resetPWDAction:(id)sender {
    
    ResetPwdViewController *resetPWDVC=[[ResetPwdViewController alloc]init];
    [self presentViewController:resetPWDVC animated:YES completion:^{
        resetPWDVC.phoneText.text=self.userAccount.text;
    }];
    
}


- (IBAction)weiboLoginClick:(id)sender {
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
            
            AVUser *user = [AVUser user];
            user.username =snsAccount.userName;
            user.password = @"123456";
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                AVFile *imageFile = [AVFile fileWithName:@"AvatarImage" data:[NSData dataWithContentsOfURL:[NSURL URLWithString:snsAccount.iconURL]]];
                
                [[NSUserDefaults standardUserDefaults] setObject:snsAccount.iconURL forKey:@"userAvatar"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    AVQuery *query=[AVUser query];
                    [query whereKey:@"username" equalTo:snsAccount.userName];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        
                        AVUser *currentUser=[objects objectAtIndex:0];
                        [currentUser setObject:imageFile forKey:@"avatar"];
                        [currentUser saveEventually];
                        [[NSUserDefaults standardUserDefaults] setObject:currentUser.objectId forKey:@"userObjectId"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        AVQuery *userDetailQuery=[AVQuery queryWithClassName:@"UserDetail"];
                        [userDetailQuery whereKey:@"userObjectId" equalTo:currentUser.objectId];
                        [userDetailQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                if ([objects count]>0) {
                                    [self setValidateWithArray:objects];
                                    AVObject *userDetailObject=[objects objectAtIndex:0];
                                    NSMutableArray *imageArray=[userDetailObject objectForKey:@"userImageArray"];
                                    [imageArray insertObject:imageFile.url atIndex:0];
                                    [userDetailObject setObject:imageArray forKey:@"userImageArray"];
                                    [userDetailObject saveEventually];
                                    [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:hasJianLi];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }else{
                                    AVObject *userDetailObject = [AVObject objectWithClassName:@"UserDetail"];
                                    NSMutableArray *imageArray=[[NSMutableArray alloc] initWithObjects:imageFile.url, nil];
                                    [userDetailObject setObject:imageArray forKey:@"userImageArray"];
                                    [userDetailObject saveEventually];
                                    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:hasJianLi];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }
                            }
                            else
                            {
                                [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:hasJianLi];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                        }];
                        
                        
                        if (loginer == nil)
                        {
                            loginer=[[SRLoginBusiness alloc]init];
                        }
                        
                        [loginer loginInbackground:snsAccount.userName Pwd:@"123456" loginType:loginType withBlock:^(BOOL succeed, NSNumber *userType) {
                            
                            AVUser *user = [AVUser currentUser];
                            [user setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] forKey:@"installationId"];
                            [user saveEventually];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:snsAccount.userName forKey:@"userName"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            int type = [[[NSUserDefaults standardUserDefaults] objectForKey:@"type"] intValue];
                            if (type == 1)
                            {
                                
                                MLTabbar1 *tabbar1=[MLTabbar1 shareInstance];
                                [self.navigationController pushViewController:tabbar1 animated:YES];
                            }
                            else if (type == 2)
                            {
                                MLTabbarVC *tabbar=[MLTabbarVC shareInstance];
                                [self.navigationController pushViewController:tabbar animated:YES];
                            }
                            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
                        }];
                        
                    }];
                }];
                
                
                
            }];
            
        }});
}


- (IBAction)weixinLoginAction:(UIButton *)sender
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
            
            AVUser *user = [AVUser user];
            user.username =snsAccount.userName;
            user.password = @"123456";
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                AVFile *imageFile = [AVFile fileWithName:@"AvatarImage" data:[NSData dataWithContentsOfURL:[NSURL URLWithString:snsAccount.iconURL]]];
                
                [[NSUserDefaults standardUserDefaults] setObject:snsAccount.iconURL forKey:@"userAvatar"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    AVQuery *query=[AVUser query];
                    [query whereKey:@"username" equalTo:snsAccount.userName];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        
                        AVUser *currentUser=[objects objectAtIndex:0];
                        [currentUser setObject:imageFile forKey:@"avatar"];
                        [currentUser saveEventually];
                        [[NSUserDefaults standardUserDefaults] setObject:currentUser.objectId forKey:@"userObjectId"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        AVQuery *userDetailQuery=[AVQuery queryWithClassName:@"UserDetail"];
                        [userDetailQuery whereKey:@"userObjectId" equalTo:currentUser.objectId];
                        [userDetailQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                if ([objects count]>0) {
                                    [self setValidateWithArray:objects];
                                    AVObject *userDetailObject=[objects objectAtIndex:0];
                                    NSMutableArray *imageArray=[userDetailObject objectForKey:@"userImageArray"];
                                    [imageArray insertObject:imageFile.url atIndex:0];
                                    [userDetailObject setObject:imageArray forKey:@"userImageArray"];
                                    [userDetailObject saveEventually];
                                    [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:hasJianLi];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }else{
                                    AVObject *userDetailObject = [AVObject objectWithClassName:@"UserDetail"];
                                    NSMutableArray *imageArray=[[NSMutableArray alloc] initWithObjects:imageFile.url, nil];
                                    [userDetailObject setObject:imageArray forKey:@"userImageArray"];
                                    [userDetailObject saveEventually];
                                    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:hasJianLi];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }
                            }
                            else
                            {
                                [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:hasJianLi];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                        }];
                        
                        
                        if (loginer == nil)
                        {
                            loginer=[[SRLoginBusiness alloc]init];
                        }
                        
                        [loginer loginInbackground:snsAccount.userName Pwd:@"123456" loginType:loginType withBlock:^(BOOL succeed, NSNumber *userType) {
                            
                            AVUser *user = [AVUser currentUser];
                            [user setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] forKey:@"installationId"];
                            [user saveEventually];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:snsAccount.userName forKey:@"userName"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            int type = [[[NSUserDefaults standardUserDefaults] objectForKey:@"type"] intValue];
                            if (type == 1)
                            {
                                
                                MLTabbar1 *tabbar1=[MLTabbar1 shareInstance];
                                [self.navigationController pushViewController:tabbar1 animated:YES];
                            }
                            else if (type == 2)
                            {
                                MLTabbarVC *tabbar=[MLTabbarVC shareInstance];
                                [self.navigationController pushViewController:tabbar animated:YES];
                            }
                            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
                        }];
                        
                    }];
                }];
                
                
                
            }];
            
        }});
}

- (IBAction)qqLoginAction:(UIButton *)sender
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            AVUser *user = [AVUser user];
            user.username =snsAccount.userName;
            user.password = @"123456";
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                AVFile *imageFile = [AVFile fileWithName:@"AvatarImage" data:[NSData dataWithContentsOfURL:[NSURL URLWithString:snsAccount.iconURL]]];
                
                [[NSUserDefaults standardUserDefaults] setObject:snsAccount.iconURL forKey:@"userAvatar"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    AVQuery *query=[AVUser query];
                    [query whereKey:@"username" equalTo:snsAccount.userName];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        
                        AVUser *currentUser=[objects objectAtIndex:0];
                        [currentUser setObject:imageFile forKey:@"avatar"];
                        [currentUser saveEventually];
                        [[NSUserDefaults standardUserDefaults] setObject:currentUser.objectId forKey:@"userObjectId"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        AVQuery *userDetailQuery=[AVQuery queryWithClassName:@"UserDetail"];
                        [userDetailQuery whereKey:@"userObjectId" equalTo:currentUser.objectId];
                        [userDetailQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                if ([objects count]>0) {
                                    AVObject *userDetailObject=[objects objectAtIndex:0];
                                    NSMutableArray *imageArray=[userDetailObject objectForKey:@"userImageArray"];
                                    [imageArray insertObject:imageFile.url atIndex:0];
                                    [userDetailObject setObject:imageArray forKey:@"userImageArray"];
                                    [userDetailObject saveEventually];
                                    [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:hasJianLi];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }else{
                                    AVObject *userDetailObject = [AVObject objectWithClassName:@"UserDetail"];
                                    NSMutableArray *imageArray=[[NSMutableArray alloc] initWithObjects:imageFile.url, nil];
                                    [userDetailObject setObject:imageArray forKey:@"userImageArray"];
                                    [userDetailObject saveEventually];
                                    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:hasJianLi];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                }
                            }
                            else
                            {
                                [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:hasJianLi];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                        }];
                        
                        
                        if (loginer == nil)
                        {
                            loginer=[[SRLoginBusiness alloc]init];
                        }
                        
                        [loginer loginInbackground:snsAccount.userName Pwd:@"123456" loginType:loginType withBlock:^(BOOL succeed, NSNumber *userType) {
                            
                            AVUser *user = [AVUser currentUser];
                            [user setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] forKey:@"installationId"];
                            [user saveEventually];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:snsAccount.userName forKey:@"userName"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            int type = [[[NSUserDefaults standardUserDefaults] objectForKey:@"type"] intValue];
                            if (type == 1)
                            {
                                
                                MLTabbar1 *tabbar1=[MLTabbar1 shareInstance];
                                [self.navigationController pushViewController:tabbar1 animated:YES];
                            }
                            else if (type == 2)
                            {
                                MLTabbarVC *tabbar=[MLTabbarVC shareInstance];
                                [self.navigationController pushViewController:tabbar animated:YES];
                            }
                            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
                        }];
                        
                    }];
                }];
                
                
                
            }];
            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
        }});
}

@end
