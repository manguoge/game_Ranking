//
//  SZGameVC.m
//  CactusLeaderBoard
//
//  Created by comfouriertech on 17/1/15.
//  Copyright © 2017年 ronghua_li. All rights reserved.
//

#import "SZGameVC.h"
/*
 1.游戏状态分为正在游戏，暂停游戏和结束游戏三种，随机生成仙人掌，x轴位置随机，Y轴位置有三种情况，仙人掌的大小有三种随机大小
 2.玩家与仙人掌的交互设计，仙人掌出来之后两秒内可以被玩家点击，玩家的分数加1，如果两秒内没有被点击，则玩家的生命数减1，玩家生命总共5条，耗完则游戏结束；
 3.在游戏期间可以暂停游戏，选择继续或者退出；
 
*/
@interface SZGameVC ()
{

    __weak IBOutlet UIImageView *dune1;
    __weak IBOutlet UIImageView *dune2;
    __weak IBOutlet UIImageView *dune3;
    enum gameEnum
    {
        kPauseAlert,
        kGameOver,
        kLifeImageViewTag
    };
}

@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation SZGameVC

- (void)viewDidLoad
{
    //初始化基本参数
    gameOver=NO;
    pause=NO;
    life=5;
    score=0;
    [super viewDidLoad];
    [self.pauseBtn setImage:[UIImage imageNamed:@"PausePressed"] forState:UIControlStateHighlighted];
    UILabel* tipLabel=[[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH-300)*0.5, (SCREENHEIGHT-100)*0.5, 300, 100)];
    //进入游戏，提示游戏将开始
    tipLabel.text=@"Game Will Start After 3s!";
    [tipLabel setFont:[UIFont systemFontOfSize:20]];
    [tipLabel setTextAlignment:NSTextAlignmentCenter];
    tipLabel.layer.borderWidth=5;
    tipLabel.layer.cornerRadius=15;
    tipLabel.layer.masksToBounds=YES;
    tipLabel.alpha=1;
    tipLabel.backgroundColor=[UIColor redColor];
    [self.view addSubview:tipLabel];
    [UIView animateWithDuration:3 animations:^
    {
        tipLabel.alpha=0;
        tipLabel.backgroundColor=[UIColor grayColor];
    } completion:^(BOOL finished)
    {
        [tipLabel removeFromSuperview];
        //初始化两个仙人掌
        [self spawnCactus];
        [self performSelector:@selector(spawnCactus) withObject:nil afterDelay:2.0];
    }];
    [self updateLife];
}
-(void)spawnCactus
{
    if (gameOver)
    {
        return;
    }
    if (pause)
    {
        //暂停状态时，每隔1秒检查一次状态，若变为非暂停状态时，继续生成一个仙人掌
        [self performSelector:@selector(spawnCactus) withObject:nil afterDelay:1];
        return;
    }
    //根据随机生成数字0、1或者2确定生成的不同大小的仙人掌图片
    int cactusSize=arc4random()%3;
    UIImage* cactusImage=nil;
    switch (cactusSize)
    {
        case 0:
            cactusImage=[UIImage imageNamed:@"CactusLarge"];
            break;
        case 1:
            cactusImage=[UIImage imageNamed:@"CactusMed"];
            break;
        case 2:
            cactusImage=[UIImage imageNamed:@"CactusSmall"];
            break;
        default:
            break;
    }
    //随机生成仙人掌的X、Y轴坐标
    int horizontalLocationX=arc4random()%(int)SCREENWIDTH;
    int VerticalLocation=arc4random()%3;
    //由于随机生成的水平位置的最长部分是屏幕边缘，所以应该将其水平位置向内移动仙人掌宽度的大小，、避免超出屏幕
    float cactusImageWidth=cactusImage.size.width;
    float cactusImageHeight=cactusImage.size.height;
    if (horizontalLocationX+cactusImageWidth>SCREENWIDTH)
    {
        horizontalLocationX=SCREENWIDTH-cactusImageWidth;
    }
    UIImageView* duneToSpawnBehind=nil;
    switch (VerticalLocation)
    {
        case 0:
            duneToSpawnBehind=dune1;
            break;
        case 1:
            duneToSpawnBehind=dune2;
            break;
        case 2:
            duneToSpawnBehind=dune3;
            break;
        default:
            break;
    }
    int verticalLocationY=duneToSpawnBehind.frame.origin.y;
    UIButton* cactusBtn=[[UIButton alloc] initWithFrame:CGRectMake(horizontalLocationX, verticalLocationY, cactusImageWidth, cactusImageHeight)];
    [cactusBtn setImage:cactusImage forState:UIControlStateNormal];
    [cactusBtn addTarget:self action:@selector(cactusHit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:cactusBtn belowSubview:duneToSpawnBehind];
    //生成的仙人掌添加到沙丘的后面之后，就可以运用动画将其跳出来显示
    [UIView beginAnimations:@"slideCactus" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    cactusBtn.frame=CGRectMake(horizontalLocationX, verticalLocationY-cactusImageHeight*0.5, cactusImageWidth, cactusImageHeight);
    [UIView commitAnimations];
    
    [self performSelector:@selector(cactusMissed:) withObject:cactusBtn afterDelay:2.0];

}
-(void)cactusHit:(UIButton*)cactusBtn
{
    [UIView animateWithDuration:0.1 animations:^
    {
        cactusBtn.alpha=0;
    } completion:^(BOOL finished)
     {
         [cactusBtn removeFromSuperview];
     }];
    score++;
    [self updateScore];
    [self performSelector:@selector(spawnCactus) withObject:nil afterDelay:arc4random()%3+0.2];
}
-(void)updateLife
{
    UIImage* lifeImage=[UIImage imageNamed:@"heart"];
    for (UIView* view in [self.view subviews])
    {
        if (view.tag==kLifeImageViewTag)
        {
            [view removeFromSuperview];
        }
    }
    for (int i=0; i<life; i++)
    {
        UIImageView* lifeImageView=[[UIImageView alloc] initWithImage:lifeImage];
        CGRect frame=lifeImageView.frame;
        frame.origin.x=SCREENWIDTH-(i+1)*30;
        frame.origin.y=20;
        lifeImageView.frame=frame;
        lifeImageView.tag=kLifeImageViewTag;
        [self.view addSubview:lifeImageView];
    }
    if (life==0)
    {
        gameOver=YES;
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Game Over!" message:[NSString stringWithFormat:@"You Total Score are %d points",score] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        alert.tag=kGameOver;
        [alert show];
    }
}
-(void)updateScore
{
    //当得分超过30并且10的倍数时，都将再生成一株仙人掌，从而增加游戏难度xs
    if (score>=30&&score%10==0)
    {
        [self spawnCactus];
    }
    self.scoreLabel.text=[NSString stringWithFormat:@"Score:%d",score];
}
-(void)cactusMissed:(UIButton*)cactusBtn
{
    CGRect frame=cactusBtn.frame;
    frame.origin.y+=cactusBtn.frame.size.height;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        cactusBtn.frame=frame;
    } completion:^(BOOL finished)
    {
        [cactusBtn removeFromSuperview];
        [self performSelector:@selector(spawnCactus) withObject:nil afterDelay:arc4random()%3+0.5];
    }];
    life--;
    [self updateLife];
}
- (IBAction)pause:(id)pauseBtn
{
    pause=YES;
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Pause Now" message:nil delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Quit", nil];
    alert.tag=kPauseAlert;
    [alert show];
}
#pragma --mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==kPauseAlert)
    {
        if (buttonIndex==0)
        {
            pause=NO;
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag==kGameOver)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
