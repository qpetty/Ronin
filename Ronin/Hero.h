//
//  Hero.h
//  Ronin
//
//  Created by Quinton Petty on 12/7/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Character.h"

@interface Hero : Character {
    @public
    GLuint glNameVertexArray;
    GLuint glNameVertexBuffer;
}


@property GLfloat *vertexArray;
@property size_t vertexArraySize;
@property GLsizei verticiesToDraw;

@property GLKVector3 destination;
@property GLKVector3 movementInterval;

-(void)reInit;
-(void)killedCharacter:(Character*)enemy;

@end
