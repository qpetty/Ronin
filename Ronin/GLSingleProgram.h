//
//  GLSingleProgram.h
//  Ronin
//
//  Created by Quinton Petty on 12/10/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Character.h"
#import "SwordTrail.h"

@interface GLSingleProgram : NSObject

@property GLuint programID;

@property GLuint vertexArray;

-(instancetype)initWithVertexShader:(NSString*)vert andFragmentShader:(NSString*)frag;

- (BOOL)linkProgram;

-(void)bindUniform:(NSString*)name;
-(void)bindAttribs:(NSString*)name;

-(GLuint)getUniformID:(NSString*)name;
-(GLuint)getAttributeID:(NSString*)name;

- (void)tearDownGL;
@end
