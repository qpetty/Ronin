//
//  SwordTrail.m
//  Ronin
//
//  Created by Quinton Petty on 12/8/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "SwordTrail.h"

@interface TouchPoint : NSObject

@property CGPoint point;
@property GLKVector4 delta;
@property NSInteger life;
@property BOOL isAlive;
-(instancetype)initWithGLKVec4:(GLKVector4)vec andNextPoint:(TouchPoint*)nextPoint;

@end

@implementation TouchPoint {
    float distance;
}

-(instancetype)initWithGLKVec4:(GLKVector4)vec andNextPoint:(TouchPoint*)nextPoint {
    self = [super init];
    if (self) {
        self.point = CGPointMake(vec.x, vec.y);
        distance = 0.02;
        self.life = 20;
        self.isAlive = YES;
        
        vec.z = vec.w = 0;
        if (nextPoint) {
            self.delta = GLKVector4Make(nextPoint.point.x, nextPoint.point.y, 0.0f, 0.0f);
            self.delta = GLKVector4Subtract(self.delta, vec);
            self.delta = GLKVector4Normalize(self.delta);
            self.delta = GLKMatrix4MultiplyVector4(GLKMatrix4RotateZ(GLKMatrix4Identity, M_PI_2), self.delta);
            self.delta = GLKVector4MultiplyScalar(self.delta, 0.1f);
        } else {
            self.delta = GLKVector4Make(0.05f, 0.05f, 0.0f, 0.0f);
        }
    }
    return self;
}

-(void)update {

    self.delta = GLKVector4Subtract(self.delta, GLKVector4MultiplyScalar(GLKVector4Normalize(self.delta), distance));

    if (--self.life < 1 || GLKVector4Length(self.delta) < 0.015) {
        self.delta = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
        self.isAlive = NO;
    }
    
}

@end


@implementation SwordTrail {
    GLfloat vertexData[NUMBER_OF_POINTS_IN_TAIL * 3 * 2 * 2];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.vertexArray = vertexData;
        self.vertexArraySize = sizeof(vertexData);
        self.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 0.4f);
        
        self.points = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addTouchPoint:(GLKVector4)touchPoint {
    TouchPoint *nextPoint = nil;
    if (self.points.count > 0) {
        nextPoint = [self.points lastObject];
    }
    
    //Needed to prevent NaN floats when subtracting almost exact floats
    if (touchPoint.x == nextPoint.point.x || touchPoint.y == nextPoint.point.y) {
        return;
    }
    
    TouchPoint *newPoint = [[TouchPoint alloc] initWithGLKVec4:touchPoint andNextPoint:nextPoint];
    [self.points insertObject:newPoint atIndex:self.points.count];
    
    if (self.points.count == NUMBER_OF_POINTS_IN_TAIL + 1) {
        [self.points removeObjectAtIndex:0];
    }
}

-(void)update {
    float depth = -5.0;
    
    int offset = 12;
    
    self.verticiesToDraw = (GLsizei)(self.points.count * 2);
    
    NSMutableIndexSet *indeciesToRemove = [[NSMutableIndexSet alloc] init];
    
    [self.points enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TouchPoint *singlePoint = (TouchPoint*)obj;
        [singlePoint update];
        
        //NSLog(@"vertexData: (%f, %f)", singlePoint.point.x, singlePoint.point.y);
        vertexData[idx * offset + 0] = singlePoint.point.x + singlePoint.delta.x;
        vertexData[idx * offset + 1] = singlePoint.point.y + singlePoint.delta.y;
        vertexData[idx * offset + 2] = depth;
        
        vertexData[idx * offset + 3] = 0.0f;
        vertexData[idx * offset + 4] = 0.0f;
        vertexData[idx * offset + 5] = 1.0f;
        
        vertexData[idx * offset + 6] = singlePoint.point.x - singlePoint.delta.x;
        vertexData[idx * offset + 7] = singlePoint.point.y - singlePoint.delta.y;
        vertexData[idx * offset + 8] = depth;
        
        vertexData[idx * offset + 9] = 0.0f;
        vertexData[idx * offset + 10] = 0.0f;
        vertexData[idx * offset + 11] = 1.0f;
        
        if (singlePoint.isAlive == NO) {
            [indeciesToRemove addIndex:idx];
        }
    }];
    
    [self.points removeObjectsAtIndexes:indeciesToRemove];
}

-(GLKMatrix4)modelMatrix {
    return GLKMatrix4Identity;
}

-(GLKMatrix3)normalMatrix {
    return GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.modelMatrix), NULL);
}

@end
