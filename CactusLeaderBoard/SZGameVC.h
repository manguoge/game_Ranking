//
//  SZGameVC.h
//  CactusLeaderBoard
//
//  Created by comfouriertech on 17/1/15.
//  Copyright © 2017年 ronghua_li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SZGameVC : UIViewController<UIAlertViewDelegate>
{
    bool gameOver;
    bool pause;
    int life;
    int score;
}
-(void)spawnCactus;
-(void)updateLife;
-(void)updateScore;

@end
