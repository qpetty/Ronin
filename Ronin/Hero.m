//
//  Hero.m
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Hero.h"

#define HERO_STARTING_HEALTH 3

@implementation Hero

-(instancetype)init {
    self = [super init];
    if (self) {
        self.diffuseColor = GLKVector4Make(0.4f, 0.6f, 0.4f, 1.0f);
        self.health = self.maxHealth = HERO_STARTING_HEALTH;
    }
    return self;
}

-(void)update {
    self.location = GLKVector3Add(self.location, self.movementInterval);
    
    if (GLKVector3Length(GLKVector3Subtract(self.destination, self.location)) < 0.05) {
        self.movementInterval = GLKVector3Make(0.0f, 0.0f, 0.0f);
    }
}

-(void)killedCharacter:(Character*)enemy {
    float scale = 0.05;
    GLKVector3 dir = GLKVector3Subtract(enemy.location, self.location);
    dir = GLKVector3Normalize(dir);
    dir = GLKVector3MultiplyScalar(dir, scale);
    dir.z = 0.0;
    self.movementInterval = dir;
    PRINT_VEC3(self.movementInterval);
    
    self.destination = enemy.location;
}

@end
