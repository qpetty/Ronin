//
//  Enemy.h
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Character.h"

@interface Enemy : Character

@property Character *target;

-(instancetype)initWithDepth:(float)depth;
-(void)hitAt:(GLKVector4)hitPoint;

@end
