//
//  Ground.m
//  Ronin
//
//  Created by Quinton Petty on 12/10/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import "Ground.h"

#define SQUARE_SIZE 1.0f

GLfloat square[48] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ, texture0x, texture0y,
    SQUARE_SIZE, SQUARE_SIZE, 0.0f,          0.0f, 0.0f, 1.0f,   1.0f, 1.0f,
    -SQUARE_SIZE, -SQUARE_SIZE, 0.0f,        0.0f, 0.0f, 1.0f,   0.0f, 0.0f,
    SQUARE_SIZE, -SQUARE_SIZE, 0.0f,         0.0f, 0.0f, 1.0f,   1.0f, 0.0f,
    SQUARE_SIZE, SQUARE_SIZE, 0.0f,          0.0f, 0.0f, 1.0f,   1.0f, 1.0f,
    -SQUARE_SIZE, -SQUARE_SIZE, 0.0f,        0.0f, 0.0f, 1.0f,   0.0f, 0.0f,
    -SQUARE_SIZE, SQUARE_SIZE, 0.0f,         0.0f, 0.0f, 1.0f,   0.0f, 1.0f
};

@implementation Ground {
    GLenum err;
}

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

-(void)drawWithProjectionMatrix:(GLKMatrix4)proj andUniform:(GLuint)var {
    GLKMatrix4 mvp, newModel = self.modelMatrix;

    float increment = 2.0 * SQUARE_SIZE * (2.0 / 3.0);
    int size = 9;
    
    newModel.m30 = -(float)(size / 2) * increment;
    newModel.m31 = -(float)(size / 2) * increment;
    
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            mvp = GLKMatrix4Multiply(proj, newModel);
            
            glUniformMatrix4fv(var, 1, 0, mvp.m);
            if((err = glGetError())){NSLog(@"Ground GL Error = %u", err);}
            glDrawArrays(GL_TRIANGLES, 0, self.verticiesToDraw);
            
            newModel.m31 += increment;// * (float)size;
            newModel.m32 += 0.001;
        }
        newModel.m31 = -(float)(size / 2) * increment;// * (float)size;
        newModel.m30 += increment;// * (float)size;
    }
}

@end
