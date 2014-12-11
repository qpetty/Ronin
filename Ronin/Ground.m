//
//  Ground.m
//  Ronin
//
//  Created by Quinton Petty on 12/10/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Ground.h"

GLfloat square[48] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ, texture0x, texture0y,
    1.0f, 1.0f, 0.0f,          0.0f, 0.0f, 1.0f,   1.0f, 1.0f,
    -1.0f, -1.0f, 0.0f,        0.0f, 0.0f, 1.0f,   0.0f, 0.0f,
    1.0f, -1.0f, 0.0f,         0.0f, 0.0f, 1.0f,   1.0f, 0.0f,
    1.0f, 1.0f, 0.0f,          0.0f, 0.0f, 1.0f,   1.0f, 1.0f,
    -1.0f, -1.0f, 0.0f,        0.0f, 0.0f, 1.0f,   0.0f, 0.0f,
    -1.0f, 1.0f, 0.0f,         0.0f, 0.0f, 1.0f,   0.0f, 1.0f
};

@implementation Ground

-(instancetype)init {
    self = [super init];
    if (self) {
        self.location = GLKVector4Make(0.0f, 0.0f, -6.0f, 1.0f);
        
        self.vertexArray = square;
        self.vertexArraySize = sizeof(square);
        self.verticiesToDraw = 6;
    }
    return self;
}

-(GLKMatrix4)modelMatrix {
    return GLKMatrix4MakeTranslation(self.location.x, self.location.y, self.location.z);
}

-(GLKMatrix3)normalMatrix {
    return GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.modelMatrix), NULL);
}

@end
