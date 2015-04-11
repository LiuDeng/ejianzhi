//
//  MLChatVC.m
//  ejianzhi
//
//  Created by RAY on 15/4/9.
//  Copyright (c) 2015年 Studio Of Spicy Hot. All rights reserved.
//

#import "MLChatVC.h"
#import "LCECommon.h"
#import "MLContactCell.h"
#import "CDService.h"
#import "CDUserFactory.h"

@interface MLChatVC ()
{
    NSDateFormatter* dateFormatter1;
    NSDateFormatter* dateFormatter2;
}

@property NSMutableArray* rooms;

@property CDStorage* storage;

@property CDNotify* notify;

@property CDIM* im;

@end

@implementation MLChatVC

- (instancetype)init {
    if ((self = [super init])) {
        _rooms=[[NSMutableArray alloc] init];
        _im=[CDIM sharedInstance];
        _storage=[CDStorage sharedInstance];
        _notify=[CDNotify sharedInstance];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView=footerView;
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"add" style:UIBarButtonItemStylePlain target:self action:@selector(addConversation)];

    if (!dateFormatter1) {
        dateFormatter1=[[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"HH:mm"];
    }
    if (!dateFormatter2) {
        dateFormatter2=[[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"MM-dd"];
    }
    
    
    CDIM* im=[CDIM sharedInstance];
    im.userDelegate=[CDIMService shareInstance];
    [im openWithClientId:[AVUser currentUser].objectId callback:^(BOOL succeeded, NSError *error) {
        if(!error){
            [self refreshRooms];
        }
    }];
}

- (void)refreshRooms{
     NSMutableArray* rooms=[[_storage getRooms] mutableCopy];
    
    [CDCache cacheAndFillRooms:rooms callback:^(BOOL succeeded, NSError *error) {
        
        if(succeeded){
            _rooms=rooms;
            [self.tableView reloadData];
            int totalUnreadCount=0;
            for(CDRoom* room in _rooms){
                totalUnreadCount+=room.unreadCount;
            }
            if(totalUnreadCount>0){
                self.tabBarItem.badgeValue=[NSString stringWithFormat:@"%d",totalUnreadCount];
            }else{
                self.tabBarItem.badgeValue=nil;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)addConversation{
    
    AVQuery *userQuery=[AVUser query];
    [userQuery whereKey:@"objectId" equalTo:@"5512d310e4b065f7eeaa6ff8"];
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



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_rooms count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BOOL nibsRegistered = NO;
    
    static NSString *Cellidentifier=@"MLContactCell";
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"MLContactCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:Cellidentifier];
        nibsRegistered = YES;
    }
    
    MLContactCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier forIndexPath:indexPath];
    
    CDRoom* room = [_rooms objectAtIndex:indexPath.row];
    
    CDConvType type=[self.im typeOfConv:room.conv];
    if(type==CDConvTypeSingle){
        AVUser* user=[CDCache lookupUser:[self.im otherIdOfConv:room.conv]];
        [CDUserService displayAvatarOfUser:user avatarView:cell.userPortraitView];
        cell.userTitleLabel.text=user.username;
    }else{
        [cell.userPortraitView setImage:[UIImage imageNamed:@"placeholder"]];
        cell.userTitleLabel.text=[self.im nameOfConv:room.conv];
    }
    
    cell.conversationLabel.text=[self.im getMsgTitle:room.lastMsg];

    
    NSString *str1=[dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:room.lastMsg.sendTimestamp/1000]];
    NSString *str2=[dateFormatter2 stringFromDate:[NSDate date]];
    if ([str1 isEqualToString:str2]) {
        cell.updateTimeLabel.text=[dateFormatter1 stringFromDate:[NSDate dateWithTimeIntervalSince1970:room.lastMsg.sendTimestamp/1000]];
    }else
        cell.updateTimeLabel.text=str1;
    
    if (room.unreadCount>0) {
        cell.badgeView.badgeText=[NSString stringWithFormat:@"%ld",(long)room.unreadCount];
    }else
        cell.badgeView.badgeText=@"";
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-  (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CDRoom *room = [_rooms objectAtIndex:indexPath.row];
    [[CDIMService shareInstance] goWithConv:room.conv fromVC:self];
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
}

- (void)deselect
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
