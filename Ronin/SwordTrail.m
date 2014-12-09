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
-(instancetype)initWithGLKVec4:(GLKVector4)vec;

@end

@implementation TouchPoint

-(instancetype)initWithGLKVec4:(GLKVector4)vec {
    self = [super init];
    if (self) {
       self.point = CGPointMake(vec.x, vec.y);
    }
    return self;
}

@end


@implementation SwordTrail {
    GLfloat vertexData[NUMBER_OF_POINTS_IN_TAIL * 3 * 4 * 2];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.vertexArray = vertexData;
        self.vertexArraySize = sizeof(vertexData);
        self.diffuseColor = GLKVector4Make(0.6f, 1.0f, 0.3f, 1.0f);
        
        self.points = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addTouchPoint:(GLKVector4)touchPoint {
    [self.points addObject:[[TouchPoint alloc] initWithGLKVec4:touchPoint]];
    if (self.points.count == NUMBER_OF_POINTS_IN_TAIL + 1) {
        [self.points removeObjectAtIndex:0];
    }
}

-(void)update {
    float delta = 0.05;
    float depth = -5.0;
    
    int offset = 24;
    
    self.verticiesToDraw = (GLsizei)(self.points.count * 4);
    
    [self.points enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TouchPoint *singlePoint = (TouchPoint*)obj;
        //NSLog(@"vertexData: (%f, %f)", singlePoint.point.x, singlePoint.point.y);
        vertexData[idx * offset + 0] = singlePoint.point.x - delta;
        vertexData[idx * offset + 1] = singlePoint.point.y + delta;
        vertexData[idx * offset + 2] = depth;
        
        vertexData[idx * offset + 3] = 0.0f;
        vertexData[idx * offset + 4] = 0.0f;
        vertexData[idx * offset + 5] = 1.0f;
        
        vertexData[idx * offset + 6] = singlePoint.point.x + delta;
        vertexData[idx * offset + 7] = singlePoint.point.y + delta;
        vertexData[idx * offset + 8] = depth;
        
        vertexData[idx * offset + 9] = 0.0f;
        vertexData[idx * offset + 10] = 0.0f;
        vertexData[idx * offset + 11] = 1.0f;
        
        vertexData[idx * offset + 12] = singlePoint.point.x - delta;
        vertexData[idx * offset + 13] = singlePoint.point.y - delta;
        vertexData[idx * offset + 14] = depth;
        
        vertexData[idx * offset + 15] = 0.0f;
        vertexData[idx * offset + 16] = 0.0f;
        vertexData[idx * offset + 17] = 1.0f;
        
        vertexData[idx * offset + 18] = singlePoint.point.x + delta;
        vertexData[idx * offset + 19] = singlePoint.point.y - delta;
        vertexData[idx * offset + 20] = depth;
        
        vertexData[idx * offset + 21] = 0.0f;
        vertexData[idx * offset + 22] = 0.0f;
        vertexData[idx * offset + 23] = 1.0f;
    }];
    
}

-(GLKMatrix4)modelMatrix {
    return GLKMatrix4Identity;
}

-(GLKMatrix3)normalMatrix {
    return GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.modelMatrix), NULL);
}

@end
