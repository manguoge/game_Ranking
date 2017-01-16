//
//  SZMainVC.m
//  CactusLeaderBoard
//
//  Created by comfouriertech on 17/1/15.
//  Copyright © 2017年 ronghua_li. All rights reserved.
//

#import "SZMainVC.h"

@interface SZMainVC ()
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *scoresBtn;
@property (weak, nonatomic) IBOutlet UIButton *achievementBtn;

@end

@implementation SZMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.playBtn addTarget:self action:@selector(enterPlayGame) forControlEvents:UIControlEventTouchUpInside];
}
-(void)enterPlayGame
{
    SZGameVC* gameVC=[[SZGameVC alloc] init];
    [self.navigationController pushViewController:gameVC animated:YES];
    
}

@end
