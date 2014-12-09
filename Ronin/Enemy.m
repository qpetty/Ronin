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
        self.location = [self spawnLocation:depth];
    }
    return self;
}

-(void)update {
    float step = 0.005;
    
    if (self.isVisible == NO) {
        self.location = [self spawnLocation:self.location.z];
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

-(GLKVector3)spawnLocation:(float)depth {
    //return GLKVector3Make(0.0f, 0.0f, depth);
    float oneRandom = RANDOM_NUMBER_NEG1_TO_1 * M_PI;
    return GLKVector3Make(2.0 * cosf(oneRandom), 2.0 * sinf(oneRandom), depth);
}

-(void)hitAt:(GLKVector4)hitPoint {
    hitPoint.z = hitPoint.w = 0.0f;
    GLKVector4 middleOfSelf = GLKVector4Make(self.location.x, self.location.y, 0.0f, 0.0f);
    //NSLog(@"location: (%f, %f, %f, %f)", middleOfSelf.x, middleOfSelf.y, middleOfSelf.z, middleOfSelf.w);
    //NSLog(@"hitpoint: (%f, %f, %f, %f)\n", hitPoint.x, hitPoint.y, hitPoint.z, hitPoint.w);

    if (GLKVector4Length(GLKVector4Subtract(middleOfSelf, hitPoint)) < 1.1) {
        NSLog(@"Enemy: %@ hit!", self);
        self.isVisible = NO;
    }
}

@end
