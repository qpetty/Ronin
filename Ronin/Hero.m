//
//  Hero.m
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Hero.h"
#import "samurai.h"

#define HERO_STARTING_HEALTH 3

@implementation Hero

-(instancetype)init {
    self = [super init];
    if (self) {
        self.diffuseColor = GLKVector4Make(0.4f, 0.6f, 0.4f, 1.0f);
        [self reInit];
        
        self.vertexArray = samuraiVerts;
        self.vertexArraySize = samuraiNumVerts * 3 * sizeof(GLfloat);
        self.verticiesToDraw = samuraiNumVerts;
        
        self.normalArray = samuraiNormals;
        self.normalArraySize = sizeof(samuraiNormals);
    }
    return self;
}

-(void)reInit {
    self.health = self.maxHealth = HERO_STARTING_HEALTH;
    self.location = GLKVector3Make(0.0f, 0.0f, -5.0f);
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

-(GLKMatrix4)modelMatrix {
    GLKMatrix4 old = [super modelMatrix];
    
    GLKVector3 toDestination = GLKVector3Subtract(self.destination, self.location);

    float initialX = M_PI_2 - 1.0;

    if (GLKVector3Length(toDestination) < 0.05) {
        old = GLKMatrix4RotateX(old, initialX);
        return old;
    }

    float angle = acosf(GLKVector2DotProduct(GLKVector2Make(1.0f, 0.0f), GLKVector2Make(toDestination.x, toDestination.y)));
    if (isnan(angle)) {
        angle = 0;
    }
    
    angle -= M_PI_2;
    float xAngle = initialX;
    
    if (toDestination.y < 0.0) {
        angle = -angle;
        xAngle = xAngle + M_PI_2;
    }

    old = GLKMatrix4RotateX(old, xAngle);
    old = GLKMatrix4RotateZ(old, angle);
    
    return old;
}

@end
