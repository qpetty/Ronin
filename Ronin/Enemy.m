//
//  Enemy.m
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Enemy.h"

#define MAX_HEALTH 2

@implementation Enemy

-(instancetype)initWithDepth:(float)depth {
    self = [self init];
    if (self) {
        self.location = GLKVector3Make(0.0f, 0.0f, depth);
        [self respawn];
    }
    return self;
}

-(void)respawn {
    self.location = [self spawnLocation:self.location.z];
    self.health = self.maxHealth = RANDOM_NUMBER_0_TO(MAX_HEALTH) + 1;
    
    if (self.health == 1) {
        self.diffuseColor = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
    } else if (self.health == 2) {
        self.diffuseColor = GLKVector4Make(0.0f, 1.0f, 0.0f, 1.0f);
    } else if (self.health == 3) {
        self.diffuseColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
    }
    
    self.isVisible = YES;
}

-(void)dead {
    self.spawnDelay = RANDOM_NUMBER_0_TO(200);
    self.isVisible = NO;
}

-(void)update {
    float step = 0.01;
    
    if (self.isVisible == NO && self.spawnDelay == 0) {
        [self respawn];
        return;
    } else if (self.isVisible == NO) {
        self.spawnDelay--;
        return;
    }
    
    GLKVector3 dir = GLKVector3Subtract(self.target.location, self.location);
    dir = GLKVector3Normalize(dir);
    dir = GLKVector3MultiplyScalar(dir, step);
    
    self.location = GLKVector3Add(self.location, dir);
    
    if (fabsf(self.location.x - self.target.location.x) <= 0.06 && fabsf(self.location.y - self.target.location.y) <= 0.06) {
        self.target.health--;
        [self dead];
    }
}

-(GLKVector3)spawnLocation:(float)depth {
    float oneRandom = RANDOM_NUMBER_NEG1_TO_1 * M_PI;
    return GLKVector3Make(2.0 * cosf(oneRandom), 2.0 * sinf(oneRandom), depth);
}

-(BOOL)hitEnemyAt:(GLKVector4)hitPoint {
    
    if (self.isVisible == NO) {
        return NO;
    }
    
    hitPoint.z = hitPoint.w = 0.0f;
    GLKVector4 middleOfSelf = GLKVector4Make(self.location.x, self.location.y, 0.0f, 0.0f);
    //NSLog(@"location: (%f, %f, %f, %f)", middleOfSelf.x, middleOfSelf.y, middleOfSelf.z, middleOfSelf.w);
    //NSLog(@"hitpoint: (%f, %f, %f, %f)\n", hitPoint.x, hitPoint.y, hitPoint.z, hitPoint.w);

    if (GLKVector4Length(GLKVector4Subtract(middleOfSelf, hitPoint)) < 1.1) {
        
        self.diffuseColor = GLKVector4MultiplyScalar(self.diffuseColor, 1.0 / (float)self.maxHealth);
        if (--self.health == 0) {
            [self dead];
        }
        NSLog(@"Enemy: %@ hit!", self);
    }
    
    return !self.isVisible;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Enemy-> Health: %lu/%lu", self.health, self.maxHealth];
}

@end
