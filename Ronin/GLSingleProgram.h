//
//  GLSingleProgram.h
//  Ronin
//
//  Created by Quinton Petty on 12/10/14.
//  Copyright (c) 2014 Octave Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "Character.h"
#import "SwordTrail.h"

@interface GLSingleProgram : NSObject

@property GLuint programID;

@property GLuint vertexArray;

-(GLuint)getUniformID:(NSString*)name;

- (void)tearDownGL;
@end
