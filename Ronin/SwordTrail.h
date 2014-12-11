//
//  SwordTrail.h
//  Ronin
//
//  Created by Quinton Petty on 12/8/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define NUMBER_OF_POINTS_IN_TAIL 12

@interface SwordTrail : NSObject

@property NSMutableArray *points;

@property GLfloat *vertexArray;
@property size_t vertexArraySize;
@property GLsizei verticiesToDraw;

@property (nonatomic) GLKMatrix4 modelMatrix;
@property (nonatomic) GLKMatrix3 normalMatrix;

-(void)addTouchPoint:(GLKVector4)touchPoint;
-(void)update;

@end
