//
//  Enemy.m
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy

-(instancetype)initWithDepth:(float)depth {
    self = [self init];
    if (self) {
        self.location = GLKVector3Make(RANDOM_NUMBER_NEG1_TO_1 * 2.0, RANDOM_NUMBER_NEG1_TO_1 * 2.0, depth);
    }
    return self;
}

-(void)update {
    float step = 0.05;
    
    if (self.isVisible == NO) {
        self.location = GLKVector3Make(RANDOM_NUMBER_NEG1_TO_1 * 2.0, RANDOM_NUMBER_NEG1_TO_1 * 2.0, self.location.z);
        self.isVisible = YES;
    }
    
    GLKVector3 dir = GLKVector3Subtract(self.target.location, self.location);
    dir = GLKVector3Normalize(dir);
    dir = GLKVector3MultiplyScalar(dir, step);
    
    self.location = GLKVector3Add(self.location, dir);
    

    if (fabsf(self.location.x - self.target.location.x) <= 0.06 && fabsf(self.location.y - self.target.location.y) <= 0.06) {
        self.isVisible = NO;
    }
}

@end
