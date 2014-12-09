//
//  GameViewController.h
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface GameViewController : GLKViewController

@property (weak) IBOutlet UILabel *highScore;
@property (weak) IBOutlet UILabel *lifeDisplay;

@property (weak) IBOutlet UIButton *startButton;

@end
